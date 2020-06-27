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
 * @author  Pedro Serquiz, Traction on Demand
 * @date    2020-05-26
 */
public with sharing class IngressAsset {
	String type;
	String status;
	Decimal count;
	Datetime reportedDateTm;
	Datetime reportDt;
	String parentAccountId;
	String parentAccountName;
	String providerAccountId;
	String providerAccountName;
	String providerBillingAddressLine1Txt;
	String providerBillingCityName;
	String providerBillingCountryName;
	String departmentAccountId;
	String departmentAccountName;
	String dataSourceName;
	Map<String, String> targetFieldMap = new Map<String,String> {
			'Ventilator Beds & Total' => 'ventilatorsCt',
			'Ventilator Beds & In Use' => 'ventilatorsInUseCt',
			'Ventilator Beds & Available' => 'ventilatorsAvailableCt',
			'Ventilator Beds & Inactive' => 'ventilatorsInactiveCt',
			'Anaesthesia Machines & Total' => 'anesthesiaMachineCt',
			'Anaesthesia Machines & In Use' => 'anesthesiaMachineInUseCt',
			'Anaesthesia Machines & Available' => 'anesthesiaMachineAvailableCt',
			'Anaesthesia Machines & Inactive' => 'anesthesiaMachineInactiveCt',
			'N95 Masks & Total' => 'n95MaskCt',
			'N95 Masks & In Use' => 'n95MaskInUseCt',
			'N95 Masks & Available' => 'n95MaskAvailableCt',
			'N95 Masks & Inactive' => 'n95MaskInactiveCt',
			'Face Shields & Total' => 'faceShieldCt',
			'Face Shields & In Use' => 'faceShieldInUseCt',
			'Face Shields & Available' => 'faceShieldAvailableCt',
			'Face Shields & Inactive' => 'faceShieldInactiveCt',
			'Hoods & Total' => 'hoodCt',
			'Hoods & In Use' => 'hoodInUseCt',
			'Hoods & Available' => 'hoodAvailableCt',
			'Hoods & Inactive' => 'hoodInactiveCt',
			'Level 3 Gowns & Total' => 'level3GownCt',
			'Level 3 Gowns & In Use' => 'level3GownInUseCt',
			'Level 3 Gowns & Available' => 'level3GownAvailableCt',
			'Level 3 Gowns & Inactive' => 'level3GownInactiveCt',
			'Level 4 Gowns & Total' => 'level4GownCt',
			'Level 4 Gowns & In Use' => 'level4GownInUseCt',
			'Level 4 Gowns & Available' => 'level4GownAvailableCt',
			'Level 4 Gowns & Inactive' => 'level4GownInactiveCt',
			'Coveralls & Total' => 'coverallCt',
			'Coveralls & In Use' => 'coverallInUseCt',
			'Coveralls & Available' => 'coverallAvailableCt'
	};

	public static List<IngressAsset> wrap(List<Status_Report__c> statusReports) {
		List<IngressAsset> wrappers = new List<IngressAsset>();
		for (Status_Report__c m : statusReports) {
			wrappers.add(new IngressAsset(m));
		}
		return wrappers;
	}

	public IngressAsset(Status_Report__c sr) {
		this.reportedDateTm = sr.Date_Time__c;
		this.reportDt = sr.Date_Time__c;
		this.parentAccountId = sr.Department__r.Parent.Parent.External_ID__c == null ? '' : sr.Department__r.Parent.Parent.External_ID__c;
		this.parentAccountName = sr.Department__r.Parent.Parent.Name == null ? '' : sr.Department__r.Parent.Parent.Name;
		this.providerAccountId = sr.Department__r.Parent.External_ID__c == null ? '' : sr.Department__r.Parent.External_ID__c;
		this.providerAccountName = sr.Department__r.Parent.Name == null ? '' : sr.Department__r.Parent.Name;
		this.providerBillingAddressLine1Txt = sr.Department__r.BillingStreet == null ? '' : sr.Department__r.BillingStreet;
		this.providerBillingCityName = sr.Department__r.BillingState == null ? '' : sr.Department__r.BillingState;
		this.providerBillingCountryName = sr.Department__r.BillingCountry == null ? '' : sr.Department__r.BillingCountry;
		this.departmentAccountId = sr.Department__r.External_ID__c == null ? '' : sr.Department__r.External_ID__c;
		this.departmentAccountName = sr.Department__r.Name == null ? '' : sr.Department__r.Name;
		this.count = sr.Count__c;
		this.type = sr.Type__c;
		this.status = sr.Status__c;
		this.dataSourceName = DataSharingSettingsController.getSettings().Data_Source_Name__c;

	}

	public String getJsonString(){
		Map<String, Object> ingressMapStrings = new Map<String, Object>{
				'reportedDateTm' => reportedDateTm.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
				'reportDt' => String.valueOf(Date.newinstance(reportedDateTm.year(), reportedDateTm.month(), reportedDateTm.day())),
				'parentAccountId' => parentAccountId,
				'parentAccountName' => parentAccountName,
				'providerAccountId' => providerAccountId,
				'providerAccountName' => providerAccountName,
				'providerBillingAddressLine1Txt' => providerBillingAddressLine1Txt,
				'providerBillingCityName' => providerBillingCityName,
				'providerBillingCountryName' => providerBillingCountryName,
				'departmentAccountId' => departmentAccountId,
				'departmentAccountName' => departmentAccountName,
				'dataSourceName' => dataSourceName
		};

		String fieldKey = type + ' & ' + status;
		if (targetFieldMap.get(fieldKey) != null) {
			ingressMapStrings.put(targetFieldMap.get(fieldKey), count);
		}
		Map<String, Map<String, Object>> ingressMapObject = new Map<String, Map<String, Object>>();
		ingressMapObject.put('disasterObservationReport',  new Map<String, Map<String, Object>>());
		ingressMapObject.put('assetObservationReport', ingressMapStrings);
		List<Map<String, Map<String, Object>>> ingressMapList = new List<Map<String, Map<String, Object>>>();
		ingressMapList.add(ingressMapObject);
		return JSON.serialize(ingressMapList);
	}
}