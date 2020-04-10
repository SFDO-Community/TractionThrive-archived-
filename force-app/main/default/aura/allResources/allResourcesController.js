/**
 * Created by Heather Purvis on 2020-03-24.
 */
({
    /**
     * @description
     * @param component
     * @param event
     * @param helper
     */
    setAttributeValue: function(component, event, helper)
    {
        var eventValue= event.getParam("attributeValue");
        component.set("v.selectedDivisionId", eventValue);
    },

})