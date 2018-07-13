# -*- coding: utf-8 -*-

import urllib
import datetime

def update_test_data(role_name, tender_data):
    name_dict = {
        u'штуки': u'штука',
        u'метри квадратні': u'метр кв.',
        u'послуга': u'послуга'
    }
    # if role_name == 'tender_owner':
    #     tender_data['data']['procuringEntity']['name'] = u'ПАТ "Тест Майно"'
    for el in tender_data['data']['items']:
        if el['unit']['name'] in name_dict:
            el['unit']['name'] = name_dict[el['unit']['name']]

    if role_name == 'tender_owner' and 'assetCustodian' in tender_data['data']:
        tender_data['data']['assetCustodian']['identifier']['id'] = u'32143254'
        tender_data['data']['assetCustodian']['identifier']['legalName'] = u'ТОВ "Тестовий Приватизатор"'
        tender_data['data']['assetCustodian']['contactPoint']['name'] = u'Приватизенко Приватизат Приватизатович'
        tender_data['data']['assetCustodian']['contactPoint']['telephone'] = u'380333333333'
        tender_data['data']['assetCustodian']['contactPoint']['email'] = u'tab_privatization@yopmail.com'

    return tender_data

def get_html_scheme1(classification_scheme):
    if classification_scheme == 'CPV':
        return 'cpv'
    else:
        return 'cav-ps'

def get_html_scheme(classification_scheme):
    if classification_scheme == 'CPV':
        return 'cpv'
    else:
        return 'cavv2'

def substract(dividend, divisor):
    return int(dividend) - int(divisor)

def get_select_unit_code(raw_code):
    unit_name_dictionary = {
        u'кг': 'KGM',
        u'бл': 'D64',
        u'уп': 'PK',
        u'га': 'HAR',
        u'м²': 'MTK',
        u'м': 'MTR',
        u'наб': 'SET',
        u'км': 'KMT',
        u'м³': 'MTQ',
        u"фл": "VI",
        u'ящ': 'BX',
        u'шт': 'H87',
        u'т': 'TNE',
        u'рейс': 'E54',
        u'од': 'E50',
        u'бобіна': '4A',
        u'МВт-год/год': 'E07',
        u'посл': u'E48',
        u'г': 'GRM',
        u"год": "HUR",
        u'роб.день': 'E49',
        u'пач': 'RM',
        u"люд/год": "RH",
        u'E48': u'E48',
        u'MTK': 'MTK',
    }
    return unit_name_dictionary[raw_code]

def get_select_unit_name(raw_name):
    unit_name_dictionary = {
        u'м²': u'метр кв.',
        u'м³': u'метри куб.',
        u'м': u'метри',
        u'посл': u"послуга",
        u'шт': u'штука',
        u'кг': u'кілограми',
        u'км': u'кілометри',
        u'рейс': u'рейси',
        u'га': u'гектар',
        u"грн": u"UAH",
        u"посл": u"послуга",
        u'год': u'години',
        u'г': u'грами',
        u'бл': u'блок',
        u'т': u'тони',
        u'ящ': u'ящик',
        u'уп': u'упаковка'
    }
    return unit_name_dictionary[raw_name]

def convert_desc(main_desc, desc2):
    desc = main_desc.replace(desc2, '').strip()
    return desc

def get_nonzero_num(code_str):
    code_str = code_str.split('-')[0]
    if code_str[0] == '0':
        return len(code_str.strip('0')) + 2, 2
    else:
        return len(code_str.strip('0')) + 1, 1

def repair_start_date(date_s):
    d_list = str(date_s).split('-')
    return '{0}.{1}.{2}'.format(d_list[2][:2], d_list[1], d_list[0])

def repair_contract_period_date(c_date):
    date_list = c_date.split(u': ')[1].split(u'.')
    return u'{}-{}-{}T00:00:00+02:00'.format(date_list[2], date_list[1], date_list[0])

def repair_tenderperiod_enddate(date_e):
    # return date_e.split('/')[0].strip()
    return date_e.replace(' / ', ' ').strip() + ':00.000000+03:00'

def get_first_symbols(scheme, code_str, num):
    return scheme + '_' + code_str[:int(num)]

