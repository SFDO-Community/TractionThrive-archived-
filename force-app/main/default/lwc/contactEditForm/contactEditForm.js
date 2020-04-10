/**
 * Created by pserquiz on 3/27/2020.
 */

import {LightningElement, track} from 'lwc';
import getInitData from '@salesforce/apex/ContactEditFormController.getInitData';
import updateContact from '@salesforce/apex/ContactEditFormController.updateContact';
import getCredentialsTypePicklistValues from '@salesforce/apex/ContactEditFormController.getCredentialsTypePicklistValues';
import insertCredential from '@salesforce/apex/ContactEditFormController.insertCredential';
import deleteCredential from '@salesforce/apex/ContactEditFormController.deleteCredential';
import updateCredential from '@salesforce/apex/ContactEditFormController.updateCredential';
import searchAccountLookup from '@salesforce/apex/StaffAvailabilityController.searchAccountLookup';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getOrgNamespace, getFieldValue } from 'c/appUtils';

export default class ContactEditForm extends LightningElement {
	contact;
	account;
	credentialsColumns;
	contactToUpdate;
	error;
	errorMessage;
	stack;
	isFirstRender = false;
	competenciesPicklistValues;
	credentialPicklistValues;
	selectedCredentialAccount;
	selectedRowToEdit;
	namespace;
	@track isEditCredential = true;
	@track selectedCompetenciesPicklistValues;
	@track selectedCredentialPicklistValue;
	@track credentialsData = [];
	@track lookupConfig = {
		isMultiEntry: false,
		initialSelection: [],
		lookupErrors: [],
		notifyViaAlerts: false // Use alerts instead of toast to notify user
	};

	/* CALLBACK METHODS START  */

	renderedCallback() {
		if (!this.isFirstRender) {
			getOrgNamespace().then(result => {
				if (result) {
					this.namespace = result+'__';
				} else {
					this.namespace = '';
				}
				this.loadContactData();
			});
			this.isFirstRender = true;
		}
	}

	errorCallback(error, stack) {
		this.error = error;
		this.stack = stack;
		console.error('CMP ERROR', error);
		console.error('CMP STACK', stack);

		if (error.message) {
			this.errorMessage = error.message;
		}
		else if (error.body && error.body.message) {
			this.errorMessage = error.body.message;
		}
		else {
			this.errorMessage = JSON.stringify(error);
		}

		this.handleToastMessage('Error', this.errorMessage, 'error');
	}

	loadContactData() {
		this.template.querySelector("c-app-spinner").displaySpinner(true);
		getInitData().then(result => {
			this.handleCallbackData(result);
			this.buildCredentialsData(result.credentials);
		})
		.catch(error => {
			this.error = error;
			console.error('ERROR', error);
			this.handleToastMessage(error.statusText, error.body.message, 'error');
		}).finally(() => {
			this.template.querySelector("c-app-spinner").displaySpinner(false);
		});
	}

	updateContact() {
		let hasChanges = this.getContactToUpdateObject();
		if (hasChanges) {
			this.template.querySelector("c-app-spinner").displaySpinner(true);
			updateContact({contactToUpdate: this.contactToUpdate}).then(result => {
				this.handleCallbackData(result);
				this.buildCredentialsData(result.credentials);
				this.handleToastMessage('Success', 'Staff Information Updated Successfully', 'success');
			}).catch(error => {
				this.error = error;
				console.error('ERROR', error);
				this.handleToastMessage(error.statusText, error.body.message, 'error');
			}).finally(() => {
				this.template.querySelector("c-app-spinner").displaySpinner(false);
			});
		} else {
			this.handleToastMessage('Warning', 'No Changes Found', 'warning');
		}
	}

	deleteCredential(row) {
		this.template.querySelector("c-app-spinner").displaySpinner(true);
		deleteCredential({credentialId: row.Id}).then(result => {
			let tempCredentialsData = this.credentialsData;
			tempCredentialsData.forEach(function (item, idx, object) {
				if (item.Id == row.Id) {
					object.splice(idx, 1);
				}
			} );
			this.credentialsData = [...tempCredentialsData];
			this.handleToastMessage('Success', 'Credential successfully deleted', 'success');
		}).catch(error => {
			this.error = error;
			console.error('ERROR', error);
			this.handleToastMessage(error.statusText, error.body.message, 'error');
		}).finally(() => {
			this.template.querySelector("c-app-spinner").displaySpinner(false);
		});
	}

