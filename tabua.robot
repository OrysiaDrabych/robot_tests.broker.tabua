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
  ${tenderAttempts}=    Get From Dictionary   ${ARGUMENTS[1].data}        tenderAttempts
  ${min_bids_number} =    Get From Dictionary   ${ARGUMENTS[1].data}        minNumberOfQualifiedBids

# Date of auction start
  ${start_date}=    Get From Dictionary   ${ARGUMENTS[1].data.auctionPeriod}    startDate
  Go To  ${BROKERS['tabua'].auctionpage}
  Wait Until Page Contains Element   xpath=//a[contains(text(), "Створити новий аукціон")]   20
  Click Link                         xpath=//a[contains(text(), "Створити новий аукціон")]
# Selecting DGF Financial asset or DGF Other assets
  Wait Until Page Contains Element   xpath=//label[@for="prozorro_auction_auction_procedure_rent"]   20
  Run Keyword If  '${mode}' == 'dgfOtherAssets'  Click Element   xpath=//label[@for="prozorro_auction_auction_procedure_rent"]
  Run Keyword If  '${mode}' != 'dgfOtherAssets'      Click Element   xpath=//label[@for="prozorro_auction_auction_procedure_rent"]
  Log To Console    Selecting Some procedure ${mode}
# Input fields tender
  Input Text   ${locator.title}              ${title}
  Input Text   ${locator.description}        ${description}
  Input Text   ${locator.dgfid}              ${dgfID}
# New fields add
  ${string_min_bids_number}      Convert To String    ${min_bids_number}
  Select From List By Value   xpath=//select[@id="prozorro_auction_minimum_bids"]    ${string_min_bids_number}
  Sleep    2
  ${tender_attempts}=   Convert To String   ${tenderAttempts}
  Select From List By Value   xpath=//select[@id="prozorro_auction_tender_attempts"]    ${tender_attempts}
  Sleep    2
# Auction Start date
  ${inp_start_date}=   repair_start_date   ${start_date}
  Input Text   xpath=//input[@id="prozorro_auction_auction_period_attributes_should_start_after"]    ${inp_start_date}
# Budget data add
  ${budget_string}      Convert To String    ${budget}
  Input Text   ${locator.value.amount}       ${budget_string}
  Click Element    xpath=//label[@for="prozorro_auction_value_attributes_vat_included"]
  ${step_rate_string}   Convert To String     ${step_rate}
  Input Text   ${locator.minimalStep.amount}  ${step_rate_string}
  ${guarantee_string}   Convert To String     ${guarantee}
  Input Text    ${locator.guaranteeamount}    ${guarantee_string}
#  Items block info
# === Loop Try to select items info ===
  ${item_number}=   substract             ${NUMBER_OF_ITEMS}    1
  ${item_number}=   Convert To Integer    ${item_number}
  : FOR   ${INDEX}  IN RANGE    0    ${NUMBER_OF_ITEMS}
  \   ${items}=         Get From Dictionary   ${ARGUMENTS[1].data}            items
  \   ${item[x]}=                              Get From List               ${items}                 ${INDEX}
  \   ${item_description}=                  Get From Dictionary         ${item[x]}     description
  \   ${item_quantity}=                     Get From Dictionary         ${item[x]}     quantity
  \   ${unit}=                              Get From Dictionary         ${item[x]}     unit
  \   ${unit_code}=                         Get From Dictionary         ${unit}        code
  \   ${unit_name}=                         Get From Dictionary         ${unit}        name
  \   ${classification}=                    Get From Dictionary         ${item[x]}     classification
  \   ${classification_scheme}=             Get From Dictionary         ${classification}    scheme
  \   ${classification_description}=        Get From Dictionary         ${classification}    description
  \   ${classification_id}=                 Get From Dictionary         ${classification}    id
  \   ${classification_scheme}=             Get From Dictionary         ${classification}    scheme
  \   ${deliveryaddress}=                   Get From Dictionary         ${item[x]}           deliveryAddress
  \   ${deliveryaddress_postalcode}=        Get From Dictionary         ${deliveryaddress}   postalCode
  \   ${deliveryaddress_countryname}=       Get From Dictionary         ${deliveryaddress}   countryName
  \   ${deliveryaddress_streetaddress}=     Get From Dictionary         ${deliveryaddress}   streetAddress
  \   ${deliveryaddress_region}=            Get From Dictionary         ${deliveryaddress}   region
  \   ${deliveryaddress_locality}=          Get From Dictionary         ${deliveryaddress}   locality
  \   ${additionalclassifications}=         Get From Dictionary         ${item[x]}           additionalClassifications
  \   ${additionalclass_dict}=              Get From List               ${additionalclassifications}     0
  \   ${additional_description}=            Get From Dictionary         ${additionalclass_dict}   description
  \   ${contractperiod}=                    Get From Dictionary         ${item[x]}           contractPeriod
  \   ${d_start_date}=                      Get From Dictionary         ${contractperiod}    startDate
  \   ${d_end_date}=                        Get From Dictionary         ${contractperiod}    endDate
# Add Item(s)
  \   ${item_descr_field}=   Get Webelements     xpath=//textarea[contains(@id, 'prozorro_auction_items_attributes_') and contains(@id, '_description_ua')]
  \   Input Text    ${item_descr_field[-1]}     ${item_description}
  \   ${item_quantity_field}=   Get Webelements     xpath=//input[contains(@id, 'prozorro_auction_items_attributes') and contains(@id, '_quantity')]
  \   ${item_quantity_string}      Convert To String    ${item_quantity}
  \   Input Text    ${item_quantity_field[-1]}           ${item_quantity_string}
  \   ${unit_name_field}=   Get Webelements     xpath=//select[contains(@id, 'prozorro_auction_items_attributes_') and contains(@id, '_unit_code')]
  \   Select From List By Value   ${unit_name_field[-1]}    ${unit_code}
# Selecting classifier
  \   Sleep   5
  \   ${classification_scheme_html} =    get_html_scheme    ${classification_scheme}
  \   ${classifier_field}=      Get Webelements     xpath=//span[@data-type="${classification_scheme_html}"]
  \   Click Element     ${classifier_field[-1]}
  \   Sleep     2
  \   set_clacifier   ${classification_id}  ${classification_scheme_html}
  \   Sleep     2
  \   ${save_button}=   Get Webelements     xpath=//span[@class='button btn_adding']
  \   Click Element     ${save_button[-1]}
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
  \   ${input_d_start_date}=    repair_start_date   ${d_start_date}
  \   ${start_date_field}=   Get Webelements     xpath=//input[contains(@id, "_contract_period_attributes_start_date")]
  \   Input Text        ${start_date_field[-1]}  ${input_d_start_date}
  \   ${input_d_end_date}=    repair_start_date   ${d_end_date}
  \   ${end_date_field}=   Get Webelements     xpath=//input[contains(@id, "_contract_period_attributes_end_date")]
  \   Input Text        ${end_date_field[-1]}  ${input_d_end_date}
  \   Run Keyword If   '${INDEX}' < '${item_number}'   Click Element     ${locator.add_item}
  \   Sleep     3
# Save Auction - publish to CDB
  Click Element                      ${locator.publish}
  Sleep    5
  Wait Until Page Contains Element     xpath=//div[@class="blue_block top_border"]   60
# Get Ids
  : FOR   ${INDEX}  IN RANGE    1   15
  \   Sleep    3
  \   Wait Until Page Contains Element     xpath=//div[@class="blue_block top_border"]
  \   ${id_values}=      Get Webelements     xpath=//div[@class="blue_block top_border"]/div/div
  \   ${uid_val}=   Get Text  ${id_values[3]}
  \   ${TENDER_UAID}=   get_ua_id   ${uid_val}
  \   Exit For Loop If  '${TENDER_UAID}' > '0'
  \   Sleep     30
  \   Reload Page
  [Return]  ${TENDER_UAID}

