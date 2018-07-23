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

${locator.publish}                     //input[@name="publish"]

${locator.tenderPeriod.endDate}           //span[@class="entry_submission_end_detail"]/span
${locator.view.minimalStep.amount}        //div[@class="blue_block"][2]//span[@class="amount"]

${locator.items[0].description}      css=div.small-7.columns.auction_description     # Description of Item (Lot in Auctions)
${locator.view.items[0].description}        //div[@class="columns blue_block items"]/ul/li[1]/div[@class="small-7 columns"]/div[@class="item_title"]
${locator.view.items[1].description}        //div[@class="columns blue_block items"]/ul/li[2]/div[@class="small-7 columns"]/div[@class="item_title"]
${locator.view.items[2].description}        //div[@class="columns blue_block items"]/ul/li[3]/div[@class="small-7 columns"]/div[@class="item_title"]

${locator.view.value.amount}                //span[@class="start_value_detail"]/span[@class="amount"]
${locator.view.minNumberOfQualifiedBids}    //div[@class="blue_block"][3]

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
  Click Element   //input[@type="submit"]
  Sleep     2
  Go To  ${BROKERS['tabua'].startpage}
  Wait Until Page Contains Element   //span[@class="button menu_btn is_logged"]   20
  Sleep     2
  Log To Console   Success logging in as Some one - ${ARGUMENTS[0]}${\n}


Оновити сторінку з тендером
  [Arguments]  ${user_name}  ${tender_id}
  Switch Browser	${BROWSER_ALIAS}
  Reload Page
  Sleep    3

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
  Log To Console    ${\n}${username}${\n}
  # Initialisation. Getting values from Dictionary
  Log To Console    Start creating procedure
  ${asset_title}=         Get From Dictionary   ${tender_data.data}    title
  ${asset_description}=   Get From Dictionary   ${tender_data.data}    description
  ${asset_decisions}=     Get From Dictionary   ${tender_data.data}    decisions
  ${asset_items}=         Get From Dictionary   ${tender_data.data}    items
  ${asset_holder}=        Get From Dictionary   ${tender_data.data}    assetHolder
  Go To  ${BROKERS['tabua'].assetpage}
  Wait Until Page Contains Element   //a[contains(text(), "Створити об'єкт")]   20
  Click Link                         //a[contains(text(), "Створити об'єкт")]
  Wait Until Page Contains Element   //input[@id="prozorro_asset_title_ua"]   20
  # Input fields tender
  Input Text   ${locator.asset_title}              ${asset_title}
  Input Text   ${locator.asset_description}        ${asset_description}
  # ======= Loop Input Decisions =======
  ${decisions_number}=   Get Length       ${asset_decisions}
  : FOR   ${INDEX}  IN RANGE    0    ${decisions_number}
  \    ${item}=    Get From List    ${asset_decisions}    ${INDEX}
  \    ${tile_id}=    get_decision_id   ${INDEX}    title
  \    ${title}=    Get From Dictionary         ${item}     title
  \    Input Text   //input[@id='${tile_id}']    ${title}
  \    ${id_id}=    get_decision_id   ${INDEX}    id
  \    ${id}=    Get From Dictionary         ${item}     decisionID
  \    Input Text   //input[@id='${id_id}']    ${id}
  \    ${date_id}=    get_decision_id   ${INDEX}    date
  \    ${date}=    Get From Dictionary         ${item}     decisionDate
  \    ${repair_date}=    repair_start_date    ${date}
  \    Input Text   //input[@id='${date_id}']    ${repair_date}
  \    ${substracted_decisions_number}=   substract    ${decisions_number}   1
  \    Run Keyword If   ${INDEX} < ${substracted_decisions_number}   Click Element     //a[@class='button btn_white add_auction_item add_fields']
  \    Sleep    2

  # === Loop Try to select items info ===
  ${items_number}=   Get Length       ${asset_items}
  : FOR   ${INDEX}  IN RANGE    0    ${items_number}
  \    ${item}=    Get From List    ${asset_items}    ${INDEX}
  \    Додати наступний обєкт активу МП    ${item}
  \    ${substracted_items_number}=   substract    ${items_number}   1
  \    Run Keyword If   '${INDEX}' < '${substracted_items_number}'   Click Element     //a[@class='button btn_white add_auction_item add_fields'][last()]
  \    Sleep     3
  # Add Asset Holder
  Click Element    //div[@class="same_address"]
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
  Input Text    //input[@id="prozorro_asset_holder_attributes_name_ua"]        ${asset_holder_name}
  Input Text    //input[@id="prozorro_asset_holder_attributes_code"]           ${asset_holder_id}
  Input Text    //input[@id="prozorro_asset_holder_attributes_postal_code"]    ${asset_holder_index}
  ${ah_region_name}=   get_region_name_asset_holder   ${asset_holder_region}
  Select From List By Value   //select[@id="prozorro_asset_holder_attributes_region"]    ${ah_region_name}
  Input Text    //input[@id="prozorro_asset_holder_attributes_locality"]          ${asset_holder_locality}
  Input Text    //input[@id="prozorro_asset_holder_attributes_street_address"]    ${asset_holder_address}
  Input Text    //input[@id="prozorro_asset_holder_attributes_contact_attributes_name_ua"]      ${asset_holder_pib}
  Input Text    //input[@id="prozorro_asset_holder_attributes_contact_attributes_telephone"]    ${asset_holder_phone}
  Input Text    //input[@id="prozorro_asset_holder_attributes_contact_attributes_email"]        ${asset_holder_email}
  Input Text    //input[@id="prozorro_asset_holder_attributes_contact_attributes_fax_number"]   ${asset_holder_fax}
  # Save Auction - publish to CDB
  Click Element                      ${locator.publish}
  Wait Until Page Contains Element     //div[@class="blue_block top_border"]   60
  # Get Ids
  : FOR   ${INDEX}  IN RANGE    1   15
  \   Sleep    3
  \   Wait Until Page Contains Element     //div[@class="blue_block top_border"]
  \   ${id_values}=      Get Webelements     //div[@class="blue_block top_border"]/div/div
  \   ${uid_val}=   Get Text    //div[@class="blue_block top_border"]/div/div[contains(@class, 'auction_ua_id')]
  \   ${TENDER_UAID}=   get_ua_id_asset   ${uid_val}
  \   Exit For Loop If  '${TENDER_UAID}' > '0'
  \   Sleep     10
  \   Reload Page
  Sleep    10
  Log To Console    ${TENDER_UAID}${\n}
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

  ${item_descr_field}=   Get Webelements     //textarea[contains(@id, 'prozorro_asset_items_attributes_') and contains(@id, '_description_ua')]
  Input Text    ${item_descr_field[-1]}     ${item_description}
  ${item_quantity_field}=   Get Webelements     xpath=//input[contains(@id, 'prozorro_asset_items_attributes') and contains(@id, '_quantity')]
  ${item_quantity_string}      Convert To String    ${item_quantity}
  Input Text    ${item_quantity_field[-1]}           ${item_quantity_string}
  ${unit_name_field}=   Get Webelements     xpath=//select[contains(@id, 'prozorro_asset_items_attributes_') and contains(@id, '_unit_code')]
  Select From List By Value   ${unit_name_field[-1]}    ${unit_code}
  # Selecting classifier
  Sleep   1
  ${classification_scheme_html} =    get_html_scheme    ${classification_scheme}
  ${classifier_field}=      Get Webelements     xpath=//span[@data-type="sp_codes"]
  Click Element     ${classifier_field[-1]}
  Sleep     3
  set_clacifier_find   ${classification_id}  ${classification_scheme_html}
  Sleep     2
  Click Element    //div[@class="ajax_block classification_type_sp_codes"]//span[@class='button btn_adding']
  Sleep     2
  # Add delivery address
  ${delivery_zip_field}=   Get Webelements     //input[contains(@id, 'prozorro_asset_items_attributes_') and contains(@id, '_postal_code')]
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
  Input Text    //input[@name="search_classification"]    ${classification_id}
  Sleep   1
  Click Element     //label[starts-with(@for, "filtered_code_")]

