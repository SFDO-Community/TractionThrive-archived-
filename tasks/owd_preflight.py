from cumulusci.tasks.salesforce import BaseSalesforceApiTask


class CheckOWDForObject(BaseSalesforceApiTask):
    task_options = {
        "sobject": {"description": "Name of the sObject to query.", "required": True},
        "internal_sharing_model": {"description": "Desired internal sharing model"},
        "external_sharing_model": {
            "description": "Desired external sharing model (where applicable)"
        },
    }

    def _run_task(self):
        sobject = self.options["sobject"]
        query = (
            f"SELECT ExternalSharingModel, InternalSharingModel "
            f"FROM EntityDefinition "
            f"WHERE QualifiedApiName = '{sobject}'"
        )

        result = self.sf.query(query)

        ret = False

        if result.get("records", []):
            rec = result["records"][0]
            target_internal = self.options.get("internal_sharing_model")
            target_external = self.options.get("external_sharing_model")
            actual_internal = rec["InternalSharingModel"]
            actual_external = rec.get("ExternalSharingModel")
            if (
                target_internal and actual_internal == target_internal
            ) or not target_internal:
                if (
                    target_external and actual_external == target_external
                ) or not target_external:
                    ret = True

            self.logger.info(
                f"Found sObject {sobject} to have internal sharing model {actual_internal} and external sharing model {actual_external}"
            )

        self.logger.info(f"Returning result {ret} from CheckOWDForObject")
        self.return_values = ret