set_clacifier
  [Arguments]       ${classification_id}  ${scheme}
  ${nonzero_num}  ${start_num}=   get_nonzero_num   ${classification_id}
  :FOR   ${INDEX_N}  IN RANGE    ${start_num}    ${nonzero_num}
  \   ${first_code_symbols}=   get_first_symbols   ${scheme}    ${classification_id}   ${INDEX_N}
  \   Click Element     xpath=//label[starts-with(@for, '${first_code_symbols}')]
  \   Sleep     2

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${TENDER_UAID}
  Switch browser   ${BROWSER_ALIAS}
  Run Keyword If   '${ARGUMENTS[0]}' == 'tabua_Owner'   Go To  ${BROKERS['tabua'].auctionpage}
  Run Keyword If   '${ARGUMENTS[0]}' != 'tabua_Owner'   Go To  ${BROKERS['tabua'].startpage}
  :FOR   ${INDEX_N}  IN RANGE    1    15
  \   Wait Until Page Contains Element     id=q  15
  \   Input Text        id=q   ${ARGUMENTS[1]}
  \   Sleep   3
  \   Click Element   xpath=//div[@class="columns search_button"]
  \   Sleep   3
  \   ${auc_on_page}=    Run Keyword And return Status    Wait Until Element Is Visible    xpath=//div[contains(@class, "columns auction_ua_id")]    10s
  \   Exit For Loop If    ${auc_on_page}
  \   Sleep   5
  \   Reload Page
  Sleep   3
  ${g_value}=   Get Element Attribute   xpath=//div[contains(@id, "auction_tabs_")]@id
  ${auc_url}=   get_auc_url   ${g_value}
  Go To  ${auc_url}
  Sleep  10

############# Tender info #########
Отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_uaid
  ...      ${ARGUMENTS[2]} ==  field_name
  tabua.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
  Sleep   5
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
  ${return_value}=    Get Element Attribute    xpath=//span[@class="entry_submission_end_detail"]@data-tender-end
  [Return]    ${return_value}

Отримати інформацію про auctionPeriod.startDate
  ${return_value}=    Get Element Attribute    xpath=//span[@class="auction_date_detail"]@data-auction-start
  [Return]    ${return_value}

Отримати інформацію про tenderPeriod.startDate
  ${return_value}=    Get Element Attribute    xpath=//span[@class="entry_submission_start_detail"]@data-tender-start
  [Return]    ${return_value}

Отримати інформацію про auctionPeriod.endDate
  ${return_value}=    Get Element Attribute    xpath=//span[@class="auction_date_detail"]@data-auction-end
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
  Sleep  3
  ${return_value}=   Отримати текст із поля і показати на сторінці   minimalStep.amount
  ${return_value}=    Convert To Number   ${return_value.replace(' ', '').replace(',', '.')}
  Click Element   xpath=//a[contains(@id,'main_tab_detail_')]
  [Return]   ${return_value}

Отримати інформацію про minNumberOfQualifiedBids
  Click Element   xpath=//a[contains(@id,'auction_tab_detail_')]
  Sleep  3
  ${return_value}=   Отримати текст із поля і показати на сторінці   minNumberOfQualifiedBids
  Click Element   xpath=//a[contains(@id,'main_tab_detail_')]
  ${return_value}=   Convert To Number   ${return_value.split(':')[-1].strip()}
  [Return]   ${return_value}

Отримати кількість предметів в тендері
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} =  username
  ...      ${ARGUMENTS[1]} =  tender_uaid
  tabua.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}  ${ARGUMENTS[1]}
  Wait Until Page Contains Element    xpath=//li[@class="row item bottom_border"]     20
  ${items} =    Get Webelements    xpath=//li[@class="row item bottom_border"]
  ${res}=   Get Length       ${items}
  [return]  ${res}

Отримати інформацію про awards[${index}].status
  Sleep    10
  Reload Page
  Sleep     3
  ${award_blocks} =    Get Webelements     xpath=//ul[@class="accordion bids_list"]/li
  ${award_len} =    Get Length    ${award_blocks}
  :FOR    ${i}    IN RANGE    0    ${award_len}
  \    Click Element   ${award_blocks[${i}]}
  \    Sleep   2
  Sleep     3
  ${award_status_blocks} =    Get Webelements     xpath=//ul[@class="accordion bids_list"]//div[contains(@class, "bid_status")]/span
  ${status}=    Get Text    ${award_status_blocks[${index}]}
  ${correct_status}=    get_award_status    ${status}
  [Return]    ${correct_status}

####  Client  #################
Отримати інформацію про title
  ${new_title}  Get Text  css=span.auction_short_title_text
  [return]  ${new_title}

Отримати інформацію про dgfID
  ${return_value}=   Get Text  xpath=//div[@class="small-6 columns"][1]
  [Return]  ${return_value}

Отримати інформацію про description
  ${main_desc}=   Get Text  xpath=//div[@class="small-7 columns auction_description"]
  ${desc2}=   Get Text  xpath=//div[@class="auction_attempts"]
  ${desc}=  convert_desc  ${main_desc}  ${desc2}
  [Return]  ${desc}

Отримати інформацію про value.valueAddedTaxIncluded
  ${tax}=   Get Text  xpath=//span[@class="amount"][1]
  ${tax}=   Convert To Boolean   ${tax}
  [Return]  ${tax}

Отримати інформацію про auctionID
  ${return_value}=   Get Text  xpath=//div[@class="small-6 columns auction_ua_id"]
  [Return]  ${return_value}

Отримати інформацію про procuringEntity.name
  ${return_value}=   Get Text  xpath=//div[@class="small-10 columns"][1]
  [Return]  ${return_value}

Отримати інформацію із classification.scheme
  [Arguments]   @{arguments}
  [Documentation]
  ...           ${ARGUMENTS[0]} == user_role
  ...           ${ARGUMENTS[1]} == auction_id
  ...           ${ARGUMENTS[2]} == field_name
  Run Keyword And Return   Отримати інформацію про ${ARGUMENTS[2]}

Отримати Інформацію Про Items[0].classification.scheme
  Sleep   2
  ${scheme_list} =    Get Webelements    xpath=//div[@class="item_classificator"]
  ${return_value}=   Get Text  ${scheme_list[${asset_index_0}]}
  [return]  ${return_value.split(':')[0]}

Отримати Інформацію Про Items[1].classification.scheme
  Sleep   2
  ${scheme_list} =    Get Webelements    xpath=//div[@class="item_classificator"]
  ${return_value}=   Get Text  ${scheme_list[${asset_index_1}]}
  [return]  ${return_value.split(':')[0]}

Отримати Інформацію Про Items[2].classification.scheme
  Sleep   2
  ${scheme_list} =    Get Webelements    xpath=//div[@class="item_classificator"]
  ${return_value}=   Get Text  ${scheme_list[${asset_index_2}]}
  [return]  ${return_value.split(':')[0]}

Отримати інформацію із classification.id
  [Arguments]   @{arguments}
  [Documentation]
  ...           ${ARGUMENTS[0]} == user_role
  ...           ${ARGUMENTS[1]} == auction_id
  ...           ${ARGUMENTS[2]} == field_name
  Run Keyword And Return   Отримати інформацію про ${ARGUMENTS[2]}

Отримати інформацію про items[0].classification.id
  Sleep  5
  Wait Until Page Contains Element     xpath=//div[@class="item_title"]
  ${des}=   GET WEBELEMENTS  xpath=//div[@class="item_classificator"]
  ${_id}=   Get Text  ${des[${asset_index_0}]}
  [Return]  ${_id.split(': ')[1].split(' -')[0]}