Пошук об’єкта МП по ідентифікатору
  [Arguments]        ${user_name}    ${asset_uaid}
  Switch browser   ${BROWSER_ALIAS}
  :FOR   ${INDEX_N}  IN RANGE    1    15
  \   Go To  ${BROKERS['tabua'].assetpage}
  \   Wait Until Page Contains Element     id=aq  15
  \   Input Text        id=aq   ${asset_uaid}
  \   Click Element   //div[@class="columns search_button"]
  \   ${auc_on_page}=    Run Keyword And return Status    Wait Until Element Is Visible    //div[contains(@class, "columns auction_ua_id")]    10s
  \   Exit For Loop If    ${auc_on_page}
  \   Reload Page

Отримати інформацію із об'єкта МП
  [Arguments]     ${username}    ${tender_uaid}     ${field_name}
  Run Keyword If    '${username}' == 'tabua_Viewer'    Sleep    30
  tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${tender_uaid}
  Run Keyword And Return  Отримати інформацію про МП ${field_name}

Отримати інформацію про МП assetID
  ${return_value}=    Get Text    //div[@class="small-6 columns auction_ua_id"]
  [Return]    ${return_value}

Отримати інформацію про МП date
  ${uid}=    Get Text    //div[@class="small-6 columns auction_ua_id"]
  ${return_value}=    Get Element Attribute    //span[@class="entry_submission_start_detail"]@data-tender-start
  [Return]    ${return_value}

Отримати інформацію про МП rectificationPeriod.endDate
  ${return_value}=    Get Element Attribute    //span[@class="entry_submission_end_detail"]@data-enquiry_date
  [Return]    ${return_value}

Отримати інформацію про МП status
  ${status_elements} =    Get Webelements    //div[contains(@class, "small-4 columns auction_header_status status_")]/div
  ${status_elements_length}=    Get Length    ${status_elements}
  ${status}=    Run Keyword If  ${status_elements_length} == 1
  ...           Get Text    ${status_elements[0]}
  ...           ELSE    Get Text    ${status_elements[1]}
  ${status}=    Convert To String    ${status}
  ${return_value}=    reflect_status    ${status}
  [Return]  ${return_value}

