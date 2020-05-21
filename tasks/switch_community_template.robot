*** Settings ***
Resource              robot/Crisis-Management/resources/CrisisManagement.robot
Library               DateTime
Suite Setup           Open Test Browser
Suite Teardown        Capture Screenshot and Delete Records and Close Browser


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
  Go To Community Template               ${MYDOMAIN_NAME}    ${COMMUNITY_ID}
  Click Template Header                  Traction Thrive
  Click Template Button                  Get Started
  Wait For Template Name Input Page      Enter a Name
  Create Community Template              Traction Thrive    Create


*** Test Cases ***

Create Traction Thrive Community With Traction Thrive Template
  Get Instance URL
  Get MyDomain Name
  Get Community ID
  Switch Community Template To Traction Thrive