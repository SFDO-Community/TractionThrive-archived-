/**
 * Created by Heather Purvis on 2020-03-19.
 */
({
    /**
     * @description Initialises the component by finding the users contact info
     * @param component
     * @param event
     * @param helper
     */
    init: function (component, event, helper) {
        //Checks the selected design attributes and sets
        //The right css classes to be added in the markup
        helper.checkDesignAttributes(component, helper);
        let action = component.get("c.getContactInfo");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set current user contact information
                component.set("v.contactInfo", storeResponse.contact);
                // set current user information
                component.set("v.userInfo", storeResponse.user);
            }
        });
        $A.enqueueAction(action);
    },

    toggleContactForm : function (component, event) {
        let showEditForm = component.get('v.showEditForm');
        if (showEditForm) {
            component.set('v.showEditForm', false);
        } else {
            component.set('v.showEditForm', true);
        }
    }
})