	editCredential() {
		let editedCredential = {
			Id: this.selectedRowToEdit.Id,
			Type__c: this.selectedCredentialPicklistValue
		};

		updateCredential({credentialToUpdate: editedCredential}).then(result => {
			let tempCredentialsData = this.credentialsData;
			let filteredResult = this.filterCredentialsData([result])[0];
			tempCredentialsData.forEach(function (item, idx, object) {
				if (item.Id == result.Id) {
					object.splice(idx, 1);
					tempCredentialsData.push(filteredResult);
				}
			} );
			this.credentialsData = [...tempCredentialsData];
			this.handleToastMessage('Success', 'Credential Successfully Updated', 'success');
		}).catch(error => {
			console.error('SAVE ERROR: ', error);
			this.handleToastMessage(error.statusText, error.body.message, 'error');
		}).finally(() => {
			this.template.querySelector("c-app-modal").displayModal(false);
		});


	}

	insertCredential() {
		this.validateLookup();
		if (this.lookupConfig.lookupErrors.length > 0) return;

		const selection = this.template.querySelector('c-lookup').getSelection();

		let newCredentialToInsert = {
			SObjectType: "Credential__c",
			Care_Facility__c: selection[0].id,
			Type__c: this.selectedCredentialPicklistValue,
			Staff__c: this.contact.Id
		};

		this.template.querySelector("c-app-modal").displayModal(true);

		insertCredential({credentialToInsert: newCredentialToInsert}).then(result => {
			let newFilteredCredential = this.filterCredentialsData([result])[0];
			this.credentialsData = [...this.credentialsData, newFilteredCredential];
			this.handleToastMessage('Success', 'New Credential Successfully Inserted', 'success');
		}).catch(error => {
			console.error('SAVE ERROR: ', error);
			this.handleToastMessage(error.statusText, error.body.message, 'error');
		}).finally(() => {
			this.template.querySelector("c-app-modal").displayModal(false);
		});
	}

