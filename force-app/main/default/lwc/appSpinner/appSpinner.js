/**
 * @author Pedro Serquiz - pserquiz@tractionondemand.com
 * @description Reusable spinner to use on Lightning Web Components
 * @date    2020-03-28
 */
import {api, LightningElement, track} from 'lwc';

export default class AppSpinner extends LightningElement {
	@api appSpinner = false;
	@track showSpinner;

	/**
	 * Alters the spinner state
	 * @param showSpinner - Show or hide spinner
	 */
	@api
	displaySpinner(showSpinner) {
		this.showSpinner = showSpinner;
	}

}