Отримати інформацію про items[1].classification.id
  Wait Until Page Contains Element     xpath=//div[@class="item_title"]
  ${des}=   GET WEBELEMENTS  xpath=//div[@class="item_classificator"]
  ${_id}=   Get Text  ${des[${asset_index_1}]}
  [Return]  ${_id.split(': ')[1].split(' -')[0]}

Отримати інформацію про items[2].classification.id
  Wait Until Page Contains Element     xpath=//div[@class="item_title"]
  ${des}=   GET WEBELEMENTS  xpath=//div[@class="item_classificator"]
  ${_id}=   Get Text  ${des[${asset_index_2}]}
  [Return]  ${_id.split(': ')[1].split(' -')[0]}

Переглянути текст із поля і показати на сторінці
  [Arguments]   ${field_name}
  ${return_value}=   Get Text  ${locator.view.${field_name}}
  Sleep  3
  [Return]  ${return_value}

Отримати інформацію про status
  ${return_value}=  Get Text  xpath=//div[@class='auction_title']/div/div[2]/span
  ${return_value}=  convert_tabua_string_to_common_string  ${return_value}
  [return]  ${return_value}


#############   classification.description   #################
Отримати інформацію із classification.description
  [Arguments]   @{arguments}
  [Documentation]
  ...           ${ARGUMENTS[0]} == user_role
  ...           ${ARGUMENTS[1]} == auction_id
  ...           ${ARGUMENTS[2]} == field_name
  Run Keyword And Return   Отримати інформацію про ${ARGUMENTS[2]}

Отримати інформацію про items[0].classification.description
  Sleep  5
  Wait Until Page Contains Element     xpath=//div[@class="item_title"]
  ${des}=   GET WEBELEMENTS  xpath=//div[@class="item_title"]
  ${_id}=   Get Text  ${des[${asset_index_0}]}
  [Return]  ${_id.split(':')[-1].strip()}

Отримати інформацію про items[1].classification.description
  Wait Until Page Contains Element     xpath=//div[@class="item_title"]
  ${des}=   GET WEBELEMENTS  xpath=//div[@class="item_title"]
  ${_id}=   Get Text  ${des[${asset_index_1}]}
  [Return]  ${_id.split(':')[-1].strip()}

Отримати інформацію про items[2].classification.description
  Wait Until Page Contains Element     xpath=//div[@class="item_title"]
  ${des}=   GET WEBELEMENTS  xpath=//div[@class="item_title"]
  ${_id}=   Get Text  ${des[${asset_index_2}]}
  [Return]  ${_id.split(':')[-1].strip()}

Отримати інформацію із additionalClassifications[0].description
  Sleep  5
  Wait Until Page Contains Element     xpath=//div[@class="item_title"]
  ${_id}=   Get Text  xpath=//div[@class="auction_type auction_type_dgf_other_assets"]/span
  [Return]  ${_id.split(':')[-1].strip()}

Отримати інформацію про items[0].unit.name
  ${units}=     Get Webelements     xpath=//div[@class="small-1 small-offset-1 columns"]
  ${unit_name}=     Get Text    ${units[${asset_index_0}]}
  ${unit_name}=  get_select_unit_name  ${unit_name.split(' ')[-1]}
  [Return]  ${unit_name}

Отримати інформацію про items[1].unit.name
  ${units}=     Get Webelements     xpath=//div[@class="small-1 small-offset-1 columns"]
  ${unit_name}=     Get Text    ${units[${asset_index_1}]}
  ${unit_name}=  get_select_unit_name  ${unit_name.split(' ')[-1]}
  [Return]  ${unit_name}

Отримати інформацію про items[2].unit.name
  ${units}=     Get Webelements     xpath=//div[@class="small-1 small-offset-1 columns"]
  ${unit_name}=     Get Text    ${units[${asset_index_2}]}
  ${unit_name}=  get_select_unit_name  ${unit_name.split(' ')[-1]}
  [Return]  ${unit_name}

Отримати інформацію із unit.code
  [Arguments]   @{arguments}
  [Documentation]
  ...           ${ARGUMENTS[0]} == user_role
  ...           ${ARGUMENTS[1]} == auction_id
  ...           ${ARGUMENTS[2]} == field_name
  Run Keyword And Return   Отримати інформацію про ${ARGUMENTS[2]}

Отримати інформацію про items[0].unit.code
  ${units}=     Get Webelements     xpath=//div[@class="small-1 small-offset-1 columns"]
  ${unit_code}=     Get Text    ${units[${asset_index_0}]}
  ${unit_code}=  get_select_unit_code  ${unit_code.split(' ')[-1].strip()}
  [Return]  ${unit_code}

Отримати інформацію про items[1].unit.code
  ${units}=     Get Webelements     xpath=//div[@class="small-1 small-offset-1 columns"]
  ${unit_code}=     Get Text    ${units[${asset_index_1}]}
  ${unit_code}=  get_select_unit_code  ${unit_code.split(' ')[-1].strip()}
  [Return]  ${unit_code}

Отримати інформацію про items[2].unit.code
  ${units}=     Get Webelements     xpath=//div[@class="small-1 small-offset-1 columns"]
  ${unit_code}=     Get Text    ${units[${asset_index_2}]}
  ${unit_code}=  get_select_unit_code  ${unit_code.split(' ')[-1].strip()}
  [Return]  ${unit_code}

Отримати інформацію із quantity
  [Arguments]   @{arguments}
  [Documentation]
  ...           ${ARGUMENTS[0]} == user_role
  ...           ${ARGUMENTS[1]} == auction_id
  ...           ${ARGUMENTS[2]} == field_name
  Run Keyword And Return   Отримати інформацію про ${ARGUMENTS[2]}

Отримати інформацію про items[0].quantity
  ${units}=     Get Webelements     xpath=//div[@class="small-1 small-offset-1 columns"]
  ${unit_name}=     Get Text    ${units[${asset_index_0}]}
  ${unit_name}=    get_first_string    ${unit_name}
  [Return]  ${unit_name}

Отримати інформацію про items[1].quantity
  ${units}=     Get Webelements     xpath=//div[@class="small-1 small-offset-1 columns"]
  ${unit_name}=     Get Text    ${units[${asset_index_1}]}
  ${unit_name}=    get_first_string    ${unit_name}
  [Return]  ${unit_name}

Отримати інформацію про items[2].quantity
  ${units}=     Get Webelements     xpath=//div[@class="small-1 small-offset-1 columns"]
  ${unit_name}=     Get Text    ${units[${asset_index_2}]}
  ${unit_name}=    get_first_string    ${unit_name}
  [Return]  ${unit_name}

Отримати інформацію із contractPeriod.startDate
  [Arguments]   @{arguments}
  [Documentation]
  ...           ${ARGUMENTS[0]} == user_role
  ...           ${ARGUMENTS[1]} == auction_id
  ...           ${ARGUMENTS[2]} == field_name
  Run Keyword And Return   Отримати інформацію про ${ARGUMENTS[2]}

Отримати інформацію про items[0].contractPeriod.startDate
  ${start_dates} =    Get Webelements     xpath=//div[text()[contains(.,'Початок дії договору: ')]]
  ${start_date} =     Get Text    ${start_dates[${asset_index_0}]}
  ${start_date} =     repair_contract_period_date    ${start_date}
  [Return]  ${start_date}

Отримати інформацію про items[1].contractPeriod.startDate
  ${start_dates} =    Get Webelements     xpath=//div[text()[contains(.,'Початок дії договору: ')]]
  ${start_date} =     Get Text    ${start_dates[${asset_index_1}]}
  ${start_date} =     repair_contract_period_date    ${start_date}
  [Return]  ${start_date}

Отримати інформацію про items[2].contractPeriod.startDate
  ${start_dates} =    Get Webelements     xpath=//div[text()[contains(.,'Початок дії договору: ')]]
  ${start_date} =     Get Text    ${start_dates[${asset_index_2}]}
  ${start_date} =     repair_contract_period_date    ${start_date}
  [Return]  ${start_date}

