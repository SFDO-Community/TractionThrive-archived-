/**
 * @author Pedro Serquiz - pserquiz@tractionondemand.com
 * @description Generates a form based on a field set
 * @date    2020-04-18
 */
import {LightningElement, track, wire, api} from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
//Utils
import {getOrgNamespace} from 'c/appUtils';
//Apex methods
import getFieldSetFields from '@salesforce/apex/AppFieldSetController.getFieldSetFields';
import insertSObject from '@salesforce/apex/AppFieldSetController.insertSObject';
import updateSObject from '@salesforce/apex/AppFieldSetController.updateSObject';
import getRecordToEdit from '@salesforce/apex/AppFieldSetController.getRecordToEdit';

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
				this.loadFieldSetFields();
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

	//Callback methods
	loadFieldSetFields() {
		this.template.querySelector("c-app-spinner").displaySpinner(true);
		getFieldSetFields({fieldSetName: this.namespace+this.fieldSetApiName, ObjectName: this.namespace+this.fieldSetObject}).then(result => {
			this.fieldSetData = result;
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
			this.recordToEdit = result;
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
			this.setupEditRecord(result);
			this.handleToastMessage('Success', 'Successfully Inserted', 'success');
		})
	}

	updateSObject() {
		return updateSObject({jSONSObject: JSON.stringify(this.buildRecord()), sObjectApiName: this.fieldSetObject}).then(result => {
			this.setupEditRecord(result);
			this.handleToastMessage('Success', 'Successfully Inserted', 'success');
		})
	}

	//Support methods
	setupEditRecord(result) {
		let allInputs = this.template.querySelectorAll('lightning-input');
		this.fieldSetData.forEach(function (field) {
			var value = result[field.fieldPath];
			if (field.isMultiPicklistField && value) {
				field.value = value.split(';');
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
}