Отримати інформацію про МП title
  ${return_value}=    Get Text    //span[@class="auction_short_title_text"]
  [Return]  ${return_value}

Отримати інформацію про МП description
  ${return_value}=    Get Text    //div[@class="small-7 columns auction_description"]
  [Return]  ${return_value}

Отримати інформацію про МП decisions[0].title
  ${decision_elem}=    Get Webelements    //div[@class="decision_title"]
  ${return_value}=    Get Text    ${decision_elem[0]}
  [Return]  ${return_value}

Отримати інформацію про МП decisions[1].title
  ${decision_elem}=    Get Webelements    //div[@class="decision_title"]
  ${return_value}=    Get Text    ${decision_elem[0]}
  [Return]  ${return_value}

Отримати інформацію про МП decisions[0].decisionDate
  ${decision_elem}=    Get Webelements   //div[@class="columns blue_block items decisions"]//ul/li//div[@class="small-4 columns"]/div
  ${number_date}=    Get Text    ${decision_elem[-1]}
  ${return_value}=    get_decision_date    ${number_date}
  [Return]  ${return_value}

Отримати інформацію про МП decisions[1].decisionDate
  ${decision_elem}=    Get Webelements   //div[@class="columns blue_block items decisions"]//ul/li//div[@class="small-4 columns"]/div
  ${number_date}=    Get Text    ${decision_elem[0]}
  ${return_value}=    get_decision_date    ${number_date}
  [Return]  ${return_value}

Отримати інформацію про МП decisions[0].decisionID
  ${decision_elem}=    Get Webelements   //div[@class="columns blue_block items decisions"]//ul/li//div[@class="small-4 columns"]/div
  ${number_date}=    Get Text    ${decision_elem[-1]}
  ${return_value}=    get_decision_number    ${number_date}
  [Return]  ${return_value}

Отримати інформацію про МП decisions[1].decisionID
  ${decision_elem}=    Get Webelements   //div[@class="columns blue_block items decisions"]//ul/li//div[@class="small-4 columns"]/div
  ${number_date}=    Get Text    ${decision_elem[0]}
  ${return_value}=    get_decision_number    ${number_date}
  [Return]  ${return_value}

Отримати інформацію про МП assetHolder.name
  ${return_value}=    Get Text    //div[@class="small-7 columns"][3]//div[@class="small-10 columns"]
  [Return]  ${return_value}

Отримати інформацію про МП assetHolder.identifier.scheme
  ${return_value}=    Get Element Attribute    //div[@data-organization_scheme="UA-EDR"]@data-organization_scheme
  [Return]  ${return_value}

Отримати інформацію про МП assetHolder.identifier.id
  ${scheme_elements}=    Get Webelements    //div[@data-organization_scheme="UA-EDR"]
  ${return_value}=    Get Text    ${scheme_elements[1]}
  [Return]  ${return_value}

Отримати інформацію про МП assetCustodian.identifier.scheme
  ${return_value}=    Get Element Attribute    //div[@data-organization_scheme="UA-EDR"]@data-organization_scheme
  [Return]  ${return_value}

Отримати інформацію про МП assetCustodian.identifier.id
  ${scheme_elements}=    Get Webelements    //div[@data-organization_scheme="UA-EDR"]
  ${return_value}=    Get Text    ${scheme_elements[0]}
  [Return]  ${return_value}

Отримати інформацію про МП assetCustodian.identifier.legalName
  ${return_value}=    Get Text    //div[@class="small-7 columns"][2]//div[@class="small-10 columns"]
  [Return]  ${return_value}

Отримати інформацію про МП assetCustodian.contactPoint.name
  ${return_value}=    Get Text    //div[@class="columns blue_block"]//div[@class="small-10 columns"]
  [Return]  ${return_value}

Отримати інформацію про МП assetCustodian.contactPoint.telephone
  ${cust_elems} =    Get Webelements    //div[@class="columns blue_block"]//div[@class="small-10 columns"]
  ${return_value}=    Get Text    ${cust_elems[1]}
  [Return]  ${return_value}

Отримати інформацію про МП assetCustodian.contactPoint.email
  ${return_value}=    Get Text    //div[@class="columns blue_block"]//div[@class="small-10 columns"]/a
  [Return]  ${return_value}

Отримати документ
  [Arguments]  ${username}  ${asset_uaid}  ${doc_id}
  Sleep    15
  Reload Page
  Sleep    2
  Click Element    //div[@class="documents_tab tabs-title"]/a
  Sleep    1
  ${file_name}=    Get Text    //a[contains(text(), '${doc_id}')]
  Sleep    1
  ${url}=    Get Element Attribute    //a[contains(text(), '${doc_id}')]@href
  download_file    ${url}    ${file_name}    ${OUTPUT_DIR}
  [Return]  ${file_name}

Отримати інформацію про МП documents[0].documentType
  Click Element    //div[@class="documents_tab tabs-title"]/a
  ${doc_type}=    Get Text    //div[@class="document_description"]/div[@class="document_link"]/a
  ${return_value}=    convert_doc_type    ${doc_type}
  [Return]  ${return_value}

