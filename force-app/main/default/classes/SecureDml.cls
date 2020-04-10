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
 * Executes DML with or without security
 */
public with sharing class SecureDml {
	public Boolean enforceSharing = true;
	public Boolean enforceFls = true;
	// =========================================================
	// STATIC FIELDS
	// =========================================================
	private static final Set<String> OK_IF_STRIPPED_BEFORE_DML = new Set<String> {
			'CreatedDate',
			'IsDeleted',
			'LastModifiedDate',
			'SystemModstamp'
	};
	// =========================================================
	//  ATTRIBUTES
	// =========================================================
	// =========================================================
	//  PUBLIC METHODS
	// =========================================================
	/*
	  SORT RECORDS BY TYPE & CALL CORRESPONDING 'SAME TYPE' DML METHOD
	 */
	public void dmlInsert(SObject obj) {
		dmlInsert(new List<SObject>{obj});
	}
	public void dmlInsert(List<SObject> objList) {
		Map<SObjectType, List<SObject>> typeToRecords = mapByType(objList);
		for (SObjectType objType : typeToRecords.keySet()) {
			dmlInsertSameType(objType, typeToRecords.get(objType));
		}
	}
	public void dmlUpdate(List<SObject> objList) {
		Map<SObjectType, List<SObject>> typeToRecords = mapByType(objList);
		for (SObjectType objType : typeToRecords.keySet()) {
			dmlUpdateSameType(objType, typeToRecords.get(objType));
		}
	}
	public void dmlDelete(List<SObject> objList) {
		Map<SObjectType, List<SObject>> typeToRecords = mapByType(objList);
		for (SObjectType objType : typeToRecords.keySet()) {
			dmlDeleteSameType(objType, typeToRecords.get(objType));
		}
	}
	public void dmlUpsert(SObjectType objType, List<SObject> objList, SObjectField field) {
		if (!objList.isEmpty()) {
			getInnerDmlForType(objType).dmlUpsert(objList, field);
		}
	}
	// =========================================================
	//  PRIVATE METHODS
	// =========================================================
	/*
	  CHECK:
		- DO DML WITH FLS/ WITH SHARING
		- DO DML WITHOUT FLS / WITHOUT SHARING
	 */
	private void dmlInsertSameType(SObjectType objType, List<SObject> objList) {
		if (!objList.isEmpty()) {
			getInnerDmlForType(objType).dmlInsert(objList);
		}
	}
	private void dmlUpdateSameType(SObjectType objType, List<SObject> objList) {
		if (!objList.isEmpty()) {
			getInnerDmlForType(objType).dmlUpdate(objList);
		}
	}
	private void dmlDeleteSameType(SObjectType objType, List<SObject> objList) {
		if (!objList.isEmpty()) {
			getInnerDmlForType(objType).dmlDelete(objType, objList);
		}
	}
	// Returns appropriate DML executor
	private WithFlsWithSharingDML getInnerDmlForType(SObjectType objType) {
		return new WithFlsWithSharingDML();
	}
	// Strips inaccessible fields according to FLS - throws exception if no table-level access
	private with sharing class WithFlsWithSharingDML {
		void dmlInsert(List<SObject> objList) {
			SObjectAccessDecision decision = Security.stripInaccessible(AccessType.CREATABLE, objList, true);
			List<SObject> stripped = decision.getRecords();
			if (areStrippedFieldsCauseForSecurityException(decision.getRemovedFields())) {
				throw new AccessConfigDMLException('Insufficient write access for insert: ' + decision.getRemovedFields());
			}
			insert stripped;
			for (Integer i = 0; i < stripped.size(); i++) {
				objList[i].Id = stripped[i].Id;
			}
		}
		void dmlUpdate(List<SObject> objList) {
			SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, objList, true);
			if (areStrippedFieldsCauseForSecurityException(decision.getRemovedFields())) {
				throw new AccessConfigDMLException('Insufficient write access for update: ' + decision.getRemovedFields());
			}
			update decision.getRecords();
		}
		void dmlDelete(SObjectType objType, List<SObject> objList) {
			if (!objType.getDescribe().isDeletable()) {
				throw new AccessConfigDMLException('Insufficient write access for delete: ' + objType.getDescribe().getName());
			}
			delete objList;
		}
		void dmlUpsert(List<SObject> objList, SObjectField field) {
			SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPSERTABLE, objList, true);
			if (areStrippedFieldsCauseForSecurityException(decision.getRemovedFields())) {
				throw new AccessConfigDMLException('Insufficient write access for upsert: ' + decision.getRemovedFields());
			}
			List<SObject> stripped = decision.getRecords();
			Database.upsert(stripped, field);
			for (Integer i = 0; i < stripped.size(); i++) {
				objList[i].Id = stripped[i].Id;
			}
		}
		// Strip inaccessible will strip system fields, autonumber & formulas before DML & that is not cause for security exception
		private Boolean areStrippedFieldsCauseForSecurityException(Map<String,Set<String>> typeToStrippedFields) {
			for (String typeName : typeToStrippedFields.keySet()) {
				DescribeSObjectResult typeDescribe = Schema.getGlobalDescribe().get(typeName).getDescribe();
				for (String fieldName : typeToStrippedFields.get(typeName)) {
					DescribeFieldResult describe = typeDescribe.fields.getMap().get(fieldName).getDescribe() ;
					if (!describe.isCalculated() &&
							!describe.isAutoNumber() &&
							!OK_IF_STRIPPED_BEFORE_DML.contains(describe.getName())) {
						return true;
					}
				}
			}
			return false;
		}
	}
	public static Map<SObjectType, List<SObject>> mapByType(List<SObject> records) {
		Map<SObjectType, List<SObject>> typeToRecords = new Map<SObjectType, List<SObject>>();
		for (SObject record : records) {
			List<SObject> typeRecords = typeToRecords.get(record.getSObjectType());
			if (typeRecords == null) {
				typeRecords = new List<SObject>();
				typeToRecords.put(record.getSObjectType(), typeRecords);
			}
			typeRecords.add(record);
		}
		return typeToRecords;
	}
	public with sharing class AccessConfigDMLException extends Exception {}
}