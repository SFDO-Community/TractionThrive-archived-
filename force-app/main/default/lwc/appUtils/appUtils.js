/**
 * @author Pedro Serquiz - pserquiz@tractionondemand.com
 * @description utils to use on Lightning Web Components
 * @date    2020-03-28
 */

import {ShowToastEvent} from "lightning/platformShowToastEvent";
import getNamespace from '@salesforce/apex/AppUtils.getNamespace';

//Variants usage - error, success, warning
const handleToastMessage = (title, message, variant) => {
	return new ShowToastEvent({
		title: title,
		message: message,
		variant: variant
	})
}

const getOrgNamespace = () => {
	return getNamespace();
}

const getFieldValue = (obj, fieldName, namespace) => {
	return obj[namespace + fieldName];
}

const setNamespaceToList = (list, namespace) => {
	let newList = [];
	if (namespace) {
		list.forEach(function (item) {
			newList.push(namespace+item);
		});
		return newList;
	} else {
		return list;
	}
}

export {handleToastMessage, getOrgNamespace, getFieldValue, setNamespaceToList}