Отримати інформацію з активу об'єкта МП
  [Arguments]  ${username}  ${asset_uaid}  ${item_id}  ${field_name}
  tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}
  ${return_value}=    Run KeyWord    Отримати інформацію про МП items.${field_name}    ${item_id}
  [Return]  ${return_value}

Отримати інформацію про МП items.description
  [Arguments]  ${item_id}
  ${description}=    Get Text    //li[contains(@data-item_title, '${item_id}')]//div[@class="item_title"]
  [Return]  ${description}

Отримати інформацію про МП items.classification.scheme
  [Arguments]  ${item_id}
  ${classification_scheme}=    Get Element Attribute   //li[contains(@data-item_title, "${item_id}")]//div[@class="item_classificator"]@data-classification_scheme
  [Return]  ${classification_scheme}

Отримати інформацію про МП items.classification.id
  [Arguments]  ${item_id}
  ${classification_id}=    Get Element Attribute    //li[contains(@data-item_title, "${item_id}")]//div[@class="item_classificator"]@data-classification_code
  [Return]  ${classification_id}

Отримати інформацію про МП items.unit.name
  [Arguments]  ${item_id}
  ${unit}=    Get Text    //li[contains(@data-item_title, "${item_id}")]//div[@class="small-10 small-offset-2 columns"]/span
  ${unitname}=    split_space    ${unit}    1
  ${return_value}=    get_select_unit_name    ${unitname}
  [Return]  ${return_value}

Отримати інформацію про МП items.quantity
  [Arguments]  ${item_id}
  ${unit}=    Get Text    //li[contains(@data-item_title, "${item_id}")]//div[@class="small-10 small-offset-2 columns"]/span
  ${quantity}=    split_space    ${unit}    0
  ${return_value}=    Convert To Number    ${quantity}
  [Return]  ${return_value}

Отримати інформацію про МП items.registrationDetails.status
  [Arguments]  ${item_id}
  ${status}=    Get Text   //li[contains(@data-item_title, "${item_id}")]//span[@class="item_registration_status"]
  ${return_value}=    convert_item_status    ${status}
  [Return]  ${return_value}

Отримати інформацію про МП dateModified
  ${return_value}=   Get Element Attribute   //div[@class="enquiry_until_date"]@data-last_editing_date
  [Return]  ${return_value}

Отримати інформацію про МП lotID
  ${return_value}=    Get Text    //div[@class="small-6 columns auction_ua_id"]
  [Return]  ${return_value}

Отримати інформацію про МП assets
  ${return_value}=    Get Text    //div[@class="small-6 columns auction_ua_id"]
  [Return]  ${return_value}

Отримати інформацію про МП lotHolder.name
  ${return_value}=    Get Text    //div[@class="small-7 columns"][3]//div[@class="small-10 columns"]
  [Return]  ${return_value}

Отримати інформацію про МП lotHolder.identifier.scheme
  ${return_value}=    Get Element Attribute    //div[@data-organization_scheme="UA-EDR"]@data-organization_scheme
  [Return]  ${return_value}

Отримати інформацію про МП lotHolder.identifier.id
  ${scheme_elements}=    Get Webelements    //div[@data-organization_scheme="UA-EDR"]
  ${return_value}=    Get Text    ${scheme_elements[1]}
  [Return]  ${return_value}

Отримати інформацію про МП lotCustodian.identifier.scheme
  ${return_value}=    Get Element Attribute    //div[@data-organization_scheme="UA-EDR"]@data-organization_scheme
  [Return]  ${return_value}

Отримати інформацію про МП lotCustodian.identifier.id
  ${scheme_elements}=    Get Webelements    //div[@data-organization_scheme="UA-EDR"]
  ${return_value}=    Get Text    ${scheme_elements[0]}
  [Return]  ${return_value}

Отримати інформацію про МП lotCustodian.identifier.legalName
  ${return_value}=    Get Text    //div[@class="small-7 columns"][2]//div[@class="small-10 columns"]
  [Return]  ${return_value}

Отримати інформацію про МП lotCustodian.contactPoint.name
  ${return_value}=    Get Text    //div[@class="columns blue_block"]//div[@class="small-10 columns"]
  [Return]  ${return_value}

Отримати інформацію про МП lotCustodian.contactPoint.telephone
  ${cust_elems} =    Get Webelements    //div[@class="columns blue_block"]//div[@class="small-10 columns"]
  ${return_value}=    Get Text    ${cust_elems[1]}
  [Return]  ${return_value}

Отримати інформацію про МП lotCustodian.contactPoint.email
  ${return_value}=    Get Text    //div[@class="columns blue_block"]//div[@class="small-10 columns"]/a
  [Return]  ${return_value}