def get_region_name(region_name):
    if region_name == u'місто Київ':
        return u'Київ'
    return region_name

def get_region_name_asset_holder(region_name):
    if region_name == u'місто Київ':
        return u'Київ'
    return region_name.split(' ')[0]

def change_dgf(dgf):
    if 'dgf_financial_assets' in dgf:
        dgf = 'dgfFinancialAssets'
    elif 'dgf_insider' in dgf:
        dgf = 'dgfInsider'
    else:
        dgf = 'dgfOtherAssets'
    return dgf

def get_auc_url(url_id_p):
    return 'http://staging_sale.tab.com.ua/auctions/{}'.format(url_id_p.split('_')[-1])

def get_ua_id(ua_id):
    if u'UA-PS-' in ua_id:
        return ua_id
    return ''

def get_ua_id_asset(ua_id):
    if u'UA-AR-' in ua_id:
        return ua_id
    return ''

count = 0

def get_next_description(desc1, desc2, desc3):
    global count
    if count == 0:
        count +=1
        return desc1
    if count == 1:
        count +=1
        return desc2
    if count == 2:
        count = 0
        return desc3

def convert_nt_string_to_common_string(proc_method):
    return {
        u"Очікується підписання протоколу": u'pending.verification',
        u"Очікується оплата": u'pending.payment',
        u"Очікується підписання договора": u'active',
        u"Очікує дискваліфікації першого учасника": u'pending.waiting',
        u"Очікує дискваліфікації переможця": u'pending.waiting',
        u"Відмова очікування": u'cancelled',
        u"Договір скасовано": u'unsuccessful',
        u"Дискваліфіковано": u'unsuccessful',
        u"Опубліковано": u'active',
        u"Пропозицію анульовано": u'invalid',
        u"АУКЦІОН": u'sellout.english',
        u"АУКЦІОН ІЗ ЗНИЖЕННЯМ СТАРТОВОЇ ЦІНИ": u'sellout.english',
        u"АУКЦІОН ЗА МЕТОДОМ ПОКРОКОВОГО ЗНИЖЕННЯ СТАРТОВОЇ ЦІНИ ТА ПОДАЛЬШОГО ПОДАННЯ ЦІНОВИХ ПРОПОЗИЦІЙ": u'sellout.insider',
    }.get(proc_method, proc_method)

def convert_string_to_integer(_str):
    return {
        u"Вперше.": 1,
        u"Вперше": 1,
        u"Вдруге": 2,
        u"Втрете": 3,
        u"Втретє": 3,
        u"Вчетверте": 4,
        u"Впяте": 5,
        u"Вшосте": 6,
        u"Всьоме": 7,
    }.get(_str, _str)

def compare_two_strings(str_1, str_2):
    return str_1 == str_2

def convert_to_price(dol, cent=None):
    return float(dol.replace(u'"', '').replace(u' ', ''))

def convert_tabua_string_to_common_string(string):
    return {
        u"грн.": u"UAH",
        u"шт.": u"штука",
        u"кв.м.": u"метр кв.",
        u" з ПДВ": True,
        u"Класифікатор:": u"CAV",
        u'document_type_x_dgfplatformlegaldetails': u'x_dgfPlatformLegalDetails',
        u'document_type_x_dgfpublicassetcertificate': u'x_dgfpublicassetcertificate',
        u'document_type_x_nda': u'x_nda',
        u'document_type_virtualdataroom': u'virtualdataroom',
        u'document_type_tendernotice': u'tendernotice',
        u'document_type_x_presentation': u'x_presentation',
        u'document_type_technicalspecifications': u'technicalspecifications',
        u"document_type_": u"None",
        u"Очікування пропозицій": u"active.auction",
        u"Період аукціону": u"active.auction",
        u"Пропозиції розглянуто": u"active.awarded",
        u"Кваліфікація": u"active.qualification",
        u"Завершений": u"complete",
        u"Відмінений": u"cancelled",
        u"Аукціон": u"active.auction",
        u"Аукціон не відбувся": u"unsuccessful",
        u"Очікування аукціону": u"active.auction"
    }.get(string, string)

def convert_cancellations_status(cancel_reas):
    return {
        u"ПРИЧИНА СКАСУВАННЯ АУКЦІОНУ": u"active",
    }.get(cancel_reas, cancel_reas)

