/**
 * Created by Heather Purvis on 2020-03-25.
 */
({
    setAttributeValue: function(component, event, helper)
    {
        var eventValue= event.getParam("attributeValue");
        component.set("v.selectedDivisionId", eventValue);
    },
})