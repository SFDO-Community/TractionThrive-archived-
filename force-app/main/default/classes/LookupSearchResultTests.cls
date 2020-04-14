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
@isTest(isParallel=true)
public class LookupSearchResultTests {
	@isTest
	static void compareTo_should_work_with_two_null_titles() {
		LookupSearchResult r1 = getSearchResult(null);
		LookupSearchResult r2 = getSearchResult(null);

		Integer compareResult = r1.compareTo(r2);

		System.assertEquals(0, compareResult);
	}

	@isTest
	static void compareTo_should_work_with_this_null_title() {
		LookupSearchResult r1 = getSearchResult(null);
		LookupSearchResult r2 = getSearchResult('a');

		Integer compareResult = r1.compareTo(r2);

		System.assertEquals(1, compareResult);
	}

	@isTest
	static void compareTo_should_work_with_other_null_title() {
		LookupSearchResult r1 = getSearchResult('a');
		LookupSearchResult r2 = getSearchResult(null);

		Integer compareResult = r1.compareTo(r2);

		System.assertEquals(-1, compareResult);
	}

	@isTest
	static void compareTo_should_work_with_non_null_titles() {
		LookupSearchResult r1 = getSearchResult('a');
		LookupSearchResult r2 = getSearchResult('b');

		Integer compareResult = r1.compareTo(r2);

		System.assertEquals(-1, compareResult);
	}

	@isTest
	static void getters_should_work() {
		// For the sake of code coverage
		LookupSearchResult r = new LookupSearchResult('0010R00000yvEyRQAU', 'type', 'icon', 'title', 'subtitle');

		System.assertEquals('0010R00000yvEyRQAU', r.getId());
		System.assertEquals('type', r.getSObjectType());
		System.assertEquals('icon', r.getIcon());
		System.assertEquals('title', r.getTitle());
		System.assertEquals('subtitle', r.getSubtitle());
	}

	private static LookupSearchResult getSearchResult(String title) {
		return new LookupSearchResult(null, null, null, title, null);
	}
}