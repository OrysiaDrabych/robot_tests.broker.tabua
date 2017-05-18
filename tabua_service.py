# -*- coding: utf-8 -*-

import urllib

def update_test_data(role_name, tender_data):
    if role_name == 'tender_owner':
        tender_data['data']['procuringEntity']['name'] = u'ПАТ "Тест Банк"'
    return tender_data

def substract(dividend, divisor):
    return int(dividend) - int(divisor)

def convert_prom_string_to_common_string(string):
    return {
        u"грн.": u"UAH",
        u"шт.": u"штуки",
        u"кв.м.": u"метри квадратні",
        u"метры квадратные": u"метри квадратні",
        u" з ПДВ": True,
        u"Класифікатор:": u"CAV",
        u"Період уточнень": u"active.enquiries",
        u"Прийом пропозицій": u"active.tendering",
        u"Аукціон": u"active.auction",
        u"Кваліфікація": u"active.qualification",
        u"Скасована": u"cancelled",
        u"Аукціон не відбувся": u"unsuccessful",
        u"Аукцион не состоялся": u"unsuccessful",
        u"Завершена": u"complete",
        u"Подписанный": u"active",
        u"Впервые": u"Лот виставляється вперше",
        u"Повторно": u"Лот виставляється повторно",
    }.get(string, string)

def get_select_unit_name(standard_unit_name):
    unit_name_dictionary = {
        u'послуга': 'E48',
        u'ящик': 'BX',
        u'блок': 'D64',
        u'Гігакалорія': 'GRM',
        # u'роботи': '',
        u'рейс': 'E54',
        u'штуки': 'H87',
        u'гектар': 'HAR',
        u'кілограми': 'KGM',
        u'кілометри': 'KMT',
        u"грн": u"UAH",
        u"посл": u"послуга"
        # u'комплект': '',
    }
    return unit_name_dictionary[standard_unit_name]

def convert_desc(desc1, desc2):
    desc = desc1.replace(desc2, '').strip()
    return desc

def get_nonzero_num(code_str):
    code_str = code_str.split('-')[0]
    while code_str[-1] == '0':
        code_str = code_str[:-1]
    return len(code_str) + 1

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

################ WARNING - hardcode
def get_min_guarant(start_price):
    return str(start_price * 0.011)
################ WARNING - hardcode

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
        u"Очікування пропозицій": u"active.auction",
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
