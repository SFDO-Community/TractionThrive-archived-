/**
 * Created by Christian Wico - cwico@tractionondemand.com on 2020-03-25.
 */

import {LightningElement, track, api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import save from '@salesforce/apex/StaffAvailabilityController.save';
import searchAccountLookup from '@salesforce/apex/StaffAvailabilityController.searchAccountLookup';
import CARE_FACILITY_PLACEHOLDER_SEARCH from '@salesforce/label/c.Care_Facility_Placeholder_Search';
import CARE_FACILITY from '@salesforce/label/c.Care_Facility';
import CANCEL from '@salesforce/label/c.Cancel_Action';
import AVAILABLE_LABEL from '@salesforce/label/c.Available_Label';
import ASSIGNED_LABEL from '@salesforce/label/c.Assigned_Label';
import NOT_AVAILABLE_LABEL from '@salesforce/label/c.Not_Available_Label';
import OK_ACTION from '@salesforce/label/c.Ok_Action';
import UPDATED from '@salesforce/label/c.Updated_label';
import AVAILABILITY from '@salesforce/label/c.Availability_Label';
import CARE_FACILITY_SELECTION_ERROR from '@salesforce/label/c.Care_Facility_Selection_Error';
import SEARCHING_LOOKUP_FIELD_ERROR from '@salesforce/label/c.Searching_Lookup_field_Error';
import LOOKUP_ERROR_LABEL from '@salesforce/label/c.Lookup_Error_Label';
import { getFieldValue } from 'c/appUtils';

export default class StaffAvailabilityItem extends LightningElement {

	ASSIGNED_STATUS = 'Assigned';

	isExpanded = false;
	@track statusValue;
	@track record;

	@api namespace;
	@api assignment;
	@api accountId;
	@api accountName;

	@track statusOptions = [
		{'label': NOT_AVAILABLE_LABEL, 'value': 'Not Available'},
		{'label': AVAILABLE_LABEL, 'value': 'Available'},
		{'label': ASSIGNED_LABEL, 'value': 'Assigned'},
	];

	@track lookupConfig = {
		isMultiEntry: false,
		initialSelection: [],
		lookupErrors: [],
		notifyViaAlerts: false // Use alerts instead of toast to notify user
	};

	label = {
		CARE_FACILITY_PLACEHOLDER_SEARCH,
		CARE_FACILITY,
		CANCEL,
		AVAILABLE_LABEL,
		ASSIGNED_LABEL,
		NOT_AVAILABLE_LABEL,
		OK_ACTION,
		UPDATED,
		AVAILABILITY,
		CARE_FACILITY_SELECTION_ERROR,
		SEARCHING_LOOKUP_FIELD_ERROR,
		LOOKUP_ERROR_LABEL
	}

	@track selectedRecord = {};

	@api
	get assignmentRecord() {
		return '';
	}

	set assignmentRecord(value) {
		this.record = {...value, sobjectType: this.namespace+'Assignment__c'};
		this.statusValue = getFieldValue(value, 'Available__c', this.namespace);
	}

	get statusLabelFromValue() {
		const result = this.statusOptions.filter(val => {
			return val.value === this.statusValue
		});
		return result ? result[0].label : '';
	}

	get isAssigned() {
		return this.statusValue === this.ASSIGNED_STATUS;
	}

	get hasLocation() {
		return this.record.Id && getFieldValue(this.record, 'Care_Facility__c', this.namespace) && getFieldValue(this.record, 'Available__c', this.namespace) === this.ASSIGNED_STATUS;
	}

	get facility() {
		return getFieldValue(this.record, 'Care_Facility__r', this.namespace);
	}

	get date() {
		return getFieldValue(this.record, 'Date__c', this.namespace);
	}

	get available() {
		return getFieldValue(this.record, 'Available__c', this.namespace);
	}

	get availableFieldName() {
		return this.namespace+'Available__c';
	}

	handleStatusChange(event) {
		const selectedOption = event.detail.value;
		this.statusValue = selectedOption;
	}

	handleExpand(event) {
		if (!this.isExpanded) this.isExpanded = true;

		// setup lookup state
		let defaultLocation = {
			id: this.accountId,
			sObjectType: 'Account',
			icon: 'standard:account',
			title: this.accountName,
			subtitle: 'Care Facility'
		};
		if (this.hasLocation) {
			defaultLocation.id = getFieldValue(this.record, 'Care_Facility__c', this.namespace);
			defaultLocation.title = getFieldValue(this.record, 'Care_Facility__r', this.namespace).Name;
		}

		this.lookupConfig.initialSelection = [defaultLocation];
		this.selectedRecord = defaultLocation;

		this.handleLookupChange(new CustomEvent());
	}

	handleCancel(event) {
		this.statusValue = getFieldValue(this.record, 'Available__c', this.namespace);
		this.isExpanded = false;
	}

	handleOK(event) {

		let recordPayload = {...this.record};
		recordPayload[this.namespace+'Available__c'] = this.statusValue;

		if (getFieldValue(recordPayload, 'Available__c', this.namespace)  === this.ASSIGNED_STATUS) {
			// validate lookup
			this.validateLookup();
			if (this.lookupConfig.lookupErrors.length > 0) return;

			console.log('LOOKUP SELECTION: ', JSON.parse(JSON.stringify(this.selectedRecord)));
			recordPayload[this.namespace+'Care_Facility__c'] = this.selectedRecord.id;
		}
		else {
			recordPayload[this.namespace+'Care_Facility__c'] = null;
		}

		this.isExpanded = false;

		console.log('RECORD PAYLOAD: ', recordPayload);

		save({assignment: recordPayload}).then(result => {
			this.record = {...result};
			console.log('SAVE RESULT: ', result);
		}).catch(err => {
			console.log('SAVE ERROR: ', err);
		});

	}


	/* CUSTOM LOOKUP METHOD START  */

	handleLookupSearch(event) {
		searchAccountLookup(event.detail)
			.then((results) => {
				this.template.querySelector('c-lookup').setSearchResults(results);
			})
			.catch((error) => {
				this.notifyLookupUser(this.label.LOOKUP_ERROR_LABEL, this.label.SEARCHING_LOOKUP_FIELD_ERROR, 'error');
				// eslint-disable-next-line no-console
				console.error('Lookup error', JSON.stringify(error));
				this.lookupConfig.lookupErrors = [error];
			});
	}

	handleLookupChange(event) {
		this.lookupConfig.lookupErrors = [];
		if (event != null && event.detail != null) {
			this.selectedRecord = event.detail.record;
		}
	}

	validateLookup() {
		const selection = this.template.querySelector('c-lookup').getSelection();
		if (selection.length === 0) {
			this.lookupConfig.lookupErrors = [
				{ message: this.label.CARE_FACILITY_SELECTION_ERROR }
			];
		} else {
			this.lookupConfig.lookupErrors = [];
		}
	}

	notifyLookupUser(title, message, variant) {
		return;
		if (this.lookupConfig.notifyViaAlerts) {
			// Notify via alert
			// eslint-disable-next-line no-alert
			alert(`${title}\n${message}`);
		} else {
			// Notify via toast
			const toastEvent = new ShowToastEvent({ title, message, variant });
			this.dispatchEvent(toastEvent);
		}
	}


}