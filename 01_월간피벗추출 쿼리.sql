--월간 피벗테이블 추출
VAR NOW_M VARCHAR2(20);
EXEC :NOW_M := '20191201';

SELECT
    CASE 
        WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') AND N.PRPOS_SE_NM = '영업용' THEN '렌트' --하허호 + 영업용
        WHEN N.VHCTY_ASORT_NM = '승용' AND N.PRPOS_SE_NM = '영업용' THEN '여객(승용)_택시'
        WHEN N.VHCTY_ASORT_NM = '승합' AND N.PRPOS_SE_NM = '영업용' THEN '여객(승합)_콜밴'
        WHEN N.VHCTY_ASORT_NM IN ('특수','화물') AND N.PRPOS_SE_NM = '영업용' THEN '운수(화물)'
    ELSE '자가용' END AS "용도구분"
--
    ,CASE 
        WHEN MBER_REGIST_NO IS NULL THEN '기타'
        WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') AND N.PRPOS_SE_NM = '영업용' THEN '기타'
        WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') AND N.PRPOS_SE_NM = '영업용' THEN '기타' --하허호 + 영업용
        WHEN N.VHCTY_ASORT_NM = '승용' AND N.PRPOS_SE_NM = '영업용' THEN '기타'
        WHEN N.VHCTY_ASORT_NM = '승합' AND N.PRPOS_SE_NM = '영업용' THEN '기타'
        WHEN N.VHCTY_ASORT_NM IN ('특수','화물') AND N.PRPOS_SE_NM = '영업용' THEN '기타'
    ELSE SUBSTR(MBER_REGIST_NO,5,2) END AS "순수개인성별"
--
    ,CASE
        WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') AND N.PRPOS_SE_NM = '영업용' THEN '기타' --하허호 + 영업용
        WHEN N.VHCTY_ASORT_NM = '승용' AND N.PRPOS_SE_NM = '영업용' THEN '기타'
        WHEN N.VHCTY_ASORT_NM = '승합' AND N.PRPOS_SE_NM = '영업용' THEN '기타'
        WHEN N.VHCTY_ASORT_NM IN ('특수','화물') AND N.PRPOS_SE_NM = '영업용'  THEN '기타'
        WHEN MBER_REGIST_NO IS NULL THEN '기타'
        WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') AND N.PRPOS_SE_NM = '영업용' THEN '기타'
    ELSE DECODE(SUBSTR(MBER_REGIST_NO,1,3),NULL,'법인및사업자','10대','20대','70대','60대','80대','60대','90대','60대',SUBSTR(MBER_REGIST_NO,1,3)) END AS "구분"
--
    ,CASE 
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '서울%' THEN '서울'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '부산%' THEN '부산'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '대구%' THEN '대구'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '인천%' THEN '인천'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '광주%' THEN '광주'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '대전%' THEN '대전'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '울산%' THEN '울산'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '세종%' THEN '세종'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '경기%' THEN '경기'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '강원%' THEN '강원'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '충청북%' THEN '충북'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '충청남%' THEN '충남'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '전라북%' THEN '전북'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '전라남%' THEN '전남'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '경상북%' THEN '경북'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '경상남%' THEN '경남'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '제주%' THEN '제주' 
    ELSE '미분류' END AS "지역"
--
    ,CASE 
        WHEN N.USE_FUEL_NM IN ('휘발유','휘발유(유연)','휘발유(무연)') THEN '휘발유'
        WHEN N.USE_FUEL_NM IN ('경유') THEN '경유'
        WHEN N.USE_FUEL_NM IN ('엘피지') THEN '엘피지'
        WHEN N.USE_FUEL_NM IN ('하이브리드(휘발유+전기)','하이브리드(경유+전기)','하이브리드(LPG+전기)','하이브리드(CNG+전기)','하이브리드(LNG+전기)') THEN '하이브리드'
        WHEN N.USE_FUEL_NM IN ('전기') THEN '전기'
    ELSE '기타연료' END AS "연료"
--
    ,CASE 
        WHEN MBER_REGIST_NO IS NULL THEN '법인및사업자'
        WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') AND N.PRPOS_SE_NM = '영업용' THEN '법인및사업자' ELSE '개인' END AS "소유자유형" --성별 연령에 널값있어서 그걸로 체크
-- 
   ,CASE 
        WHEN MBER_REGIST_NO IS NULL THEN '법인및사업자'
        WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') AND N.PRPOS_SE_NM = '영업용' THEN '법인및사업자'
    ELSE DECODE(SUBSTR(MBER_REGIST_NO,1,3),NULL,'법인및사업자','10대','20대','70대','60대','80대','60대','90대','60대',SUBSTR(MBER_REGIST_NO,1,3)) END AS "연령"
--
    ,CASE 
        WHEN MBER_REGIST_NO IS NULL THEN '법인및사업자'
        WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') AND N.PRPOS_SE_NM = '영업용' THEN '법인및사업자'
    ELSE DECODE(SUBSTR(MBER_REGIST_NO,5,2),NULL,'법인및사업자',SUBSTR(MBER_REGIST_NO,5,2)) END AS "성별"
