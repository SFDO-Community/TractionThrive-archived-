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
 * @date    2020-05-27
 */
public with sharing class IngressInfection {
	String type;
	String status;
	Decimal count;
	Datetime reportedDateTm;
	Datetime reportDt;
	String reportProviderAccountId;
	String reportProviderAccountName;
	String provinceStateName;
	String countyName;
	String locationShippingAddressLine1Txt;
	String locationtShippingCityName;
	String locationShippingProvinceStateName;
	String locationShippingPostalCodeTxt;
	String locationShippingCountryName;

	Map<String, String> targetFieldMap = new Map<String,String> {
			'Presumptive COVID' => 'presumptiveInfectedCt',
			'Comorbidity' => 'comorbidityCt',
			'Health Care Staff COVID Positive' => 'healthCarePeoplePositiveCt',
			'COVID Positive' => 'peoplePositiveCasesCt',
			'COVID Like' => 'covid19LikeSymptomCount'
	};

	public static List<IngressInfection> wrap(List<Status_Report__c> memberships) {
		List<IngressInfection> wrappers = new List<IngressInfection>();
		for (Status_Report__c m : memberships) {
			wrappers.add(new IngressInfection(m));
		}
		return wrappers;
	}

	public IngressInfection(Status_Report__c sr) {
		this.reportedDateTm = sr.Date_Time__c;
		this.reportDt = sr.Date_Time__c;
		this.reportProviderAccountId = sr.Department__r.Parent.ParentId == null ? '' : sr.Department__r.Parent.ParentId;
		this.reportProviderAccountName = sr.Department__r.Parent.Parent.Name == null ? '' : sr.Department__r.Parent.Parent.Name;
		this.provinceStateName = sr.Department__r.BillingState == null ? '' : sr.Department__r.BillingState;
		this.countyName = sr.Department__r.BillingCountry == null ? '' : sr.Department__r.BillingCountry;
		this.locationShippingAddressLine1Txt = sr.Department__r.ShippingStreet == null ? '' : sr.Department__r.ShippingStreet;
		this.locationtShippingCityName = sr.Department__r.ShippingCity == null ? '' : sr.Department__r.ShippingCity;
		this.locationShippingProvinceStateName = sr.Department__r.ShippingState == null ? '' : sr.Department__r.ShippingState;
		this.locationShippingPostalCodeTxt = sr.Department__r.ShippingPostalCode == null ? '' : sr.Department__r.ShippingPostalCode;
		this.locationShippingCountryName = sr.Department__r.ShippingCountry == null ? '' : sr.Department__r.ShippingCountry;
		this.count = sr.Count__c;
		this.type = sr.Type__c;
		this.status = sr.Status__c;
	}

	public String getJsonString(){
		Map<String, Object> ingressMapStrings = new Map<String, Object>{
				'reportedDateTm' => reportedDateTm.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
				'reportDt' => String.valueOf(Date.newinstance(reportedDateTm.year(), reportedDateTm.month(), reportedDateTm.day())),
				'reportProviderAccountId' => reportProviderAccountId,
				'reportProviderAccountName' => reportProviderAccountName,
				'provinceStateName' => provinceStateName,
				'countyName' => countyName,
				'locationShippingAddressLine1Txt' => locationShippingAddressLine1Txt,
				'locationtShippingCityName' => locationtShippingCityName,
				'locationShippingProvinceStateName' => locationShippingProvinceStateName,
				'locationShippingPostalCodeTxt' => locationShippingPostalCodeTxt,
				'locationShippingCountryName' => locationShippingCountryName
		};

		if (targetFieldMap.get(type) != null) {
			ingressMapStrings.put(targetFieldMap.get(type), count);
		}

		return JSON.serialize(ingressMapStrings);
	}
}