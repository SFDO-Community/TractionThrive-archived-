/*
    Copyright (c) 2020, Traction Sales And Marketing Inc.
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
 * @description Controller class for the appFieldSet Lightning Web Component
 * @author  Pedro Serquiz, Traction on Demand
 * @date    2020-04-18
 */
public without sharing class AppFieldSetController {
	static final Integer MAX_RESULTS = 5;

	// =========================================================
	//  PUBLIC METHODS
	// =========================================================

	/**
	 * gets the given fieldset fields
	 *
	 * @param fieldSetName the fieldset api name
	 * @param ObjectName the object name that contains the fieldSetName
	 *
	 * @return Field set fields
	 */
	@AuraEnabled
	public static List<FieldSetMember> getFieldSetFields(String fieldSetName, String ObjectName)
	{
		Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
		Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
		Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
		Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
		List<Schema.FieldSetMember> fieldSetMemberList =  fieldSetObj.getFields();

		Map<String, SObjectField> fieldMap = DescribeSObjectResultObj.fields.getMap();
		List<FieldSetMember> fieldSetMembersWrapper = new List<FieldSetMember>();
		for (Schema.FieldSetMember f : fieldSetMemberList) {
			fieldSetMembersWrapper.add(new FieldSetMember(f, fieldMap));
		}

		return fieldSetMembersWrapper;
	}

	/**
	 * Get given generic record to edit
	 *
	 * @param recordId the record to edit
	 * @param fieldNames the fields to be queried
	 *
	 * @return the queried object and its lookup fields
	 */
	@AuraEnabled
	public static EditObjectData getRecordToEdit(Id recordId, List<String> fieldNames) {
		String fields = 'Id ';
		Map<String, String> lookupFieldsMapTemp = new Map<String, String>();
		SObjectType sObjectType = recordId.getSObjectType();
		for (String fieldName : fieldNames) {
			DescribeFieldResult field = sObjectType.getDescribe().fields.getMap().get(fieldName).getDescribe();
			if (field.getType() == Schema.DisplayType.REFERENCE) {
				fields += ', '+field.getRelationshipName()+'.Name';
				lookupFieldsMapTemp.put(fieldName, field.getRelationshipName()+'.Name');
			}
			fields += ', '+fieldName;
		}

		String qryString = 'SELECT ' + fields + ' FROM ' + sObjectType + ' WHERE Id =: recordId';
		SObject recordToEdit = Database.query(qryString);

		Map<String, String> lookupFields = new Map<String, String>();

		if (lookupFieldsMapTemp.size() > 0) {
			for (String lookupField : lookupFieldsMapTemp.keySet()) {
				if ((String) recordToEdit.get(lookupField) != null) {
					lookupFields.put(lookupField, lookupFieldsMapTemp.get(lookupField));
				}
			}
		}

		EditObjectData dataToReturn = new EditObjectData(recordToEdit, JSON.serialize(lookupFields));

		return dataToReturn;
	}

	/**
	* Inserts a generic sobject
	*
	* @param jSONSObject the object to be inserted
	* @param sObjectApiName the object api name
	*/
	@AuraEnabled
	public static SObject insertSObject(String jSONSObject, String sObjectApiName) {
		SObject objectToInsert = convertGenericSObject(jSONSObject, sObjectApiName);
		SecureDml insertObject = new SecureDml();
		insertObject.dmlInsert(new List<SObject>{convertGenericSObject(jSONSObject, sObjectApiName)});
		return objectToInsert;
	}

	/**
	* Updates a generic sobject
	*
	* @param jSONSObject the object to be updated
	* @param sObjectApiName the object api name
	*/
	@AuraEnabled
	public static SObject updateSObject(String jSONSObject, String sObjectApiName) {
		SObject objectToUpdate = convertGenericSObject(jSONSObject, sObjectApiName);
		SecureDml updateObject = new SecureDml();
		updateObject.dmlUpdate(new List<SObject>{objectToUpdate});
		return objectToUpdate;
	}

	// custom lookup for sfdc-ui-lookup-lwc - https://github.com/pozil/sfdc-ui-lookup-lwc/tree/master/src-sample
	@AuraEnabled(Cacheable=true)
	public static List<LookupSearchResult> searchGenericLookup(String searchTerm, List<String> selectedIds, String lookupObject) {
		// Prepare query parameters
		searchTerm += '*';

		// Execute search query
		String query = 'FIND \'' + String.escapeSingleQuotes(searchTerm) + '\' IN ALL FIELDS RETURNING ' + lookupObject + '(Id, Name WHERE Id NOT IN :selectedIds) LIMIT :MAX_RESULTS';
		system.debug('query => '+query);
		List<List<SObject>> searchResults = Search.query(query);


		// Prepare results
		List<LookupSearchResult> results = new List<LookupSearchResult>();

		// Extract SObject & convert them into LookupSearchResult
		String icon = 'standard:account';
		SObject[] filteredResults = (List<SObject>) searchResults[0];
		for (SObject obj : filteredResults) {
			String name = (String) obj.get('Name');
			results.add(
					new LookupSearchResult(
							obj.Id,
							lookupObject,
							icon,
							name,
							lookupObject+' • ' + name
					)
			);
		}


		// Optionally sort all results on title
		results.sort();

		return results;
	}


	// =========================================================
	//  Private METHODS
	// =========================================================

	/**
	 * build
	 *
	 * @param jSONSObject the object to be converted
	 * @param sObjectApiName the object api name
	 */
	private static SObject convertGenericSObject(String jSONSObject, String sObjectApiName) {
		Map<String, Object> fieldMap = (Map<String, Object>)JSON.deserializeUntyped(jSONSObject);
		Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectApiName);
		SObject newSobject = targetType.newSObject();
		Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();
		for (String key : fieldMap.keySet())
		{
			Object value = fieldMap.get(key);
			Schema.DisplayType valueType = targetFields.get(key).getDescribe().getType();
			if (value instanceof String && valueType != Schema.DisplayType.String)
			{
				String svalue = (String)value;
				if (valueType == Schema.DisplayType.Date)
					newSobject.put(key, Date.valueOf(svalue));
				else if(valueType == Schema.DisplayType.DateTime)
					newSobject.put(key, DateTime.valueOfGmt(svalue));
				else if (valueType == Schema.DisplayType.Percent || valueType == Schema.DisplayType.Currency)
					newSobject.put(key, svalue == '' ? null : Decimal.valueOf(svalue));
				else if (valueType == Schema.DisplayType.Double)
					newSobject.put(key, svalue == '' ? null : Double.valueOf(svalue));
				else if (valueType == Schema.DisplayType.Integer)
					newSobject.put(key, Integer.valueOf(svalue));
				else if (valueType == Schema.DisplayType.Base64)
					newSobject.put(key, Blob.valueOf(svalue));
				else
						newSobject.put(key, svalue);
			}
			else
					newSobject.put(key, value);
		}
		return newSobject;
	}

	// =========================================================
	//  WRAPPER METHODS
	// =========================================================

	public class FieldSetMember {
		@AuraEnabled public Boolean DBRequired;
		@AuraEnabled public String fieldPath;
		@AuraEnabled public String label;
		@AuraEnabled public Boolean required;
		@AuraEnabled public String type;
		@AuraEnabled public String value;
		@AuraEnabled public String lookupObject;
		@AuraEnabled public Boolean isLookupField;
		@AuraEnabled public Boolean isPicklistField;
		@AuraEnabled public Boolean isCheckboxField;
		@AuraEnabled public Boolean isMultiPicklistField;
		@AuraEnabled public Boolean isRegularField;
		@AuraEnabled public List<PicklistEntry> picklistEntries = new List<PicklistEntry>();

		public FieldSetMember(Schema.FieldSetMember f, Map<String, SObjectField> fieldMap) {
			this.DBRequired = f.dbRequired;
			this.fieldPath = f.fieldPath;
			this.label = f.label;
			this.required = f.required;
			this.type = String.valueOf(f.getType());
			this.value = '';
			this.lookupObject = fieldMap.get(fieldPath).getDescribe().getRelationshipName();
			this.isLookupField = f.type == Schema.DisplayType.REFERENCE;
			this.isPicklistField = f.type == Schema.DisplayType.PICKLIST;
			this.isCheckboxField = f.type == Schema.DisplayType.BOOLEAN;
			this.isMultiPicklistField = f.type == Schema.DisplayType.MULTIPICKLIST;
			this.isRegularField = f.type != Schema.DisplayType.PICKLIST && f.type != Schema.DisplayType.BOOLEAN && f.type != Schema.DisplayType.MULTIPICKLIST && f.type != Schema.DisplayType.REFERENCE;

			if (this.type == 'Picklist' || this.type == 'Multipicklist') {
				for (Schema.PicklistEntry ple : fieldMap.get(fieldPath).getDescribe().getPicklistValues()) {
					picklistEntries.add(new PicklistEntry(ple));
				}
			}
		}
	}

	public with sharing class PicklistEntry {
		@AuraEnabled public String label;
		@AuraEnabled public String value;
		@AuraEnabled public Boolean isActive;
		@AuraEnabled public Boolean isDefaultValue;

		public PicklistEntry(Schema.PicklistEntry ple) {
			this.label = ple.getLabel();
			this.value = ple.getValue();
			this.isActive = ple.isActive();
			this.isDefaultValue = ple.isDefaultValue();
		}
	}

	public with sharing class EditObjectData {
		@AuraEnabled public SObject editedObject;
		@AuraEnabled public String lookupFields;

		public EditObjectData(SObject editedObject, String lookupFields) {
			this.editedObject = editedObject;
			this.lookupFields = lookupFields;
		}
	}
}