	getCredentialsData() {
		getCredentialsTypePicklistValues().then(result => {
			let filteredPicklistValues = [];
			result.forEach(value => filteredPicklistValues.push({label : value, value : value}));
			this.credentialPicklistValues = filteredPicklistValues;
		}).catch(error => {
			this.error = error;
			console.error('ERROR', error);
			this.handleToastMessage(error.statusText, error.body.message, 'error');
		}).finally(() => {
			this.template.querySelector("c-app-spinner").displaySpinner(false);
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

	handleLookupChange() {
		this.lookupConfig.lookupErrors = [];
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

	setupLookupConfigData() {
		// setup lookup state
		let defaultLocation = {
			id: this.accountId,
			sObjectType: 'Account',
			icon: 'standard:account',
			title: this.contact.Account.Name,
			subtitle: 'Care Facility'
		};

		if (this.contact.Account.Id) {
			defaultLocation.id = this.contact.Account.Id;
			defaultLocation.title = this.contact.Account.Name;
		}

		this.lookupConfig.initialSelection = [defaultLocation];
	}

	/* HELPER METHODS START  */

	openModalForEditCredential(row) {
		if (!this.credentialPicklistValues) {
			this.getCredentialsData();
		}

		this.selectedRowToEdit = row;
		this.isEditCredential = true;
		this.selectedCredentialPicklistValue = row.TypeName;
		this.selectedCredentialAccount = row.CareFacilityName;
		this.template.querySelector("c-app-modal").displayModal(true);
	}

	openCredentialModal() {
		this.isEditCredential = false;
		this.selectedCredentialPicklistValue = '';
		this.template.querySelector("c-app-modal").displayModal(true);
		this.setupLookupConfigData();
		this.getCredentialsData();
	}

	getContactToUpdateObject() {
		let hasChanges = false;
		let allPills = this.template.querySelectorAll("lightning-pill");
		let selectedCompetencies = '';

		if (allPills.length > 0) {
			allPills.forEach(function (pill) {
				selectedCompetencies += pill.label+';'
			});
			selectedCompetencies = selectedCompetencies.slice(0, -1);
		}

		const allValid = [...this.template.querySelectorAll('lightning-input')]
			.reduce((validSoFar, inputFields) => {
				inputFields.reportValidity();
				return validSoFar && inputFields.checkValidity();
			}, true);

		if (allValid) {
			let originalContactData = this.contact;
			let mobilePhone = this.template.querySelector("[data-field='Mobile']").value;
			let Phone = this.template.querySelector("[data-field='Phone']").value;
			let contactToUpdate = {
				Id: originalContactData.Id
			};

			if (originalContactData.MobilePhone != mobilePhone) {
				contactToUpdate.MobilePhone = mobilePhone;
				hasChanges = true;
			}
			if (originalContactData.Phone != Phone) {
				contactToUpdate.Phone = Phone;
				hasChanges = true;
			}
			if (getFieldValue(originalContactData, 'Skills__c', this.namespace) != selectedCompetencies) {
				contactToUpdate.Skills__c = selectedCompetencies;
				hasChanges = true;
			}

			this.contactToUpdate = contactToUpdate;

			return hasChanges;
		}
	}

	handleCallbackData(response) {
		var filteredPicklistValues = [];
		response.skillsPicklistValues.forEach(value => filteredPicklistValues.push({label : value, value : value}));

		var savedPicklistValues = [];
		var skills = getFieldValue(response.contactData.contact, 'Skills__c', this.namespace);
		if (skills) {
			savedPicklistValues = skills.split(';');
		}

		this.contact = response.contactData.contact;
		this.account = response.contactData.contact.Account;
		this.competenciesPicklistValues = filteredPicklistValues;
		this.selectedCompetenciesPicklistValues = savedPicklistValues;
	}

	buildCredentialsData(credentials) {
		this.credentialsColumns = [
			{label: 'Staff', fieldName: 'StaffName'},
			{label: 'Care Facility', fieldName: 'CareFacilityName'},
			{label: 'Registrant Type', fieldName: 'TypeName'},
			{
				type: 'button-icon',
				fixedWidth: 40,
				typeAttributes:
					{
						alternativeText: 'Edit Credential',
						iconName: 'utility:edit',
						name: 'editCredentialBtn',
						title: 'Edit Credential',
						class: 'cmp-edit-credential'
					}
			},
			{
				type: 'button-icon',
				fixedWidth: 40,
				typeAttributes:
					{
						alternativeText: 'Delete Credential',
						iconName: 'utility:delete',
						name: 'deleteCredentialBtn',
						title: 'Delete Credential',
						class: 'cmp-delete-credential'
					}
			}
		];
		this.credentialsData = this.filterCredentialsData(credentials);
	}

	filterCredentialsData(credentials) {
		let filteredCredentialsData = [];
		if(credentials.length > 0){
			credentials.forEach(credential => filteredCredentialsData.push(
				{
					Id: credential.Id,
					StaffName: getFieldValue(credential, 'Staff__r', this.namespace).Name,
					CareFacilityName: getFieldValue(credential, 'Care_Facility__r', this.namespace).Name,
					TypeName: getFieldValue(credential, 'Type__c', this.namespace)
				}
			));
		}
		return filteredCredentialsData;
	}

	handleCredentialAction(event) {
		const actionName = event.detail.action.name;
		const row = event.detail.row;
		switch (actionName) {
			case 'deleteCredentialBtn':
				this.deleteCredential(row);
				break;
			case 'editCredentialBtn':
				this.openModalForEditCredential(row);
				break;
			default:
		}
	}

	handleCredentialPicklistChange(event) {
		this.selectedCredentialPicklistValue = event.detail.value;
	}

	handleCompetenciesPicklistChange(event) {
		let selectedValue = event.detail.value;
		if (!this.selectedCompetenciesPicklistValues.includes(selectedValue)) {
			this.selectedCompetenciesPicklistValues.push(selectedValue);
		}
	}

	handleCompetenciesPicklistRemoval(event) {
		let selectedValue = event.target.dataset.item;
		this.selectedCompetenciesPicklistValues = this.selectedCompetenciesPicklistValues.filter(e => e !== selectedValue);
	}

	cancel() {
		this.dispatchEvent(new CustomEvent('cancelevent', {}));
	}

	//Variants usage - error, success, warning
	handleToastMessage(title, message, variant) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: variant
			})
		);
	}
}