from cumulusci.tasks.salesforce.update_profile import ProfileGrantAllAccess as BaseProfileGrantAllAccess

class ProfileGrantAllAccess(BaseProfileGrantAllAccess):
    def _expand_package_xml(self, package_xml):
        # Query the target org for all namespaced objects
        # Add these entities to the package.xml

        results = self.tooling.query_all(
            "SELECT DeveloperName, NamespacePrefix FROM CustomObject WHERE NamespacePrefix = '{}' AND DeveloperName != 'Knowledge'".format(self.project_config.project__package__namespace)
        )

        custom_objects = package_xml.find("types", name="CustomObject")
        if not custom_objects:
            raise CumulusCIException(
                "Unable to add packaged objects to package.xml because it does not contain a <types> tag of type CustomObject."
            )

        for record in results.get("records", []):
            custom_objects.append(
                "members",
                text=f"{record['NamespacePrefix']}__{record['DeveloperName']}__c",
            )

    def _set_record_types(self, tree, api_name):
        record_types = self.options.get("record_types") or []

        # Set recordTypeVisibilities
        for rt in record_types:
            # Replace namespace prefix tokens in rt name
            rt_prefixed = rt["record_type"].format(**self.namespace_prefixes)

            # Look for the recordTypeVisiblities element
            elem = tree.find("recordTypeVisibilities", recordType=rt_prefixed)
            if elem is None:
                raise TaskOptionsError(
                    f"Record Type {rt['record_type']} not found in retrieved {api_name}.profile"
                )

            # Set visible
            elem.visible.text = str(rt.get("visible", "true")).lower()

            # Set default
            elem.default.text = str(rt.get("default", "false")).lower()

            # Set person account default if element exists
            pa_default = elem.find("personAccountDefault")
            if pa_default is not None:
                pa_default.text = str(rt.get("person_account_default", "false")).lower()