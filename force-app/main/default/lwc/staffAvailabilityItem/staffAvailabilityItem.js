/**
 * Created by Christian Wico - cwico@tractionondemand.com on 2020-03-25.
 */

import {LightningElement, track, api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import save from '@salesforce/apex/StaffAvailabilityController.save';
import searchAccountLookup from '@salesforce/apex/StaffAvailabilityController.searchAccountLookup';
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
		{'label': 'Not Available', 'value': 'Not Available'},
		{'label': 'Available', 'value': 'Available'},
		{'label': 'Assigned', 'value': 'Assigned'},
	];

	@track lookupConfig = {
		isMultiEntry: false,
		initialSelection: [],
		lookupErrors: [],
		notifyViaAlerts: false // Use alerts instead of toast to notify user
	};

	@track selectedRecord = {};

	@api
	get assignmentRecord() {
		return '';
	}

	set assignmentRecord(value) {
		this.record = {...value, sobjectType: this.namespace+'Assignment__c'};
		this.statusValue = getFieldValue(value, 'Available__c', this.namespace);
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

		this.handleLookupChange();
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
			recordPayload[this.namespace+'Care_Facility__c'] = this.selectedRecord.Id;
			recordPayload[this.namespace+'Care_Facility__r'] = this.selectedRecord;
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
				this.notifyLookupUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				// eslint-disable-next-line no-console
				console.error('Lookup error', JSON.stringify(error));
				this.lookupConfig.lookupErrors = [error];
			});
	}

	handleLookupChange(event) {
		this.lookupConfig.lookupErrors = [];
		this.selectedRecord = event.detail.record;
	}

	validateLookup() {
		const selection = this.template.querySelector('c-lookup').getSelection();
		if (selection.length === 0) {
			this.lookupConfig.lookupErrors = [
				{ message: 'Please choose your care facility to continue...' }
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