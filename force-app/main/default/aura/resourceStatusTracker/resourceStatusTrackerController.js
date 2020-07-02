/**
 * Created by Heather Purvis on 2020-03-18.
 */
({
    /**
     * @description Initialises the component
     * @param component
     * @param event
     * @param helper
     */
    init: function (component, event, helper) {
        let facilityId = event.getParam("facilityId");
        if(typeof facilityId !== 'undefined'){
            component.set("v.divisionId", facilityId);
        }

        helper.getStatusReport(component,event,helper);
    },

    /**
     * @description Increases the count by 1 and activates the save button
     * @param component
     * @param event
     * @param helper
     */
    increaseCount: function (component, event, helper) {
        let currentCount = component.get("v.count");

        if(Number(currentCount) >= 0) {
            component.set("v.count", Number(currentCount) + 1);
            helper.activateSaveButton(component);
        }
    },

    /**
     * @description Decreases the count by 1 and activates the save button
     * @param component
     * @param event
     * @param helper
     */
    decreaseCount: function (component, event, helper) {
        let currentCount = component.get("v.count");

        if(Number(currentCount) > 0) {
            component.set("v.count", Number(currentCount) - 1);
            helper.activateSaveButton(component);
        }
    },

    /**
     * @description Handles saving the new status and disables save button
     * @param component
     * @param event
     * @param helper
     */
    handleUpdate: function (component, event, helper) {
        helper.setCount(component,event,helper);
        helper.deactivateSaveButton(component);
    },

    /**
     * @description Handles a cell value change by checking validity and activating save button if valid
     * @param component
     * @param event
     * @param helper
     */
    handleChange: function (component, event, helper) {
        var validity = component.find("count").get("v.validity");
        if(validity.valid === true) {
            helper.activateSaveButton(component);
        } else {
            helper.deactivateSaveButton(component);
        }
    },
})