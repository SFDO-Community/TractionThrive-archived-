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
 * @description Controller class for the contactEditForm Lightning Web Component
 * @author  Pedro Serquiz, Traction on Demand
 * @date    2020-03-27
 */
public with sharing class ContactEditFormController {
	// =========================================================
	//  PUBLIC METHODS
	// =========================================================

	/**
	 * @description Gets the initial data to be used in the edit form
	 * @return InitData Wrapper with contact info, picklist values
	 * and credentials related to the contact
	 */
	@AuraEnabled
	public static InitData getInitData() {
		ContactCardCtrl.ContactData contactInfo = ContactCardCtrl.getContactInfo();
		List<Credential__c> contactCredentials = CredentialsSelector.selectCredentialsByContactId(contactInfo.contact.Id);

		return new InitData(contactInfo, getPicklistValuesFromObjectAndField('Contact', UTIL_Namespace.StrTokenNSPrefix('Skills__c')), contactCredentials);
	}

	/**
	 * @description Updates the contact record
	 * @param contactToUpdate the given contact record to update
	 * @return InitData Wrapper with contact updated info, picklist values
	 * and credentials related to the contact
	 */
	@AuraEnabled
	public static InitData updateContact(Contact contactToUpdate) {
		if (contactToUpdate == null) {
			throw new AuraHandledException('Wrong object was passed');
		}

		SecureDml updateObject = new SecureDml();
		try{
			updateObject.dmlUpdate(new List<Contact>{contactToUpdate});
		}catch (Exception e){
			throw new AuraHandledException(JSON.serialize(e.getTypeName() + ': ' + e.getMessage() + ' - ' + e.getStackTraceString()));
		}

		return getInitData();
	}

	/**
	 * @description Updates the credential record
	 * @param credentialToUpdate the given credential record to update
	 * @return the credential record with its updated data
	 */
	@AuraEnabled
	public static Credential__c updateCredential(Credential__c credentialToUpdate) {
		if (credentialToUpdate == null) {
			throw new AuraHandledException('Wrong object was passed');
		}
		SecureDml updateObject = new SecureDml();
		try{
			updateObject.dmlUpdate(new List<Credential__c>{credentialToUpdate});
		}catch (Exception e){
			throw new AuraHandledException(JSON.serialize(e.getTypeName() + ': ' + e.getMessage() + ' - ' + e.getStackTraceString()));
		}
		return CredentialsSelector.selectCredentialsById(credentialToUpdate.Id);
	}

	/**
	 * @description Insert a new credential record
	 * @param credentialToInsert
	 * @return the newly created credential record
	 */
	@AuraEnabled
	public static Credential__c insertCredential(Credential__c credentialToInsert) {
//		Credential__c credentialToInsert = (Credential__c)(JSON.deserialize(credentialToInsertJSON, Credential__c.class));
		if (credentialToInsert == null) {
			throw new AuraHandledException('Wrong credential');
		}
		SecureDml insertObject = new SecureDml();
		try{
			insertObject.dmlInsert(credentialToInsert);
		}catch (Exception e){
			throw new AuraHandledException(JSON.serialize(e.getTypeName() + ': ' + e.getMessage() + ' - ' + e.getStackTraceString()));
		}
		/*Database.SaveResult saveResult = Database.insert(credentialToInsert, false);
		if (!saveResult.isSuccess()) {
			throw new AuraHandledException(saveResult.getErrors()[0].getMessage());
		}*/

		return CredentialsSelector.selectCredentialsById(credentialToInsert.Id);
	}

	/**
	 * @description Gets the credentials picklist values
	 * @return a list with all the picklist values
	 */
	@AuraEnabled
	public static Map<String, String> getCredentialsTypePicklistValues() {
		return getPicklistValuesFromObjectAndField(UTIL_Namespace.StrTokenNSPrefix('Credential__c'), UTIL_Namespace.StrTokenNSPrefix('Type__c'));
	}

	/**
	 * @description Deletes a given credential
	 * @param credentialId the credential Id to be deleted
	 */
	@AuraEnabled
	public static void deleteCredential(Id credentialId) {
		if (credentialId == null) {
			throw new AuraHandledException('No Credential Selected');
		}

		SecureDml deleteObject = new SecureDml();
		try{
			deleteObject.dmlDelete(new List<Credential__c>{CredentialsSelector.selectCredentialsById(credentialId)});
		}catch (Exception e){
			throw new AuraHandledException(JSON.serialize(e.getTypeName() + ': ' + e.getMessage() + ' - ' + e.getStackTraceString()));
		}

	}

	// =========================================================
	//  PRIVATE METHODS
	// =========================================================

	/**
	 * Gets the picklist values for the given object name and field name
	 *
	 * @param objectName the object name i.e Credential__c
	 * @param fieldName the picklist field name related to the given object i.e Type__c
	 *
	 * @return a list with all the picklist values
	 *
	 * @example
	 * getPicklistValuesFromObjectAndField(UTIL_Namespace.StrTokenNSPrefix('Credential__c'), UTIL_Namespace.StrTokenNSPrefix('Type__c'))
	 */
	private static Map<String,String> getPicklistValuesFromObjectAndField(String objectName, String fieldName) {
		Map<String,String> picklistValues = new Map<String,String>();
		Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
		Schema.DescribeSObjectResult r = s.getDescribe() ;
		Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
		Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		for( Schema.PicklistEntry pickListVal : ple){
			picklistValues.put(pickListVal.getLabel(),pickListVal.getValue());
		}

		return picklistValues;
	}

	// =========================================================
	//  WRAPPERS
	// =========================================================

	public class InitData {
		@AuraEnabled public ContactCardCtrl.ContactData contactData;
		@AuraEnabled public Map<String, String> skillsPicklistValues;
		@AuraEnabled public List<Credential__c> credentials;

		public InitData(ContactCardCtrl.ContactData contactData, Map<String, String> skillsPicklistValues, List<Credential__c> credentials) {
			this.contactData = contactData;
			this.skillsPicklistValues = skillsPicklistValues;
			this.credentials = credentials;
		}
	}
}