Отримати інформацію із contractPeriod.endDate
  [Arguments]   @{arguments}
  [Documentation]
  ...           ${ARGUMENTS[0]} == user_role
  ...           ${ARGUMENTS[1]} == auction_id
  ...           ${ARGUMENTS[2]} == field_name
  Run Keyword And Return   Отримати інформацію про ${ARGUMENTS[2]}

Отримати інформацію про items[0].contractPeriod.endDate
  ${end_dates} =    Get Webelements     xpath=//div[text()[contains(.,'Закінчення дії договору: ')]]
  ${end_date} =     Get Text    ${end_dates[${asset_index_0}]}
  ${end_date} =     repair_contract_period_date    ${end_date}
  [Return]  ${end_date}

Отримати інформацію про items[1].contractPeriod.endDate
  ${end_dates} =    Get Webelements     xpath=//div[text()[contains(.,'Закінчення дії договору: ')]]
  ${end_date} =     Get Text    ${end_dates[${asset_index_1}]}
  ${end_date} =     repair_contract_period_date    ${end_date}
  [Return]  ${end_date}

Отримати інформацію про items[2].contractPeriod.endDate
  ${end_dates} =    Get Webelements     xpath=//div[text()[contains(.,'Закінчення дії договору: ')]]
  ${end_date} =     Get Text    ${end_dates[${asset_index_2}]}
  ${end_date} =     repair_contract_period_date    ${end_date}
  [Return]  ${end_date}

Отримати інформацію про value.currency
    ${return_value}=   Get Text  xpath=//span[@class="currency"]
    ${return_value}=   get_select_unit_name      ${return_value}
    [Return]  ${return_value}

Отримати інформацію про eligibilityCriteria
# “Incorrect requirement, see the decision of DGF from 21.01.2017
  [Return]  'Only licensed financial institutions are eligible to participate.'

Отримати інформацію про cancellations[0].status
  ${return_value}=  Get Text  xpath=//div[@class='callout warning']/div[@class='form_subtitle']
  ${return_value}=  convert_cancellations_status    ${return_value}
  [return]  ${return_value}

Отримати інформацію про cancellations[0].reason
  ${return_value}=  Get Text  xpath=//div[@class='callout warning']/div[@class='blue_block']
  [return]  ${return_value}

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
  [Return]  ${unit_name}


Отримати інформацію із description
  ${descriptions}=   GET WEBELEMENTS  xpath=//div[@class="item_title"]
  ${description0}=  GET TEXT  ${descriptions[${asset_index_0}]}
  ${description1}=  GET TEXT  ${descriptions[${asset_index_1}]}
  ${description2}=  GET TEXT  ${descriptions[${asset_index_2}]}
  @{ITEMS}  CREATE LIST  ${description0}  ${description1}  ${description2}
  ${description}=   get_next_description  @{ITEMS}
  [Return]  ${description}

Отримати інформацію про tenderAttempts
  ${return_value}=   Get Text   xpath=//div[@class="tabs-panel is-active main_tab_detail"]/div/div/span
  ${return_value}=   convert_string_to_integer   ${return_value}
  [Return]      ${return_value}

Отримати інформацію про guarantee.amount
  Click Element   xpath=//a[contains(@id,'auction_tab_detail_')]
  Sleep  3
  ${amaunts}=     Get Webelements     xpath=//span[@class="amount"]
  ${guarantee_amount}=    Get Text  ${amaunts[-1]}
  ${return_value} =    Convert To Number   ${guarantee_amount.replace(' ', '').replace(',', '.')}
  [Return]      ${return_value}

 ######### Changes #########

Внести зміни в тендер
  [Arguments]  ${user_name}  ${tender_id}  ${field}  ${value}
  tabua.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}
  ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible    xpath=//a[text()[contains(.,'Змінити')]]    10s
  Run Keyword If	${at_auc_page}	Перейти на сторінку зміни параметрів аукціону   ${field}	${value}
  Run Keyword If	${at_auc_page}!=True	Перевірити доступність зміни і змінити лот    ${field}	${value}

Перейти на сторінку зміни параметрів аукціону
  [Arguments]  ${field}    ${value}
  Click Element   xpath=//a[text()[contains(.,'Змінити')]]
  Wait Until Element Is Visible    xpath=//div[text()[contains(.,'Редагування аукціону')]]    10
  Перевірити доступність зміни і змінити лот    ${field}	${value}

Перевірити доступність зміни і змінити лот
  [Arguments]  ${field}	 ${value}
  ${avail_change}=    Run Keyword And return Status    Wait Until Element Is Visible	${locator.title}	10s
  Run Keyword If    ${avail_change}!=True    Додати документ
  Sleep  5
  Run Keyword	Змінити ${field}	${value}
  Click Element     xpath=//input[@name="commit"]
  Sleep  10
  Reload Page
  Sleep  3

Додати документ
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  ${add_doc_button}=   Get Webelements     xpath=//a[@class="button btn_white documents_add add_fields"]
  Click Element       ${add_doc_button[0]}
  Sleep   1
  Choose File       xpath=//input[@type="file"]        ${file_path}

Змінити value.amount
    [Arguments]    ${value}
    Input text    ${locator.value.amount}    '${value}'

Змінити minimalStep.amount
    [Arguments]    ${value}
    Input text    ${locator.minimalStep.amount}    '${value}'

Змінити title
  [Arguments]  ${value}
  Input Text   ${locator.title}          ${value}

Змінити description
  [Arguments]  ${value}
  Input Text   ${locator.description}          ${value}

Змінити procuringEntity.name
  [Arguments]  ${value}
  Input text	 xpath=//label[@for="prozorro_auction_procurement_method_type_dgf_financial_assets"] 	${value}

Змінити tenderPeriod.startDate
  [Arguments]  ${value}
  ${inp_start_date}=   repair_start_date   ${value}
  Input Text   xpath=//input[@id="prozorro_auction_auction_period_attributes_should_start_after"]    ${inp_start_date}

Змінити eligibilityCriteria
  [Arguments]  ${value}
# “Incorrect requirement, see the decision of DGF from 21.01.2017
  Input text	css=input[tid='eligibilityCriteria']	${value}

Змінити guarantee.amount
  [Arguments]  ${value}
  ${value}   Convert To String     ${value}
  Input text	${locator.guaranteeamount}	${value}

Змінити dgfID
    [Arguments]  ${value}
    Input Text   ${locator.dgfid}    ${value}

Змінити tenderAttempts
  [Arguments]  ${value}
  ${tender_attempts}=   Convert To String   ${value}
  Select From List By Value   xpath=//select[@id="prozorro_auction_tender_attempts"]    ${tender_attempts}

Завантажити ілюстрацію
  [Arguments]  ${user_name}  ${tender_id}  ${filepath}
  ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible	xpath=//a[text()[contains(.,'Змінити')]]	10s
  Run Keyword If    ${at_auc_page}    Click Element    xpath=//a[text()[contains(.,'Змінити')]]
  Wait Until Element Is Visible	    xpath=//div[text()[contains(.,'Редагування аукціону')]]    10
  ${add_doc_button}=   Get Webelements     xpath=//a[@class="button btn_white documents_add add_fields"]
  Click Element       ${add_doc_button[-1]}
  Choose File       xpath=//input[@type="file"]        ${file_path}
  Sleep   5
  Click Element     xpath=//input[@name="commit"]
  Sleep   5

Завантажити документ в тендер з типом
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${doc_type}
  tabua.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible	xpath=//a[text()[contains(.,'Змінити')]]	10s
  Run Keyword If    ${at_auc_page}   	Click Element   xpath=//a[text()[contains(.,'Змінити')]]
  Wait Until Element Is Visible  	xpath=//div[text()[contains(.,'Редагування аукціону')]]    10
  Run Keyword If    '${doc_type}' != 'x_nda'    Додати документ з типом    ${username}  ${tender_uaid}  ${filepath}  ${doc_type}
  Run Keyword If    '${doc_type}' == 'x_nda'    Додати договір про нерозголошення    ${username}  ${tender_uaid}  ${filepath}
  Sleep    5


