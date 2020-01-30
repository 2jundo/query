#케이카 크롤링
import re
import requests
import json
import sys
from datetime import datetime
from urllib.request import urlopen
from bs4 import BeautifulSoup
import timeit
start = timeit.default_timer()
# 실행 코드
now = datetime.now()
now_f = str(now.year)+'/'+str(now.month)+'/'+str(now.day)

#벤츠 e https://www.kcar.com/car/info/car_info_imported_detail.do?i_sCarCd=EC60292041
base_url = 'https://www.kcar.com/car/info/car_info_detail.do?i_sCarCd=EC{}'
detail_url = 'https://www.kcar.com/car/info/inspdtl_pop.do?i_sCarCd=EC{}'
start = 60315106
end = 60315999

for n in range(start,end):
    try:
        url = base_url.format(n+1)
        webpage = urlopen(url)
        source = BeautifulSoup(webpage, 'html.parser')
        html = requests.get(url).text

        page_num = n+1
        page_num = str(page_num)

        #브랜드
        matched = re.search(r'makeNm : "(.*?)"', html, re.S)
        ORG_CAR_MAKER = matched.group(0)
        #대표모델
        matched = re.search(r'modelNm : "(.*?)"', html, re.S)
        CAR_MOEL_DT = matched.group(0)
        #상세모델
        matched = re.search(r'classNm : "(.*?)"', html, re.S)
        CAR_CLASS_NAME = matched.group(0)
        CAR_CLASS_NAME_F = CAR_CLASS_NAME.replace('classNm : \"', '') #,
        CAR_CLASS_NAME_F = CAR_CLASS_NAME_F.replace('\"', '') #,
        #print(CAR_CLASS_NAME_F)
        #금액
        matched = re.search(r'nPrice : "(.*?)"', html, re.S)
        ACQS_AMOUNT = matched.group(0)
#콤마만 없애요.
        FIN = ORG_CAR_MAKER + CAR_MOEL_DT
        FIN = FIN.replace('makeNm : \"', '')
        FIN = FIN.replace('\"modelNm : \"', ' ') #,
        FIN = FIN.replace('\"', '')
        FIN = FIN.replace(',', ',')