Отримати інформацію про МП auctions[0].procurementMethodType
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${auction_type}=    Get Text    //div[@class="blue_block auction_1"]/div[@class="auction_tab_subtitle bottom_border"]
  ${return_value}=    convert_nt_string_to_common_string    ${auction_type}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[1].procurementMethodType
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${auction_type}=    Get Text    //div[@class="blue_block auction_2"]/div[@class="auction_tab_subtitle bottom_border"]
  ${return_value}=    convert_nt_string_to_common_string    ${auction_type}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[2].procurementMethodType
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${auction_type}=    Get Text    //div[@class="blue_block auction_3"]/div[@class="auction_tab_subtitle bottom_border"]
  ${return_value}=    convert_nt_string_to_common_string    ${auction_type}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[0].status
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Element Attribute    //div[@class="blue_block auction_1"]//div[@class="small-6 columns status"]@data-status
  [Return]  ${return_value}

Отримати інформацію про МП auctions[1].status
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Element Attribute    //div[@class="blue_block auction_2"]//div[@class="small-6 columns status"]@data-status
  [Return]  ${return_value}

Отримати інформацію про МП auctions[2].status
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Element Attribute    //div[@class="blue_block auction_3"]//div[@class="small-6 columns status"]@data-status
  [Return]  ${return_value}

Отримати інформацію про МП auctions[0].tenderAttempts
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Element Attribute    //div[@class="blue_block auction_1"]@data-tender_attempts
  ${return_value}=    Convert To Integer    ${return_value}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[1].tenderAttempts
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Element Attribute    //div[@class="blue_block auction_2"]@data-tender_attempts
  ${return_value}=    Convert To Integer    ${return_value}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[2].tenderAttempts
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Element Attribute    //div[@class="blue_block auction_3"]@data-tender_attempts
  ${return_value}=    Convert To Integer    ${return_value}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[0].value.amount
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Text    //div[@class="blue_block auction_1"]//div[@class="small-6 columns value_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[1].value.amount
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Text    //div[@class="blue_block auction_2"]//div[@class="small-6 columns value_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[2].value.amount
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Text    //div[@class="blue_block auction_3"]//div[@class="small-6 columns value_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[0].minimalStep.amount
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Text    //div[@class="blue_block auction_1"]//div[@class="small-6 columns minimal_step_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[1].minimalStep.amount
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Text    //div[@class="blue_block auction_2"]//div[@class="small-6 columns minimal_step_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[2].minimalStep.amount
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Set Variable    0
  ${return_value}=    Convert To Number    ${return_value}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[0].guarantee.amount
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Text    //div[@class="blue_block auction_1"]//div[@class="small-6 columns guarantee_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[1].guarantee.amount
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Text    //div[@class="blue_block auction_2"]//div[@class="small-6 columns guarantee_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[2].guarantee.amount
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Text    //div[@class="blue_block auction_3"]//div[@class="small-6 columns guarantee_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[0].registrationFee.amount
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Text    //div[@class="blue_block auction_1"]//div[@class="small-6 columns fee_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[1].registrationFee.amount
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Text    //div[@class="blue_block auction_2"]//div[@class="small-6 columns fee_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[2].registrationFee.amount
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Text    //div[@class="blue_block auction_3"]//div[@class="small-6 columns fee_amount"]/span[@class="amount"]
  ${return_value}=    convert_to_price    ${return_value}
  [Return]  ${return_value}

Отримати інформацію про МП auctions[1].tenderingDuration
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Element Attribute    //div[contains(@class, "tendering_duration")]@data-tendering_duration
  [Return]  ${return_value}

Отримати інформацію про МП auctions[2].tenderingDuration
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Element Attribute    //div[contains(@class, "tendering_duration")]@data-tendering_duration
  [Return]  ${return_value}

Отримати інформацію про МП auctions[0].auctionPeriod.startDate
  Click Element    //a[text()[contains(.,'Деталі аукціонів')]]
  Sleep    1
  ${return_value}=    Get Element Attribute    //div[@class="blue_block auction_1"]//div[@class="small-6 columns auction_start_date"]@data-auction_start_date
  [Return]  ${return_value}

###############################

Завантажити ілюстрацію в об'єкт МП
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}
  ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible	//a[text()[contains(.,'Змінити')]]	10
  Run Keyword If    ${at_auc_page}    Click Element    //a[text()[contains(.,'Змінити')]]
  Wait Until Element Is Visible	    //div[text()[contains(.,"Редагування об’єкта")]]    10
  ${add_doc_button}=   Get Webelements     //a[@class="button btn_white documents_add add_fields"]
  Click Element       ${add_doc_button[-1]}
  Choose File       //input[@type="file"]        ${file_path}
  Sleep   3
  Click Element     //input[@name="publish"]
  Sleep   10

Завантажити документ в об'єкт МП з типом
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${doc_type}
  tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${tender_uaid}
  ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible	//a[text()[contains(.,'Змінити')]]	10
  Run Keyword If    ${at_auc_page}    Click Element    //a[text()[contains(.,'Змінити')]]
  Wait Until Element Is Visible    //div[text()[contains(.,"Редагування об’єкта")]]    10
  ${add_doc_button}=    Get Webelements    //a[@class="button btn_white documents_add add_fields"]
  Click Element    ${add_doc_button[-2]}
  Choose File    //input[@type="file"]    ${file_path}
  Sleep    3
  Click Element    //input[@name="publish"]
  Sleep    20

################################

