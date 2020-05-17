*** Settings ***
Resource              robot/Crisis-Management/resources/CrisisManagement.robot
Library               DateTime
Suite Setup           Open Test Browser
Suite Teardown        Close Browser


*** Keywords ***

Get Instance URL
  ${orginfo}=             Get Org Info
  ${INSTANCE_URL}=        Pop From Dictionary     ${orginfo}                 instance_url
  Set Global Variable     ${INSTANCE_URL}         ${INSTANCE_URL}

Get MyDomain Name
  ${split_on_slash}=      Split String            ${INSTANCE_URL}            /
  ${split_on_dot}=        Split String            ${split_on_slash}[2]       .
  Set Global Variable     ${MYDOMAIN_NAME}        ${split_on_dot}[0]

Get Community ID
  ${community_info}=      Get Community Info      Traction Thrive
  ${community_id_18}=     Pop From Dictionary     ${community_info}          id
  ${community_id_15}=     Get Substring           ${community_id_18}         0   15
  Set Global Variable     ${COMMUNITY_ID}         ${community_id_15}

Switch Community Template To Traction Thrive
  # Go to Traction Thrive Community Template selection in Builder
  Go To                             https://${MYDOMAIN_NAME}.builder.salesforce-communities.com/sfsites/picasso/core/config/wizard.jsp?networkId=${COMMUNITY_ID}
  Click Element                     xpath: //*/div[1]/div[1][@class="cb-StartWizard-TemplateTitle cb-TemplateTile-header slds-grid"]

  # Click Get Started
  Wait Until Page Contains Element  //*/button[@title="Get Started"]
  Click Element                     //*/button[@title="Get Started"]

  # Name Community "Traction Thrive"
  Press Keys                        //*/input[@id="cb-StartWizard-propertyInput-Name"]    Traction Thrive

  # Click Create
  Click Element                     //*/button[@title="Create"]

  # Wait 10 Minutes for Template to Save
  Wait Until Page Contains          Add Metrics  timeout=10 minutes


*** Test Cases ***

Create Traction Thrive Community With Traction Thrive Template
  Get Instance URL
  Get MyDomain Name
  Get Community ID
  Switch Community Template To Traction Thrive
  # Go To                        ${INSTANCE_URL}/servlet/networks/switch?networkId=${COMMUNITY_ID}&startURL=%2FcommunitySetup%2FcwApp.app%23%2Fc%2Fpage%2Fsettings&
  # Wait Until Element Contains  //*/span[2][@class="zen-prs netx-fixedWidthText"]  Traction Thrive