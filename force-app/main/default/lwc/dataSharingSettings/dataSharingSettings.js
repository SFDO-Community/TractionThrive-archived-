import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getSettings from '@salesforce/apex/DataSharingSettingsController.getSettings';
import save from '@salesforce/apex/DataSharingSettingsController.save';

export default class DataSharingSettings extends LightningElement {

	@track dataSharingSettings;

	connectedCallback() {
		this.loadSettings();
	}

	async loadSettings() {
		this.dataSharingSettings = await getSettings();
		console.log('DATA SETTINGS', JSON.parse(JSON.stringify(this.dataSharingSettings)));
	}

	async handleSaveClick(event) {

		let payload = {
			Id: this.dataSharingSettings.Id,
			Is_Active__c: this.template.querySelector('.cmp-toggle').checked,
			Client_ID__c: this.template.querySelector('.cmp-client-id').value,
			Client_Secret__c: this.template.querySelector('.cmp-client-secret').value,
			Endpoint__c: this.template.querySelector('.cmp-endpoint').value,
		};

		console.log('SAVE PAYLOAD', payload);

		try {
			this.template.querySelector('.cmp-save-button').disabled = true;
			this.dataSharingSettings = await save({dataSharing: payload});
			this.showToast('Record Saved!', 'Settings saved successfully...', 'success');
		} catch (err) {
			this.showError(err);
		} finally {
			this.template.querySelector('.cmp-save-button').disabled = false;
		}

	}

	showError(error) {
		console.error('CMP ERROR', error);

		let errorMessage;

		if (error.message) {
			errorMessage = error.message;
		}
		else if (error.body && error.body.message) {
			errorMessage = error.body.message;
		}
		else {
			errorMessage = JSON.stringify(error);
		}

		this.showToast('Oops!', errorMessage, 'error' )
	}


	showToast(title, message, variant) {
		this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
	}


}