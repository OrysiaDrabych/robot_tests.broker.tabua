*** Settings ***
Library  String
Library  Selenium2Library
Library  tabua_service.py
Library  Collections
Library  BuiltIn


*** Variables ***

# Auction creation locators
${locator.title}                     id=prozorro_auction_title_ua                         # Lot number (name) according to DGF
${locator.description}               id=prozorro_auction_description_ua                   # Lot is going to be present on Auction
${locator.dgfid}                     id=prozorro_auction_dgf_id                           # dfgID field
${locator.value.amount}              id=prozorro_auction_value_attributes_amount          # Start Lot price
${locator.minimalStep.amount}        id=prozorro_auction_minimal_step_attributes_amount   # Minimal price step-up
${locator.guaranteeamount}           id=prozorro_auction_guarantee_attributes_amount      # Amount of Bank guarantee

${locator.delivery_zip}              xpath=//input[contains(@id, "prozorro_auction_items_attributes_") and contains(@id, "_postal_code")]
${locator.delivery_region}           xpath=//select[contains(@id, "prozorro_auction_items_attributes_") and contains(@id, "_region")]
${locator.delivery_country}          xpath=//select[contains(@id, "prozorro_auction_items_attributes_") and contains(@id, "_country_name")]
${locator.delivery_town}             xpath=//input[contains(@id, "prozorro_auction_items_attributes_") and contains(@id, "_locality")]
${locator.delivery_address}          xpath=//input[contains(@id, "prozorro_auction_items_attributes_") and contains(@id, "_street_address")]
${locator.add_item}                  xpath=//a[@class="button btn_white add_auction_item add_fields"]

${locator.publish}                     xpath=//input[@name="publish"]

${locator.tenderPeriod.endDate}           xpath=//span[@class="entry_submission_end_detail"]/span
${locator.view.minimalStep.amount}        xpath=//div[@class="blue_block"][2]//span[@class="amount"]

${locator.items[0].description}      css=div.small-7.columns.auction_description     # Description of Item (Lot in Auctions)
${locator.view.items[0].description}        xpath=//div[@class="columns blue_block items"]/ul/li[1]/div[@class="small-7 columns"]/div[@class="item_title"]
${locator.view.items[1].description}        xpath=//div[@class="columns blue_block items"]/ul/li[2]/div[@class="small-7 columns"]/div[@class="item_title"]
${locator.view.items[2].description}        xpath=//div[@class="columns blue_block items"]/ul/li[3]/div[@class="small-7 columns"]/div[@class="item_title"]

${locator.view.value.amount}                xpath=//span[@class="start_value_detail"]/span[@class="amount"]
${locator.view.minNumberOfQualifiedBids}    xpath=//div[@class="blue_block"][3]

${asset_index_0}    -1
${asset_index_1}    1
${asset_index_2}    0


# Asset creation locators
${locator.asset_title}                     id=prozorro_asset_title_ua
${locator.asset_description}               id=prozorro_asset_description_ua



*** Keywords ***

Підготувати клієнт для користувача
  [Arguments]  @{ARGUMENTS}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
  ...      ${ARGUMENTS[0]} ==  username
  ${alias}=   Catenate   SEPARATOR=   role_  ${ARGUMENTS[0]}
  Set Global Variable   ${BROWSER_ALIAS}   ${alias}
  Open Browser
  ...      ${USERS.users['${ARGUMENTS[0]}'].homepage}
  ...      ${USERS.users['${ARGUMENTS[0]}'].browser}
  ...      alias=${BROWSER_ALIAS}
  Set Window Size   @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Run Keyword If   '${ARGUMENTS[0]}' != 'tabua_Viewer'   Login    ${ARGUMENTS[0]}


Login
  [Arguments]  @{ARGUMENTS}
#  Logs in as Auction owner, who can create Fin auctions
  Wait Until Page Contains Element   id=user_password   20
  Input Text   id=user_email   ${USERS.users['${ARGUMENTS[0]}'].login}
  Input Text   id=user_password   ${USERS.users['${ARGUMENTS[0]}'].password}
  Click Element   xpath=//input[@type="submit"]
  Sleep     2
  Go To  ${BROKERS['tabua'].startpage}
  Wait Until Page Contains Element   xpath=//span[@class="button menu_btn is_logged"]   20
  Sleep     2
  Log To Console   Success logging in as Some one - ${ARGUMENTS[0]}


Оновити сторінку з тендером
  [Arguments]  ${user_name}  ${tender_id}
  Switch Browser	${BROWSER_ALIAS}
  Reload Page
  Sleep    3s

Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}  ${role_name}
  ${tender_data}=   update_test_data   ${role_name}   ${tender_data}
  [Return]   ${tender_data}

############# Small privatization #########

Оновити сторінку з об'єктом МП
  [Arguments]    ${user_name}    ${tender_uaid}
  Switch Browser	${BROWSER_ALIAS}
  Reload Page
  Sleep    3

Створити об'єкт МП
  [Arguments]  ${username}    ${tender_data}
  Log To Console    ${username}
  # Initialisation. Getting values from Dictionary
  Log To Console    Start creating procedure
  ${asset_title}=         Get From Dictionary   ${tender_data.data}    title
  ${asset_description}=   Get From Dictionary   ${tender_data.data}    description
  ${asset_decisions}=     Get From Dictionary   ${tender_data.data}    decisions
  ${asset_items}=         Get From Dictionary   ${tender_data.data}    items
  ${asset_holder}=        Get From Dictionary   ${tender_data.data}    assetHolder
  Go To  ${BROKERS['tabua'].assetpage}
  Wait Until Page Contains Element   xpath=//a[contains(text(), "Створити об'єкт")]   20
  Click Link                         xpath=//a[contains(text(), "Створити об'єкт")]
  Wait Until Page Contains Element   xpath=//input[@id="prozorro_asset_title_ua"]   20
# Input fields tender
  Input Text   ${locator.asset_title}              ${asset_title}
  Input Text   ${locator.asset_description}        ${asset_description}
