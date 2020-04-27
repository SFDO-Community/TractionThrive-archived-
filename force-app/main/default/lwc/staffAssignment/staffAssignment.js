/**
 * Created by mmanik on 3/28/2020.
 */

import { api, LightningElement, track, wire } from "lwc";
import searchAccountLookup from "@salesforce/apex/StaffAssignmentController.searchLookup";
import save from "@salesforce/apex/StaffAssignmentController.save";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import SAVE from '@salesforce/label/c.Save_Action';
import CARE_FACILITY_PLACEHOLDER_SEARCH from '@salesforce/label/c.Care_Facility_Placeholder_Search';
import NEW_STAFF_ACCESS from '@salesforce/label/c.New_Staff_Access';

export default class StaffAssignment extends LightningElement {
  @api objectApiName;
  @api recordId;
  @track currentObjectIsContact = false;
  @track currentObjectIsAccount = false;
  @track recordName;
  @track lookupName;
  del = false;
  label = {
    SAVE,
    CARE_FACILITY_PLACEHOLDER_SEARCH,
    NEW_STAFF_ACCESS
  };

  connectedCallback() {
    if (this.objectApiName === "Contact") {
      this.lookupName = "Facility ";
      this.recordName = "Staff Member - ";
    } else if (this.objectApiName === "Account") {
      this.lookupName = "Staff Member";
      this.recordName = "Facility ";
    }
  }

  @track lookupConfig = {
    isMultiEntry: false,
    initialSelection: [],
    lookupErrors: [],
    notifyViaAlerts: false // Use alerts instead of toast to notify user
  };
  disableSave = true;

  /* CUSTOM LOOKUP METHOD START  */

  handleLookupSearch(event) {
    searchAccountLookup(event.detail)
      .then(results => {
        this.template.querySelector("c-lookup").setSearchResults(results);
      })
      .catch(error => {
        this.notifyLookupUser(
          "Lookup Error",
          "An error occured while searching with the lookup field.",
          "error"
        );
        // eslint-disable-next-line no-console
        console.error("Lookup error", JSON.stringify(error));
        this.lookupConfig.lookupErrors = [error];
      });
  }

  handleLookupChange() {
    this.lookupConfig.lookupErrors = [];
    this.disableSave = true;
    if (this.template.querySelector("c-lookup").getSelection().length > 0) {
      this.disableSave = false;
    }
  }

  handleSave(event) {
    this.template.querySelector("c-app-spinner").displaySpinner(true);
    this.validateLookup();
    if (this.lookupConfig.lookupErrors.length > 0) return;
    const selection = this.template.querySelector("c-lookup").getSelection();
    save({ accountRecord: selection[0].id, contactId: this.recordId })
      .then(result => {
        this.record = { ...result };
      })
      .catch(err => {
        console.error("SAVE ERROR: ", err);
        this.handleToastMessage(
          "Error",
          "There is an error while saving this access record",
          "Error"
        );
      })
      .finally(() => {
        this.template.querySelector("c-app-spinner").displaySpinner(false);
      });
    this.handleToastMessage(
      "Success",
      "Access record created successfully",
      "Success"
    );
  }

  validateLookup() {
    const selection = this.template.querySelector("c-lookup").getSelection();
    if (selection.length === 0) {
      this.lookupConfig.lookupErrors = [
        { message: "Please choose your care facility to continue..." }
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