#        CAR_CLASS_NAME_F = CAR_CLASS_NAME.replace('classNm : \"', ' ') #,
#        CAR_CLASS_NAME_F = CAR_CLASS_NAME.replace('\"', '')
#        CAR_CLASS_NAME_F = CAR_CLASS_NAME.replace(',', ',')
        ACQS_AMOUNT_F = ACQS_AMOUNT.replace('\"nPrice : \"', '')
        ACQS_AMOUNT_F = ACQS_AMOUNT_F.replace('\"', '')
        ACQS_AMOUNT_F = ACQS_AMOUNT_F.replace('nPrice : ', '')

        #게시일(추정)
        board_date = source.select_one("#wrap > div.body > div.contents > div.chargerinfo > div.firstt > table > tbody > tr > td:nth-child(6)")
        board_date_f = re.sub('<.+?>', '', str(board_date), 0).strip()
        #연료
        USE_FUEL_NM = source.select_one("#content > div > div.head_field > div > div.tit_area > div.top_field > p:nth-child(3) > span:nth-child(4)")
        USE_FUEL_NM_F = re.sub('<.+?>', '', str(USE_FUEL_NM), 0).strip()
        #색상
        COLOR = source.select_one("#content > div > div.head_field > div > div.tit_area > div.top_field > p:nth-child(3) > span:nth-child(5)")
        COLOR_F = re.sub('<.+?>', '', str(COLOR), 0).strip()
        #미션
        MISSION = source.select_one("#content > div > div.head_field > div > div.tit_area > div.top_field > p:nth-child(3) > span:nth-child(6)")
        MISSION_F = re.sub('<.+?>', '', str(MISSION), 0).strip()
        #직영여부
        DIRECT = source.select_one("#content > div > div.head_field > div > div.tit_area > div.top_field > p:nth-child(3) > span:nth-child(7)")
        DIRECT_F = re.sub('<.+?>', '', str(DIRECT), 0).strip()
        #직영위치
        DIRECT_ADR = source.select_one("#content > div > div.head_field > div > div.tit_area > div.top_field > p:nth-child(3) > span:nth-child(8)")
        DIRECT_ADR_F = re.sub('<.+?>', '', str(DIRECT_ADR), 0).strip()
        #차량번호
        vhrno = source.select_one("#content > div > div.detail_info_body > div > div.acticle.acticle04 > div.row > div.piece.piece01 > div > ul > li:nth-child(1) > span.txt")
        vhrno_f = re.sub('<.+?>', '', str(vhrno), 0).strip()
        #차종
        segment = source.select_one("#content > div > div.detail_info_body > div > div.acticle.acticle04 > div.row > div.piece.piece01 > div > ul > li:nth-child(2) > span.txt")
        segment_f = re.sub('<.+?>', '', str(segment), 0).strip()
        #도어수
        door = source.select_one("#content > div > div.detail_info_body > div > div.acticle.acticle04 > div.row > div.piece.piece01 > div > ul > li:nth-child(3) > span.txt")
        door_f = re.sub('<.+?>', '', str(door), 0).strip()
        #인승
        person = source.select_one("#content > div > div.detail_info_body > div > div.acticle.acticle04 > div.row > div.piece.piece01 > div > ul > li:nth-child(4) > span.txt")
        person_f = re.sub('<.+?>', '', str(person), 0).strip()
        #배기량
        dsplvl = source.select_one("#content > div > div.detail_info_body > div > div.acticle.acticle04 > div.row > div.piece.piece01 > div > ul > li:nth-child(5) > span.txt")
        dsplvl_f = re.sub('<.+?>', '', str(dsplvl), 0).strip()
        dsplvl_f = dsplvl_f.replace(',', '')
        dsplvl_f = dsplvl_f.replace('cc', '')
        #최초등록일 및 연식
        YEAR = source.select_one("#content > div > div.head_field > div > div.tit_area > div.top_field > p:nth-child(3) > span:nth-child(2)")
        YEAR_F = re.sub('<.+?>', '', str(YEAR), 0).strip()
        YEAR_F = re.sub('\t', '',YEAR_F, 0).strip()
        YEAR_F_1 = YEAR_F[0:6]
        #print(YEAR_F_1) # 최초등록일
        #연형
        matched = re.search(r'\(.*', YEAR_F, re.S)
        NH = matched.group(0)
        NH = NH.replace('(', '')
        NH_F = NH.replace(')', '')
        #print(NH_F)
        #운행키로수
        TRVL_DSTNC = source.select_one("#content > div > div.head_field > div > div.tit_area > div.top_field > p:nth-child(3) > span:nth-child(3)")
        TRVL_DSTNC_F = re.sub('<.+?>', '', str(TRVL_DSTNC), 0).strip()
        TRVL_DSTNC_F = TRVL_DSTNC_F.replace('km', '')
        TRVL_DSTNC_F = re.sub('<.+?>', '', str(TRVL_DSTNC_F), 0).strip()
        TRVL_DSTNC_F = TRVL_DSTNC_F.replace(',', '')
        #print(TRVL_DSTNC_F)
        #사고여부
        accident = source.select_one("#content > div > div.head_field > div > div.tit_area > div.top_field > p:nth-child(3) > span:nth-child(1) > strong")
        accident_F = re.sub('<.+?>', '', str(accident), 0).strip()
        #print(accident_F)
#        url_2 = detail_url.format(n+1)
#        webpage_2 = urlopen(url_2)
#        source_2 = BeautifulSoup(webpage_2, 'html.parser')
#        html2 = requests.get(url_2).text
#        data = source_2.find('tr')
#        data = data.text
#        og_data = data
#        data = data.find('2')
#        data_start = data
#        data_end = data_start + 10
#        write_date = og_data[data_start:data_end]
#        write_date = write_date.replace('.', '/')
        #
        FIN = page_num +  ',' + ACQS_AMOUNT_F + ',' + now_f + ',' + ',' + FIN +',' + CAR_CLASS_NAME_F + ',' + TRVL_DSTNC_F +',' + YEAR_F_1 + '(' + NH_F + '),' + USE_FUEL_NM_F + ','  + vhrno_f +',' +',' + DIRECT_F + ',' + DIRECT_ADR_F + ',' + ',' + segment_f + ',' + COLOR_F + ',' + MISSION_F + ',' + dsplvl_f + ',' + accident_F
        print(FIN)
#        print("\n")
    except AttributeError as ORG_CAR_MAKER:
        pass

#stop = timeit.default_timer()
#print(그만)
#print(stop - start)