def download_file(url, file_name, output_dir):
    urllib.urlretrieve(url, ('{}/{}'.format(output_dir, file_name)))

def get_currt_date():
    i = datetime.datetime.now()
    return i.strftime('%d.%m.%Y')

def get_tag_field(doc_type):
    doc_tags_dict = {
        u'tenderNotice': u'tender_notice',
        u'x_presentation': u'x_presentation',
        u'technicalSpecifications': u'technical_specifications'
    }
    if doc_type in doc_tags_dict:
        return doc_tags_dict[doc_type]
    else:
        return u'tender_notice'

def check_has_value(dict):
    return 'value' in dict

def get_award_status(status):
    return convert_nt_string_to_common_string(status)

def get_first_string(str_wt):
    return float(str_wt.strip().split(' ')[0])

def get_decision_id(item_index, tag):
    ID_DICT = {
        'title': 'prozorro_asset_decisions_attributes_{}_title_ua',
        'id': 'prozorro_asset_decisions_attributes_{}_decision_id',
        'date': 'prozorro_asset_decisions_attributes_{}_date',
    }
    return ID_DICT[tag].format(item_index)

def get_date_from_uid(uid):
    return '.'.join(uid.split('-')[3:6])

def reflect_status(mp_status):
    mp_status = mp_status.strip()
    STATUS_DICT = {
        u'Опубліковано': 'pending',
        u'Опубліковано\nОчікування інформаційного повідомлення': 'pending',
        u'Виключено з переліку': 'deleted',
        u"Об’єкт виключено": 'deleted',
        u'Публікація інформаційного повідомлення': 'composing',
        u'Об’єкт виставлено на продаж': 'salable',
        u'Аукціон': 'auction'
    }
    return STATUS_DICT.get(mp_status)

def get_decision_date(number_date):
    return_value = number_date.split(u'від')[1].strip()
    if '.' in return_value:
        return_value = ('-').join(return_value.split('.')[::-1])
    return return_value


def get_decision_number(number_date):
    return number_date.split(u'від')[0].strip().strip(u'№')

def convert_doc_type(doc_type):
    DOC_TYPES_DICT = {
        u'Інформація про оприлюднення інформаційного повідомлення': 'informationDetails'
    }
    return DOC_TYPES_DICT.get(doc_type)

def split_colon(text, index):
    result = text.split(u':')[int(index)].strip()
    if index == 1:
        return result.split(' ')[0]
    return result

def split_space(text, index):
    return text.split(u' ')[int(index)].strip()

def convert_item_status(item_status):
    ITEM_STAT_DICT = {
        u"об’єкт зареєстровано": "complete",
        u"невідомо": "unknown",
        u"об’єкт реєструється": "registering",
    }
    return ITEM_STAT_DICT.get(item_status)

def get_duration_period(tendering_duration):
    DURATION_DICT = {
        'P1M': 30
    }
    return DURATION_DICT.get(tendering_duration)

def repair_start_date_temp(date_s):
    d_list = str(date_s).split('-')
    return '{0}.{1}.{2}'.format(d_list[2][:2], int(d_list[1])+2, d_list[0])

def repair_start_date_zero(start_date):
    sd_list = start_date.split(".")
    # current_date = datetime.datetime.now()
    # return "{}-{}-{}T{}:{}:00+03:00".format(sd_list[2], sd_list[1], sd_list[0], current_date.hour, current_date.minute - 1)
    return "{}-{}-{}T00:00:00+03:00".format(sd_list[2], sd_list[1], sd_list[0])

def correct_document_type_value(document_type):
    document_type_dict = {
        'technicalSpecifications': 'technical_specifications'
    }
    if document_type in document_type_dict:
        return document_type_dict[document_type]
    return document_type

def add_five_days(old_date):
    fs = u"%Y-%m-%dT%H:%M:%S.%f"
    dt_string = old_date[:-6]
    dt_5 = datetime.datetime.strptime(dt_string, fs) + datetime.timedelta(days=5)
    zone = old_date[-6:]
    new_date = datetime.datetime.strftime(dt_5, fs) + zone
    return new_date

def replace_none_with_empty(ent_str):
    if not ent_str:
        return u''
    return ent_str