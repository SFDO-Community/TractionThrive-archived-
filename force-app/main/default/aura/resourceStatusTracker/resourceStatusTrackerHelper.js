/**
 * Created by Heather Purvis on 2020-03-18.
 */
({
    /**
     * @description Finds the most recent status report of a given status of a resource in a specific division
     *              (e.g. available beds, in use beds)
     * @param component
     * @param event
     * @param helper
     */
    getStatusReport: function (component, event, helper) {
        let facilityId = component.get("v.divisionId");
        if(!facilityId){
            return;
        }

        let action = component.get("c.getStatusReport");

        action.setParams({
            resourceType: component.get("v.resource"),
            status: component.get("v.status"),
            divisionId: facilityId
        });

        action.setCallback(this, $A.getCallback(function (response) {
            let state = response.getState();

            if (state === "SUCCESS") {
                let data = response.getReturnValue();

                if(data.record != null) {
                    component.set("v.statusReport", data.record);
                    let count = component.get("v.statusReport." +  data.namespace + "Count__c");
                    component.set("v.count", count);
                } else {
                    component.set("v.count", 0);
                    component.set("v.statusReport", null);
                }

            } else if (state === "ERROR") {
                let errors = response.getError();
                this.showToast(
                    "There was a problem fetching status reports",
                    "error",
                    errors[0].message);
                for (let i = 0; i < errors.length; i++){
                    console.error(errors[i].message);
                }
            }
        }));

        $A.enqueueAction(action);
    },

    /**
     * @description Updates the total count of a resource with the selected status in this division
     * @param component
     * @param event
     * @param helper
     */
    setCount: function (component, event, helper) {
        if(component.get("v.isReadOnly") || !component.get("v.divisionId")) {
            return;
        }

        let action = component.get("c.updateLatestCountForUserDepartment");

        action.setParams({
            resourceType: component.get("v.resource"),
            status: component.get("v.status"),
            divisionId: component.get("v.divisionId"),
            count: component.get("v.count")
        });

        action.setCallback(this, $A.getCallback(function (response) {
            let state = response.getState();

            if (state === "SUCCESS") {
                helper.getStatusReport(component, event, helper);

            } else if (state === "ERROR") {
                let errors = response.getError();
                this.showToast(
                    "There was a problem saving",
                    "error",
                    errors[0].message);
                for (let i = 0; i < errors.length; i++){
                    console.error(errors[i].message);
                }
            }
        }));

        $A.enqueueAction(action);
    },

    /**
     * @description Allows the user to press the save button
     * @param component
     */
    activateSaveButton: function (component) {
        let saveButton = component.find("save");
        let isReadOnly = component.get("v.isReadOnly");
        let facilityId = component.get("v.divisionId");

        if(saveButton && !isReadOnly && facilityId) {
            saveButton.set("v.disabled",false);
        }
    },

    /**
     * @description Deactivates the save button
     * @param component
     */
    deactivateSaveButton: function (component) {
        let saveButton = component.find("save");

        if(saveButton) {
            saveButton.set("v.disabled", true);
        }
    },

    /**
     * @description Displays a toast message of the given type, with given title and body
     * @param       title - Title of toast message
     * @param       type - type e.g. success, error
     * @param       body - Text to display in body
     */
    showToast: function(title, type, body) {
        let toastEvent = $A.get("e.force:showToast");

        toastEvent.setParams({
            "title": title,
            "message": body,
            "type": type
        });

        toastEvent.fire();
    },
})