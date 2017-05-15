*** Settings ***
 Library  String
Library  Selenium2Library
Library  tabua_service.py
 Library  DebugLibrary
 Library  Collections
 Library  BuiltIn

*** Variables ***
${TENDER_UAID_H}                                         UA-EA-2017-05-15-000083-1

${HOME_PAGE}                                           http://staging_sale.tab.com.ua/
${AUCTION_PAGE}                                        http://staging_sale.tab.com.ua/auctions
${EligibilityCriteria}                                 Only licensed financial institutions are eligible to participate.

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

${locator.tenderPeriod.endDate}           xpath=//span[@class="entry_submission_end_detail"]
${locator.view.minimalStep.amount}        xpath=//div[@class="blue_block"][2]//span[@class="amount"]

${locator.items[0].description}      css=div.small-7.columns.auction_description     # Description of Item (Lot in Auctions)
${locator.view.items[0].description}        xpath=//div[@class="columns blue_block items"]/ul/li[1]/div[@class="small-7 columns"]/div[@class="item_title"]
${locator.view.items[1].description}        xpath=//div[@class="columns blue_block items"]/ul/li[2]/div[@class="small-7 columns"]/div[@class="item_title"]
${locator.view.items[2].description}        xpath=//div[@class="columns blue_block items"]/ul/li[3]/div[@class="small-7 columns"]/div[@class="item_title"]

${locator.view.value.amount}         xpath=//span[@class="amount"]







*** Keywords ***
Підготувати клієнт для користувача
  [Arguments]  @{ARGUMENTS}
  [Documentation]  Відкрити браузер, створити об’єкт api wrapper, тощо
  ...      ${ARGUMENTS[0]} ==  username
  Open Browser
  ...      ${USERS.users['${ARGUMENTS[0]}'].homepage}
  ...      ${USERS.users['${ARGUMENTS[0]}'].browser}
  ...      alias=${ARGUMENTS[0]}
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
  Go To  ${HOME_PAGE}
  Wait Until Page Contains Element   xpath=//span[@class="button menu_btn is_logged"]   20
  Sleep     2
  Log To Console   Success logging in as Some one - ${ARGUMENTS[0]}


Оновити сторінку з тендером
	[Arguments]  ${user_name}  ${tender_id}
	Switch Browser	${user_name}
	Reload Page
	Sleep	3s


Підготувати дані для оголошення тендера
  [Arguments]  ${username}  ${tender_data}  ${role_name}
  ${tender_data}=   update_test_data   ${role_name}   ${tender_data}
  [Return]   ${tender_data}


Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
# Initialisation. Getting values from Dictionary
  Log To Console    Start creating procedure

  ${title}=         Get From Dictionary   ${ARGUMENTS[1].data}               title
  ${description}=   Get From Dictionary   ${ARGUMENTS[1].data}               description
  ${dgfID}=         Get From Dictionary   ${ARGUMENTS[1].data}               dgfID
  ${budget}=        Get From Dictionary   ${ARGUMENTS[1].data.value}         amount
  ${guarantee}=     Get From Dictionary   ${ARGUMENTS[1].data.guarantee}     amount
  ${step_rate}=     Get From Dictionary   ${ARGUMENTS[1].data.minimalStep}   amount
  ${dgfDecisionID}=     Get From Dictionary   ${ARGUMENTS[1].data}        dgfDecisionID
  ${dgfDecisionDate}=   Get From Dictionary   ${ARGUMENTS[1].data}        dgfDecisionDate
  ${tenderAttempts}=    Get From Dictionary   ${ARGUMENTS[1].data}        tenderAttempts

# Date of auction start
  ${start_date}=    Get From Dictionary   ${ARGUMENTS[1].data.auctionPeriod}    startDate

#  Wait Until Page Contains Element   xpath=//a[contains(text(), "Мої аукціони")]   20
#  Click Link                         xpath=//a[contains(text(), "Мої аукціони")]

  Go To  ${AUCTION_PAGE}
  Wait Until Page Contains Element   xpath=//a[contains(text(), "Створити новий аукціон")]   20
  Click Link                         xpath=//a[contains(text(), "Створити новий аукціон")]

# Selecting DGF Financial asset or DGF Other assets
  Wait Until Page Contains Element   xpath=//label[@for="prozorro_auction_procurement_method_type_dgf_financial_assets"]   20
  Run Keyword If  '${mode}' == 'dgfFinancialAssets'  Click Element   xpath=//label[@for="prozorro_auction_procurement_method_type_dgf_financial_assets"]
  Run Keyword If  '${mode}' == 'dgfOtherAssets'      Click Element   xpath=//label[@for="prozorro_auction_procurement_method_type_dgf_other_assets"]

  Log To Console    Selecting Some procedure ${mode}