Додати документ з типом
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}  ${doc_type}
  ${add_doc_button}=   Get Webelements     xpath=//a[@class="button btn_white documents_add add_fields"]
  Click Element       ${add_doc_button[-2]}
  Sleep    5
  Choose File       xpath=//input[@type="file"]        ${filepath}
  Sleep   5
  Click Element     xpath=//input[@name="commit"]
  Sleep    5

Додати договір про нерозголошення
  [Arguments]  ${username}  ${tender_uaid}  ${filepath}
  ${add_doc_button}=   Get Webelements     xpath=//a[@class="button btn_white documents_add add_fields"]
  Click Element       ${add_doc_button[-3]}
  Sleep    5
  Choose File       xpath=//input[@type="file"]        ${filepath}
  Sleep   5
  Click Element     xpath=//input[@name="commit"]
  Sleep    5

Завантажити документ
  [Arguments]  ${user_name}  ${filepath}  ${tender_id}=${None}
  Sleep    3
  ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible	xpath=//a[text()[contains(.,'Змінити')]]	10s
  Run Keyword If    ${at_auc_page}    Click Element    xpath=//a[text()[contains(.,'Змінити')]]
  Wait Until Element Is Visible	    xpath=//div[text()[contains(.,'Редагування аукціону')]]    10
  ${add_doc_button}=   Get Webelements     xpath=//a[@class="button btn_white documents_add add_fields"]
  Click Element       ${add_doc_button[0]}
  Choose File       xpath=//input[@type="file"]        ${filepath}
  Sleep  5
  Click Element     xpath=//input[@name="commit"]
  Sleep    5

Додати Virtual Data Room
  [Arguments]  ${username}  ${tender_uaid}  ${vdr_url}  ${title}=Sample Virtual Data Room
  Sleep    3
  ${at_auc_page}=   Run Keyword And return Status    Wait Until Element Is Visible	 xpath=//a[text()[contains(.,'Змінити')]]	10s
  Run Keyword If    ${at_auc_page}    Click Element    xpath=//a[text()[contains(.,'Змінити')]]
  Wait Until Page Contains Element      xpath=//input[contains(@id, "prozorro_auction_documents_attributes") and contains(@id, "url")]    10
  ${url_elements}=    Get Webelements        xpath=//input[contains(@id, "prozorro_auction_documents_attributes") and contains(@id, "url")]
  Input Text         ${url_elements[0]}          ${vdr_url}
  Sleep    5
  Click Element     xpath=//input[@name="commit"]
  Sleep    5

Додати публічний паспорт активу
  [Arguments]  ${user_name}  ${tender_id}  ${urlpath}
  Reload Page
  ${at_auc_page}=   Run Keyword And return Status    Wait Until Element Is Visible	 xpath=//a[text()[contains(.,'Змінити')]]	10s
  Run Keyword If    ${at_auc_page}    Click Element    xpath=//a[text()[contains(.,'Змінити')]]
  Wait Until Page Contains Element      xpath=//input[contains(@id, "prozorro_auction_documents_attributes") and contains(@id, "url")]    30
  Sleep    5
  ${url_elements}=    Get Webelements        xpath=//input[contains(@id, "prozorro_auction_documents_attributes") and contains(@id, "url")]
  Input Text         ${url_elements[-1]}          ${urlpath}
  Sleep  5
  Click Element     xpath=//input[@name="commit"]
  Sleep    5
  Reload Page

Додати офлайн документ
  [Arguments]  ${user_name}  ${tender_id}  ${accessDetails}
  Reload Page
  ${at_auc_page}=    Run Keyword And return Status    Wait Until Element Is Visible	xpath=//a[text()[contains(.,'Змінити')]]	10s
  Run Keyword If	${at_auc_page}	Click Element   xpath=//a[text()[contains(.,'Змінити')]]
  Wait Until Element Is Visible	    xpath=//div[text()[contains(.,'Редагування аукціону')]]    10
  ${add_doc_button}=   Get Webelements     xpath=//a[@class="button btn_white documents_add add_fields"]
  Click Element       ${add_doc_button[-1]}
  Reload Page
  tabua.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}

Скасувати закупівлю
  [Arguments]  ${user_name}  ${tender_id}  ${reason}  ${doc_path}  ${description}
  tabua.Пошук тендера по ідентифікатору  ${user_name}  ${tender_id}
  Click Element                         xpath=//a[contains(@class, "button btn_white cancel_auction warning") and contains(@class, "add_fields")]
  Wait Until Element Is Visible			xpath=//span[contains(@id, "select2-prozorro_auction_cancellations_attributes_") and contains(@id, "_reason_ua-container")]    5
  Sleep    5
  Click Element                         xpath=//span[contains(@aria-labelledby, "_reason_ua-container")]
  Sleep    5
  Input Text                            xpath=//input[@role="textbox"]    ${reason}
  Sleep    5
  Click Element                         xpath=//li[contains(@id, "select2-prozorro_auction_cancellations_attributes_")]
  Sleep    5
  Click Element                         xpath=//a[@class="button btn_white documents_add add_fields"]
  Sleep    5
  Choose File                           xpath=//input[@type="file"]        ${doc_path}
  Sleep    5
  Input Text                            xpath=//input[@id="cancellation_file_description"]    ${description}
  Sleep    5
  Click Element                         xpath=//input[@name="commit"]
  Sleep    10

Додати предмет закупівлі
  [Arguments]   @{ARGUMENTS}
  [Documentation]
  ...     ${ARGUMENTS[0]} == username
  ...     ${ARGUMENTS[1]} == tender_uaid
  ...     ${ARGUMENTS[2]} == item_info
  Log To Console    Add predmet - ${ARGUMENTS[2]}

Видалити предмет закупівлі
  [Arguments]   @{ARGUMENTS}
  [Documentation]
  ...     ${ARGUMENTS[0]} == username
  ...     ${ARGUMENTS[1]} == tender_uaid
  ...     ${ARGUMENTS[2]} == item_id
  Log To Console    Del predmet - ${ARGUMENTS[2]}


#################### Questions ######################

Задати запитання на тендер
  [Arguments]  ${user_name}  ${tender_id}  ${question_data}
  Sleep   3
  Reload Page
  Wait Until Element Is Visible			xpath=//div[@class="columns blue_block questions"]//span[@class="button your_organization_need_verified to_modal"]	 5
  Click Element							xpath=//div[@class="columns blue_block questions"]//span[@class="button your_organization_need_verified to_modal"]
  Wait Until Element Is Visible			id=prozorro_question_title   5
  Input Text							id=prozorro_question_title	${question_data.data.title}
  Sleep   3
  Input Text							id=prozorro_question_description	${question_data.data.description}
  Click Element							xpath=//input[@name="commit"]
  Sleep   2
  Check if question on page by id       ${question_data.data.title}
  Sleep   10
  Reload Page

Check if question on page by id
  [Arguments]  ${q_id}
   : FOR   ${INDEX}  IN RANGE    1   15
  \   ${text}=   Get Matching Xpath Count   xpath=//ul[@class="questions_list"]//div[@class="question_title" and contains(text(),"${q_id}")]
  \   Exit For Loop If  '${text}' > '0'
  \   Sleep     10
  \   Reload Page