Внести зміни в об'єкт МП
  [Arguments]  ${username}  ${tender_uaid}  ${fieldname}  ${fieldvalue}
  tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${tender_uaid}
  ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible    //div[text()[contains(.,"Редагування об’єкта")]]    10
  tabua.Перейти на сторінку зміни параметрів активу    ${fieldname}    ${fieldvalue}

Перейти на сторінку зміни параметрів активу
  [Arguments]  ${fieldname}  ${fieldvalue}
  Click Element    //a[text()[contains(.,'Змінити')]]
  Wait Until Element Is Visible    //div[text()[contains(.,"Редагування об’єкта")]]    10
  Перевірити доступність зміни і змінити актив    ${fieldname}    ${fieldvalue}

Перевірити доступність зміни і змінити актив
  [Arguments]  ${field}	 ${value}
  ${avail_change}=    Run Keyword And return Status    Wait Until Element Is Visible	//div[text()[contains(.,"Редагування об’єкта")]]	10
  Run Keyword    Змінити МП ${field}    ${value}
  Click Element     //input[@name="publish"]
  Sleep  15

Змінити МП title
  [Arguments]  ${value}
  Input text    //input[@id="prozorro_asset_title_ua"]    ${value}

Змінити МП description
  [Arguments]  ${value}
  Input text    //textarea[@id="prozorro_asset_description_ua"]    ${value}

Внести зміни в актив об'єкта МП
  [Arguments]  ${username}  ${item_id}  ${asset_uaid}  ${field}  ${value}
  tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}
  ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible    //div[text()[contains(.,"Редагування об’єкта")]]    10
  Click Element   //a[text()[contains(.,'Змінити')]]
  Wait Until Element Is Visible    //div[text()[contains(.,"Редагування об’єкта")]]    10
  Run KeyWord  Внести зміни в актив об'єкта МП поле ${field}    ${value}    ${item_id}
  Click Element     //input[@name="publish"]
  Sleep    15

Внести зміни в актив об'єкта МП поле quantity
  [Arguments]  ${value}  ${item_id}
  ${fieldvalue}=    Convert To String    ${value}
  Input text    //div[contains(@data-item_title, "${item_id}")]//input[contains(@id, 'prozorro_asset_items_attributes') and contains(@id, '_quantity')]    ${fieldvalue}

Внести зміни в актив об'єкта МП поле description
  [Arguments]  ${value}  ${item_id}
  Input text    //div[contains(@data-item_title, "${item_id}")]//textarea[contains(@id, 'prozorro_asset_items_attributes') and contains(@id, '_description_ua')]    ${value}

Внести зміни в актив об'єкта МП поле registrationDetails.status
  [Arguments]  ${value}  ${item_id}
  ${registration_status_field}=    Get Webelements    //div[contains(@data-item_title, "${item_id}")]//select[contains(@id, 'prozorro_asset_items_attributes_') and contains(@id, '_registration_details_attributes_status')]
  Select From List By Value    ${registration_status_field[-1]}    ${value}

Отримати кількість активів в об'єкті МП
  [Arguments]  ${username}  ${asset_uaid}
  tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}
  ${items}=    Get Webelements    //div[@class="columns blue_block items"]/ul/li
  ${return_value}=    Get Length    ${items}
  [Return]  ${return_value}

Додати актив до об'єкта МП
  [Arguments]  ${username}  ${asset_uaid}  ${item}
  tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}
  ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible    //div[text()[contains(.,"Редагування об’єкта")]]    10
  Click Element    //a[text()[contains(.,'Змінити')]]
  Wait Until Element Is Visible    //div[text()[contains(.,"Редагування об’єкта")]]    10
  Click Element    //a[@class='button btn_white add_auction_item add_fields'][last()]
  Sleep    2
  Додати наступний обєкт активу МП    ${item}
  Click Element    //input[@name="publish"]
  Sleep    20

Завантажити документ для видалення об'єкта МП
  [Arguments]  ${username}  ${asset_uaid}  ${file_path}
  tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}
  Click Element    //div[@class="button warning asset_cancel"]
  Wait Until Element Is Visible    //input[@value="Виключити з переліку"]    10
  Click Element    //a[@class="button btn_white documents_add add_fields"]
  Choose File    //input[@type="file"]    ${file_path}
  Sleep    3
  Click Element    //input[@value="Виключити з переліку"]
  Sleep    30
  tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}

Видалити об'єкт МП
  [Arguments]  ${username}  ${asset_uaid}
  tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}
  Click Element    //div[@class="documents_tab tabs-title"]/a
  Sleep    2
  ${cancel_details}=   Get Text   //div[contains(text(), 'Підстава для скасування')]
  Click Element    //div[@class="main_tab tabs-title"]/a
  Sleep    2
  tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}

################# LOT #################

