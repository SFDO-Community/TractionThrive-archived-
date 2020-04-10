import json
from datetime import datetime
from simple_salesforce.exceptions import SalesforceMalformedRequest
from cumulusci.tasks.salesforce import BaseSalesforceApiTask
from cumulusci.core.exceptions import SalesforceException


class CreateCommunity(BaseSalesforceApiTask):
    api_version = "46.0"
    task_docs = """
    Create a Salesforce Community via the Connect API.
    Specify the `template` "VF Template" for Visualforce Tabs community,
    or the name for a specific desired template
    """
    task_options = {
        "template": {
            "description": "Name of the template for the community.",
            "required": True,
        },
        "name": {"description": "Name of the community.", "required": True},
        "description": {
            "description": "Description of the community.",
            "required": False,
        },
        "url_path_prefix": {
            "description": "URL prefix for the community.",
            "required": False,
        },
        "retries": {
            "description": "Number of times to retry community creation request",
            "default": 6,
        },
        "timeout": {
            "description": "Time to wait, in seconds, for the community to be created",
            "default": 300,
        },
    }

    def _init_options(self, kwargs):
        super(CreateCommunity, self)._init_options(kwargs)
        self.options["retries"] = int(self.options.get("retries", 6))
        self.options["timeout"] = int(self.options.get("timeout", 300))

    def _run_task(self):
        self.logger.info('Creating community "{}"'.format(self.options["name"]))
        self._try_create_community(0)

    def _try_create_community(self, tries):
        try:
            tries += 1
            self._create_community()
        except Exception as e:
            if tries > self.options["retries"]:
                raise
            else:
                self.logger.info("Retrying community creation request")
                self.poll_interval_s = 1
                self._try_create_community(tries)

    def _create_community(self):
        payload = {
            "name": self.options["name"],
            "description": self.options.get("description") or "",
            "templateName": self.options["template"],
            "urlPathPrefix": self.options.get("url_path_prefix") or "",
        }

        self.logger.info("Sending request to create Community")
        try:
            self.sf.restful("connect/communities", method="POST", data=json.dumps(payload))
        except SalesforceMalformedRequest as e:
            if "Error: A Community with this name already exists" in str(e):
                community_list = self.sf.restful("connect/communities")["communities"]
                communities = {c["name"]: c for c in community_list}
                self.poll_complete = True
                self.logger.info(
                    "Community {} created".format(communities[self.options["name"]]["id"])
                )
                return
            else:
                raise

        # Wait for the community to be created
        self.time_start = datetime.now()
        self._poll()

    def _poll_action(self):
        elapsed = datetime.now() - self.time_start
        if elapsed.total_seconds() > self.options["timeout"]:
            raise SalesforceException(
                "Community creation not finished after {timeout} seconds".format(
                    **self.options
                )
            )

        community_list = self.sf.restful("connect/communities")["communities"]
        communities = {c["name"]: c for c in community_list}
        # self.logger.info("name: " + self.options["name"] + " - communities: " + str(communities))
        if self.options["name"] in communities:
            self.poll_complete = True
            self.logger.info(
                "Community {} created".format(communities[self.options["name"]]["id"])
            )