# Input fields tender
  Input Text   ${locator.title}              ${title}
  Input Text   ${locator.description}        ${description}
  Input Text   ${locator.dgfid}              ${dgfID}

# New fields add
  Input Text   xpath=//input[@id="prozorro_auction_dgf_decision_id"]    ${dgfDecisionID}
  Input Text   xpath=//input[@id="prozorro_auction_dgf_decision_date"]  ${dgfDecisionDate}
  ${tender_attempts}=   Convert To String   ${tenderAttempts}
  Log To Console    attempts - '${tender_attempts}'
  Select From List By Value   xpath=//select[@id="prozorro_auction_tender_attempts"]    ${tender_attempts}

# Auction Start date
  Log To Console    date - '${start_date}'
  ${inp_start_date}=   repair_start_date   ${start_date}
  Log To Console    date - ${inp_start_date}
  Input Text   xpath=//input[@id="prozorro_auction_auction_period_attributes_should_start_after"]    ${inp_start_date}

# Budget data add
  ${budget_string}      Convert To String    ${budget}
  Input Text   ${locator.value.amount}       ${budget_string}
  Click Element    xpath=//label[@for="prozorro_auction_value_attributes_vat_included"]
  ${step_rate_string}   Convert To String     ${step_rate}
  Input Text   ${locator.minimalStep.amount}  ${step_rate_string}
#  ${guarantee_string}   Convert To String     ${guarantee}
######################### Warning HARDCODE
  ${guarantee_string}   get_min_guarant     ${budget}
  Log To Console    min guarant - ${guarantee_string}
######################### Warning HARDCODE
  Input Text    ${locator.guaranteeamount}    ${guarantee_string}

#  Items block info
# === Loop Try to select items info ===
  ${item_number}=   substract             ${NUMBER_OF_ITEMS}    1
  ${item_number}=   Convert To Integer    ${item_number}
  log to console    number of items - 1 = '${item_number}'
  : FOR   ${INDEX}  IN RANGE    0    ${NUMBER_OF_ITEMS}
  \   ${items}=         Get From Dictionary   ${ARGUMENTS[1].data}            items
  \   ${item[x]}=                              Get From List               ${items}                 ${INDEX}
  \   ${item_description}=                  Get From Dictionary         ${item[x]}     description
  \   Log to Console    item-0-description '${INDEX}' - '${item_description}'
  \   ${item_quantity}=                     Get From Dictionary         ${item[x]}     quantity
  \   ${unit}=                              Get From Dictionary         ${item[x]}     unit
  \   ${unit_code}=                         Get From Dictionary         ${unit}        code
  \   Log to console      unit code - ${unit_code}
  \   ${unit_name}=                         Get From Dictionary         ${unit}        name
  \   ${classification}=                    Get From Dictionary         ${item[x]}     classification
  \   ${classification_scheme}=             Get From Dictionary         ${classification}    scheme
  \   ${classification_description}=        Get From Dictionary         ${classification}    description
  \   ${classification_id}=                 Get From Dictionary         ${classification}    id
  \   ${deliveryaddress}=                   Get From Dictionary         ${item[x]}           deliveryAddress
  \   ${deliveryaddress_postalcode}=        Get From Dictionary         ${deliveryaddress}   postalCode
  \   ${deliveryaddress_countryname}=       Get From Dictionary         ${deliveryaddress}   countryName
  \   ${deliveryaddress_streetaddress}=     Get From Dictionary         ${deliveryaddress}   streetAddress
  \   ${deliveryaddress_region}=            Get From Dictionary         ${deliveryaddress}   region
  \   ${deliveryaddress_locality}=          Get From Dictionary         ${deliveryaddress}   locality
  \   Log To Console    index - ${INDEX}
# Add Item(s)
  \   ${item_descr_field}=   Get Webelements     xpath=//textarea[contains(@id, 'prozorro_auction_items_attributes_') and contains(@id, '_description_ua')]
  \   Input Text    ${item_descr_field[-1]}     ${item_description}
  \   ${item_quantity_field}=   Get Webelements     xpath=//input[contains(@id, 'prozorro_auction_items_attributes') and contains(@id, '_quantity')]
  \   Input Text    ${item_quantity_field[-1]}           ${item_quantity}
  \   ${spec_unit_name}=   get_select_unit_name   ${unit_name}
  \   ${unit_name_field}=   Get Webelements     xpath=//select[contains(@id, 'prozorro_auction_items_attributes_') and contains(@id, '_unit_code')]
  \   Select From List By Value   ${unit_name_field[-1]}    ${spec_unit_name}
