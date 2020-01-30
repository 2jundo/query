--전국중고차연합회 데이터 전달용
SELECT
    NS.SPMNNO
    ,NS.CL_HMMD_IMP_SE_NM
    ,NS.ORG_CAR_MAKER_KOR
    ,NS.CAR_MAKER_KOR
    ,NS.ORG_CAR_NATION
    ,NS.CAR_NATION
    ,NS.CAR_MOEL_DT
    ,NS.CAR_MODEL_KOR
    ,NS.CNM
    ,NS.SPCF_MODEL_YEAR
    ,NS.REGIT
    ,NS.FRST_REGIST_DE
    ,NS.YBL_MD
    ,NS.GB1
    ,NS.GB2
    ,NS.CAR_GB
    ,NS.CAR_SZ
    ,HM.IHS_HK_SEG
    ,NS.CAR_BT
    ,HM.IHS_BT
    ,NS.FUEL1
    ,HM.FUEL2
    ,NS.DSPLVL
    ,NS.GRBX_KKND_NM
    ,NS.CBD_LT
    ,NS.CBD_BT
    ,NS.CBD_HG
    ,NS.WHLB
    ,NS.TKCAR_PSCAP_CO
    ,NS.MXMM_LDG
    ,NS.GB3
    ,NS.CV_MAKER
    ,NS.GB4
    ,NS.USE1
    ,NS.USE2
    ,NS.ACQS_AMOUNT
    ,NS.MBER_REGIST_NO_1
    ,NS.MBER_REGIST_NO_2
    ,NS.MBER_REGIST_NO_3
    ,NS.USE_STRNGHLD_ADRES_NM_1
    ,NS.USE_STRNGHLD_ADRES_NM_2
    ,NS.USE_STRNGHLD_ADRES_NM_3
    ,NS.OWNER_ADRES_NM_4
