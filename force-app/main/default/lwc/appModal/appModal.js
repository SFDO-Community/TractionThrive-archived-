/**
 * @author Pedro Serquiz - pserquiz@tractionondemand.com
 * @description Reusable modal to use on Lightning Web Components
 * @date    2020-03-28
 */

import {LightningElement} from 'lwc';
import { api, track } from "lwc";

const headerStyles = {
	BASE: "slds-theme_alert-texture slds-theme_info",
	WARNING: "slds-theme_alert-texture slds-theme_warning",
	ERROR: "slds-theme_error slds-theme_alert-texture",
	OFFLINE: "slds-theme_alert-texture slds-theme_offline"
};

export default class AppModal extends LightningElement {
	@api
	modelHeaderStyle;

	@api
	headerName;

	@api
	modalSize;

	@api
	hideCloseButton = false;

	@track
	shouldHideBackdrop = false;

	@track
	showModal;

	@api
	displayModal(state) {
		this.showModal = state;
	}

	@api
	hideBackdrop() {
		this.shouldHideBackdrop = true;
	}

	hide() {
		this.showModal = false;
	}

	handleSlotContentChange() {
		let modalContent = this.template.querySelector('[data-id="content"]');
		if (modalContent && modalContent.classList) {
			modalContent.classList.remove("slds-hide");
		}
	}

	handleSlotFooterChange() {
		let modalFooter = this.template.querySelector('[data-id="footer"]');
		if (modalFooter && modalFooter.classList) {
			modalFooter.classList.remove("slds-hide");
		}
	}

	get headerStyle() {
		let headerStyle = "";

		for (let [key, value] of Object.entries(headerStyles)) {
			if (this.modelHeaderStyle && this.modelHeaderStyle.toLowerCase() == key.toLowerCase()) {
				headerStyle = value;
				break;
			}
		}

		return "slds-modal__header " + headerStyle;
	}

	get wrapperStyle() {
		let wrapperStyle = "slds-modal slds-fade-in-open";

		if (this.modalSize) {
			wrapperStyle += " slds-modal_" + this.modalSize.toLowerCase();
		}

		return wrapperStyle;
	}
}