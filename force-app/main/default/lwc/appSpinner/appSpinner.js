/**
 * Created by pserquiz on 3/28/2020.
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