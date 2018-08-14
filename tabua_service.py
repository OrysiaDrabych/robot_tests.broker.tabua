# -*- coding: utf-8 -*-

import urllib
import datetime

def update_test_data(role_name, tender_data):
    name_dict = {
        u'штуки': u'штука',
        u'метри квадратні': u'метр кв.',
        u'послуга': u'послуга'
    }

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

def get_html_scheme(classification_scheme):
    if classification_scheme == 'CPV':
        return 'cpv'
    else:
        return 'cav-ps'

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

def repair_start_date(date_s):
    d_list = str(date_s).split('-')
    return '{0}.{1}.{2}'.format(d_list[2][:2], d_list[1], d_list[0])

def get_region_name(region_name):
    if region_name == u'місто Київ':
        return u'Київ'
    return region_name

def get_region_name_asset_holder(region_name):
    if region_name == u'місто Київ':
        return u'Київ'
    return region_name.split(' ')[0]

def get_ua_id_asset(ua_id):
    if u'UA-AR-' in ua_id:
        return ua_id
    return ''

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

def convert_to_price(dol, cent=None):
    return float(dol.replace(u'"', '').replace(u' ', ''))

def download_file(url, file_name, output_dir):
    urllib.urlretrieve(url, ('{}/{}'.format(output_dir, file_name)))

def get_decision_id(item_index, tag):
    ID_DICT = {
        'title': 'prozorro_asset_decisions_attributes_{}_title_ua',
        'id': 'prozorro_asset_decisions_attributes_{}_decision_id',
        'date': 'prozorro_asset_decisions_attributes_{}_date',
    }
    return ID_DICT[tag].format(item_index)

def refactor_names(our_name):
    our_name = our_name.strip()
    NAMES_DICT = {
        'active_auction': 'active.auction',
        'active_tendering': 'active.tendering',
        'sellout_english': 'sellout.english',
        'active_qualification': 'active.qualification',
    }
    if our_name in NAMES_DICT:
        return NAMES_DICT[our_name].decode('UTF-8')
    return our_name

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

def check_has_value(dict):
    return 'value' in dict
