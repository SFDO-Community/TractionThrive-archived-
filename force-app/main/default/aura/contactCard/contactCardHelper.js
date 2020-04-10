/**
 * Created by Heather Purvis on 2020-03-19.
 */
({
	/**
	 * creates an object with all the right css class values and set
	 * the designAttributeCssClasses attribute
	 * @param component
	 * @param helper
	 */
	checkDesignAttributes : function (component, helper) {
		let showAvatar = component.get('v.showAvatar');
		let showContactInfo = component.get('v.showContactInfo');
		let showAccountInfo = component.get('v.showAccountInfo');
		let allSelectedClasses = {
			avatarAttributeClass: helper.getCssClassValue(showAvatar),
			contactInfoAttributeClass: helper.getCssClassValue(showContactInfo),
			accountInfoAttributeClass: helper.getCssClassValue(showAccountInfo)
		};

		component.set('v.designAttributeCssClasses', allSelectedClasses);

	},

	/**
	 * Filters out the select value in the design attribute to return the right css class name
	 * @param attributeValue the selected design attribute value
	 * @returns string the css class based on the selected design attribute value
	 */
	getCssClassValue : function (attributeValue) {
		const DESKTOP = 'Desktop';
		const MOBILE = 'Mobile';
		const BOTH = 'Desktop and Mobile';
		const NONE = 'none';
		let selectedCssClass = '';

		switch(attributeValue) {
			case DESKTOP:
				selectedCssClass = 'cmp-hide-on-mobile';
				break;
			case MOBILE:
				selectedCssClass = 'cmp-hide-on-desktop';
				break;
			case BOTH:
				selectedCssClass = '';
				break;
			case NONE:
				selectedCssClass = 'cmp-hide-on-desktop cmp-hide-on-mobile';
				break;
		}

		return selectedCssClass;
	}
})