Задати запитання на предмет
  [Arguments]  ${username}  ${tender_uaid}  ${item_id}  ${question_data}
  tabua.Пошук тендера по ідентифікатору  ${username}  ${tender_uaid}
  Wait Until Element Is Visible			xpath=//div[@class="columns blue_block questions"]//span[@class="button your_organization_need_verified to_modal"]	 20
  Sleep    2
  Click Element							xpath=//div[@class="columns blue_block questions"]//span[@class="button your_organization_need_verified to_modal"]
  Wait Until Element Is Visible			id=prozorro_question_title   20
  Input Text							id=prozorro_question_title	                                    ${question_data.data.title}
  sleep   3
  ${arrow_elements} =    Get Webelements     xpath=//span[@class="select2-selection__arrow"]
  ${arrow_length} =    Get Length    ${arrow_elements}
  Click Element							${arrow_elements[-1]}
  Sleep    2
  Input Text							xpath=//input[@class="select2-search__field"]	                ${item_id}
  Sleep    3
  Click Element                         xpath=//li[contains(@id, "select2-prozorro_question_item_id-result-")]
  Sleep    1
  Input Text							id=prozorro_question_description	                ${question_data.data.description}
  Sleep    2
  Click Element							xpath=//input[@name="commit"]
  Check if question on page by id       ${question_data.data.title}

Отримати інформацію із запитання
  [Arguments]  ${username}  ${tender_uaid}  ${questions_id}  ${field_name}
  Check if question on page by id       ${questions_id}
  ${titles} =    Get Webelements     xpath=//ul[@class="questions_list"]/li/div[@class="question_title"]
  ${descriptions} =    Get Webelements     xpath=//ul[@class="questions_list"]/li/div[@class="question_text"]
  ${size} =    Get Length	${titles}
  ${title} =	Set Variable	${EMPTY}
  ${descr} =    Set Variable	${EMPTY}
  : FOR    ${i}    IN RANGE    0    ${size}+1
  \    ${title} =    Get Text    ${titles[${i}]}
  \    ${descr} =    Get Text    ${descriptions[${i}]}
  \    Exit For Loop If    "${questions_id}" in "${title}"
  ${return_value}=      Run Keyword If   '${field_name}' == 'title'
    ...     Set Variable    ${title}
    ...     ELSE IF  '${field_name}' == 'answer'     Get Text   xpath=//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//span[@class='qa_answer']
    ...     ELSE    Get Text   xpath=//div[@class='zk-question' and .//p[contains(text(), '${question_id}')]]//div[contains(@class, 'qa_message_description')]
  [Return]     ${return_value}

Check if question on page by num
  [Arguments]  ${num}
  : FOR   ${INDEX}  IN RANGE    1   15
  \   Log To Console   .   no_newline=true
  \   ${question_list}=    Get Webelements    xpath=//ul[@class="questions_list"]/li/div[@class="question_title"]
  \   ${q_lenght}=    Get Length    ${question_list}
  \   Sleep     10
  \   Exit For Loop If  '${q_lenght}' > '${num}'
  \   Reload Page
  \   Sleep     10

Отримати інформацію про questions[0].title
  Check if question on page by num    0
  ${q_title_els}=    Get Webelements     xpath=//ul[@class="questions_list"]/li/div[@class="question_title"]
  ${q_title}=   Get Text  ${q_title_els[0]}
  [Return]    ${q_title}

Отримати інформацію про questions[1].title
  Check if question on page by num    1
  ${q_title_els}=    Get Webelements     xpath=//ul[@class="questions_list"]/li/div[@class="question_title"]
  ${q_title}=   Get Text  ${q_title_els[1]}
  [Return]    ${q_title}

Отримати інформацію про questions[2].title
  Check if question on page by num    2
  ${q_title_els}=    Get Webelements     xpath=//ul[@class="questions_list"]/li/div[@class="question_title"]
  ${q_title}=   Get Text  ${q_title_els[2]}
  [Return]    ${q_title}

Отримати інформацію про questions[3].title
  Check if question on page by num    3
  ${q_title_els}=    Get Webelements     xpath=//ul[@class="questions_list"]/li/div[@class="question_title"]
  ${q_title}=   Get Text  ${q_title_els[3]}
  [Return]    ${q_title}

Отримати інформацію про questions[0].description
  Check if question on page by num    0
  ${q_descr_els}=    Get Webelements     xpath=//ul[@class="questions_list"]/li/div[@class="question_text"]
  ${q_descr}=   Get Text  ${q_descr_els[0]}
  [Return]    ${q_descr}

Отримати інформацію про questions[1].description
  Check if question on page by num    1
  ${q_descr_els}=    Get Webelements     xpath=//ul[@class="questions_list"]/li/div[@class="question_text"]
  ${q_descr}=   Get Text  ${q_descr_els[1]}
  [Return]    ${q_descr}

Отримати інформацію про questions[2].description
  Check if question on page by num    2
  ${q_descr_els}=    Get Webelements     xpath=//ul[@class="questions_list"]/li/div[@class="question_text"]
  ${q_descr}=   Get Text  ${q_descr_els[2]}
  [Return]    ${q_descr}

Отримати інформацію про questions[3].description
  Check if question on page by num    3
  ${q_descr_els}=    Get Webelements     xpath=//ul[@class="questions_list"]/li/div[@class="question_text"]
  ${q_descr}=   Get Text  ${q_descr_els[3]}
  [Return]    ${q_descr}

Отримати інформацію про questions[0].answer
  Check if question on page by num    0
  ${q_answ_els}=    Get Webelements     xpath=//div[@class="question_answer"]/div
  ${q_answ}=   Get Text  ${q_answ_els[0]}
  [Return]  ${q_answ}

Отримати інформацію про questions[1].answer
  Check if question on page by num    1
  ${q_answ_els}=    Get Webelements     xpath=//div[@class="question_answer"]/div
  ${q_answ}=   Get Text  ${q_answ_els[1]}
  [Return]  ${q_answ}

Отримати інформацію про questions[2].answer
  Check if question on page by num    2
  ${q_answ_els}=    Get Webelements     xpath=//div[@class="question_answer"]/div
  ${q_answ}=   Get Text  ${q_answ_els[2]}
  [Return]  ${q_answ}

Отримати інформацію про questions[3].answer
  Check if question on page by num    3
  ${q_answ_els}=    Get Webelements     xpath=//div[@class="question_answer"]/div
  ${q_answ}=   Get Text  ${q_answ_els[3]}
  [Return]  ${q_answ}

Відповісти на запитання
  [Arguments]  ${user_name}  ${tender_id}  ${answer_data}  ${question_id}
  Check if question on page by id       ${question_id}
  ${titles} =           Get Webelements     xpath=//ul[@class="questions_list"]/li/div[@class="question_title"]
  ${answer_buttons} =   Get Webelements     xpath=//span[text()[contains(.,'Дати відповідь')]]
  ${t_size} =    Get Length    ${titles}
  ${answ_size} =	Get Matching Xpath Count	xpath=//ul[@class="questions_list"]/li/div[@class="question_answer"]/div
  ${title} =	Set Variable	${EMPTY}
  : FOR    ${i}    IN RANGE    0    ${t_size}+1
  \    ${title} =	Get Text   ${titles[${i}]}
  \    Exit For Loop If    "${question_id}" in "${title}"
  ${index}=    Evaluate    ${i} - ${answ_size}
  Click Button    ${answer_buttons[${index}]}
  Wait Until Element Is Visible	   xpath=//textarea[@id='prozorro_question_answer']
  Input Text	xpath=//textarea[@id='prozorro_question_answer']	${answer_data.data.answer}
  Click Button	xpath=//input[@name="commit"]
  Sleep     20
  Reload Page

#################### Bids #########################