FROM
    (
        SELECT 
             N.SPMNNO
            ,S.CL_HMMD_IMP_SE_NM
            ,S.ORG_CAR_MAKER_KOR
            ,S.CAR_MAKER_KOR
            ,S.ORG_CAR_NATION
            ,S.CAR_NATION
            ,S.CAR_MOEL_DT
            ,S.CAR_MODEL_KOR
            ,S.CNM
            ,N.SPCF_MODEL_YEAR
            ,SUBSTR(N.REGIST_DE, 1, 4) AS "REGIT"
            ,N.FRST_REGIST_DE
            ,N.YBL_MD
            ,CASE
                WHEN S.CAR_NATION=S.ORG_CAR_NATION THEN '정식'
                WHEN S.CAR_NATION != S.ORG_CAR_NATION THEN '병행'
            ELSE '병행' END AS "GB1"
            ,CASE 
                WHEN S.CAR_BT IN ('버스','트럭','특장') AND S.CAR_MOEL_DT NOT IN ('버스','트럭','특장차') THEN '소상'
                WHEN S.CAR_BT IN ('버스','트럭','특장') AND S.CAR_MOEL_DT IN ('버스','트럭','특장차') THEN '상용'
            ELSE '승용' END AS "GB2"
            ,NVL(S.CAR_GB, '-') AS "CAR_GB" --조인하기 위해서 추가함.
            ,S.CAR_SZ
            ,S.CAR_BT
        --
            ,DECODE(N.USE_FUEL_NM, '휘발유', '휘발유', '휘발유(무연)', '휘발유', '휘발유(유연)', '휘발유',
                                   '경유', '경유', '엘피지', '엘피지', '전기', '전기',
                                   '하이브리드(CNG+전기)', '하이브리드', '하이브리드(LPG+전기)', '하이브리드', '하이브리드(경유+전기)', '하이브리드', '하이브리드(휘발유+전기)', '하이브리드',
                                   'CNG', 'CNG', '기타연료', '기타연료', '등유', '기타연료', '수소', '수소', '태양열', '기타연료', NULL, NULL,'기타연료') AS "FUEL1"
            ,DECODE(N.USE_FUEL_NM,'전기',0,'수소',0,N.DSPLVL) AS "DSPLVL"--(전기,수소 차는 배기량 0 이외는 본래의 배기량 가져옴)
        --    ,DECODE(N.USE_FUEL_NM,'전기','A/T','수소','A/T',DECODE(N.GRBX_KND_NM,'수동','M/T','자동','A/T','변속기 없음','A/T','반자동','A/T','무단','CVT','A/T')) AS "GRBX_KND_NM"
            ,DECODE(N.USE_FUEL_NM,'전기','자동','수소','자동',DECODE(N.GRBX_KND_NM, '수동', '수동', '자동', '자동', '변속기 없음', '기타', '반자동', '자동', '무단', '무단', '자동')) AS "GRBX_KKND_NM"
            ,S.CBD_LT
            ,S.CBD_BT
            ,S.CBD_HG
            ,S.WHLB
            ,S.TKCAR_PSCAP_CO
            ,S.MXMM_LDG
            ,CASE 
                WHEN S.CAR_MODEL_KOR = '-' AND ORG_CAR_MAKER_KOR = '-' THEN NULL
                WHEN S.CAR_USE IS NULL THEN 'X' 
                WHEN S.CAR_USE IS NOT NULL AND S.ORG_CAR_MAKER_KOR = S.CAR_MAKER_KOR THEN 'OEM'
            ELSE 'CC' END AS "GB3" -- 특장 여부
            ,CASE WHEN S.CAR_USE IS NOT NULL THEN S.CAR_MAKER_KOR END AS "CV_MAKER" -- 특장업체
            ,CASE 
                WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') AND N.PRPOS_SE_NM = '영업용' THEN '렌트' --하허호 + 영업용
                WHEN N.VHCTY_ASORT_NM = '승용' AND N.PRPOS_SE_NM = '영업용' THEN '여객(승용)_택시'      
                WHEN N.VHCTY_ASORT_NM = '승합' AND N.PRPOS_SE_NM = '영업용' THEN '여객(승합)_콜밴'
                WHEN N.VHCTY_ASORT_NM IN ('특수','화물') AND N.PRPOS_SE_NM = '영업용' THEN '운수(화물)'
                ELSE '자가용' END AS "GB4" -- 등록용도
            ,S.CAR_USE AS "USE1"
            ,S.CAR_USE_DETAL AS "USE2"
            ,N.ACQS_AMOUNT AS "ACQS_AMOUNT"
            ,CASE 
                   WHEN N.MBER_REGIST_NO IS NULL THEN '법인및사업자'
                   WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') THEN '법인및사업자'
               ELSE '개인' END AS "MBER_REGIST_NO_1" --현소유자 유형
            ,CASE 
                WHEN (N.MBER_REGIST_NO LIKE '10대%' OR N.MBER_REGIST_NO LIKE '20대%') THEN '20대' 
                WHEN (N.MBER_REGIST_NO LIKE '30대%') THEN '30대' 
                WHEN (N.MBER_REGIST_NO LIKE '40대%') THEN '40대' 
                WHEN (N.MBER_REGIST_NO LIKE '50대%') THEN '50대' 
                WHEN (N.MBER_REGIST_NO LIKE '60대%' OR N.MBER_REGIST_NO LIKE '70대%' OR N.MBER_REGIST_NO LIKE '80대%' OR N.MBER_REGIST_NO LIKE '90대%') THEN '60대'                      
            ELSE '법인및사업자' END AS "MBER_REGIST_NO_2" --현소유자 연령
            ,CASE 
                WHEN (SUBSTR(N.MBER_REGIST_NO, 5,2) = '남자') THEN '남자'
                WHEN (SUBSTR(N.MBER_REGIST_NO, 5,2) = '여자') THEN '여자'
            ELSE '법인및사업자' END AS "MBER_REGIST_NO_3" --현소유자 성별
            ,CASE 
                WHEN REGEXP_SUBSTR(N.USE_STRNGHLD_ADRES_NM, '[^ ]+', 1, 1) = '충청북도' THEN '충북'
                WHEN REGEXP_SUBSTR(N.USE_STRNGHLD_ADRES_NM, '[^ ]+', 1, 1) = '부산광역시' THEN '부산'
                WHEN REGEXP_SUBSTR(N.USE_STRNGHLD_ADRES_NM, '[^ ]+', 1, 1) = '전라북도' THEN '전북'
                WHEN REGEXP_SUBSTR(N.USE_STRNGHLD_ADRES_NM, '[^ ]+', 1, 1) = '광주광역시' THEN '광주'
                WHEN REGEXP_SUBSTR(N.USE_STRNGHLD_ADRES_NM, '[^ ]+', 1, 1) = '대전광역시' THEN '대전'
                WHEN REGEXP_SUBSTR(N.USE_STRNGHLD_ADRES_NM, '[^ ]+', 1, 1) = '전라남도' THEN '전남'
                WHEN REGEXP_SUBSTR(N.USE_STRNGHLD_ADRES_NM, '[^ ]+', 1, 1) = '인천광역시' THEN '인천'
                WHEN REGEXP_SUBSTR(N.USE_STRNGHLD_ADRES_NM, '[^ ]+', 1, 1) = '경상남도' THEN '경남'
                WHEN REGEXP_SUBSTR(N.USE_STRNGHLD_ADRES_NM, '[^ ]+', 1, 1) = '서울특별시' THEN '서울'
                WHEN REGEXP_SUBSTR(N.USE_STRNGHLD_ADRES_NM, '[^ ]+', 1, 1) = '경기도' THEN '경기'
                WHEN REGEXP_SUBSTR(N.USE_STRNGHLD_ADRES_NM, '[^ ]+', 1, 1) = '경상북도' THEN '경북'
                WHEN REGEXP_SUBSTR(N.USE_STRNGHLD_ADRES_NM, '[^ ]+', 1, 1) = '세종특별자치시' THEN '세종'
                WHEN REGEXP_SUBSTR(N.USE_STRNGHLD_ADRES_NM, '[^ ]+', 1, 1) = '충청남도' THEN '충남'
                WHEN REGEXP_SUBSTR(N.USE_STRNGHLD_ADRES_NM, '[^ ]+', 1, 1) = '제주특별자치도' THEN '제주'
                WHEN REGEXP_SUBSTR(N.USE_STRNGHLD_ADRES_NM, '[^ ]+', 1, 1) = '울산광역시' THEN '울산'
                WHEN REGEXP_SUBSTR(N.USE_STRNGHLD_ADRES_NM, '[^ ]+', 1, 1) = '강원도' THEN '강원'
                WHEN REGEXP_SUBSTR(N.USE_STRNGHLD_ADRES_NM, '[^ ]+', 1, 1) = '대구광역시' THEN '대구'        
            ELSE NULL END AS "USE_STRNGHLD_ADRES_NM_1" --현소유자 사용본거지(시/도)
            ,N.OWNER_ADRES_NM AS "USE_STRNGHLD_ADRES_NM_2" --현소유자 사용본거지(상세)
            ,CASE 
                WHEN REGEXP_SUBSTR(N.OWNER_ADRES_NM, '[^ ]+', 1, 1) = '충청북도' THEN '충북'
                WHEN REGEXP_SUBSTR(N.OWNER_ADRES_NM, '[^ ]+', 1, 1) = '부산광역시' THEN '부산'
                WHEN REGEXP_SUBSTR(N.OWNER_ADRES_NM, '[^ ]+', 1, 1) = '전라북도' THEN '전북'
                WHEN REGEXP_SUBSTR(N.OWNER_ADRES_NM, '[^ ]+', 1, 1) = '광주광역시' THEN '광주'
                WHEN REGEXP_SUBSTR(N.OWNER_ADRES_NM, '[^ ]+', 1, 1) = '대전광역시' THEN '대전'
                WHEN REGEXP_SUBSTR(N.OWNER_ADRES_NM, '[^ ]+', 1, 1) = '전라남도' THEN '전남'
                WHEN REGEXP_SUBSTR(N.OWNER_ADRES_NM, '[^ ]+', 1, 1) = '인천광역시' THEN '인천'
                WHEN REGEXP_SUBSTR(N.OWNER_ADRES_NM, '[^ ]+', 1, 1) = '경상남도' THEN '경남'
                WHEN REGEXP_SUBSTR(N.OWNER_ADRES_NM, '[^ ]+', 1, 1) = '서울특별시' THEN '서울'
                WHEN REGEXP_SUBSTR(N.OWNER_ADRES_NM, '[^ ]+', 1, 1) = '경기도' THEN '경기'
                WHEN REGEXP_SUBSTR(N.OWNER_ADRES_NM, '[^ ]+', 1, 1) = '경상북도' THEN '경북'
                WHEN REGEXP_SUBSTR(N.OWNER_ADRES_NM, '[^ ]+', 1, 1) = '세종특별자치시' THEN '세종'
                WHEN REGEXP_SUBSTR(N.OWNER_ADRES_NM, '[^ ]+', 1, 1) = '충청남도' THEN '충남'
                WHEN REGEXP_SUBSTR(N.OWNER_ADRES_NM, '[^ ]+', 1, 1) = '제주특별자치도' THEN '제주'
                WHEN REGEXP_SUBSTR(N.OWNER_ADRES_NM, '[^ ]+', 1, 1) = '울산광역시' THEN '울산'
                WHEN REGEXP_SUBSTR(N.OWNER_ADRES_NM, '[^ ]+', 1, 1) = '강원도' THEN '강원'
                WHEN REGEXP_SUBSTR(N.OWNER_ADRES_NM, '[^ ]+', 1, 1) = '대구광역시' THEN '대구'   
            ELSE NULL END AS "USE_STRNGHLD_ADRES_NM_3" --현소유자 주소(시/도)
            ,N.OWNER_ADRES_NM AS "OWNER_ADRES_NM_4" --현소유자 주소(상세)
        FROM
            REQST_NEW_CAR_MARKET_INFO N
            , TEST_CAR_SPMNNO_DETAIL_INFO S
        WHERE
            N.SPMNNO = S.SPMNNO(+)
            AND N.EXTRACT_DE = '20190601'
            AND S.GUBUN IN ('1','2')
            AND N.REQST_SE_NM NOT IN ('부활차이전등록', '부활차단순등록')
            AND TO_DATE(N.EXTRACT_DE, 'YYYYMMDD') - CASE WHEN N.YBL_MD IS NOT NULL AND LENGTH(N.YBL_MD) = 6 AND (SUBSTR(N.YBL_MD, 5, 2) BETWEEN '01' AND '12') THEN TO_DATE(N.YBL_MD||'01', 'YYYYMMDD') ELSE TO_DATE(TO_NUMBER(N.PRYE||'0101'), 'YYYYMMDD') END <= 365*3
            AND NOT (S.CAR_MODEL_KOR = '트레일러')
            AND ((S.CAR_BT NOT IN ('버스', '트럭', '특장')) OR (S.CAR_BT IN ('버스','트럭','특장') AND S.CAR_MOEL_DT NOT IN ('버스','트럭','특장차')))
    ) NS
    , 
    (
        SELECT
            CL_HMMD_IMP_SE_NM
            ,ORG_CAR_MAKER_KOR
            ,CAR_MOEL_DT
            ,CAR_MODEL_KOR
            ,NVL(CAR_GB, '-') AS "CAR_GB"
            ,CAR_SZ
            ,IHS_HK_SEG
            ,CAR_BT
            ,IHS_BT
            ,FUEL1
            ,FUEL2
        FROM
            HM_BT        
    ) HM
WHERE
        NS.CL_HMMD_IMP_SE_NM = HM.CL_HMMD_IMP_SE_NM(+)
    AND NS.ORG_CAR_MAKER_KOR = HM.ORG_CAR_MAKER_KOR(+)
    AND NS.CAR_MOEL_DT = HM.CAR_MOEL_DT(+)
    AND NS.CAR_MODEL_KOR = HM.CAR_MODEL_KOR(+)
    AND NS.CAR_GB = HM.CAR_GB(+)
    AND NS.CAR_SZ = HM.CAR_SZ(+)
    AND NS.CAR_BT = HM.CAR_BT
    AND NS.FUEL1 = HM.FUEL1(+)
;