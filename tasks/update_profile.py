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