# ======= Loop Input Decisions =======
  ${decisions_number}=   Get Length       ${asset_decisions}
  : FOR   ${INDEX}  IN RANGE    0    ${decisions_number}
  \    ${item}=    Get From List    ${asset_decisions}    ${INDEX}
  \    ${tile_id}=    get_decision_id   ${INDEX}    title
  \    ${title}=    Get From Dictionary         ${item}     title
  \    Input Text   xpath=//input[@id='${tile_id}']    ${title}
  \    ${id_id}=    get_decision_id   ${INDEX}    id
  \    ${id}=    Get From Dictionary         ${item}     decisionID
  \    Input Text   xpath=//input[@id='${id_id}']    ${id}
  \    ${date_id}=    get_decision_id   ${INDEX}    date
  \    ${date}=    Get From Dictionary         ${item}     decisionDate
  \    ${repair_date}=    repair_start_date    ${date}
  \    Input Text   xpath=//input[@id='${date_id}']    ${repair_date}
  \    ${substracted_decisions_number}=   substract    ${decisions_number}   1
  \    Run Keyword If   ${INDEX} < ${substracted_decisions_number}   Click Element     xpath=//a[@class='button btn_white add_auction_item add_fields']
  \    Sleep    2

# === Loop Try to select items info ===
  ${items_number}=   Get Length       ${asset_items}
  : FOR   ${INDEX}  IN RANGE    0    ${items_number}
  \    ${item}=    Get From List    ${asset_items}    ${INDEX}
  \    Додати наступний обєкт активу МП    ${item}
  \    ${substracted_items_number}=   substract    ${items_number}   1
  \    Run Keyword If   '${INDEX}' < '${substracted_items_number}'   Click Element     xpath=(//a[@class='button btn_white add_auction_item add_fields'])[last()]
  \    Sleep     3
# Add Asset Holder
  Click Element    xpath=//div[@class="same_address"]
  Sleep    3
  ${asset_holder_name}=        Get From Dictionary   ${asset_holder}               name
  ${asset_holder_id}=          Get From Dictionary   ${asset_holder.identifier}    id
  ${asset_holder_index}=       Get From Dictionary   ${asset_holder.address}       postalCode
  ${asset_holder_region}=      Get From Dictionary   ${asset_holder.address}       region
  ${asset_holder_locality}=    Get From Dictionary   ${asset_holder.address}       locality
  ${asset_holder_address}=     Get From Dictionary   ${asset_holder.address}       streetAddress
  ${asset_holder_pib}=         Get From Dictionary   ${asset_holder.contactPoint}       name
  ${asset_holder_phone}=       Get From Dictionary   ${asset_holder.contactPoint}       telephone
  ${asset_holder_email}=       Get From Dictionary   ${asset_holder.contactPoint}       email
  ${asset_holder_fax}=         Get From Dictionary   ${asset_holder.contactPoint}       faxNumber
  Input Text    xpath=//input[@id="prozorro_asset_holder_attributes_name_ua"]        ${asset_holder_name}
  Input Text    xpath=//input[@id="prozorro_asset_holder_attributes_code"]           ${asset_holder_id}
  Input Text    xpath=//input[@id="prozorro_asset_holder_attributes_postal_code"]    ${asset_holder_index}
  ${ah_region_name}=   get_region_name_asset_holder   ${asset_holder_region}
  Select From List By Value   xpath=//select[@id="prozorro_asset_holder_attributes_region"]    ${ah_region_name}
  Input Text    xpath=//input[@id="prozorro_asset_holder_attributes_locality"]          ${asset_holder_locality}
  Input Text    xpath=//input[@id="prozorro_asset_holder_attributes_street_address"]    ${asset_holder_address}
  Input Text    xpath=//input[@id="prozorro_asset_holder_attributes_contact_attributes_name_ua"]      ${asset_holder_pib}
  Input Text    xpath=//input[@id="prozorro_asset_holder_attributes_contact_attributes_telephone"]    ${asset_holder_phone}
  Input Text    xpath=//input[@id="prozorro_asset_holder_attributes_contact_attributes_email"]        ${asset_holder_email}
  Input Text    xpath=//input[@id="prozorro_asset_holder_attributes_contact_attributes_fax_number"]   ${asset_holder_fax}
# Save Auction - publish to CDB
  Click Element                      ${locator.publish}
  Sleep    5
  Wait Until Page Contains Element     xpath=//div[@class="blue_block top_border"]   60
# Get Ids
  : FOR   ${INDEX}  IN RANGE    1   15
  \   Sleep    3
  \   Wait Until Page Contains Element     xpath=//div[@class="blue_block top_border"]
  \   ${id_values}=      Get Webelements     xpath=//div[@class="blue_block top_border"]/div/div
  \   ${uid_val}=   Get Text    xpath=//div[@class="blue_block top_border"]/div/div[contains(@class, 'auction_ua_id')]
  \   ${TENDER_UAID}=   get_ua_id_asset   ${uid_val}
  \   Exit For Loop If  '${TENDER_UAID}' > '0'
  \   Sleep     30
  \   Reload Page
  Sleep    60
  [Return]  ${TENDER_UAID}

Додати наступний обєкт активу МП
  [Arguments]  ${item}
  ${item_description}=                  Get From Dictionary         ${item}              description
  ${item_quantity}=                     Get From Dictionary         ${item}              quantity
  ${unit}=                              Get From Dictionary         ${item}              unit
  ${unit_code}=                         Get From Dictionary         ${unit}              code
  ${classification}=                    Get From Dictionary         ${item}              classification
  ${classification_scheme}=             Get From Dictionary         ${classification}    scheme
  ${classification_id}=                 Get From Dictionary         ${classification}    id
  ${deliveryaddress}=                   Get From Dictionary         ${item}              address
  ${deliveryaddress_postalcode}=        Get From Dictionary         ${deliveryaddress}   postalCode
  ${deliveryaddress_countryname}=       Get From Dictionary         ${deliveryaddress}   countryName
  ${deliveryaddress_streetaddress}=     Get From Dictionary         ${deliveryaddress}   streetAddress
  ${deliveryaddress_region}=            Get From Dictionary         ${deliveryaddress}   region
  ${deliveryaddress_locality}=          Get From Dictionary         ${deliveryaddress}   locality
  ${registration_details}=              Get From Dictionary         ${item}              registrationDetails
  ${registration_status}=               Get From Dictionary         ${registration_details}     status

  ${item_descr_field}=   Get Webelements     xpath=//textarea[contains(@id, 'prozorro_asset_items_attributes_') and contains(@id, '_description_ua')]
  Input Text    ${item_descr_field[-1]}     ${item_description}
  ${item_quantity_field}=   Get Webelements     xpath=//input[contains(@id, 'prozorro_asset_items_attributes') and contains(@id, '_quantity')]
  ${item_quantity_string}      Convert To String    ${item_quantity}
  Input Text    ${item_quantity_field[-1]}           ${item_quantity_string}
  ${unit_name_field}=   Get Webelements     xpath=//select[contains(@id, 'prozorro_asset_items_attributes_') and contains(@id, '_unit_code')]
  Select From List By Value   ${unit_name_field[-1]}    ${unit_code}
# Selecting classifier
  Sleep   1
  ${classification_scheme_html_1} =    get_html_scheme_1    ${classification_scheme}
  ${classification_scheme_html} =    get_html_scheme    ${classification_scheme}
  ${cav_tag} =   Set Variable    ajax_block classification_type_${classification_scheme_html_1}
  ${classifier_field}=      Get Webelements     xpath=//span[@data-type="sp_codes"]
  Click Element     ${classifier_field[-1]}
  Sleep     5
  set_clacifier_find   ${classification_id}  ${classification_scheme_html}
  Sleep     2
  Click Element    xpath=//div[@class="ajax_block classification_type_sp_codes"]//span[@class='button btn_adding']
  Sleep     2
# Add delivery address
  ${delivery_zip_field}=   Get Webelements     xpath=//input[contains(@id, 'prozorro_asset_items_attributes_') and contains(@id, '_postal_code')]
  Input Text        ${delivery_zip_field[-1]}      ${deliveryaddress_postalcode}
  ${delivery_country_field}=   Get Webelements     xpath=//select[contains(@id, 'prozorro_asset_items_attributes_') and contains(@id, '_country_name')]
  Select From List By Value   ${delivery_country_field[-1]}    ${deliveryaddress_countryname}
  ${region_name}=   get_region_name   ${deliveryaddress_region}
  ${region_name_field}=   Get Webelements     xpath=//select[contains(@id, 'prozorro_asset_items_attributes_') and contains(@id, '_region')]
  Select From List By Value   ${region_name_field[-1]}    ${region_name}
  ${delivery_town_field}=   Get Webelements     xpath=//input[contains(@id, 'prozorro_asset_items_attributes_') and contains(@id, '_locality')]
  Input Text        ${delivery_town_field[-1]}     ${deliveryaddress_locality}
  ${delivery_address_field}=   Get Webelements     xpath=//input[contains(@id, 'prozorro_asset_items_attributes_') and contains(@id, '_street_address')]
  Input Text        ${delivery_address_field[-1]}  ${deliveryaddress_streetaddress}
  ${registration_status_field}=   Get Webelements     xpath=//select[contains(@id, 'prozorro_asset_items_attributes_') and contains(@id, '_registration_details_attributes_status')]
  Select From List By Value   ${registration_status_field[-1]}    ${registration_status}

set_clacifier_find
  [Arguments]       ${classification_id}  ${scheme}
  Input Text    xpath=//input[@name="search_classification"]    ${classification_id}
  Sleep   5
  Click Element     xpath=//label[starts-with(@for, "filtered_code_")]
  Sleep   5

Пошук об’єкта МП по ідентифікатору
  [Arguments]        ${user_name}    ${asset_uaid}
  Switch browser   ${BROWSER_ALIAS}
  :FOR   ${INDEX_N}  IN RANGE    1    15
  \   Go To  ${BROKERS['tabua'].assetpage}
  \   Wait Until Page Contains Element     id=aq  15
  \   Input Text        id=aq   ${asset_uaid}
  \   Sleep   3
  \   Click Element   xpath=//div[@class="columns search_button"]
  \   Sleep   3
  \   ${auc_on_page}=    Run Keyword And return Status    Wait Until Element Is Visible    xpath=//div[contains(@class, "columns auction_ua_id")]    10s
  \   Exit For Loop If    ${auc_on_page}
  \   Sleep   5
  \   Reload Page
  Sleep   3

Отримати інформацію із об'єкта МП
  [Arguments]     ${username}    ${tender_uaid}     ${field_name}
  Run Keyword If    '${username}' == 'tabua_Viewer'    Sleep    30
  tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${tender_uaid}
  Sleep   5
  Run Keyword And Return  Отримати інформацію про МП ${field_name}

Отримати інформацію про МП assetID
  ${return_value}=    Get Text    xpath=//div[@class="small-6 columns auction_ua_id"]
  [Return]    ${return_value}

Отримати інформацію про МП date
  ${uid}=    Get Text    xpath=//div[@class="small-6 columns auction_ua_id"]
  ${return_value}=    Get Element Attribute    xpath=//span[@class="entry_submission_start_detail"]@data-tender-start
  [Return]    ${return_value}

Отримати інформацію про МП rectificationPeriod.endDate
  ${return_value}=    Get Element Attribute    xpath=//span[@class="entry_submission_end_detail"]@data-enquiry_date
  [Return]    ${return_value}

Отримати інформацію про МП status
  ${status_elements} =    Get Webelements    xpath=//div[contains(@class, "small-4 columns auction_header_status status_")]/div
  ${status_elements_length}=    Get Length     ${status_elements}
  ${status}=   Run Keyword If  ${status_elements_length}==1
  ...          Get Text    ${status_elements[0]}
  ...          ELSE    Get Text    ${status_elements[1]}
  ${status}=    Convert To String    ${status}
  ${return_value}=    reflect_status    ${status}
  [Return]    ${return_value}

Отримати інформацію про МП title
  ${return_value}=    Get Text    xpath=//span[@class="auction_short_title_text"]
  [Return]    ${return_value}

Отримати інформацію про МП description
  ${return_value}=    Get Text    xpath=//div[@class="small-7 columns auction_description"]
  [Return]    ${return_value}

Отримати інформацію про МП decisions[0].title
  ${decision_elem}=    Get Webelements   xpath=//div[@class="decision_title"]
  ${return_value}=    Get Text    ${decision_elem[0]}
  [Return]    ${return_value}

Отримати інформацію про МП decisions[1].title
  ${decision_elem}=    Get Webelements   xpath=//div[@class="decision_title"]
  ${return_value}=    Get Text    ${decision_elem[0]}
  [Return]    ${return_value}

Отримати інформацію про МП decisions[0].decisionDate
  ${decision_elem}=    Get Webelements   xpath=//div[@class="columns blue_block items decisions"]//ul/li//div[@class="small-4 columns"]/div
  ${number_date}=    Get Text    ${decision_elem[-1]}
  ${return_value}=    get_decision_date    ${number_date}
  [Return]    ${return_value}

Отримати інформацію про МП decisions[1].decisionDate
  ${decision_elem}=    Get Webelements   xpath=//div[@class="columns blue_block items decisions"]//ul/li//div[@class="small-4 columns"]/div
  ${number_date}=    Get Text    ${decision_elem[0]}
  ${return_value}=    get_decision_date    ${number_date}
  [Return]    ${return_value}

Отримати інформацію про МП decisions[0].decisionID
  ${decision_elem}=    Get Webelements   xpath=//div[@class="columns blue_block items decisions"]//ul/li//div[@class="small-4 columns"]/div
  ${number_date}=    Get Text    ${decision_elem[-1]}
  ${return_value}=    get_decision_number    ${number_date}
  [Return]    ${return_value}

Отримати інформацію про МП decisions[1].decisionID
  ${decision_elem}=    Get Webelements   xpath=//div[@class="columns blue_block items decisions"]//ul/li//div[@class="small-4 columns"]/div
  ${number_date}=    Get Text    ${decision_elem[0]}
  ${return_value}=    get_decision_number    ${number_date}
  [Return]    ${return_value}

Отримати інформацію про МП assetHolder.name
  ${return_value}=    Get Text    xpath=//div[@class="small-7 columns"][3]//div[@class="small-10 columns"]
  [Return]    ${return_value}

Отримати інформацію про МП assetHolder.identifier.scheme
  ${return_value}=    Get Element Attribute    xpath=//div[@data-organization_scheme="UA-EDR"]@data-organization_scheme
  [Return]    ${return_value}

Отримати інформацію про МП assetHolder.identifier.id
  ${scheme_elements}=    Get Webelements    xpath=//div[@data-organization_scheme="UA-EDR"]
  ${return_value}=    Get Text    ${scheme_elements[1]}
  [Return]    ${return_value}

Отримати інформацію про МП assetCustodian.identifier.scheme
  ${return_value}=    Get Element Attribute    xpath=//div[@data-organization_scheme="UA-EDR"]@data-organization_scheme
  [Return]    ${return_value}

Отримати інформацію про МП assetCustodian.identifier.id
  ${scheme_elements}=    Get Webelements    xpath=//div[@data-organization_scheme="UA-EDR"]
  ${return_value}=    Get Text    ${scheme_elements[0]}
  [Return]    ${return_value}

Отримати інформацію про МП assetCustodian.identifier.legalName
  ${return_value}=    Get Text    xpath=//div[@class="small-7 columns"][2]//div[@class="small-10 columns"]
  [Return]    ${return_value}

Отримати інформацію про МП assetCustodian.contactPoint.name
  ${return_value}=    Get Text    xpath=//div[@class="columns blue_block"]//div[@class="small-10 columns"]
  [Return]    ${return_value}

Отримати інформацію про МП assetCustodian.contactPoint.telephone
  ${cust_elems} =    Get Webelements    xpath=//div[@class="columns blue_block"]//div[@class="small-10 columns"]
  ${return_value}=    Get Text    ${cust_elems[1]}
  [Return]    ${return_value}

Отримати інформацію про МП assetCustodian.contactPoint.email
  ${return_value}=    Get Text    xpath=//div[@class="columns blue_block"]//div[@class="small-10 columns"]/a
  [Return]    ${return_value}

Отримати документ
  [Arguments]  ${username}  ${asset_uaid}  ${doc_id}
  Sleep  10
  Reload Page
  Sleep   2
  Click Element    xpath=//div[@class="documents_tab tabs-title"]/a
  Sleep    5
  ${file_name}=   Get Text   xpath=//a[contains(text(), '${doc_id}')]
  Sleep  5
  ${url}=   Get Element Attribute   xpath=//a[contains(text(), '${doc_id}')]@href
  download_file   ${url}  ${file_name}  ${OUTPUT_DIR}
  [Return]  ${file_name}

Отримати інформацію про МП documents[0].documentType
  Click Element    xpath=//div[@class="documents_tab tabs-title"]/a
  ${doc_type}=    Get Text    xpath=//div[@class="document_description"]/div[@class="document_link"]/a
  ${return_value}=    convert_doc_type    ${doc_type}
  [Return]    ${return_value}

Отримати інформацію з активу об'єкта МП
  [Arguments]  ${username}  ${asset_uaid}  ${item_id}  ${field_name}
  tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${tender_uaid}
  ${return_value}=   Run KeyWord   Отримати інформацію про МП items[0].${field_name}
  [Return]  ${return_value}

Отримати інформацію про МП items[${item_id}].description
  ${descr_elements}=    Get Webelements    xpath=//div[@class="item_title"]
  ${return_value}=    Get Text   ${descr_elements[${item_id}]}
  [Return]  ${return_value}

Отримати інформацію про МП items[${item_id}].classification.scheme
  ${return_value}=    Get Element Attribute   xpath=//div[@class="item_classificator"]@data-classification_scheme
  [Return]  ${return_value}

Отримати інформацію про МП items[${item_id}].classification.id
  ${return_value}=    Get Element Attribute   xpath=//div[@class="item_classificator"]@data-classification_code
  [Return]  ${return_value}

Отримати інформацію про МП items[${item_id}].unit.name
  ${unit_elements}=    Get Webelements    xpath=//div[@class="small-10 small-offset-2 columns"]/span
  ${unit}=    Get Text   ${unit_elements[${item_id}]}
  ${unitname}=    split_space    ${unit}    1
  ${return_value}=    get_select_unit_name    ${unitname}
  [Return]  ${return_value}

Отримати інформацію про МП items[${item_id}].quantity
  ${unit_elements}=    Get Webelements    xpath=//div[@class="small-10 small-offset-2 columns"]/span
  ${unit}=    Get Text   ${unit_elements[${item_id}]}
  ${quantity}=    split_space    ${unit}    0
  ${return_value}=    Convert To Number    ${quantity}
  [Return]  ${return_value}

Отримати інформацію про МП items[${item_id}].registrationDetails.status
  ${status}=    Get Text   xpath=//span[@class="item_registration_status"]
  ${return_value}=    convert_item_status    ${status}
  [Return]  ${return_value}

Отримати інформацію про МП dateModified
  ${return_value}=   Get Element Attribute   xpath=//div[@class="enquiry_until_date"]@data-last_editing_date
  [Return]  ${return_value}

Отримати інформацію про МП lotID
  ${return_value}=    Get Text    xpath=//div[@class="small-6 columns auction_ua_id"]
  [Return]    ${return_value}

Отримати інформацію про МП assets
  ${return_value}=    Get Text    xpath=//div[@class="small-6 columns auction_ua_id"]
  [Return]    ${return_value}

Отримати інформацію про МП lotHolder.name
  ${return_value}=    Get Text    xpath=//div[@class="small-7 columns"][3]//div[@class="small-10 columns"]
  [Return]    ${return_value}

Отримати інформацію про МП lotHolder.identifier.scheme
  ${return_value}=    Get Element Attribute    xpath=//div[@data-organization_scheme="UA-EDR"]@data-organization_scheme
  [Return]    ${return_value}

Отримати інформацію про МП lotHolder.identifier.id
  ${scheme_elements}=    Get Webelements    xpath=//div[@data-organization_scheme="UA-EDR"]
  ${return_value}=    Get Text    ${scheme_elements[1]}
  [Return]    ${return_value}

Отримати інформацію про МП lotCustodian.identifier.scheme
  ${return_value}=    Get Element Attribute    xpath=//div[@data-organization_scheme="UA-EDR"]@data-organization_scheme
  [Return]    ${return_value}

Отримати інформацію про МП lotCustodian.identifier.id
  ${scheme_elements}=    Get Webelements    xpath=//div[@data-organization_scheme="UA-EDR"]
  ${return_value}=    Get Text    ${scheme_elements[0]}
  [Return]    ${return_value}

Отримати інформацію про МП lotCustodian.identifier.legalName
  ${return_value}=    Get Text    xpath=//div[@class="small-7 columns"][2]//div[@class="small-10 columns"]
  [Return]    ${return_value}

Отримати інформацію про МП lotCustodian.contactPoint.name
  ${return_value}=    Get Text    xpath=//div[@class="columns blue_block"]//div[@class="small-10 columns"]
  [Return]    ${return_value}

Отримати інформацію про МП lotCustodian.contactPoint.telephone
  ${cust_elems} =    Get Webelements    xpath=//div[@class="columns blue_block"]//div[@class="small-10 columns"]
  ${return_value}=    Get Text    ${cust_elems[1]}
  [Return]    ${return_value}

Отримати інформацію про МП lotCustodian.contactPoint.email
  ${return_value}=    Get Text    xpath=//div[@class="columns blue_block"]//div[@class="small-10 columns"]/a
  [Return]    ${return_value}

Отримати інформацію про МП auctions[0].procurementMethodType
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${auction_type}=    Get Text    xpath=//div[@class="blue_block auction_1"]/div[@class="auction_tab_subtitle bottom_border"]
  ${return_value}=    convert_nt_string_to_common_string    ${auction_type}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[1].procurementMethodType
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${auction_type}=    Get Text    xpath=//div[@class="blue_block auction_2"]/div[@class="auction_tab_subtitle bottom_border"]
  ${return_value}=    convert_nt_string_to_common_string    ${auction_type}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[2].procurementMethodType
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${auction_type}=    Get Text    xpath=//div[@class="blue_block auction_3"]/div[@class="auction_tab_subtitle bottom_border"]
  ${return_value}=    convert_nt_string_to_common_string    ${auction_type}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[0].status
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Element Attribute    xpath=//div[@class="blue_block auction_1"]//div[@class="small-6 columns status"]@data-status
  [Return]    ${return_value}

Отримати інформацію про МП auctions[1].status
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Element Attribute    xpath=//div[@class="blue_block auction_2"]//div[@class="small-6 columns status"]@data-status
  [Return]    ${return_value}

Отримати інформацію про МП auctions[2].status
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Element Attribute    xpath=//div[@class="blue_block auction_3"]//div[@class="small-6 columns status"]@data-status
  [Return]    ${return_value}

Отримати інформацію про МП auctions[0].tenderAttempts
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Element Attribute    xpath=//div[@class="blue_block auction_1"]@data-tender_attempts
  ${return_value}=    Convert To Integer    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[1].tenderAttempts
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Element Attribute    xpath=//div[@class="blue_block auction_2"]@data-tender_attempts
  ${return_value}=    Convert To Integer    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[2].tenderAttempts
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Element Attribute    xpath=//div[@class="blue_block auction_3"]@data-tender_attempts
  ${return_value}=    Convert To Integer    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[0].value.amount
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Text    xpath=//div[@class="blue_block auction_1"]//div[@class="small-6 columns value_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[1].value.amount
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Text    xpath=//div[@class="blue_block auction_2"]//div[@class="small-6 columns value_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[2].value.amount
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Text    xpath=//div[@class="blue_block auction_3"]//div[@class="small-6 columns value_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[0].minimalStep.amount
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Text    xpath=//div[@class="blue_block auction_1"]//div[@class="small-6 columns minimal_step_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[1].minimalStep.amount
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Text    xpath=//div[@class="blue_block auction_2"]//div[@class="small-6 columns minimal_step_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[2].minimalStep.amount
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Set Variable    0
  ${return_value}=    Convert To Number    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[0].guarantee.amount
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Text    xpath=//div[@class="blue_block auction_1"]//div[@class="small-6 columns guarantee_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[1].guarantee.amount
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Text    xpath=//div[@class="blue_block auction_2"]//div[@class="small-6 columns guarantee_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[2].guarantee.amount
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Text    xpath=//div[@class="blue_block auction_3"]//div[@class="small-6 columns guarantee_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[0].registrationFee.amount
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Text    xpath=//div[@class="blue_block auction_1"]//div[@class="small-6 columns fee_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[1].registrationFee.amount
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Text    xpath=//div[@class="blue_block auction_2"]//div[@class="small-6 columns fee_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[2].registrationFee.amount
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Text    xpath=//div[@class="blue_block auction_3"]//div[@class="small-6 columns fee_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]    ${return_value}

Отримати інформацію про МП auctions[1].tenderingDuration
  ${return_value}=    Get Element Attribute    xpath=//div[contains(@class, "tendering_duration")]@data-tendering_duration
  [Return]    ${return_value}

Отримати інформацію про МП auctions[2].tenderingDuration
  ${return_value}=    Get Element Attribute    xpath=//div[contains(@class, "tendering_duration")]@data-tendering_duration
  [Return]    ${return_value}

Отримати інформацію про МП auctions[0].auctionPeriod.startDate
  Sleep    3
  Click Element    xpath=//a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    3
  ${return_value}=    Get Element Attribute    xpath=//div[@class="blue_block auction_1"]//div[@class="small-6 columns auction_start_date"]@data-auction_start_date
  [Return]    ${return_value}

###############################

Завантажити ілюстрацію в об'єкт МП
  [Arguments]     ${username}    ${tender_uaid}    ${filepath}
  ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible	xpath=//a[text()[contains(.,'Змінити')]]	10s
  Run Keyword If    ${at_auc_page}    Click Element    xpath=//a[text()[contains(.,'Змінити')]]
  Wait Until Element Is Visible	    xpath=//div[text()[contains(.,"Редагування об’єкта")]]    10
  ${add_doc_button}=   Get Webelements     xpath=//a[@class="button btn_white documents_add add_fields"]
  Click Element       ${add_doc_button[-1]}
  Choose File       xpath=//input[@type="file"]        ${file_path}
  Sleep   5
  Click Element     xpath=//input[@name="publish"]
  Sleep   5

Завантажити документ в об'єкт МП з типом
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${doc_type}
  tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${tender_uaid}
  ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible	xpath=//a[text()[contains(.,'Змінити')]]	10s
  Run Keyword If    ${at_auc_page}    Click Element    xpath=//a[text()[contains(.,'Змінити')]]
  Sleep    20
  Wait Until Element Is Visible	    xpath=//div[text()[contains(.,"Редагування об’єкта")]]    10
  ${add_doc_button}=   Get Webelements     xpath=//a[@class="button btn_white documents_add add_fields"]
  Click Element       ${add_doc_button[-2]}
  Choose File       xpath=//input[@type="file"]        ${file_path}
  Sleep   5
  Click Element     xpath=//input[@name="publish"]
  Sleep   20
  Reload Page
  Sleep    5

################################

Внести зміни в об'єкт МП
  [Arguments]  ${username}    ${tender_uaid}    ${fieldname}    ${fieldvalue}
  tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${tender_uaid}
  ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible    xpath=//div[text()[contains(.,"Редагування об’єкта")]]    10s
  tabua.Перейти на сторінку зміни параметрів активу   ${fieldname}    ${fieldvalue}
  Sleep    30

Перейти на сторінку зміни параметрів активу
  [Arguments]    ${fieldname}    ${fieldvalue}
  Click Element   xpath=//a[text()[contains(.,'Змінити')]]
  Wait Until Element Is Visible    xpath=//div[text()[contains(.,"Редагування об’єкта")]]    10
  Перевірити доступність зміни і змінити актив    ${fieldname}    ${fieldvalue}

Перевірити доступність зміни і змінити актив
  [Arguments]    ${field}	 ${value}
  ${avail_change}=    Run Keyword And return Status    Wait Until Element Is Visible	xpath=//div[text()[contains(.,"Редагування об’єкта")]]	10s
  Sleep  5
  Run Keyword    Змінити МП ${field}    ${value}
  Click Element     xpath=//input[@name="publish"]
  Sleep  60
  Reload Page
  Sleep  30

Змінити МП title
    [Arguments]    ${value}
    Sleep    2
    Input text    xpath=//input[@id="prozorro_asset_title_ua"]    ${value}

Змінити МП description
    [Arguments]    ${value}
    Sleep    2
    Input text    xpath=//textarea[@id="prozorro_asset_description_ua"]    ${value}

Внести зміни в актив об'єкта МП
    [Arguments]  ${username}  ${item_id}  ${asset_uaid}  ${field}  ${value}
    tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}
    ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible    xpath=//div[text()[contains(.,"Редагування об’єкта")]]    10s
    Click Element   xpath=//a[text()[contains(.,'Змінити')]]
    Wait Until Element Is Visible    xpath=//div[text()[contains(.,"Редагування об’єкта")]]    10
    Sleep   2
    Run KeyWord  Внести зміни в актив об'єкта МП поле ${field}    ${value}
    Sleep   2
    Click Element     xpath=//input[@name="publish"]
    Sleep   60
    Reload Page
    Sleep  30

