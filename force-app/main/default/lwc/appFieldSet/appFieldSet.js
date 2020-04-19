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

export default class AppFieldSet extends LightningElement {
	isFirstRender = false;
	error;
	errorMessage;
	stack;

	// Design time attribute
	@api fieldSetObject;
	@api fieldSetApiName;
	@api isUsedInCommunityBuilder = false;

	namespace;
	fieldSetData;
	@track picklistFields;
	@track multiPicklistFields;
	@track checkboxFields;
	@track inputFields;

	@api
	isValid() {
		return this.validateForm();
	}

	@api
	getFormInputObject() {
		return this.buildObjectToInsert();
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
			this.buildObjectToInsert();
			let promise = this.insertObject();
			promise.catch(error => {
				console.error('SAVE ERROR: ', error);
				this.handleToastMessage(error.statusText, error.body.message, 'error');
			}).finally(() => {
				this.template.querySelector("c-app-spinner").displaySpinner(false);
			});
		}
	}

	insertObject() {
		return insertSObject({jSONSObject: JSON.stringify(this.buildObjectToInsert()), sObjectApiName: this.fieldSetObject}).then(() => {
			this.handleToastMessage('Success', 'Successfully Inserted', 'success');
		})
	}

	//Support methods
	buildObjectToInsert() {
		let newObjectToInsert = {};

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
}