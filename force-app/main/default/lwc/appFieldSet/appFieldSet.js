/**
 * @author Pedro Serquiz - pserquiz@tractionondemand.com
 * @description Generates a form based on a field set
 * @date    2020-04-18
 */
import {LightningElement, track, wire, api} from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
//Utils
import {getFieldValue, getOrgNamespace, setNamespaceToList} from 'c/appUtils';
//Apex methods
import getFieldSetFields from '@salesforce/apex/AppFieldSetController.getFieldSetFields';
import getFieldsFromList  from '@salesforce/apex/AppFieldSetController.getFieldsFromList';
import insertSObject from '@salesforce/apex/AppFieldSetController.insertSObject';
import updateSObject from '@salesforce/apex/AppFieldSetController.updateSObject';
import getRecordToEdit from '@salesforce/apex/AppFieldSetController.getRecordToEdit';
import searchGenericLookup from '@salesforce/apex/AppFieldSetController.searchGenericLookup';

export default class AppFieldSet extends LightningElement {
	isFirstRender = false;
	error;
	errorMessage;
	stack;
	namespace;
	fieldSetData;
	recordToEdit;

	// Design time attribute
	@api fieldSetObject;
	@api fieldSetApiName;

	@api hasParent = false;
	@api recordId;
	@api fields = [];

	@track picklistFields;
	@track multiPicklistFields;
	@track checkboxFields;
	@track inputFields;

	@api
	get isValid() {
		return this.validateForm();
	}