Внести зміни в актив об'єкта МП поле quantity
    [Arguments]  ${value}
    ${fieldvalue}=    Convert To String    ${value}
    Input text    xpath=//input[contains(@id, 'prozorro_asset_items_attributes') and contains(@id, '_quantity')]    ${fieldvalue}
    Sleep    5

Внести зміни в актив об'єкта МП поле description
    [Arguments]  ${value}
    Input text    xpath=//textarea[contains(@id, 'prozorro_asset_items_attributes') and contains(@id, '_description_ua')]    ${value}

Внести зміни в актив об'єкта МП поле registrationDetails.status
    [Arguments]  ${value}
    ${registration_status_field}=   Get Webelements     xpath=//select[contains(@id, 'prozorro_asset_items_attributes_') and contains(@id, '_registration_details_attributes_status')]
    Select From List By Value   ${registration_status_field[-1]}    ${value}

Отримати кількість активів в об'єкті МП
    [Arguments]    ${username}    ${asset_uaid}
    tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}
    Sleep    5
    ${items}=   Get Webelements    xpath=//div[@class="columns blue_block items"]/ul/li
    ${return_value}=    Get Length     ${items}
    [Return]  ${return_value}

Додати актив до об'єкта МП
    [Arguments]  ${username}  ${asset_uaid}  ${item}
    Sleep    30
    tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}
    ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible    xpath=//div[text()[contains(.,"Редагування об’єкта")]]    10s
    Click Element   xpath=//a[text()[contains(.,'Змінити')]]
    Wait Until Element Is Visible    xpath=//div[text()[contains(.,"Редагування об’єкта")]]    10
    Sleep   2
    Click Element     xpath=(//a[@class='button btn_white add_auction_item add_fields'])[last()]
    Sleep   5
    Додати наступний обєкт активу МП    ${item}
    Sleep    3
    Click Element     xpath=//input[@name="publish"]
    Sleep   60
    tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}