# Selecting classifier
  \   ${classifier_field}=      Get Webelements     xpath=//span[@class="btn btn_editing"]
  \   Click Element     ${classifier_field[-1]}
  \   Sleep     2
  \   Input Text        id=search_classification    ${classification_id}
  \   ${nonzero_num}=   get_nonzero_num   ${classification_id}
  \   set_clacifier   ${nonzero_num}   ${classification_id}
  \   Click Element     xpath=//span[@class='button btn_adding']
  \   Sleep     2
# Add delivery address
  \   ${delivery_zip_field}=   Get Webelements     ${locator.delivery_zip}
  \   Input Text        ${delivery_zip_field[-1]}      ${deliveryaddress_postalcode}
  \   ${delivery_country_field}=   Get Webelements     ${locator.delivery_country}
  \   Select From List By Value   ${delivery_country_field[-1]}    ${deliveryaddress_countryname}
  \   ${region_name}=   get_region_name   ${deliveryaddress_region}
  \   ${region_name_field}=   Get Webelements     ${locator.delivery_region}
  \   Select From List By Value   ${region_name_field[-1]}    ${region_name}
  \   ${delivery_town_field}=   Get Webelements     ${locator.delivery_town}
  \   Input Text        ${delivery_town_field[-1]}     ${deliveryaddress_locality}
  \   ${delivery_address_field}=   Get Webelements     ${locator.delivery_address}
  \   Input Text        ${delivery_address_field[-1]}  ${deliveryaddress_streetaddress}
  \   Run Keyword If   '${INDEX}' < '${item_number}'   Click Element     ${locator.add_item}
  \   Sleep     3

# Save Auction - publish to CDB
  Click Element                      ${locator.publish}

# Get Ids
###################### WARNING Need to be changed
  : FOR   ${INDEX}  IN RANGE    1   15
  \   Wait Until Page Contains Element     xpath=//div[@class="blue_block top_border"]
  \   ${id_values}=      Get Webelements     xpath=//div[@class="blue_block top_border"]/div/div
  \   ${uid_val}=   Get Text  ${id_values[3]}
  \   ${TENDER_UAID}=   get_ua_id   ${uid_val}
  \   Exit For Loop If  '${TENDER_UAID}' > '0'
  \   Sleep     30
  \   Reload Page
  [Return]  ${TENDER_UAID}
#  Log To Console    tend id - ${TENDER_UAID_H}
#  [Return]  ${TENDER_UAID_H}

set_clacifier
  [Arguments]        ${nonzero_num}   ${classification_id}
  :FOR   ${INDEX_N}  IN RANGE    2    ${nonzero_num}
  \   ${first_code_symbols}=   get_first_symbols   ${classification_id}   ${INDEX_N}
  \   Click Element     xpath=//label[starts-with(@for, '${first_code_symbols}')]
  \   Sleep     2


Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  Log To Console   Who is it_0 - ${ARGUMENTS[0]}
  Log To Console   Searching for UFOs - ${ARGUMENTS[1]}
  Switch browser   ${ARGUMENTS[0]}
  Run Keyword If   '${ARGUMENTS[0]}' == 'tabua_Owner'   Go To  ${AUCTION_PAGE}
  Run Keyword If   '${ARGUMENTS[0]}' != 'tabua_Owner'   Go To  ${HOME_PAGE}
  Wait Until Page Contains Element     id=q  10
  Input Text        id=q  ${ARGUMENTS[1]}
  Sleep   1
  Click Element   xpath=//input[@class="button btn_search"]
  Wait Until Page Contains Element     xpath=//a[@class="auction_title accordion-title"]    10
  Click Element   xpath=//a[@class="auction_title accordion-title"]
  Sleep   3
  ${g_value}=   Get Element Attribute   xpath=//div[contains(@id, "auction_tabs_")]@id
  Log To Console    auction_tabs_ - ${g_value}
  ${auc_url}=   get_auc_url   ${g_value}
  Log To Console    lot url - ${auc_url}
  Go To  ${auc_url}
  Sleep  3


############# Tender info #########
Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_uaid
  ...      ${ARGUMENTS[2]} ==  field_name
  Run Keyword And Return  Отримати інформацію про ${ARGUMENTS[2]}

