# Traction Thrive

![Traction Thrive Logo](https://github.com/SFDO-Community/TractionThrive/blob/master/assets/traction_thrive_logo-medium.png)

Traction Thrive is an application for hospitals and clinics to track and report on resources related to COVID-19 response. Created by Traction On Demand in partnership with Thrive Health and initially rolled out in British Columbia, now available as an open source managed package to maximize community collaboration.

For more information, please visit https://tractionondemand.com/traction-thrive/

## Development

### Requirements

Install the Salesforce CLI (sfdx), connect it to a DevHub, and set the config var `defaultdevhubusername`

Next, install CumulusCI per the instructions at https://cumulusci.readthedocs.io/en/latest/install.html

### Creating a development scratch org

* Run `cci flow run dev_org --org dev` to deploy this project.
* Run `cci org browser dev` to open the org in your browser.

### Creating a test scratch org

* Run `cci flow run qa_org --org qa` to deploy this project.
* Run `cci org browser qa` to open the org in your browser.