Завантажити документ для видалення об'єкта МП
    [Arguments]  ${username}  ${asset_uaid}  ${file_path}
    tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}
    Sleep   5
    Click Element   xpath=//div[@class="button warning asset_cancel"]
    Wait Until Element Is Visible    xpath=//input[@value="Виключити з переліку"]    10
    Click Element       xpath=//a[@class="button btn_white documents_add add_fields"]
    Choose File       xpath=//input[@type="file"]        ${file_path}
    Sleep   5
    Click Element     xpath=//input[@value="Виключити з переліку"]
    Sleep   60
    tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}

Видалити об'єкт МП
    [Arguments]  ${username}  ${asset_uaid}
    tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}
    Sleep   5
    Click Element    xpath=//div[@class="documents_tab tabs-title"]/a
    Sleep    5
    ${cancel_details}=   Get Text   xpath=//div[contains(text(), 'Підстава для скасування')]
    Sleep    2
    Click Element    xpath=//div[@class="main_tab tabs-title"]/a
    Sleep    5
    tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}

################# LOT #################

Створити лот
    [Arguments]    ${username}  ${tender_data}  ${asset_uaid}
    tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}
    Sleep   5
    Click Element    xpath=//div[@class="auction_buttons"]/a
    Wait Until Page Contains Element   id=new_prozorro_lot_   20
    ${repair_date}=    repair_start_date    ${tender_data.data.decisions[0].decisionDate}
    Input Text    xpath=//input[contains(@id, "prozorro_lot_decisions_attributes_") and contains(@id, "_title_ua")]     ${tender_data.data.lotType}
    Input Text    xpath=//input[contains(@id, "prozorro_lot_decisions_attributes_") and contains(@id, "_decision_id")]      ${tender_data.data.decisions[0].decisionID}
    Input Text    xpath=//input[contains(@id, "prozorro_lot_decisions_attributes_") and contains(@id, "_date")]      ${repair_date}
    Sleep    2
    Click Element    xpath=//input[@name="publish"]
    Sleep    5
    Wait Until Page Contains Element     xpath=//div[@class="blue_block top_border"]   60
    ${LOT_UAID}=   Get Text    xpath=//div[@class="blue_block top_border"]/div/div[@class="small-6 columns auction_ua_id"]
    [Return]  ${LOT_UAID}