--
    ,CASE 
        WHEN S.USE_FUEL_NM IN ('전기','태양열','수소') THEN '기타'
    ELSE 
        CASE 
            WHEN S.DSPLVL >= 0 AND    S.DSPLVL < 1000 THEN '1000cc'
            WHEN S.DSPLVL >= 1000 AND S.DSPLVL < 1600 THEN '1600cc'
            WHEN S.DSPLVL >= 1600 AND S.DSPLVL < 2000 THEN '2000cc'
            WHEN S.DSPLVL >= 2000 AND S.DSPLVL < 2500 THEN '2500cc'
            WHEN S.DSPLVL >= 2500 AND S.DSPLVL < 3000 THEN '3000cc'
            WHEN S.DSPLVL >= 3000 AND S.DSPLVL < 3500 THEN '3500cc'
            WHEN S.DSPLVL >= 3500 AND S.DSPLVL < 4000 THEN '4000cc'
            WHEN S.DSPLVL >= 4000 THEN '4000cc이상' END END AS "배기량"
--
    ,NVL(DECODE(S.CAR_SZ,'준대형','준대형',S.CAR_SZ),N.VHCTY_CL_NM) AS "차급" --준대형을 중형으로
    ,NVL(DECODE(S.CAR_BT,'리무진','세단',S.CAR_BT),'미분류') AS "외형" --리무진을 세단으로
    ,CASE 
        WHEN S.ORG_CAR_NATION = '한국' THEN '국산'
        WHEN (S.ORG_CAR_NATION = '-' AND S.CL_HMMD_IMP_SE_NM = '국산') THEN '국산' 
    ELSE '수입' END AS "국산/수입"--제조국가가 한국 or -일때만  CL구분이 국산인것
    ,DECODE(S.CAR_BT,'트럭','상용차','버스','상용차','특장','상용차','-','상용차','','미분류','승용차')AS "승용차/상용차"
    ,S.ORG_CAR_MAKER_KOR  AS "브랜드"
    ,S.CAR_MOEL_DT AS "대표모델"
    ,SUM(CASE WHEN EXTRACT_DE = :NOW_M THEN 1 ELSE 0 END) AS "19년04월"
FROM
    CARREGISTDB.REQST_NEW_CAR_MARKET_INFO N, CARREGISTDB.TEST_CAR_SPMNNO_DETAIL_INFO S
WHERE
    N.EXTRACT_DE = :NOW_M--------------------------------------------------------------------매월변경
    AND N.REQST_SE_NM IN ('신조차 신규등록','수입차 신규등록')
    AND N.SPMNNO = S.SPMNNO(+)
    AND S.CAR_NATION IS NOT NULL
    AND S.GUBUN IN ('1','2')
    AND TO_DATE(EXTRACT_DE, 'YYYYMMDD') - CASE WHEN YBL_MD IS NOT NULL AND LENGTH(YBL_MD) = 6 AND (SUBSTR(YBL_MD, 5, 2) BETWEEN '01' AND '12') THEN TO_DATE(YBL_MD||'01', 'YYYYMMDD') ELSE TO_DATE(TO_NUMBER(PRYE||'0101'), 'YYYYMMDD') END <= 365*3
    AND S.CAR_BT NOT IN ('트럭','버스','특장','-')
    AND SP_LEN != '14' -- 20190503 남선기 추가
GROUP BY
    CASE 
        WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') AND N.PRPOS_SE_NM = '영업용' THEN '렌트' --하허호 + 영업용
        WHEN N.VHCTY_ASORT_NM = '승용' AND N.PRPOS_SE_NM = '영업용' THEN '여객(승용)_택시'
        WHEN N.VHCTY_ASORT_NM = '승합' AND N.PRPOS_SE_NM = '영업용' THEN '여객(승합)_콜밴'
        WHEN N.VHCTY_ASORT_NM IN ('특수','화물') AND N.PRPOS_SE_NM = '영업용' THEN '운수(화물)'
    ELSE '자가용' END
--
    ,CASE 
        WHEN MBER_REGIST_NO IS NULL THEN '기타'
        WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') AND N.PRPOS_SE_NM = '영업용' THEN '기타'
        WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') AND N.PRPOS_SE_NM = '영업용' THEN '기타' --하허호 + 영업용
        WHEN N.VHCTY_ASORT_NM = '승용' AND N.PRPOS_SE_NM = '영업용' THEN '기타'
        WHEN N.VHCTY_ASORT_NM = '승합' AND N.PRPOS_SE_NM = '영업용' THEN '기타'
        WHEN N.VHCTY_ASORT_NM IN ('특수','화물') AND N.PRPOS_SE_NM = '영업용' THEN '기타'
    ELSE SUBSTR(MBER_REGIST_NO,5,2) END
