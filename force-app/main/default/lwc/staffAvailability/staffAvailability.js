/**
 * @author Christian Wico - cwico@tractionondemand.com
 * @description Staff Availability Component for communities
 */

import {LightningElement, track, wire, api} from 'lwc';

import getAssignmentData from '@salesforce/apex/StaffAvailabilityController.getAssignmentData';
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

	renderedCallback() {
		console.log('RECORD ID: ', this.recordId);

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
		console.log('CMP ERROR', error);
		console.log('CMP STACK', stack);
	}

	loadAssignmentData() {
		this.template.querySelector("c-app-spinner").displaySpinner(true);
		getAssignmentData({contactId: this.recordId? this.recordId:null}).then(result => {
			console.log('ASSIGNMENT DATA', result);
			this.data = result;
			this.staffStatus = getFieldValue(result.contact, 'Status__c', this.namespace);
			this.isStaffAvailable = getFieldValue(result.contact, 'Status__c', this.namespace) == 'On staff' ? true : false;
		}).catch(error => {
			this.error = error;
			this.formatError(error);
			console.log('LOAD ASSIGNMENT ERROR', error);
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
			console.log('UPDATE STAFF STATUS ERROR', error);
		}).finally(() => {
			this.template.querySelector("c-app-spinner").displaySpinner(false);
		});
	}

	cancelStatusModal() {
		if(this.isStaffAvailable) {
			this.isStaffAvailable = false;
		} else {
			this.isStaffAvailable = true;
		}
		this.template.querySelector("c-app-modal").displayModal(false);
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