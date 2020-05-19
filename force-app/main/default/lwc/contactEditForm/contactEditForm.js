/**
 * @author Pedro Serquiz - pserquiz@tractionondemand.com
 * @description Contact Edit Form Component for communities
 * @date    2020-03-27
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
import STAFF_INFORMATION from '@salesforce/label/c.Staff_Information';
import SAVE from '@salesforce/label/c.Save_Action';
import CANCEL from '@salesforce/label/c.Cancel_Action';
import STAFF_EMAIL from '@salesforce/label/c.Email';
import STAFF_NAME from '@salesforce/label/c.Staff_Name';
import CARE_FACILITY from '@salesforce/label/c.Care_Facility';
import MOBILE from '@salesforce/label/c.Mobile';
import PHONE from '@salesforce/label/c.Phone';
import COMPETENCIES from '@salesforce/label/c.Competencies';
import CREDENTIALS from '@salesforce/label/c.Credentials';
import COMPETENCE_PLACEHOLDER from '@salesforce/label/c.Competence_Placeholder';
import ADD_CREDENTIAL from '@salesforce/label/c.Add_credential';
import ADD from '@salesforce/label/c.Add_Action';
import CREATE_CREDENTIAL from '@salesforce/label/c.Create_Credential';
import CARE_FACILITY_PLACEHOLDER_SEARCH from '@salesforce/label/c.Care_Facility_Placeholder_Search';
import REGISTRANT_TYPE from '@salesforce/label/c.Registrant_Type';
import SEARCHING_LOOKUP_FIELD_ERROR from '@salesforce/label/c.Searching_Lookup_field_Error';
import LOOKUP_ERROR_LABEL from '@salesforce/label/c.Lookup_Error_Label';
import CARE_FACILITY_SELECTION_ERROR from '@salesforce/label/c.Care_Facility_Selection_Error';
import SUCCESS from '@salesforce/label/c.Success_Label';
import WARNING from '@salesforce/label/c.Warning_Label';
import STAFF_INFO_UPDATE_SUCCESS from '@salesforce/label/c.Success_Message_Staff_Info_Update';
import NO_CHANGES_FOUND from '@salesforce/label/c.Warning_message_for_no_changes_found';
import ERROR_LABEL from '@salesforce/label/c.Error_Label';
import CREDENTIAL_DELETION_MSG from '@salesforce/label/c.Message_Credential_Deletion';
import CREDENTIAL_UPDATE_MSG from '@salesforce/label/c.Message_Credential_Update';
import CREDENTIAL_INSERT_SUCCESS from '@salesforce/label/c.Success_Message_Credential_Insertion';
import EDIT_CREDENTIAL from '@salesforce/label/c.Edit_Credential';
import DELETE_CREDENTIAL from '@salesforce/label/c.Delete_Credential';
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
	labels = {
		STAFF_INFORMATION,
		SAVE,
		CARE_FACILITY,
		STAFF_EMAIL,
		STAFF_NAME,
		MOBILE,
		PHONE,
		COMPETENCIES,
		COMPETENCE_PLACEHOLDER,
		CANCEL,
		CREDENTIALS,
		ADD_CREDENTIAL,
		ADD,
		CREATE_CREDENTIAL,
		CARE_FACILITY_PLACEHOLDER_SEARCH,
		REGISTRANT_TYPE,
		SEARCHING_LOOKUP_FIELD_ERROR,
		LOOKUP_ERROR_LABEL,
		CARE_FACILITY_SELECTION_ERROR,
		SUCCESS,
		WARNING,
		STAFF_INFO_UPDATE_SUCCESS,
		NO_CHANGES_FOUND,
		ERROR_LABEL,
		CREDENTIAL_DELETION_MSG,
		CREDENTIAL_UPDATE_MSG,
		CREDENTIAL_INSERT_SUCCESS,
		EDIT_CREDENTIAL,
		DELETE_CREDENTIAL
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

		this.handleToastMessage(this.labels.ERROR_LABEL, this.errorMessage, 'error');
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
				this.handleToastMessage(this.labels.SUCCESS, this.labels.STAFF_INFO_UPDATE_SUCCESS, 'success');
			}).catch(error => {
				this.error = error;
				console.error('ERROR', error);
				this.handleToastMessage(error.statusText, error.body.message, 'error');
			}).finally(() => {
				this.template.querySelector("c-app-spinner").displaySpinner(false);
			});
		} else {
			this.handleToastMessage(this.labels.WARNING, this.labels.NO_CHANGES_FOUND, 'warning');
		}
	}

	deleteCredential(row) {
		this.template.querySelector("c-app-spinner").displaySpinner(true);
		deleteCredential({credentialId: row.Id}).then(result => {
			let tempCredentialsData = this.credentialsData;
			tempCredentialsData.forEach(function (item, idx, object) {
				if (item.Id === row.Id) {
					object.splice(idx, 1);
				}
			} );
			this.credentialsData = [...tempCredentialsData];
			this.handleToastMessage(this.labels.SUCCESS, this.labels.CREDENTIAL_DELETION_MSG, 'success');
		}).catch(error => {
			this.error = error;
			console.error('ERROR', error);
			this.handleToastMessage(error.statusText, error.body.message, 'error');
		}).finally(() => {
			this.template.querySelector("c-app-spinner").displaySpinner(false);
		});
	}

	editCredential() {
		let editedCredential = {};
		editedCredential["Id"] = this.selectedRowToEdit.Id;
		editedCredential[this.namespace+"Type__c"] = this.selectedCredentialPicklistValue;

		updateCredential({credentialToUpdate: editedCredential}).then(result => {
			let tempCredentialsData = this.credentialsData;
			let filteredResult = this.filterCredentialsData([result])[0];
			tempCredentialsData.forEach(function (item, idx, object) {
				if (item.Id === result.Id) {
					object.splice(idx, 1);
					tempCredentialsData.push(filteredResult);
				}
			} );
			this.credentialsData = [...tempCredentialsData];
			this.handleToastMessage(this.labels.SUCCESS, this.labels.CREDENTIAL_UPDATE_MSG, 'success');
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

		let newCredentialToInsert = {};
		newCredentialToInsert["SObjectType"] = this.namespace+"Credential__c";
		newCredentialToInsert[this.namespace+"Care_Facility__c"] = selection[0].id;
		newCredentialToInsert[this.namespace+"Type__c"] = this.selectedCredentialPicklistValue;
		newCredentialToInsert[this.namespace+"Staff__c"] = this.contact.Id;

		this.template.querySelector("c-app-modal").displayModal(true);

		insertCredential({credentialToInsert: newCredentialToInsert}).then(result => {
			let newFilteredCredential = this.filterCredentialsData([result])[0];
			this.credentialsData = [...this.credentialsData, newFilteredCredential];
			this.handleToastMessage(this.labels.SUCCESS, this.labels.CREDENTIAL_INSERT_SUCCESS, 'success');
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
			for (const key in result) {
				filteredPicklistValues.push({label : key, value : result[key]});
			}
			//result.forEach(value => filteredPicklistValues.push({label : value, value : value}));
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
				this.notifyLookupUser(this.labels.LOOKUP_ERROR_LABEL, this.labels.SEARCHING_LOOKUP_FIELD_ERROR, 'error');
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
				{ message: this.labels.CARE_FACILITY_SELECTION_ERROR }
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
			subtitle: this.labels.CARE_FACILITY
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

			if (originalContactData.MobilePhone !== mobilePhone) {
				contactToUpdate.MobilePhone = mobilePhone;
				hasChanges = true;
			}
			if (originalContactData.Phone !== Phone) {
				contactToUpdate.Phone = Phone;
				hasChanges = true;
			}
			if (getFieldValue(originalContactData, 'Skills__c', this.namespace) !== selectedCompetencies) {
				contactToUpdate[this.namespace+"Skills__c"] = selectedCompetencies;
				hasChanges = true;
			}

			this.contactToUpdate = contactToUpdate;

			return hasChanges;
		}
	}

	handleCallbackData(response) {
		var filteredPicklistValues = [];
		for (const key in response.skillsPicklistValues) {
			filteredPicklistValues.push({label : key, value : response.skillsPicklistValues[key]})
		}
		//response.skillsPicklistValues.forEach(value => filteredPicklistValues.push({label : value, value : value}));

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
			{label: this.labels.STAFF_NAME, fieldName: 'StaffName'},
			{label: this.labels.CARE_FACILITY, fieldName: 'CareFacilityName'},
			{label: this.labels.REGISTRANT_TYPE, fieldName: 'TypeName'},
			{
				type: 'button-icon',
				fixedWidth: 40,
				typeAttributes:
					{
						alternativeText: this.labels.EDIT_CREDENTIAL,
						iconName: 'utility:edit',
						name: 'editCredentialBtn',
						title: this.labels.EDIT_CREDENTIAL,
						class: 'cmp-edit-credential'
					}
			},
			{
				type: 'button-icon',
				fixedWidth: 40,
				typeAttributes:
					{
						alternativeText: this.labels.DELETE_CREDENTIAL,
						iconName: 'utility:delete',
						name: 'deleteCredentialBtn',
						title: this.labels.DELETE_CREDENTIAL,
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
					TypeName: getFieldValue(credential, 'typeLabel', '')
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