Отримати тест із поля і показати на сторінці
    [Arguments]   ${field_name}
    ${return_value}=   Get Text  ${locator.${field_name}}
    [Return]  ${return_value}

Отримати текст із поля і показати на сторінці
    [Arguments]   ${field_name}
    ${return_value}=   Get Text  ${locator.view.${field_name}}
    [Return]  ${return_value}

Отримати інформацію про tenderPeriod.endDate
    ${return_value}=    Отримати тест із поля і показати на сторінці  tenderPeriod.endDate
    [Return]    ${return_value}

Отримати інформацію про value.amount
  ${valueAmount}=   Отримати текст із поля і показати на сторінці   value.amount
  ${valueAmount}=   Convert To Number   ${valueAmount.replace(' ','').replace(',','.')}
  [Return]  ${valueAmount}

Отримати інформацію про procurementMethodType
  ${dgf_value}=   Get Element Attribute   xpath=//div[contains(@class, "auction_type auction_type_")]@class
  ${dgf_value}=   change_dgf   ${dgf_value}
  [Return]  ${dgf_value}

Отримати інформацію про minimalStep.amount
  Click Element   xpath=//a[contains(@id,'auction_tab_detail_')]
  Sleep  10
  ${return_value}=   Отримати текст із поля і показати на сторінці   minimalStep.amount
  ${return_value}=    Convert To Number   ${return_value.replace(' ', '').replace(',', '.')}
  Click Element   xpath=//a[contains(@id,'main_tab_detail_')]
  Sleep  5
  [Return]   ${return_value}

Отримати кількість предметів в тендері
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  tender_uaid
  Switch Browser    ${ARGUMENTS[0]}
  ${res}=   Get Text      xpath=//li[@class="row item bottom_border"]
  [return]  ${res}

Додати предмет закупівлі
  [Arguments]   @{ARGUMENTS}
  [Documentation]
  ...     ${ARGUMENTS[0]} == username
  ...     ${ARGUMENTS[1]} == tender_uaid
  ...     ${ARGUMENTS[2]} == item_info
  Log To Console    arg-0 - ${ARGUMENTS[1]}

Видалити предмет закупівлі
  [Arguments]   @{ARGUMENTS}
  [Documentation]
  ...     ${ARGUMENTS[0]} == username
  ...     ${ARGUMENTS[1]} == tender_uaid
  ...     ${ARGUMENTS[2]} == item_id
  Log To Console    arg-0 - ${ARGUMENTS[0]}

Отримати інформацію про eligibilityCriteria
# “Incorrect requirement, see the decision of DGF from 21.01.2017
  [Return]  ${EligibilityCriteria}


######### Item info #########
Отримати інформацію із предмету
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_uaid
  ...      ${ARGUMENTS[2]} ==  item_id
  ...      ${ARGUMENTS[3]} ==  field_name
  Run Keyword And Return  Отримати інформацію із ${ARGUMENTS[3]}


Отримати інформацію про items[0].description
# Відображення опису номенклатур тендера
  ${description_raw}=   Переглянути текст із поля і показати на сторінці   items[0].description
  ${description_1}=     Get Substring     ${description_raw}  0   11
  ${description_2}=     convert_nt_string_to_common_string  ${description_raw.split(': ')[-1]}
  ${description}=       Catenate  ${description_1}  ${description_2}
  [Return]  ${description}

Отримати інформацію із unit.name
  ${unit_name}=   Get Text      xpath=//div[contains(., '${item_id}')]//span[@class="unit ng-binding"]
#  ${unit_name}=   Переглянути текст із поля і показати на сторінці   items[${ARGUMENTS[2]}].unit.name
  Log To Console    unit name - ${unit_name}
#  Run Keyword And Return If  '${unit_name}' == 'килограммы'   Convert To String   кілограм
  [Return]  ${unit_name}

Переглянути текст із поля і показати на сторінці
  [Arguments]   ${field_name}
  ${return_value}=   Get Text  ${locator.${field_name}}
  [Return]  ${return_value}

Отримати інформацію із description

  ${descriptions}=   GET WEBELEMENTS  xpath=//div[@class="item_title"]
  ${description0}=  GET TEXT  ${descriptions[0]}
  ${description1}=  GET TEXT  ${descriptions[1]}
  ${description2}=  GET TEXT  ${descriptions[2]}
  @{ITEMS}  CREATE LIST  ${description0}  ${description1}  ${description2}
  ${description}=   get_next_description  @{ITEMS}
  [Return]  ${description}