--
    ,CASE
        WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') AND N.PRPOS_SE_NM = '영업용' THEN '기타' --하허호 + 영업용
        WHEN N.VHCTY_ASORT_NM = '승용' AND N.PRPOS_SE_NM = '영업용' THEN '기타'
        WHEN N.VHCTY_ASORT_NM = '승합' AND N.PRPOS_SE_NM = '영업용' THEN '기타'
        WHEN N.VHCTY_ASORT_NM IN ('특수','화물') AND N.PRPOS_SE_NM = '영업용'  THEN '기타'
        WHEN MBER_REGIST_NO IS NULL THEN '기타'
        WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') AND N.PRPOS_SE_NM = '영업용' THEN '기타'
    ELSE DECODE(SUBSTR(MBER_REGIST_NO,1,3),NULL,'법인및사업자','10대','20대','70대','60대','80대','60대','90대','60대',SUBSTR(MBER_REGIST_NO,1,3)) END
--
    ,CASE 
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '서울%' THEN '서울'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '부산%' THEN '부산'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '대구%' THEN '대구'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '인천%' THEN '인천'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '광주%' THEN '광주'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '대전%' THEN '대전'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '울산%' THEN '울산'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '세종%' THEN '세종'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '경기%' THEN '경기'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '강원%' THEN '강원'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '충청북%' THEN '충북'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '충청남%' THEN '충남'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '전라북%' THEN '전북'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '전라남%' THEN '전남'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '경상북%' THEN '경북'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '경상남%' THEN '경남'
        WHEN N.USE_STRNGHLD_ADRES_NM LIKE '제주%' THEN '제주' 
    ELSE '미분류' END
--
    ,CASE 
        WHEN N.USE_FUEL_NM IN ('휘발유','휘발유(유연)','휘발유(무연)') THEN '휘발유'
        WHEN N.USE_FUEL_NM IN ('경유') THEN '경유'
        WHEN N.USE_FUEL_NM IN ('엘피지') THEN '엘피지'
        WHEN N.USE_FUEL_NM IN ('하이브리드(휘발유+전기)','하이브리드(경유+전기)','하이브리드(LPG+전기)','하이브리드(CNG+전기)','하이브리드(LNG+전기)') THEN '하이브리드'
        WHEN N.USE_FUEL_NM IN ('전기') THEN '전기'
    ELSE '기타연료' END
--
    ,CASE 
        WHEN MBER_REGIST_NO IS NULL THEN '법인및사업자'
        WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') AND N.PRPOS_SE_NM = '영업용' THEN '법인및사업자' ELSE '개인' END
-- 
   ,CASE 
        WHEN MBER_REGIST_NO IS NULL THEN '법인및사업자'
        WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') AND N.PRPOS_SE_NM = '영업용' THEN '법인및사업자'
    ELSE DECODE(SUBSTR(MBER_REGIST_NO,1,3),NULL,'법인및사업자','10대','20대','70대','60대','80대','60대','90대','60대',SUBSTR(MBER_REGIST_NO,1,3)) END
--
    ,CASE 
        WHEN MBER_REGIST_NO IS NULL THEN '법인및사업자'
        WHEN (N.VHRNO LIKE '%허%' OR N.VHRNO LIKE '%하%' OR N.VHRNO LIKE '%호%') AND N.PRPOS_SE_NM = '영업용' THEN '법인및사업자'
    ELSE DECODE(SUBSTR(MBER_REGIST_NO,5,2),NULL,'법인및사업자',SUBSTR(MBER_REGIST_NO,5,2)) END
--
    ,CASE 
        WHEN S.USE_FUEL_NM IN ('전기','태양열','수소') THEN '기타'
    ELSE CASE 
            WHEN S.DSPLVL >= 0 AND    S.DSPLVL < 1000 THEN '1000cc'
            WHEN S.DSPLVL >= 1000 AND S.DSPLVL < 1600 THEN '1600cc'
            WHEN S.DSPLVL >= 1600 AND S.DSPLVL < 2000 THEN '2000cc'
            WHEN S.DSPLVL >= 2000 AND S.DSPLVL < 2500 THEN '2500cc'
            WHEN S.DSPLVL >= 2500 AND S.DSPLVL < 3000 THEN '3000cc'
            WHEN S.DSPLVL >= 3000 AND S.DSPLVL < 3500 THEN '3500cc'
            WHEN S.DSPLVL >= 3500 AND S.DSPLVL < 4000 THEN '4000cc'
            WHEN S.DSPLVL >= 4000 THEN '4000cc이상' END END
--
    ,NVL(DECODE(S.CAR_SZ,'준대형','준대형',S.CAR_SZ),N.VHCTY_CL_NM)
    ,NVL(DECODE(S.CAR_BT,'리무진','세단',S.CAR_BT),'미분류')
    ,CASE 
        WHEN S.ORG_CAR_NATION = '한국' THEN '국산'
        WHEN (S.ORG_CAR_NATION = '-' AND S.CL_HMMD_IMP_SE_NM = '국산') THEN '국산' 
    ELSE '수입' END
    ,DECODE(S.CAR_BT,'트럭','상용차','버스','상용차','특장','상용차','-','상용차','','미분류','승용차')
    ,S.ORG_CAR_MAKER_KOR
    ,S.CAR_MOEL_DT
;