/**
 * Created by Heather Purvis on 2020-03-24.
 */
({
    /**
     * @description Gets the division id from an event and sets it in the component to know which division to track
     *              resources in
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