Пошук лоту по ідентифікатору
    [Arguments]  ${username}  ${lot_uaid}
    Switch browser   ${BROWSER_ALIAS}
    :FOR   ${INDEX_N}  IN RANGE    1    15
    \   Go To  ${BROKERS['tabua'].lotpage}
    \   Wait Until Page Contains Element     id=lq  15
    \   Input Text        id=lq   ${lot_uaid}
    \   Sleep   3
    \   Click Element   xpath=//div[@class="columns search_button"]
    \   Sleep   3
    \   ${auc_on_page}=    Run Keyword And return Status    Wait Until Element Is Visible    xpath=//div[contains(@class, "columns auction_ua_id")]    10s
    \   Exit For Loop If    ${auc_on_page}
    \   Sleep   5
    \   Reload Page
    Sleep   3

Додати умови проведення аукціону
  [Arguments]    ${username}    ${auction}    ${index}    ${lot_uaid}
  tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
  Sleep    2
  Run KeyWord  Додати умови проведення аукціону номер ${index}    ${username}    ${lot_uaid}    ${auction}

Додати умови проведення аукціону номер 0
  [Arguments]    ${username}    ${lot_uaid}   ${auction}
  Click Link    xpath=//a[contains(text(), "Уточнити та активувати")]
  ${start_price}=    Convert To String    ${auction.value.amount}
  Input Text    id=prozorro_lot_lot_auctions_attributes_0_value_attributes_amount    ${start_price}
  ${value_valueaddedtaxincluded}=  Convert To String  ${auction.value.valueAddedTaxIncluded}
  ${guarantee_amount}=    Convert To String    ${auction.guarantee.amount}
  Input Text    id=prozorro_lot_lot_auctions_attributes_0_guarantee_attributes_amount    ${guarantee_amount}
  ${registrationFee}=  Convert To String  ${auction.registrationFee.amount}
  ${minimalStep}=  Convert To String  ${auction.minimalStep.amount}
  Input Text  id=prozorro_lot_lot_auctions_attributes_0_minimal_step_attributes_amount  ${minimalStep}
  ${treasure_account}=    Convert To String    ${auction.bankAccount.description}
  Input Text  id=prozorro_lot_lot_auctions_attributes_0_bank_description  ${treasure_account}
  ${bank_name}=    Convert To String    ${auction.bankAccount.bankName}
  Input Text  id=prozorro_lot_lot_auctions_attributes_0_bank_name  ${bank_name}
  ${bank_edrpou}=    Set Variable    00032129
  Input Text  id=prozorro_lot_lot_auctions_attributes_0_bank_data_attributes_0_code  ${bank_edrpou}
  ${bank_mfo}=    Set Variable    300465
  Input Text  id=prozorro_lot_lot_auctions_attributes_0_bank_data_attributes_1_code  ${bank_mfo}
  ${account_id}=    Set Variable    6944936700
  Input Text  id=prozorro_lot_lot_auctions_attributes_0_bank_data_attributes_2_code  ${account_id}
  ${start_date}=    add_five_days    ${auction.auctionPeriod.startDate}
  Input Text  id=prozorro_lot_lot_auctions_attributes_0_auction_period_attributes_start_date  ${start_date}
  Sleep    2
  Click Element    xpath=//input[@name="publish"]
  Sleep    120
  Reload Page
  Sleep    10