Подати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} == username
  ...      ${ARGUMENTS[1]} == tender_uaid
  ...      ${ARGUMENTS[2]} == ${test_bid_data}
  tabua.Пошук тендера по ідентифікатору  ${ARGUMENTS[0]}    ${ARGUMENTS[1]}
  ${has_value}=    check_has_value   ${ARGUMENTS[2].data}
  Wait Until Element Is Visible			xpath=//div[@class="auction_buttons"]/span[@class="button your_organization_need_verified to_modal"]	20
  Sleep    2
  Click Element     xpath=//div[@class="auction_buttons"]/span[@class="button your_organization_need_verified to_modal"]
  Run Keyword If   ${has_value}   tabua.Ввести цінову пропозицію    ${ARGUMENTS[2]}

  ${confirm_webelements}=    Get Webelements     xpath=//div[@class="form_block confirm_rules"]
  ${conf_len} =    Get Length    ${confirm_webelements}
  :FOR   ${INDEX_C}  IN RANGE    0    ${conf_len}
  \   Run Keyword If    '${ARGUMENTS[2].data.qualified}'== 'True'    Click Element    ${confirm_webelements[${INDEX_C}]}
  \   Sleep   1
  Sleep     5
  Run Keyword If    '${ARGUMENTS[0]}' == 'tabua_Provider1'    tabua.Подати заявку про непричетність
  Run Keyword If    '${ARGUMENTS[0]}' == 'tabua_Provider'    tabua.Подати заявку про непричетність
  Sleep    1
  Click Element       xpath=//input[@name="commit"]
  Sleep     5
  Reload Page
  :FOR   ${INDEX_N}  IN RANGE    1    5
  \   ${button_change}=    Run Keyword And return Status    Wait Until Element Is Visible  	xpath=//span[@class="button to_modal"]	  10s
  \   Exit For Loop If    ${button_change}
  \   Sleep   5
  \   Reload Page
  Wait Until Element Is Visible	      xpath=//span[@class="button to_modal"]	  10s
  ${result}=    Set Variable    'Вашу пропозицію було прийнято'
  [Return]     ${result}

Ввести цінову пропозицію
  [Arguments]  ${test_bid_data}
  ${amount}=    Get From Dictionary     ${test_bid_data.data.value}    amount
  ${amount_bid}=    Convert To Integer                 ${amount}
  Sleep     3
  Clear Element Text  xpath=//input[@id="prozorro_bid_value_attributes_amount"]
  Input Text          xpath=//input[@id="prozorro_bid_value_attributes_amount"]    ${amount_bid}

Подати заявку про непричетність
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  ${doc_buttons} =    Get Webelements    xpath=//a[@class="button btn_white documents_add add_fields"]
  Click Element    ${doc_buttons[0]}
  Sleep    1
  ${inp_files} =    Get Webelements    xpath=//input[@type="file"]
  Choose File        ${inp_files[0]}       ${file_path}
  Sleep    2

Скасувати цінову пропозицію
  [Arguments]    ${user_name}    ${tender_id}
  tabua.Пошук тендера по ідентифікатору    ${user_name}     ${tender_id}
  Wait Until Element Is Visible			xpath=//span[@class="button warning to_modal"]	20
  Sleep    2
  Click Element     xpath=//span[@class="button warning to_modal"]
  Sleep    3
  Wait Until Element Is Visible			xpath=//label[@for="prozorro_bid_confirm_cancellation"]	20
  Click Element     xpath=//label[@for="prozorro_bid_confirm_cancellation"]
  Sleep    2
  Click Element     xpath=//input[@name="commit"]
  Sleep     3

Завантажити фінансову ліцензію
  [Arguments]  ${user_name}  ${tender_id}  ${financial_license_path}
  tabua.Завантажити документ в ставку    ${user_name}    ${tender_id}    ${financial_license_path}

Змінити документ в ставці
  [Arguments]  ${user_name}  ${tender_id}  ${filepath}  ${bidid}
  tabua.Завантажити документ в ставку    ${user_name}    ${tender_id}    ${filepath}

Завантажити документ в ставку
  [Arguments]  ${user_name}  ${tender_id}  ${financial_license_path}
  Click Element   xpath=//span[@class="button to_modal"]
  Wait Until Element Is Visible  	xpath=//a[@class="button btn_white documents_add add_fields"]	10s
  ${doc_buttons} =    Get Webelements    xpath=//a[@class="button btn_white documents_add add_fields"]
  Sleep  2
  Click Element    ${doc_buttons[-1]}
  Sleep  3
  ${inp_files} =    Get Webelements    xpath=//input[@type="file"]
  Choose File       ${inp_files[-1]}        ${financial_license_path}
  Sleep  2
  Click Element     xpath=//input[@name="commit"]
  Sleep   3

Змінити цінову пропозицію
  [Arguments]  ${user_name}  ${tender_id}  ${name}  ${amount_bid}
  ${amount_bid}=   Convert To String    ${amount_bid}
  Click Element   xpath=//span[@class="button to_modal"]
  Wait Until Element Is Visible	  xpath=//a[@class="button btn_white documents_add add_fields"]	  10s
  Clear Element Text  xpath=//input[@id="prozorro_bid_value_attributes_amount"]
  Input Text          xpath=//input[@id="prozorro_bid_value_attributes_amount"]    ${amount_bid}
  Click Element       xpath=//input[@name="commit"]
  Sleep     3

Отримати інформацію із пропозиції
  [Arguments]  ${user_name}  ${tender_id}  ${field}
  ${dollar}= 	Get Text			xpath=//div[@class="your_bid_amount"]/span
  ${cent}= 	    Get Text			xpath=//div[@class="your_bid_amount"]/span/span
  ${result}=    convert_to_price    ${dollar}    ${cent}
  [return]  ${result}

######### Document Viewer ###########
Отримати документ
  [Arguments]  ${username}  ${tender_uaid}  ${doc_id}
  Sleep  2
  tabua.Пошук тендера по ідентифікатору  ${user_name}  ${tender_uaid}
  Sleep   2
  Click Element   xpath=//a[text()[contains(.,'Документи')]]
  Sleep    5
  ${file_name}=   Get Text   xpath=//a[contains(text(), '${doc_id}')]
  Sleep  5
  ${url}=   Get Element Attribute   xpath=//a[contains(text(), '${doc_id}')]@href
  download_file   ${url}  ${file_name}  ${OUTPUT_DIR}
  [Return]  ${file_name}

Отримати кількість документів в тендері
  [Arguments]   @{ARGUMENTS}
  Click Element   xpath=//a[text()[contains(.,'Документи')]]
  ${number_of_documents}=  Get Matching Xpath Count  //div[@class="document_description"]
  [return]  ${number_of_documents}

Отримати інформацію із документа по індексу
  [Arguments]  ${username}  ${tender_uaid}  ${document_index}  ${field}
  ${doc_value}=  Get Element Attribute  xpath=//li[contains(@class, "document_type_")][${document_index + 1}]@class
  ${doc_value}=  convert_tabua_string_to_common_string  ${doc_value}
  [return]  ${doc_value}

Отримати інформацію із документа
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...       ${ARGUMENTS[0]} == username
  ...       ${ARGUMENTS[1]} == auction_uaid
  ...       ${ARGUMENTS[2]} == doc_id
  ...       ${ARGUMENTS[3]} == field
  Sleep     2
  Click Element   xpath=//a[text()[contains(.,'Документи')]]
  Sleep     2
  Run Keyword And Return If    '${ARGUMENTS[3]}' == 'title'    Get Text   xpath=//a[text()[contains(.,'${ARGUMENTS[2]}')]]
  Run Keyword And Return If    '${ARGUMENTS[3]}' == 'description'    Get Text   xpath=//div[contains(@class, "document_description")]
  [Return]

Отримати посилання на аукціон для глядача
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderId
  Switch Browser   ${BROWSER_ALIAS}
  tabua.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Sleep  120
  Reload Page
  Wait Until Page Contains Element    xpath=//span[@class="auction_link"]/a     300
  ${url}=  Get Element Attribute    xpath=//span[@class="auction_link"]/a@href
  [Return]   ${url}

