/**
 * Created by Heather Purvis on 2020-03-24.
 */
({

    /**
     * @description Gets relevant accounts for each picklist for this user
     * @param component
     * @param event
     * @param helper
     */
    getAccountData: function (component, event, helper) {
        let action = component.get("c.getAccountSelections");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                this.formatAccountData(component, helper, data);
            } else if (state === "ERROR") {
                let errors = response.getError();
                this.showToast(
                    "There was a problem fetching hospital data",
                    "error",
                    errors[0].message);
                for (let i = 0; i < errors.length; i++){
                    console.log(errors[i].message);
                }
            }
        });

        $A.enqueueAction(action);
    },

    /**
     * @description Organises and stores the account data retrieved
     * @param component
     * @param event
     * @param helper
     */
    formatAccountData: function (component, helper, data) {
        // Authority data
        let authorities = helper.generateOptionListFromString(data.healthAuthorities);
        component.set("v.healthAuthorities", authorities);

        // Hospital data
        component.set("v.hospitalMap", data.authorityHospitalMap);

        // Division data
        component.set("v.divisionMap", data.hospitalDivisionMap);

        if (data.currentHealthAuthority) {
            component.set("v.selectedAuthority", data.currentHealthAuthority);
            let hospitals = helper.generateOptionList(data.authorityHospitalMap[data.currentHealthAuthority]);
            component.set("v.hospitals", hospitals);

            if (data.currentHospital) {
                component.set("v.selectedHospital", data.currentHospital.Id);
                let divisions = helper.generateOptionList(data.hospitalDivisionMap[data.currentHospital.Id]);
                component.set("v.divisions", divisions);

                if (data.currentDivision) {
                    component.set("v.selectedDivision", data.currentDivision.Id);
                    helper.fireDivisionSetEvent(component);
                }
            }
        }
    },

    /**
     * @description Finds the hospitals under the selected health authority
     * @param component
     * @param event
     * @param helper
     */
    getHospitals: function (component, event, helper) {
        component.set("v.hospitals", null);
        let authorityName = component.get("v.selectedAuthority");
        let hospitalMap = component.get("v.hospitalMap");

        if(hospitalMap && hospitalMap[authorityName]) {
            let hospitals = helper.generateOptionList(hospitalMap[authorityName]);
            component.set("v.hospitals", hospitals);
        } else {
            let action = component.get("c.getChildHospitals");

            action.setParams({
                authorityName: component.get("v.selectedAuthority")
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    let data = response.getReturnValue();
                    let hospitals = helper.generateOptionList(data);
                    component.set("v.hospitals", hospitals);
                }
            });

            $A.enqueueAction(action);
        }
    },

    /**
     * @description Finds the divisions under the selected hospital
     * @param component
     * @param event
     * @param helper
     */
    getDivisions: function (component, event, helper) {
        component.set("v.divisions", null);
        let hospitalId = component.get("v.selectedHospital");
        let divisionMap = component.get("v.divisionMap");

        if(divisionMap && divisionMap[hospitalId]) {
            let divisions = helper.generateOptionList(divisionMap[hospitalId]);
            component.set("v.divisions", divisions);
        } else {
            let action = component.get("c.getChildAccounts");

            action.setParams({
                parentId: hospitalId
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    let data = response.getReturnValue();
                    let divisions = helper.generateOptionList(data);
                    component.set("v.divisions", divisions);
                }
            });

            $A.enqueueAction(action);
        }

    },

    /**
     * @description Generates a list of names with the id as a value and name as label
     * @param objectList
     */
    generateOptionList: function (objectList) {
        let options = [];
        objectList.forEach(function(object) {
            options.push({
                value: object.Id,
                label: object.Name
            });
        });
        return options;
    },

    /**
     * @description Generates a list given a list of names
     * @param objectList
     */
    generateOptionListFromString: function (nameList) {
        let options = [];
        nameList.forEach(function(name) {
            options.push({
                value: name,
                label: name
            });
        });
        return options;
    },

    /**
     * @description Fires an event containing the division selected up to the parent component
     * @param component
     */
    fireDivisionSetEvent: function (component) {
        let setEvent = component.getEvent("setAttribute");
        setEvent.setParams({"attributeValue":component.get("v.selectedDivision")});
        setEvent.fire();
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