Створити лот
  [Arguments]    ${username}  ${tender_data}  ${asset_uaid}
  tabua.Пошук об’єкта МП по ідентифікатору    ${username}    ${asset_uaid}
  Click Element    //div[@class="auction_buttons"]/a
  Wait Until Page Contains Element   id=new_prozorro_lot_   20
  ${repair_date}=    repair_start_date    ${tender_data.data.decisions[0].decisionDate}
  Input Text    //input[contains(@id, "prozorro_lot_decisions_attributes_") and contains(@id, "_title_ua")]     ${tender_data.data.lotType}
  Input Text    //input[contains(@id, "prozorro_lot_decisions_attributes_") and contains(@id, "_decision_id")]      ${tender_data.data.decisions[0].decisionID}
  Input Text    //input[contains(@id, "prozorro_lot_decisions_attributes_") and contains(@id, "_date")]      ${repair_date}
  Click Element    //input[@name="publish"]
  Sleep    5
  Wait Until Page Contains Element     //div[@class="blue_block top_border"]   60
  ${LOT_UAID}=   Get Text    //div[@class="blue_block top_border"]/div/div[@class="small-6 columns auction_ua_id"]
  [Return]  ${LOT_UAID}

Пошук лоту по ідентифікатору
  [Arguments]  ${username}  ${lot_uaid}
  Switch browser   ${BROWSER_ALIAS}
  :FOR   ${INDEX_N}  IN RANGE    1    15
  \   Go To  ${BROKERS['tabua'].lotpage}
  \   Wait Until Page Contains Element     id=lq  5
  \   Input Text        id=lq   ${lot_uaid}
  \   Click Element   //div[@class="columns search_button"]
  \   ${auc_on_page}=    Run Keyword And return Status    Wait Until Element Is Visible    //div[contains(@class, "columns auction_ua_id")]    10
  \   Exit For Loop If    ${auc_on_page}
  \   Sleep   10
  \   Reload Page

Додати умови проведення аукціону
  [Arguments]    ${username}    ${auction}    ${index}    ${lot_uaid}
  Run Keyword If    ${index} == 0    tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
  Run KeyWord  Додати умови проведення аукціону номер ${index}    ${username}    ${lot_uaid}    ${auction}

Додати умови проведення аукціону номер 0
  [Arguments]    ${username}    ${lot_uaid}   ${auction}
  Click Link    //a[contains(text(), "Уточнити та активувати")]
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

Додати умови проведення аукціону номер 1
  [Arguments]  ${username}  ${lot_uaid}  ${auction}
  ${duration_period}=    get_duration_period    ${auction.tenderingDuration}
  Input Text    id=prozorro_lot_lot_auctions_attributes_1_tendering_duration    ${duration_period}
  Click Element    //input[@name="publish"]
  Sleep    5

Оновити сторінку з лотом
  [Arguments]  ${username}  ${lot_uaid}
  Switch Browser	${BROWSER_ALIAS}
  tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
  Reload Page
  Sleep    3

Отримати інформацію із лоту
  [Arguments]  ${username}  ${lot_uaid}  ${field_name}
  tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
  ${return_value}=    Run Keyword    Отримати інформацію про МП ${fieldname}
  [Return]  ${return_value}

Отримати інформацію з активу лоту
  [Arguments]  ${username}  ${lot_uaid}  ${item_id}  ${field_name}
  tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
  ${return_value}=    Run KeyWord    Отримати інформацію про МП items.${field_name}    ${item_id}
  [Return]  ${return_value}

############################

Завантажити ілюстрацію в лот
  [Arguments]  ${username}  ${lot_uaid}  ${filepath}
  tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
  Click Element    //a[text()[contains(.,'Змінити')]]
  Wait Until Element Is Visible    //div[text()[contains(.,'Редагування інформаційного повідомлення')]]    10
  ${add_doc_button}=    Get Webelements    //a[@class="button btn_white documents_add add_fields"]
  Click Element       ${add_doc_button[-1]}
  Choose File    //input[@type="file"]    ${filepath}
  Sleep    1
  Click Element    //input[@name="publish"]
  Sleep    10

Завантажити документ в лот з типом
  [Arguments]  ${username}  ${lot_uaid}  ${filepath}  ${document_type}
  tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
  ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible	//a[text()[contains(.,'Змінити')]]	  10
  Run Keyword If    ${at_auc_page}    Click Element    //a[text()[contains(.,'Змінити')]]
  Wait Until Element Is Visible    //div[text()[contains(.,'Редагування інформаційного повідомлення')]]    10
  ${add_doc_button}=    Get Webelements    //a[@class="button btn_white documents_add add_fields"]
  Click Element    ${add_doc_button[-2]}
  Choose File    //input[@type="file"]    ${filepath}
  Sleep    3
  ${document_type_field}=    Get Webelements    //select[contains(@id, 'prozorro_lot_documents_attributes_') and contains(@id, '_document_type')]
  ${document_type_value}=    correct_document_type_value    ${document_type}
  Select From List By Value    ${document_type_field[-1]}    ${document_type_value}
  Sleep    2
  Click Element    //input[@name="publish"]
  Sleep    20