Отримати посилання на аукціон для учасника
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderId
  Switch Browser   ${BROWSER_ALIAS}
  tabua.Пошук тендера по ідентифікатору    ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Sleep  30
  Reload Page
  ${avail_secure_url}=    Run Keyword And return Status    Wait Until Page Contains Element    xpath=//div[@class="bid_auction_link"]/a     300
  ${url}=    Run Keyword If    ${avail_secure_url}
    ...      Get Element Attribute    xpath=//div[@class="bid_auction_link"]/a@href
    ...      ELSE
    ...      Get Element Attribute    xpath=//span[@class="auction_link"]/a@href
  Sleep  5
  [Return]   ${url}


Отримати посилання на аукціон для зареєстрованого учасника
  ${url}=  Get Element Attribute    xpath=//div[@class="bid_auction_link"]/a@href
  [Return]   ${url}

Отримати посилання на аукціон для незареєстрованого учасника
  ${url}=  Get Element Attribute    xpath=//span[@class="auction_link"]/a@href
  [Return]   ${url}


Завантажити протокол аукціону в авард
  [Arguments]   ${user_name}   ${tender_uaid}   ${auction_protocol_path}   ${award_index}
  Sleep    30
  Reload Page
  Sleep    3
  Click Element    xpath=//div[contains (@class, "columns bid_status bid_status_award_pending_verification")]
  Wait Until Element Is Visible    xpath=//span[@class="button to_modal"]    5
  Click Element    xpath=//span[@class="button to_modal"]
  Sleep  5
  Click Element    xpath=//a[@class="button btn_white documents_add add_fields"]
  Sleep  5
  Choose File      xpath=//input[@type="file"]        ${auction_protocol_path}
  Sleep  5
  Click Element    xpath=//input[@name="commit"]
  Sleep  10

Підтвердити наявність протоколу аукціону
  [Arguments]   @{ARGUMENTS}
  [Documentation]
  ...       ${ARGUMENTS[0]} == auction_uaid
  ...       ${ARGUMENTS[1]} == index
  ${response}=      Run Keyword If   'Неможливість змінити статус' in '${TEST NAME}'     '${False}'
  ${response}=      Run Keyword If   'Можливість підтвердити наявність протоколу аукціону' in '${TEST NAME}'   Log To Console   ok
  [Return]     ${response}

Підтвердити постачальника
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  ${winner_open}=    Run Keyword And return Status    Wait Until Element Is Visible    xpath=//span[@class="button to_modal"]    10s
  Run Keyword If     '${winner_open}' != 'True'    Click Element    xpath=//div[contains (@class, "columns bid_status bid_status_award_pending_payment")]
  Sleep     2
  Click Element  xpath=//span[@class="button to_modal"]
  Sleep     5
  Run Keyword If    '${TEST NAME}' == 'Можливість підтвердити оплату першого кандидата'   Click Element  xpath=//input[@name="commit"]
  Run Keyword If    '${TEST NAME}' == 'Можливість підтвердити оплату другого кандидата'   Click Element  xpath=//input[@name="commit"]
  Sleep     5

Дискваліфікувати постачальника
  [Arguments]  ${username}  ${tender_id}  ${award_num}  ${description}
  ${opened}=    Run Keyword And return Status    Wait Until Element Is Visible    xpath=//span[@class="button to_modal"]    10s
  Sleep    150
  Reload Page
  Wait Until Page Contains Element      xpath=//div[contains(@class, "columns bid_status bid_status_contract_pending") or contains(@class, "columns bid_status bid_status_award_pending_verification") or contains(@class, "columns bid_status bid_status_award_pending_payment")]    20
  Sleep    10
  Click Element    xpath=//div[contains (@class, "columns bid_status bid_status_contract_pending") or contains(@class, "columns bid_status bid_status_award_pending_verification") or contains(@class, "columns bid_status bid_status_award_pending_payment")]
  Sleep     10
  Click Element     xpath=//span[@class="button warning to_modal"]
  Sleep     5
  Wait Until Page Contains Element      xpath=//input[@class="validate-required"]
  Input Text    id=prozorro_award_title_ua           ${description}
  Input Text    id=prozorro_award_description_ua     ${description}
  Sleep     2
  ${add_file}=    Run Keyword And return Status    Wait Until Element Is Visible    xpath=//a[@class="button btn_white documents_add add_fields"]    10s
  Run Keyword If     '${add_file}' == 'True'        Add disqualification file
  Click Element  xpath=//input[@name="commit"]
  Sleep     10

Add disqualification file
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  Click Element    xpath=//a[@class="button btn_white documents_add add_fields"]
  Sleep  5
  Choose File      xpath=//input[@type="file"]        ${file_path}
  Sleep     2

Завантажити угоду до тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]}  ==  user_name
  ...      ${ARGUMENTS[1]}  ==  auction_uaid
  ...      ${ARGUMENTS[2]}  ==  contract_num
  ...      ${ARGUMENTS[3]}  ==  file_path
  ${opened}=    Run Keyword And return Status    Wait Until Element Is Visible    xpath=//span[@class="button to_modal"]    30s
  Wait Until Page Contains Element      xpath=//div[contains (@class, "columns bid_status bid_status_contract_pending")]    120
  Run Keyword If     '${opened}' != 'True'    Click Element    xpath=//div[contains (@class, "columns bid_status bid_status_contract_pending")]
  Sleep     2
  Click Element     xpath=//span[@class="button to_modal"]
  Sleep     5
  Wait Until Page Contains Element      xpath=//div[@class="contract_confirm_document"]
#  Input Text    id=prozorro_contract_contract_number     ${ARGUMENTS[2]}
#  Sleep     5
#  ${cdate} =    get_currt_date
#  Input Text    id=prozorro_contract_date_signed     ${cdate}
  Sleep     5
  Click Element    xpath=//a[@class="button btn_white documents_add add_fields"]
  Sleep  5
  Choose File      xpath=//input[@type="file"]        ${ARGUMENTS[3]}
  Sleep  5
  Click Element    xpath=//input[@name="commit"]
  Sleep  10

  ${opened}=    Run Keyword And return Status    Wait Until Element Is Visible    xpath=//span[@class="button to_modal"]    30s
  Wait Until Page Contains Element      xpath=//div[contains (@class, "columns bid_status bid_status_contract_pending")]    120
  Run Keyword If     '${opened}' != 'True'    Click Element    xpath=//div[contains (@class, "columns bid_status bid_status_contract_pending")]
  Sleep     2
  ${modal_buttons}=   Get Webelements      xpath=//span[@class="button to_modal"]
  Click Element     ${modal_buttons[-1]}
  Sleep     2
  Click Element     xpath=//a[@class="button"]


Підтвердити підписання контракту
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  Sleep    20
  tabua.Пошук тендера по ідентифікатору    ${username}   ${tender_uaid}
  Wait Until Page Contains Element      xpath=//span[text()[contains(.,'Договір підписано')]]    15

Скасування рішення кваліфікаційної комісії
  [Arguments]  ${username}  ${tender_uaid}  ${award_num}
  tabua.Пошук тендера по ідентифікатору    ${username}    ${tender_uaid}
  Sleep    5
  Click Element    xpath=//span[contains(@class, "guarantee_back_button")]
  Wait Until Element Is Visible    xpath=//div[contains(text(), "Відмова від очікування")]    10
  Wait Until Element Is Visible			xpath=//label[@for="prozorro_award_confirm_cancellation"]	10
  Click Element    xpath=//label[@for="prozorro_award_confirm_cancellation"]
  ${file_path}  ${file_name}  ${file_content}=  create_fake_doc
  Click Element    xpath=//a[@class="button btn_white documents_add add_fields"]
  Sleep  5
  Choose File      xpath=//input[@type="file"]        ${file_path}
  Sleep  5
  Click Element    xpath=//input[@name="commit"]
  Sleep  10
