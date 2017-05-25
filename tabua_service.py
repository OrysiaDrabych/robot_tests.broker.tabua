# -*- coding: utf-8 -*-

import urllib
import datetime

def update_test_data(role_name, tender_data):
    name_dict = {
        u'штуки': u'штука',
        u'метри квадратні': u'метр кв.',
        u'послуга': u'послуга'
    }
    if role_name == 'tender_owner':
        tender_data['data']['procuringEntity']['name'] = u'ПАТ "Тест Банк"'
    tender_data['data']['guarantee']['amount'] = tender_data['data']['value']['amount']* 0.011
    for el in tender_data['data']['items']:
        if el['unit']['name'] in name_dict:
            el['unit']['name'] = name_dict[el['unit']['name']]
    return tender_data

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
        u'H87': u'H87',
    }
    return unit_name_dictionary[raw_code]

def get_select_unit_name(raw_name):
    unit_name_dictionary = {
        u'м²': u'метри квадратні',
        u'м³': u'метри куб.',
        u'м': u'метри',
        u"посл": u"послуга",
        u'шт': u'штуки',
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
        u'ящ': 'ящик',
        u'уп': 'упаковка'
    }
    return unit_name_dictionary[raw_name]

def convert_desc(desc1, desc2):
    desc = desc1.replace(desc2, '').strip()
    return desc

def get_nonzero_num(code_str):
    code_str = code_str.split('-')[0]
    while code_str[-1] == '0':
        code_str = code_str[:-1]
    if code_str[0] == '0':
        start_num = 2
    else:
        start_num = 1
    return len(code_str) + 1, start_num

def repair_start_date(date_s):
    d_list = str(date_s).split('-')
    return '{0}.{1}.{2}'.format(d_list[2][:2], d_list[1], d_list[0])

def get_first_symbols(code_str, num):
    return 'cav_' + code_str[:int(num)]

def get_region_name(region_name):
    if region_name == u'місто Київ':
        return u'Київ'
    return region_name

def change_dgf(dgf):
    if 'dgf_financial_assets' in dgf:
        dgf = 'dgfFinancialAssets'
    else:
        dgf = 'dgfOtherAssets'
    return dgf

def get_auc_url(url_id_p):
    return 'http://staging_sale.tab.com.ua/auctions/{}'.format(url_id_p.split('_')[-1])

def get_ua_id(ua_id):
    if u'UA-EA-' in ua_id:
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
    return proc_method.split(':')[-1].strip()

def convert_string_to_integer(_str):
    return {
        u"Вперше.": 1,
        u"Вдруге": 2,
        u"Втрете": 3,
        u"Вчетверте": 4,
    }.get(_str, _str)

def compare_two_strings(str_1, str_2):
    return str_1 == str_2

def convert_to_price(dol, cent):
    return float(dol.replace(u'"', '').replace(u' ', ''))

def convert_tabua_string_to_common_string(string):
    return {
        u"грн.": u"UAH",
        u"шт.": u"штуки",
        u"кв.м.": u"метри квадратні",
        u"метры квадратные": u"метри квадратні",
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
        u"Очікування пропозицій": u"active.tendering",
        u"Період аукціону": u"active.auction",
        u"Пропозиції розглянуто": u"active.awarded",
        u"Кваліфікація": u"active.qualification",
        u"Завершений": u"complete",
        u"Відмінений": u"cancelled",
        u"Аукціон" : u"active.auction",
        u"Аукціон не відбувся" : u"unsuccessful",
    }.get(string, string)

def download_file(url, file_name, output_dir):
    urllib.urlretrieve(url, ('{}/{}'.format(output_dir, file_name)))

def get_currt_date():
    i = datetime.datetime.now()
    return i.strftime('%d.%m.%y')

def get_int_sleep(base_sleep, mult=1):
    min_v = int(base_sleep * mult)
    return min_v + ((base_sleep * mult - min_v) > 0)