Додати умови проведення аукціону номер 1
  [Arguments]  ${username}  ${lot_uaid}  ${auction}
  Click Link    xpath=//a[contains(text(), "Змінити")]
  Sleep    1
  ${duration_period}=    get_duration_period    ${auction.tenderingDuration}
  Input Text  id=prozorro_lot_lot_auctions_attributes_1_tendering_duration    ${duration_period}
  Sleep    1
  Click Element    xpath=//input[@name="publish"]
  Sleep    2

Оновити сторінку з лотом
    [Arguments]  ${username}  ${lot_uaid}
    Switch Browser	${BROWSER_ALIAS}
    tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
    Reload Page
    Sleep    3

Отримати інформацію із лоту
    [Arguments]  ${username}  ${lot_uaid}  ${field_name}
    tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
    ${return_value}=  Run Keyword    Отримати інформацію про МП ${fieldname}
    [Return]  ${return_value}

Отримати інформацію з активу лоту
  [Arguments]  ${username}  ${lot_uaid}  ${item_id}  ${field_name}
  tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
  ${return_value}=   Run KeyWord   Отримати інформацію про МП items[0].${field_name}
  [Return]  ${return_value}

############################

Завантажити ілюстрацію в лот
  [Arguments]  ${username}  ${lot_uaid}  ${filepath}
  tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
  Sleep   2
  Click Element    xpath=//a[text()[contains(.,'Змінити')]]
  Wait Until Element Is Visible	    xpath=//div[text()[contains(.,'Редагування інформаційного повідомлення')]]    10
  ${add_doc_button}=   Get Webelements     xpath=//a[@class="button btn_white documents_add add_fields"]
  Click Element       ${add_doc_button[-1]}
  Choose File       xpath=//input[@type="file"]        ${filepath}
  Sleep   5
  Click Element     xpath=//input[@name="publish"]
  Sleep   5