Завантажити документ в умови проведення аукціону
  [Arguments]  ${username}  ${lot_uaid}  ${filepath}  ${documentType}  ${auction_index}
  tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
  ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible	//a[text()[contains(.,'Змінити')]]	  10
  Run Keyword If    ${at_auc_page}    Click Element    //a[text()[contains(.,'Змінити')]]
  Wait Until Element Is Visible	    //div[text()[contains(.,'Редагування інформаційного повідомлення')]]    10
  ${add_doc_button}=    Get Webelements    //a[@class="button btn_white documents_add add_fields"]
  Click Element    ${add_doc_button[-2]}
  Choose File    //input[@type="file"]    ${filepath}
  Sleep    3
  ${document_type_field}=    Get Webelements    //select[contains(@id, 'prozorro_lot_documents_attributes_') and contains(@id, '_document_type')]
  ${document_type_value}=    correct_document_type_value    ${document_type}
  Select From List By Value    ${document_type_field[-1]}    ${document_type_value}
  Sleep    2
  Click Element    //input[@name="publish"]
  Sleep    20

Внести зміни в лот
  [Arguments]  ${username}  ${lot_uaid}  ${fieldname}  ${fieldvalue}
  Click Link    //a[contains(text(), "Змінити")]
  Sleep    1
  Run KeyWord  Внести зміни в лот поле ${fieldname}  ${fieldvalue}
  Click Element    //input[@name="publish"]
  Sleep    5

Внести зміни в лот поле title
  [Arguments]  ${fieldvalue}
  Input Text    //input[@id="prozorro_lot_title_ua"]     ${fieldvalue}

Внести зміни в лот поле description
  [Arguments]  ${fieldvalue}
  Input Text    //textarea[@id="prozorro_lot_description_ua"]     ${fieldvalue}

Внести зміни в актив лоту
  [Arguments]  ${username}  ${item_id}  ${lot_uaid}  ${fieldname}  ${fieldvalue}
  Click Link    //a[contains(text(), "Змінити")]
  Sleep    1
  Run KeyWord  Внести зміни в актив лоту поле ${fieldname}    ${fieldvalue}    ${item_id}
  Click Element    //input[@name="publish"]
  Sleep    5

Внести зміни в актив лоту поле quantity
  [Arguments]  ${fieldvalue}  ${item_id}
  ${fieldvalue}=    Convert To String    ${fieldvalue}
  Input Text    //div[contains(@data-item_title, "${item_id}")]//input[contains(@id, 'prozorro_lot_items_attributes') and contains(@id, '_quantity')]    ${fieldvalue}

Внести зміни в умови проведення аукціону
  [Arguments]  ${username}  ${lot_uaid}  ${fieldname}  ${fieldvalue}  ${auc_num}
  Click Link    //a[contains(text(), "Змінити")]
  Sleep    1
  Run KeyWord  Внести зміни в умови проведення аукціону поле ${fieldname}  ${fieldvalue}
  Click Element    //input[@name="publish"]
  Sleep    5

Внести зміни в умови проведення аукціону поле value.amount
  [Arguments]  ${fieldvalue}
  ${fieldvalue}=    Convert To String    ${fieldvalue}
  Input Text    //input[@id="prozorro_lot_lot_auctions_attributes_0_value_attributes_amount"]     ${fieldvalue}

Внести зміни в умови проведення аукціону поле minimalStep.amount
  [Arguments]  ${fieldvalue}
  ${fieldvalue}=    Convert To String    ${fieldvalue}
  Input Text    //input[@id="prozorro_lot_lot_auctions_attributes_0_minimal_step_attributes_amount"]     ${fieldvalue}

Внести зміни в умови проведення аукціону поле guarantee.amount
  [Arguments]  ${fieldvalue}
  ${fieldvalue}=    Convert To String    ${fieldvalue}
  Input Text    //input[@id="prozorro_lot_lot_auctions_attributes_0_guarantee_attributes_amount"]     ${fieldvalue}

Внести зміни в умови проведення аукціону поле registrationFee.amount
  [Arguments]  ${fieldvalue}
  ${fieldvalue}=    Convert To String    ${fieldvalue}
  Input Text    //input[@id="prozorro_lot_lot_auctions_attributes_0_fee_attributes_amount"]     ${fieldvalue}

Внести зміни в умови проведення аукціону поле auctionPeriod.startDate
  [Arguments]  ${fieldvalue}
  Input Text    //input[@id="prozorro_lot_lot_auctions_attributes_0_auction_period_attributes_start_date"]     ${fieldvalue}

######################### DELETE LOT ######################
Завантажити документ для видалення лоту
  [Arguments]  ${username}  ${lot_uaid}  ${filepath}
  tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
  Click Element     //div[@class="button warning asset_cancel"]
  Sleep   1
  Wait Until Element Is Visible    //input[@value="Виключити з переліку"]    10
  Click Element       //a[@class="button btn_white documents_add add_fields"]
  Choose File       //input[@type="file"]        ${file_path}
  Sleep   3
  Click Element     //input[@value="Виключити з переліку"]
  Sleep   15
  tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}

Видалити лот
  [Arguments]  ${username}  ${lot_uaid}
  tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
  Click Element    //div[@class="documents_tab tabs-title"]/a
  Sleep    1
  ${cancel_details}=    Get Text    //div[contains(text(), 'Підстава для скасування')]
  Sleep    1
  Click Element    //div[@class="main_tab tabs-title"]/a
  Sleep    1
  tabua.Пошук лоту по ідентифікатору    ${username}    ${lot_uaid}
