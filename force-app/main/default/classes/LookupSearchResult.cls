/*
   Copyright 2019 Salesforce.com

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

/**
 * Class used to serialize a single Lookup search result item
 * The Lookup controller returns a List<LookupSearchResult> when sending search result back to Lightning
 */
public class LookupSearchResult implements Comparable {
	private Id id;
	private String sObjectType;
	private String icon;
	private String title;
	private String subtitle;

	public LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle) {
		this.id = id;
		this.sObjectType = sObjectType;
		this.icon = icon;
		this.title = title;
		this.subtitle = subtitle;
	}

	@AuraEnabled
	public Id getId() {
		return id;
	}

	@AuraEnabled
	public String getSObjectType() {
		return sObjectType;
	}

	@AuraEnabled
	public String getIcon() {
		return icon;
	}

	@AuraEnabled
	public String getTitle() {
		return title;
	}

	@AuraEnabled
	public String getSubtitle() {
		return subtitle;
	}

	/**
	 * Allow to sort search results based on title
	 */
	public Integer compareTo(Object compareTo) {
		LookupSearchResult other = (LookupSearchResult) compareTo;
		if (this.getTitle() == null) {
			return (other.getTitle() == null) ? 0 : 1;
		}
		if (other.getTitle() == null) {
			return -1;
		}
		return this.getTitle().compareTo(other.getTitle());
	}
}