	@api
	get record() {
		return this.buildRecord();
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
			}).finally(() => {
				if (this.fields.length > 0) {
					this.loadFields();
				} else {
					this.loadFieldSetFields();
				}
			});
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

	/* CALLBACK METHODS  */
	loadFields() {
		this.template.querySelector("c-app-spinner").displaySpinner(true);
		getFieldsFromList({
			fields: setNamespaceToList(this.fields, this.namespace),
			objectName: this.namespace + this.fieldSetObject
		}).then(result => {
			console.log('loadFields: ', result);
			this.fieldSetData = result;
			this.handleLookupField();
			if (this.recordId) {
				this.getRecordToEdit();
			}
		}).catch(error => {
			this.error = error;
			console.error('ERROR', error);
			this.handleToastMessage(error.statusText, error.body.message, 'error');
		}).finally(() => {
			this.template.querySelector("c-app-spinner").displaySpinner(false);
		});
	}

	loadFieldSetFields() {
		this.template.querySelector("c-app-spinner").displaySpinner(true);
		getFieldSetFields({
			fieldSetName: this.namespace + this.fieldSetApiName,
			ObjectName: this.namespace + this.fieldSetObject
		}).then(result => {
			this.fieldSetData = result;
			this.handleLookupField();
			if (this.recordId) {
				this.getRecordToEdit();
			}
		}).catch(error => {
			this.error = error;
			console.error('ERROR', error);
			this.handleToastMessage(error.statusText, error.body.message, 'error');
		}).finally(() => {
			this.template.querySelector("c-app-spinner").displaySpinner(false);
		});
	}

	getRecordToEdit() {
		this.template.querySelector("c-app-spinner").displaySpinner(true);

		let fieldNames = [];
		this.fieldSetData.forEach(function (field) {
			fieldNames.push(field.fieldPath);
		});

		getRecordToEdit({recordId: this.recordId, fieldNames: fieldNames}).then(result => {
			this.recordToEdit = result.editedObject;
			this.setupEditRecord(result);
		}).catch(error => {
			this.error = error;
			console.error('ERROR', error);
			this.handleToastMessage(error.statusText, error.body.message, 'error');
		}).finally(() => {
			this.template.querySelector("c-app-spinner").displaySpinner(false);
		});
	}

	saveAndValidate() {
		if (this.validateForm()) {
			this.template.querySelector("c-app-spinner").displaySpinner(true);
			this.buildRecord();
			let promise;

			if (this.recordId) {
				promise = this.updateSObject();
			} else {
				promise = this.insertObject();
			}

			promise.catch(error => {
				console.error('SAVE ERROR: ', error);
				this.handleToastMessage(error.statusText, error.body.message, 'error');
			}).finally(() => {
				this.template.querySelector("c-app-spinner").displaySpinner(false);
			});
		}
	}

	insertObject() {
		return insertSObject({jSONSObject: JSON.stringify(this.buildRecord()), sObjectApiName: this.fieldSetObject}).then(result => {
			this.handleToastMessage('Success', 'Successfully Inserted', 'success');
		})
	}

	updateSObject() {
		return updateSObject({jSONSObject: JSON.stringify(this.buildRecord()), sObjectApiName: this.fieldSetObject}).then(result => {
			this.handleToastMessage('Success', 'Successfully Inserted', 'success');
		})
	}

	/* SUPPORT METHODS  */
	setupEditRecord(result) {
		let allInputs = this.template.querySelectorAll('lightning-input');
		let lookupFields = JSON.parse(result.lookupFields);
		this.fieldSetData.forEach(function (field) {
			let value = result.editedObject[field.fieldPath];
			if (field.isMultiPicklistField && value) {
				field.value = value.split(';');
			} else if (field.isLookupField) {
				let lookupName = lookupFields[field.fieldPath];
				if (lookupName) {
					let lookupFieldName = lookupName.split('.');
					let initialSelection = {
						id: value,
						sObjectType: field.lookupObject,
						icon: 'standard:account',
						title: result.editedObject[lookupFieldName[0]][lookupFieldName[1]],
						subtitle: result.editedObject[lookupFieldName[0]][lookupFieldName[1]]
					};
					field.lookupConfig.initialSelection = [initialSelection];
					field.value = value;
				}
			} else {
				field.value = value;
			}
			allInputs.forEach(function (input) {
				if (input.type == 'checkbox' && input.name == field.fieldPath) {
					input.checked = value;
				}
			});
		});
		this.fieldSetData = [...this.fieldSetData];
	}

	buildRecord() {
		let newObjectToInsert = {};
		if (this.recordId) {
			newObjectToInsert["Id"] = this.recordId;
		}

		this.template.querySelectorAll('lightning-input').forEach(function (input) {
			if (input.type == 'checkbox') {
				newObjectToInsert[input.name] = input.checked;
			} else if (input.value) {
				newObjectToInsert[input.name] = input.value;
			}
		});

		this.template.querySelectorAll('lightning-combobox').forEach(function (combobox) {
			if (combobox.value) {
				newObjectToInsert[combobox.name] = combobox.value;
			}
		});

		this.template.querySelectorAll('lightning-dual-listbox').forEach(function (listbox) {
			if (listbox.value) {
				newObjectToInsert[listbox.name] = listbox.value.join(";");
			}
		});

		let allData = this.fieldSetData;
		this.template.querySelectorAll('c-lookup').forEach(function (lookup) {
			allData.forEach(function (data) {
				if (data.fieldPath === lookup.customKey) {
					if (lookup.getSelection().length > 0 && data.fieldPath) {
						let initialSelection = {
							id: lookup.getSelection()[0].id,
							sObjectType: lookup.getSelection()[0].sObjectType,
							icon: 'standard:account',
							title: lookup.getSelection()[0].title,
							subtitle: lookup.getSelection()[0].subtitle
						};
						data.lookupConfig.initialSelection = [initialSelection];
						newObjectToInsert[data.fieldPath] = lookup.getSelection()[0].id;
					}
				}
			});
		});

		this.fieldSetData = [...allData];

		return newObjectToInsert;
	}

	validateForm() {
		const isValid = [...this.template.querySelectorAll('lightning-input')]
			.reduce((validSoFar, inputFields) => {
				inputFields.reportValidity();
				return validSoFar && inputFields.checkValidity();
			}, true);

		return isValid;
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

	cancel() {
		this.fieldSetData.forEach(function (field) {
			field.value = "";
		});

		this.fieldSetData = [...this.fieldSetData];
	}

	/* CUSTOM LOOKUP METHOD START  */
	handleLookupField() {
		this.fieldSetData.forEach(function (item) {
			if (item.isLookupField) {
				item.lookupConfig = {
					isMultiEntry: false,
					initialSelection: [],
					lookupErrors: [],
					notifyViaAlerts: false // Use alerts instead of toast to notify user
				};
			}
		});
	}

	handleLookupSearch(event) {
		let selectedLookupKey = event.currentTarget.customKey;
		let lookupObject;

		this.fieldSetData.forEach(function (data) {
			if (data.fieldPath == selectedLookupKey) {
				lookupObject = data.lookupObject;
			}
		});

		let parameters = event.detail;
		parameters.lookupObject = lookupObject;
 		searchGenericLookup(parameters).then((results) => {
				this.template.querySelectorAll('c-lookup').forEach(function (lookup) {
					if (selectedLookupKey === lookup.customKey) {
						lookup.setSearchResults(results);
					}
				})
			}).catch((error) => {
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
}