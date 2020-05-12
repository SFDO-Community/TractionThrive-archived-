/**
 * @author Christian Wico - cwico@tractionondemand.com
 * @description Staff Availability Component for communities
 */

import {LightningElement, track, wire, api} from 'lwc';

import getAssignmentData from '@salesforce/apex/StaffAvailabilityController.getAssignmentData';
import ASSIGNMENTS from '@salesforce/label/c.Assignments';
import ERROR from '@salesforce/label/c.Error_Label';
import MY_AVAILABILITY from '@salesforce/label/c.My_Availability'
import AVAILABILITY from '@salesforce/label/c.Availability_Label';
import CREATE_CREDENTIAL from '@salesforce/label/c.Create_Credential';
import SAVE from '@salesforce/label/c.Save_Action';
import CANCEL from '@salesforce/label/c.Cancel_Action';
import NO_AVAILABILITY_MESSAGE from '@salesforce/label/c.No_Availability_Message';
import STAFF_STATUS_AVAILABLE_TODAY_FUTURE from '@salesforce/label/c.Staff_Status_Available_from_today_future';
import STAFF_STATUS_NOT_AVAILABLE_TODAY_FUTURE from '@salesforce/label/c.Staff_Status_Not_Available_from_today_future';
import updateStaffStatus from '@salesforce/apex/StaffAvailabilityController.updateStaffStatus';
import {getFieldValue, getOrgNamespace} from 'c/appUtils';

export default class StaffAvailability extends LightningElement {
	// design time attribute
	@api recordId;
	@api showTitleBar;
	@api showIcon;
	@api titleText;
	@api titleTextForContactRecord;
	@api iconColorBackground;
	@api iconName;
	@api statusBackground;
	@api statusColorAvailable;
	@api statusColorNotAvailable;
	@api statusColorAssigned;

	@track isStaffAvailable;
	@track staffStatus;

	data;
	namespace;
	error;
	errorMessage;
	stackTrace;
	isFirstRender = false;
	label = {
		ASSIGNMENTS,
		ERROR,
		MY_AVAILABILITY,
		CREATE_CREDENTIAL,
		SAVE,
		CANCEL,
		NO_AVAILABILITY_MESSAGE,
		STAFF_STATUS_AVAILABLE_TODAY_FUTURE,
		STAFF_STATUS_NOT_AVAILABLE_TODAY_FUTURE
	};

	connectedCallback() {
		this.titleText = MY_AVAILABILITY;
		this.titleTextForContactRecord =  AVAILABILITY;
	}

	renderedCallback() {
		if (!this.isFirstRender) {
			this.isFirstRender = true;
			getOrgNamespace().then(result => {
				if (result) {
					this.namespace = result+'__';
				} else {
					this.namespace = '';
				}
				this.loadAssignmentData();
			});

		}

	}

	errorCallback(error, stack) {
		this.error = error;
		this.stack = stack;
		console.error('CMP ERROR', error);
		console.error('CMP STACK', stack);
	}

	loadAssignmentData() {
		this.template.querySelector("c-app-spinner").displaySpinner(true);
		getAssignmentData({contactId: this.recordId? this.recordId:null}).then(result => {
			this.data = result;
			this.staffStatus = getFieldValue(result.contact, 'StatusLabel', '');
			this.isStaffAvailable = getFieldValue(result.contact, 'Status__c', this.namespace) === 'On staff';
		}).catch(error => {
			this.error = error;
			this.formatError(error);
			console.error('LOAD ASSIGNMENT ERROR', error);
		}).finally(() => {
			this.template.querySelector("c-app-spinner").displaySpinner(false);
		});
	}

	formatError(error) {
		if (error.message) {
			this.errorMessage = error.message;
		}
		else if (error.body && error.body.message) {
			this.errorMessage = error.body.message;
			this.stackTrace = error.body.stackTrace;
		}
		else {
			this.errorMessage = JSON.stringify(error);
		}
	}

	handleToggleStatus(event) {
		this.isStaffAvailable = event.target.checked;
		this.template.querySelector("c-app-modal").displayModal(true);
	}

	updateStaffStatus() {
		this.template.querySelector("c-app-modal").displayModal(false);
		this.template.querySelector("c-app-spinner").displaySpinner(true);
		updateStaffStatus({contactId: this.data.contact.Id, isStaffAvailable: this.isStaffAvailable}).then(() => {
			if (this.isStaffAvailable) {
				this.loadAssignmentData();
			}
		}).catch(error => {
			this.error = error;
			this.formatError(error);
			console.error('UPDATE STAFF STATUS ERROR', error);
		}).finally(() => {
			this.template.querySelector("c-app-spinner").displaySpinner(false);
		});
	}

	cancelStatusModal() {
		this.isStaffAvailable = !this.isStaffAvailable;
		this.template.querySelector("c-app-modal").displayModal(false);
		if (this.isStaffAvailable) {
			this.loadAssignmentData();
		}
	}

	get hasRecordId() {
		return typeof this.recordId !== 'undefined' && this.recordId.length >= 15;
	}

	get customStyle() {
		return '--cmp-icon-background-color: ' + this.iconColorBackground + ';' +
			'--cmp-status-background-color: ' + this.statusBackground + ';' +
			'--cmp-status-available-color: ' + this.statusColorAvailable + ';' +
			'--cmp-status-not-available-color: ' + this.statusColorNotAvailable + ';' +
			'--cmp-status-assigned-color: ' + this.statusColorAssigned + ';';
	}
}