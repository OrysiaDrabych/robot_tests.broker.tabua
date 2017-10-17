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

def convert_desc(main_desc, desc1, desc2):
    desc = main_desc.replace(desc1, '').replace(desc2, '').strip()
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

def repair_tenderperiod_enddate(date_e):
    # return date_e.split('/')[0].strip()
    return date_e.replace(' / ', ' ').strip() + ':00.000000+03:00'

def get_first_symbols(code_str, num):
    return 'cav_' + code_str[:int(num)]

def get_region_name(region_name):
    if region_name == u'місто Київ':
        return u'Київ'
    return region_name

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
    return {
        u"Очікується підписання протоколу": u'pending.verification',
        u"Очікується оплата": u'pending.payment',
        u"Очікується підписання договора": u'active',
        u"Очікує дискваліфікації першого учасника": u'pending.waiting',
        u"Відмова очікування": u'cancelled',
        u"Договір скасовано": u'unsuccessful',
        u"Дискваліфіковано": u'unsuccessful',
        u"Опубліковано": u'active',
        u"Пропозицію анульовано": u'invalid',
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

def convert_to_price(dol, cent):
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

def get_award_status(status_0, status_1, date_0, date_1, num):
    status_list = [status_0, status_1]
    date_list = [date_0, date_1]
    date_l = [datetime.datetime.strptime(x.split(': ')[1], "%d.%m.%Y %H:%M") for x in date_list]
    if (date_l[0] > date_l[1] and int(num)) or (date_l[0] < date_l[1] and not int(num)):
        return convert_nt_string_to_common_string(status_list[0])
    else:
        return convert_nt_string_to_common_string(status_list[1])