Завантажити документ в лот з типом
  [Arguments]  ${username}  ${lot_uaid}  ${filepath}  ${document_type}
  tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
  ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible	xpath=//a[text()[contains(.,'Змінити')]]	10s
  Run Keyword If    ${at_auc_page}    Click Element    xpath=//a[text()[contains(.,'Змінити')]]
  Sleep    2
  Wait Until Element Is Visible	    xpath=//div[text()[contains(.,'Редагування інформаційного повідомлення')]]    10
  ${add_doc_button}=   Get Webelements     xpath=//a[@class="button btn_white documents_add add_fields"]
  Click Element       ${add_doc_button[-2]}
  Choose File       xpath=//input[@type="file"]        ${filepath}
  Sleep   20
  ${document_type_field}=   Get Webelements     xpath=//select[contains(@id, 'prozorro_lot_documents_attributes_') and contains(@id, '_document_type')]
  ${document_type_value}=    correct_document_type_value    ${document_type}
  Sleep    1
  Select From List By Value   ${document_type_field[-1]}    ${document_type_value}
  Sleep   10
  Click Element     xpath=//input[@name="publish"]
  Sleep   3
  Reload Page
  Sleep    1

Завантажити документ в умови проведення аукціону
  [Arguments]  ${username}  ${lot_uaid}  ${filepath}  ${documentType}  ${auction_index}
  tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
  ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible	xpath=//a[text()[contains(.,'Змінити')]]	10s
  Run Keyword If    ${at_auc_page}    Click Element    xpath=//a[text()[contains(.,'Змінити')]]
  Sleep    2
  Wait Until Element Is Visible	    xpath=//div[text()[contains(.,'Редагування інформаційного повідомлення')]]    10
  ${add_doc_button}=   Get Webelements     xpath=//a[@class="button btn_white documents_add add_fields"]
  Click Element       ${add_doc_button[-2]}
  Choose File       xpath=//input[@type="file"]        ${filepath}
  Sleep   20
  ${document_type_field}=   Get Webelements     xpath=//select[contains(@id, 'prozorro_lot_documents_attributes_') and contains(@id, '_document_type')]
  ${document_type_value}=    correct_document_type_value    ${document_type}
  Sleep    1
  Select From List By Value   ${document_type_field[-1]}    ${document_type_value}
  Sleep   10
  Click Element     xpath=//input[@name="publish"]
  Sleep   3
  Reload Page
  Sleep    1

Внести зміни в лот
  [Arguments]  ${username}  ${lot_uaid}  ${fieldname}  ${fieldvalue}
  Sleep    1
  Click Link    xpath=//a[contains(text(), "Змінити")]
  Sleep    1
  Run KeyWord  Внести зміни в лот поле ${fieldname}  ${fieldvalue}
  Sleep    1
  Click Element    xpath=//input[@name="publish"]
  Sleep    5

Внести зміни в лот поле title
  [Arguments]  ${fieldvalue}
  Sleep    5
  Input Text    xpath=//input[@id="prozorro_lot_title_ua"]     ${fieldvalue}
  Sleep    15

Внести зміни в лот поле description
  [Arguments]  ${fieldvalue}
  Input Text    xpath=//textarea[@id="prozorro_lot_description_ua"]     ${fieldvalue}

Внести зміни в актив лоту
  [Arguments]  ${username}  ${item_id}  ${lot_uaid}  ${fieldname}  ${fieldvalue}
  Sleep    1
  Click Link    xpath=//a[contains(text(), "Змінити")]
  Sleep    1
  Run KeyWord  Внести зміни в актив лоту поле ${fieldname}  ${fieldvalue}
  Sleep    1
  Click Element    xpath=//input[@name="publish"]
  Sleep    5

Внести зміни в актив лоту поле quantity
  [Arguments]  ${fieldvalue}
  ${fieldvalue}=    Convert To String    ${fieldvalue}
  Input Text    xpath=//input[@id="prozorro_lot_items_attributes_0_quantity"]     ${fieldvalue}

Внести зміни в умови проведення аукціону
  [Arguments]  ${username}  ${lot_uaid}  ${fieldname}  ${fieldvalue}  ${auc_num}
  Sleep    1
  Click Link    xpath=//a[contains(text(), "Змінити")]
  Sleep    1
  Run KeyWord  Внести зміни в умови проведення аукціону поле ${fieldname}  ${fieldvalue}
  Sleep    1
  Click Element    xpath=//input[@name="publish"]
  Sleep    5

Внести зміни в умови проведення аукціону поле value.amount
  [Arguments]  ${fieldvalue}
  ${fieldvalue}=    Convert To String    ${fieldvalue}
  Input Text    xpath=//input[@id="prozorro_lot_lot_auctions_attributes_0_value_attributes_amount"]     ${fieldvalue}

Внести зміни в умови проведення аукціону поле minimalStep.amount
  [Arguments]  ${fieldvalue}
  ${fieldvalue}=    Convert To String    ${fieldvalue}
  Input Text    xpath=//input[@id="prozorro_lot_lot_auctions_attributes_0_minimal_step_attributes_amount"]     ${fieldvalue}

Внести зміни в умови проведення аукціону поле guarantee.amount
  [Arguments]  ${fieldvalue}
  ${fieldvalue}=    Convert To String    ${fieldvalue}
  Input Text    xpath=//input[@id="prozorro_lot_lot_auctions_attributes_0_guarantee_attributes_amount"]     ${fieldvalue}

Внести зміни в умови проведення аукціону поле registrationFee.amount
  [Arguments]  ${fieldvalue}
  ${fieldvalue}=    Convert To String    ${fieldvalue}
  Input Text    xpath=//input[@id="prozorro_lot_lot_auctions_attributes_0_fee_attributes_amount"]     ${fieldvalue}

Внести зміни в умови проведення аукціону поле auctionPeriod.startDate
  [Arguments]  ${fieldvalue}
  Input Text    xpath=//input[@id="prozorro_lot_lot_auctions_attributes_0_auction_period_attributes_start_date"]     ${fieldvalue}

######################### DELETE LOT ######################
Завантажити документ для видалення лоту
    [Arguments]  ${username}  ${lot_uaid}  ${filepath}
    tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
    Sleep   5
    Click Element     xpath=//div[@class="button warning asset_cancel"]
    Sleep   2
    Wait Until Element Is Visible    xpath=//input[@value="Виключити з переліку"]    10
    Click Element       xpath=//a[@class="button btn_white documents_add add_fields"]
    Choose File       xpath=//input[@type="file"]        ${file_path}
    Sleep   5
    Click Element     xpath=//input[@value="Виключити з переліку"]
    Sleep   60
    tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}


Видалити лот
    [Arguments]  ${username}  ${lot_uaid}
    tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
    Sleep   5
    Click Element    xpath=//div[@class="documents_tab tabs-title"]/a
    Sleep    5
    ${cancel_details}=   Get Text   xpath=//div[contains(text(), 'Підстава для скасування')]
    Sleep    2
    Click Element    xpath=//div[@class="main_tab tabs-title"]/a
    Sleep    5
    tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}