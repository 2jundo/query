--★STEP1
--★제원 + 등급, 기본 매칭 테이블
--DROP TABLE WELCOME;

WITH WELCOME AS
(
SELECT DISTINCT
    SPMNNO
    ,CASE
        WHEN ER = 'E102' AND CNM LIKE '%슈퍼%' AND CAR_GRADE_NM NOT LIKE '%슈퍼%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%냉동%' AND CAR_GRADE_NM NOT LIKE '%냉동%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%냉장%' AND CAR_GRADE_NM NOT LIKE '%냉장%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%내장%' AND CAR_GRADE_NM NOT LIKE '%내장%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%활어%' AND CAR_GRADE_NM NOT LIKE '%활어%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%파워%' AND CAR_GRADE_NM NOT LIKE '%파워%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%윙바디%' AND CAR_GRADE_NM NOT LIKE '%윙바디%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%덤프%' AND CAR_GRADE_NM NOT LIKE '%덤프%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%어린이%' AND CAR_GRADE_NM NOT LIKE '%어린이%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%휠체어%' AND CAR_GRADE_NM NOT LIKE '%휠체어%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%이동주유%' AND CAR_GRADE_NM NOT LIKE '%이동주유%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%홈로리%' AND CAR_GRADE_NM NOT LIKE '%홈로리%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%보냉%' AND CAR_GRADE_NM NOT LIKE '%보냉%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%워크스루%' AND CAR_GRADE_NM NOT LIKE '%워크스루%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%초장축%' AND CAR_GRADE_NM NOT LIKE '%초장축%' THEN NULL
        WHEN ER = 'E102' AND CNM NOT LIKE '%초장축%' AND CNM LIKE '%장축%'AND CAR_GRADE_NM LIKE '%초장축%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%다용도탑%' AND CAR_GRADE_NM NOT LIKE '%다용도탑%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%크레인%' AND CAR_GRADE_NM NOT LIKE '%크레인%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%시티밴%' AND CAR_GRADE_NM NOT LIKE '%시티밴%' THEN NULL
        WHEN ER = 'E102' AND CNM LIKE '%트랜스%' AND CAR_GRADE_NM NOT LIKE '%트랜스%' THEN NULL
        WHEN ER = 'E102' AND (CNM LIKE '%엠뷸%' OR CNM LIKE '%앰뷸%' OR CNM LIKE '%구급%') AND (CAR_GRADE_NM NOT LIKE '%엠뷸%' AND CAR_GRADE_NM NOT LIKE '%앰뷸%' AND CAR_GRADE_NM NOT LIKE '%구급%') THEN NULL
    ELSE CAR_GRADE_NBR END AS "CAR_GRADE_NBR"
    ,CAR_GRADE_NM
    ,CAR_GRADE_NM_ENG
    ,CNM
    ,CASE
        WHEN CAR_GRADE_NBR IS NOT NULL THEN NULL -----상용차지만 등급매칭되는 애들 반환
        --WHEN CAR_GRADE_NBR IS NULL AND ER IS NULL THEN 'E900' ------카이즈유 제원정보 상이 이건 수정해서 고쳐야함
    ELSE ER END AS "ER"
    ,CASE
        WHEN UPPER(CAR_GRADE_NM) = UPPER(CNM) OR UPPER(CAR_GRADE_NM_ENG) = UPPER(CNM) THEN 1
        WHEN LENGTH(CAR_GRADE_NM) = LENGTH(CNM) THEN NULL
        WHEN (INSTR(UPPER(CAR_GRADE_NM),UPPER(CNM)) > 0 OR INSTR(UPPER(CAR_GRADE_NM_ENG),UPPER(CNM)) > 0) AND LENGTH(CNM) >= 3 AND LENGTH(CAR_GRADE_NM) >= 3 AND LENGTH(CAR_GRADE_NM_ENG) >= 3 THEN 2
        WHEN (INSTR(UPPER(CNM),UPPER(CAR_GRADE_NM)) > 0 OR INSTR(UPPER(CNM),UPPER(CAR_GRADE_NM_ENG)) > 0) AND LENGTH(CNM) >= 3 AND LENGTH(CAR_GRADE_NM) >= 3 AND LENGTH(CAR_GRADE_NM_ENG) >= 3 THEN 3
        WHEN UTL_MATCH.jaro_winkler_similarity(UPPER(CNM), UPPER(CAR_GRADE_NM)) >= 85
            OR UTL_MATCH.jaro_winkler_similarity(UPPER(CNM), UPPER(CAR_GRADE_NM_ENG)) >= 85
            OR UTL_MATCH.jaro_winkler_similarity(UPPER(REPLACE(CNM,'GranTurismo','GT')), UPPER(CAR_GRADE_NM)) >= 85
            OR UTL_MATCH.jaro_winkler_similarity(UPPER(REPLACE(CNM,'GranTurismo','GT')), UPPER(CAR_GRADE_NM_ENG)) >= 85 THEN 4
    END AS "GB"
    --UTL_MATCH는 두 문자열의 유사도를 계산하는 함수들을 제공하는 패키지
    ,UTL_MATCH.edit_distance_similarity(UPPER(CNM), UPPER(CAR_GRADE_NM)) AS "edsk" -- 두 문자열 중 긴 문자열의 길이로 Normalize후 백분율 값으로 반환하는 함수(str1과 str2가 모두 NULL인 경우는 100을 반환하고, 둘 중 하나만 NULL인 경우는 0을 반환) / EDSK( Edit Distance Similarity Korean )
    ,UTL_MATCH.jaro_winkler_similarity(UPPER(CNM), UPPER(CAR_GRADE_NM)) AS "jwsk" -- str1과 str2의 Match Score 산출 결과를 백분율값으로 반환하는 함수(str1과 str2 중 하나라도 NULL인 경우는 0을 반환) / JWSK ( Jaro Winkler Similarity Korean )
    ,UTL_MATCH.edit_distance_similarity(UPPER(CNM), UPPER(CAR_GRADE_NM_ENG)) AS "edse" --두 문자열 중 긴 문자열의 길이로 Normalize후 백분율 값으로 반환하는 함수(str1과 str2가 모두 NULL인 경우는 100을 반환하고, 둘 중 하나만 NULL인 경우는 0을 반환) / EDSE( Edit Distance Similarity English )
    ,UTL_MATCH.jaro_winkler_similarity(UPPER(CNM), UPPER(CAR_GRADE_NM_ENG)) AS "jwse" -- str1과 str2의 Match Score 산출 결과를 백분율값으로 반환하는 함수(str1과 str2 중 하나라도 NULL인 경우는 0을 반환) / JWSK ( Jaro Winkler Similarity English )
    ,CL_HMMD_IMP_SE_NM AS "IMPORT_YN" -- 수입 여부 (국산: N, 수입 : Y)
	,DRIVE_GB
	,DRIVE
FROM
    (
    --제원 + CIY (탑승 인원 : 기본 탑승 인원인 'PERSON')
		SELECT
            SPMNNO
            ,ORG_CAR_MAKER_KOR
            ,CAR_MOEL_DT
            ,CAR_MODEL_KOR
            ,CIY_MODEL_YEAR
            ,TKCAR_PSCAP_CO
            ,USE_FUEL_NM
            ,DSPLVL
            ,GRBX_KND_NM
            ,CAR_BT
            ,CAR_GRADE_NBR
            ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
            ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
            ,CNM
            ,ER
            ,CL_HMMD_IMP_SE_NM
						,DRIVE_GB
						,DRIVE
						,DRIVE2
        FROM
            (
                SELECT
                    SPMNNO
                    ,DECODE(CL_HMMD_IMP_SE_NM,'국산','N','외산','Y') AS "CL_HMMD_IMP_SE_NM" -- 수입 여부 (국산 : N, 수입 : Y)
                    ,ORG_CAR_MAKER_KOR
                    ,CAR_MOEL_DT
                    ,CAR_MODEL_KOR
                    ,TKCAR_PSCAP_CO
                    ,CASE
                        WHEN SPMNNO in ('04220002300001219','04220002300011219') THEN 'Diesel'
                        WHEN USE_FUEL_NM IN ('휘발유','휘발유(유연)','휘발유(무연)') THEN 'Gasoline'
                        WHEN USE_FUEL_NM IN ('경유') THEN 'Diesel'
                        WHEN USE_FUEL_NM IN ('엘피지') THEN 'LPG'
                        WHEN USE_FUEL_NM IN ('하이브리드(휘발유+전기)') THEN 'Gasoline/Hybrid'
                        WHEN USE_FUEL_NM IN ('하이브리드(경유+전기)') THEN 'Diesel/Hybrid'
                        WHEN USE_FUEL_NM IN ('하이브리드(LPG+전기)') THEN 'LPG/Hybrid'
                        WHEN USE_FUEL_NM LIKE '하이브리드%' THEN 'Hybrid'
                        WHEN USE_FUEL_NM IN ('전기') THEN 'Electric'
                        WHEN USE_FUEL_NM IN ('수소') THEN 'Hydrogen'
                    ELSE 'ETC' END AS "USE_FUEL_NM" --사용연료 : 연료명 단일화
		            ,DECODE(USE_FUEL_NM, '전기', 0, '수소', 0, DSPLVL) AS "DSPLVL" --배기량 : 전기 및 수소 차량은 배기량 0, 이외의 차량은 본래의 배기량.
                    ,DECODE(USE_FUEL_NM, '전기', 'A/T', '수소', 'A/T', DECODE(GRBX_KND_NM, '수동', 'M/T', '자동', 'A/T', '변속기 없음', 'A/T', '반자동', 'A/T', '무단', 'CVT', 'A/T')) AS "GRBX_KND_NM" --변속기 : 변속기명 단일화
                    ,DECODE(CAR_BT,'버스','ETC','특장','ETC','트럭','ETC','세단','SEDAN','컨버터블','CONVERTIBLE','해치백','HATCHBACK','SUV','SUV','왜건','WAGON','쿠페','COUPE','RV','RV','픽업트럭','PICKUPTRUCK','-','ETC','리무진','SEDAN','ETC') AS "CAR_BT" --외형 : 외형 단일화
                    ,REPLACE(REPLACE(REPLACE(UPPER(cnm),' ',''), UPPER(ORG_CAR_MAKER_KOR), ''), UPPER(ORG_CAR_MAKER_ENG), '') AS "CNM" -- 대문자로 변환 후 띄어쓰기 제거 후, 제작사 명 들어간 것 없애고, 영문명도 없앤다.
                    ,CIY_MODEL_YEAR AS "CIY_MODEL_YEAR"
                    ,CASE --2019/02/13 나이스 측에서 에러코드 우선순위 지정
                    --1) 2003년 이전 연형 or 17제원이 아닌 차량 구분
                        --WHEN DECODE(CIY_MODEL_YEAR,NULL,SPCF_MODEL_YEAR,'-',SPCF_MODEL_YEAR,CIY_MODEL_YEAR) <= '2002' THEN 'E005'
                    --2) 2003년 이전 연형 or 17제원이 아닌 차량 구분
                        --WHEN LENGTH(SPMNNO) != 17 THEN 'E005'
                    --3) 경찰차 구분
                        WHEN CAR_USE_DETAL = '경찰' THEN 'E999'
                    --4) 상용차 구분
                        WHEN CAR_BT IN ('트럭','버스','특장','-') THEN 'E102'
                        WHEN CAR_MOEL_DT IN ('트럭','버스','특장차') THEN 'E102'
                    --5) 승용차 중 용도가 특수인 차량 구분
                        WHEN CAR_BT NOT IN ('트럭','버스','특장','-') AND car_use IS NOT NULL THEN 'E103'
                    -- 6) SOFA 차량 구분
                        WHEN SUBSTR(SPMNNO,1,3) = '999' THEN 'E006'
                    --7) 병행 수입차량 구분
                        WHEN GUBUN IN ('1','2') AND CAR_MAKER_KOR != ORG_CAR_MAKER_KOR AND CAR_BT NOT IN ('트럭','버스','특장','-') AND ORG_CAR_NATION != '한국' THEN 'E007'
                    --8) 병행 국산차량 구분
                        WHEN GUBUN IN ('1','2') AND CAR_MAKER_KOR != ORG_CAR_MAKER_KOR AND CAR_BT NOT IN ('트럭','버스','특장','-') AND ORG_CAR_NATION = '한국' THEN 'E007'
                    --9) 이삿짐 차량 구분(1,2제원 이외의 차량은 가져가지 않겠음)
                        WHEN GUBUN NOT IN ('1','2') THEN 'E008'
                    --10) 연형 정보부족 매칭불가
--                        WHEN SPMNNO IN ('02420009500011212', '03820001300001315', '03820001300011315', '06120003300001316', '06120003300011318', '06120003300021318', '06120003300031318', '06120003900001317',
--                                        '06120003900021318', 'A0110003800391307', 'A0110003800771308') THEN 'E999' --카이즈유팀 요청 제외 제원
                        WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN 'E101'
                    ELSE NULL END AS "ER"
										,CASE WHEN DRVNG_SYSTEM LIKE '%4륜%' OR DRVNG_SYSTEM LIKE '%사륜%' OR DRVNG_SYSTEM LIKE '%총륜%' OR DRVNG_SYSTEM = '4x4' THEN '4WD'
										WHEN DRVNG_SYSTEM LIKE '%2륜%' OR DRVNG_SYSTEM LIKE '%이륜%' OR DRVNG_SYSTEM LIKE '%후륜%' OR DRVNG_SYSTEM LIKE '%전륜%' OR DRVNG_SYSTEM LIKE '%후륭%' OR DRVNG_SYSTEM = '4x2' THEN '2WD'
										WHEN UFRM_CBD_FRM_NM LIKE '%4륜%' OR UFRM_CBD_FRM_NM LIKE '%사륜%' OR UFRM_CBD_FRM_NM LIKE '%총륜%' OR UFRM_CBD_FRM_NM = '4x4' THEN '4WD'
										WHEN UFRM_CBD_FRM_NM LIKE '%2륜%' OR UFRM_CBD_FRM_NM LIKE '%이륜%' OR UFRM_CBD_FRM_NM LIKE '%후륜%' OR UFRM_CBD_FRM_NM LIKE '%전륜%'
										OR UFRM_CBD_FRM_NM LIKE '%후륭%' OR UFRM_CBD_FRM_NM LIKE '%2WD%' OR UFRM_CBD_FRM_NM = '4x2' THEN '2WD'
					ELSE '' END AS "DRIVE_GB" --7.13 2륜 4륜 구분 추가
                FROM
                    TEST_CAR_SPMNNO_DETAIL_INFO
            ) S
            ,
            (
                SELECT
                    IMPORT_YN, BRAND_NM, BRAND_NBR, REP_CAR_CLASS_NM, REP_CAR_CLASS_NBR, CAR_CLASS_NM, CAR_CLASS_NBR, YEAR_TYPE, CAR_GRADE_NBR, CAR_GRADE_NM, CAR_GRADE_NM_ENG
                    ,PERSON
                    ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                    ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                    ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
	                  ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
										,CASE WHEN DRIVE IN('AWD','4WD') THEN '4WD'
										WHEN DRIVE IN ('FWD','2WD','FR','RR','MR','FF') THEN '2WD'
										WHEN DRIVE = 0 THEN NULL ELSE DRIVE END AS "DRIVE"--7.13 2륜 4륜 구분 추가
										,CASE WHEN TIRE_2 = '4' THEN '4WD' END AS "DRIVE2"--7.31 옵션으로 인한 2륜 4륜 구분 추가
                FROM
                    CIY
                WHERE
                    SALES_SE_CD != '2' -- 판매 여부(1:시판, 2:미정, 3:단종)
            ) C
		WHERE
                CL_HMMD_IMP_SE_NM = IMPORT_YN(+) -- 수입 여부
            AND ORG_CAR_MAKER_KOR = BRAND_NM(+) -- 브랜드명
            AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+) -- 대표 모델명
            AND CAR_MODEL_KOR = CAR_CLASS_NM(+) -- 상세 모델명
            AND CIY_MODEL_YEAR = YEAR_TYPE(+) -- 모델연형
            AND USE_FUEL_NM = FUEL(+) -- 사용 연료
            AND DSPLVL = ENGINESIZE(+) -- 배기량
            AND GRBX_KND_NM = ISTD_TRANS(+) -- 변속기
            AND TKCAR_PSCAP_CO = PERSON(+) -- 탑승 인원
            AND CAR_BT = EXT_SHAPE(+) -- 외형
--
--                      ↑
		UNION ALL --옵션에의한 인승변경 매칭
--                      ↓
--
    --제원 + CIY (탑승 인원 : 옵션 변경으로 최종 탑승 인원인 'RESULT')
		SELECT
            SPMNNO
            ,ORG_CAR_MAKER_KOR
            ,CAR_MOEL_DT
            ,CAR_MODEL_KOR
            ,CIY_MODEL_YEAR
            ,TKCAR_PSCAP_CO
            ,USE_FUEL_NM
            ,DSPLVL
            ,GRBX_KND_NM
            ,CAR_BT
            ,CAR_GRADE_NBR
            ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
            ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
            ,CNM
            ,ER
            ,CL_HMMD_IMP_SE_NM
			,DRIVE_GB
			,DRIVE
			,DRIVE2
		FROM
            (
                SELECT
                    SPMNNO
                    ,DECODE(CL_HMMD_IMP_SE_NM,'국산','N','외산','Y') AS CL_HMMD_IMP_SE_NM -- 수입 여부 (국산 : N, 수입 : Y)
                    ,ORG_CAR_MAKER_KOR
                    ,CAR_MOEL_DT
                    ,CAR_MODEL_KOR
                    ,TKCAR_PSCAP_CO
                    ,CASE
                        WHEN USE_FUEL_NM IN ('휘발유','휘발유(유연)','휘발유(무연)') THEN 'Gasoline'
                        WHEN USE_FUEL_NM IN ('경유') THEN 'Diesel'
                        WHEN USE_FUEL_NM IN ('엘피지') THEN 'LPG'
                        WHEN USE_FUEL_NM IN ('하이브리드(휘발유+전기)') THEN 'Gasoline/Hybrid'
                        WHEN USE_FUEL_NM IN ('하이브리드(경유+전기)') THEN 'Diesel/Hybrid'
                        WHEN USE_FUEL_NM IN ('하이브리드(LPG+전기)') THEN 'LPG/Hybrid'
                        WHEN USE_FUEL_NM LIKE '하이브리드%' THEN 'Hybrid'
                        WHEN USE_FUEL_NM IN ('전기') THEN 'Electric'
                        WHEN USE_FUEL_NM IN ('수소') THEN 'Hydrogen'
                    ELSE 'ETC' END AS "USE_FUEL_NM" --사용연료 : 연료명 단일화
                    ,DECODE(USE_FUEL_NM, '전기', 0, '수소', 0, DSPLVL) AS "DSPLVL" --배기량 : 전기 및 수소 차량은 배기량 0, 이외의 차량은 본래의 배기량.
                    ,DECODE(USE_FUEL_NM, '전기', 'A/T','수소','A/T',DECODE(GRBX_KND_NM,'수동','M/T','자동','A/T','변속기 없음','A/T','반자동','A/T','무단','CVT','A/T')) AS "GRBX_KND_NM" --변속기 : 변속기명 단일화
                    ,DECODE(CAR_BT,'버스','ETC','특장','ETC','트럭','ETC','세단','SEDAN','컨버터블','CONVERTIBLE','해치백','HATCHBACK','SUV','SUV','왜건','WAGON','쿠페','COUPE','RV','RV','픽업트럭','PICKUPTRUCK','-','ETC','리무진','SEDAN','ETC') AS "CAR_BT" --외형 : 외형 단일화
                    ,REPLACE(REPLACE(REPLACE(UPPER(cnm),' ',''), UPPER(ORG_CAR_MAKER_KOR), ''), UPPER(ORG_CAR_MAKER_ENG), '') AS "CNM" -- 대문자로 변환 후 띄어쓰기 제거 후, 제작사 명 들어간 것 없애고, 영문명도 없앤다.
                    ,CIY_MODEL_YEAR AS "CIY_MODEL_YEAR"
                    ,CASE --2019/02/13 나이스 측에서 에러코드 우선순위 지정
                    --1) 2003년 이전 연형 or 17제원이 아닌 차량 구분
                        --WHEN DECODE(CIY_MODEL_YEAR,NULL,SPCF_MODEL_YEAR,'-',SPCF_MODEL_YEAR,CIY_MODEL_YEAR) <= '2002' THEN 'E005'
                    --2) 2003년 이전 연형 or 17제원이 아닌 차량 구분
                        --WHEN LENGTH(SPMNNO) != 17 THEN 'E005'
                    --3) 경찰차 구분
                        WHEN CAR_USE_DETAL = '경찰' THEN 'E999'
                    --4) 상용차 구분
                        WHEN CAR_BT IN ('트럭','버스','특장','-') THEN 'E102'
                        WHEN CAR_MOEL_DT IN ('트럭','버스','특장차') THEN 'E102'
                    --5) 승용차 중 용도가 특수인 차량 구분
                        WHEN CAR_BT NOT IN ('트럭','버스','특장','-') AND car_use IS NOT NULL THEN 'E103'
                    -- 6) SOFA 차량 구분
                        WHEN SUBSTR(SPMNNO,1,3) = '999' THEN 'E006'
                    --7) 병행 수입차량 구분
                        WHEN GUBUN IN ('1','2') AND CAR_MAKER_KOR != ORG_CAR_MAKER_KOR AND CAR_BT NOT IN ('트럭','버스','특장','-') AND ORG_CAR_NATION != '한국' THEN 'E007'
                    --8) 병행 국산차량 구분
                        WHEN GUBUN IN ('1','2') AND CAR_MAKER_KOR != ORG_CAR_MAKER_KOR AND CAR_BT NOT IN ('트럭','버스','특장','-') AND ORG_CAR_NATION = '한국' THEN 'E007'
                    --9) 이삿짐 차량 구분(1,2제원 이외의 차량은 가져가지 않겠음)
                        WHEN GUBUN NOT IN ('1','2') THEN 'E008'
                    --10) 연형 정보부족 매칭불가
--                        WHEN SPMNNO IN ('02420009500011212','03820001300001315','03820001300011315','06120003300001316','06120003300011318','06120003300021318','06120003300031318','06120003900001317',
--									    '06120003900021318','A0110003800391307','A0110003800771308') THEN 'E999'--카이즈유팀 요청 제외 제원
                        WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN 'E101'
                  		  ELSE NULL END AS "ER"
												,CASE WHEN DRVNG_SYSTEM LIKE '%4륜%' OR DRVNG_SYSTEM LIKE '%사륜%' OR DRVNG_SYSTEM LIKE '%총륜%' OR DRVNG_SYSTEM = '4x4' THEN '4WD'
												WHEN DRVNG_SYSTEM LIKE '%2륜%' OR DRVNG_SYSTEM LIKE '%이륜%' OR DRVNG_SYSTEM LIKE '%후륜%' OR DRVNG_SYSTEM LIKE '%전륜%' OR DRVNG_SYSTEM LIKE '%후륭%' OR DRVNG_SYSTEM = '4x2' THEN '2WD'
												WHEN UFRM_CBD_FRM_NM LIKE '%4륜%' OR UFRM_CBD_FRM_NM LIKE '%사륜%' OR UFRM_CBD_FRM_NM LIKE '%총륜%' OR UFRM_CBD_FRM_NM = '4x4' THEN '4WD'
												WHEN UFRM_CBD_FRM_NM LIKE '%2륜%' OR UFRM_CBD_FRM_NM LIKE '%이륜%' OR UFRM_CBD_FRM_NM LIKE '%후륜%' OR UFRM_CBD_FRM_NM LIKE '%전륜%'
												OR UFRM_CBD_FRM_NM LIKE '%후륭%' OR UFRM_CBD_FRM_NM LIKE '%2WD%' OR UFRM_CBD_FRM_NM = '4x2' THEN '2WD'
												ELSE '' END AS "DRIVE_GB" --7.13 2룬 4륜 구분 추가
                FROM
                    TEST_CAR_SPMNNO_DETAIL_INFO
            ) S
            ,
            (
                SELECT
                    IMPORT_YN, BRAND_NM, BRAND_NBR, REP_CAR_CLASS_NM, REP_CAR_CLASS_NBR, CAR_CLASS_NM, CAR_CLASS_NBR, YEAR_TYPE, CAR_GRADE_NBR, CAR_GRADE_NM, CAR_GRADE_NM_ENG
                    ,CASE WHEN RESULT IS NULL AND PERSON = '4' THEN '5'
										WHEN RESULT IS NULL AND PERSON = '5' THEN '4'
										WHEN RESULT IS NULL AND PERSON = '2' THEN '4'
										ELSE RESULT END AS "PERSON"--★옵션에의한 인승변경 / 7.13수정 인승변경이력 없을시 4인승 > 5인승, 5인승>4인승 변경 강제추가
                    ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                    ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                    ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                    ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
										,CASE WHEN DRIVE IN('AWD','4WD') THEN '4WD'
										WHEN DRIVE IN ('FWD','2WD','FR','RR','MR','FF') THEN '2WD'
										WHEN DRIVE = 0 THEN NULL ELSE DRIVE END AS "DRIVE" --7.13 2룬 4륜 구분 추가
										,CASE WHEN TIRE_2 = '4' THEN '4WD' END AS "DRIVE2"--7.31 옵션으로 인한 2륜 4륜 구분 추가
                FROM
                    CIY
                WHERE
                    SALES_SE_CD != '2' -- 판매 여부(1:시판, 2:미정, 3:단종)
            ) C
		WHERE
            CL_HMMD_IMP_SE_NM = IMPORT_YN(+) -- 수입 여부
            AND ORG_CAR_MAKER_KOR = BRAND_NM(+) -- 브랜드명
            AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+) -- 대표 모델명
            AND CAR_MODEL_KOR = CAR_CLASS_NM(+) -- 상세 모델명
            AND CIY_MODEL_YEAR = YEAR_TYPE(+) -- 모델연형
            AND USE_FUEL_NM = FUEL(+) -- 사용 연료
            AND DSPLVL = ENGINESIZE(+) -- 배기량
            AND GRBX_KND_NM = ISTD_TRANS(+) -- 변속기
            AND TKCAR_PSCAP_CO = PERSON(+) -- 탑승 인원
            AND CAR_BT = EXT_SHAPE(+) -- 외형
		)
WHERE
--SPMNNO IN ('A0810010001541217')
(DRIVE_GB IS NOT NULL AND (DRIVE_GB = DRIVE OR DRIVE_GB = DRIVE2 OR DRIVE IS NULL))
OR (DRIVE_GB IS NULL)
ORDER BY
    1,2,3,4,5
)
--★STEP2
--★제원 + 등급, 기본 매칭 테이블에서 정보가 '부족', '부정확' 등의 이유로 매칭이 불가한 것들을 강제 매칭
,SPMNNO_temp AS
(
    SELECT
        T.SPMNNO
        ,DECODE(CL_HMMD_IMP_SE_NM,'국산','N','외산','Y') AS "CL_HMMD_IMP_SE_NM"
        ,ORG_CAR_MAKER_KOR
        ,CAR_MOEL_DT
        ,CAR_MODEL_KOR
        ,TKCAR_PSCAP_CO
        ,CASE
            WHEN USE_FUEL_NM IN ('휘발유','휘발유(유연)','휘발유(무연)') THEN 'Gasoline'
            WHEN USE_FUEL_NM IN ('경유') THEN 'Diesel'
            WHEN USE_FUEL_NM IN ('엘피지') THEN 'LPG'
            WHEN USE_FUEL_NM IN ('하이브리드(휘발유+전기)') THEN 'Gasoline/Hybrid'
            WHEN USE_FUEL_NM IN ('하이브리드(경유+전기)') THEN 'Diesel/Hybrid'
            WHEN USE_FUEL_NM IN ('하이브리드(LPG+전기)') THEN 'LPG/Hybrid'
            WHEN USE_FUEL_NM LIKE '하이브리드%' THEN 'Hybrid'
            WHEN USE_FUEL_NM IN ('전기') THEN 'Electric'
            WHEN USE_FUEL_NM IN ('수소') THEN 'Hydrogen'
        ELSE 'ETC' END AS "USE_FUEL_NM"
        ,DECODE(USE_FUEL_NM,'전기',0,'수소',0,DSPLVL) AS "DSPLVL"
        ,DECODE(USE_FUEL_NM,'전기','A/T','수소','A/T',DECODE(GRBX_KND_NM,'수동','M/T','자동','A/T','변속기 없음','A/T','반자동','A/T','무단','CVT','A/T'))AS "GRBX_KND_NM"
        ,DECODE(CAR_BT,'버스','ETC','특장','ETC','트럭','ETC','세단','SEDAN','컨버터블','CONVERTIBLE','해치백','HATCHBACK','SUV','SUV','왜건','WAGON','쿠페','COUPE','RV','RV','픽업트럭','PICKUPTRUCK','-','ETC','리무진','SEDAN','ETC') AS "CAR_BT"
        ,REPLACE(REPLACE(REPLACE(UPPER(cnm),' ','')
        ,UPPER(ORG_CAR_MAKER_KOR),''),UPPER(ORG_CAR_MAKER_ENG),'') AS "CNM"
        ,CIY_MODEL_YEAR AS "CIY_MODEL_YEAR"
        ,SPCF_MODEL_YEAR AS "SPCF_MODEL_YEAR"--강제 매칭을 위해 '제원 연형'을 추가
        ,ER
    FROM
        TEST_CAR_SPMNNO_DETAIL_INFO T
        ,(SELECT SPMNNO, ER FROM WELCOME WHERE ER IS NOT NULL AND ER NOT IN ('E102','E999') ----여기 이상
        ) W
    WHERE
         W.SPMNNO = T.SPMNNO
) --★★★
,WELCOME_ADD AS
(
SELECT DISTINCT *
FROM
    (
        SELECT
            SPMNNO, ORG_CAR_MAKER_KOR, CAR_MOEL_DT, CAR_MODEL_KOR, SPCF_MODEL_YEAR, TKCAR_PSCAP_CO, USE_FUEL_NM, DSPLVL, GRBX_KND_NM, CAR_BT, CAR_GRADE_NBR, CAR_GRADE_NM, CAR_GRADE_NM_ENG, CNM, ER, CL_HMMD_IMP_SE_NM, RK
            ,DENSE_RANK()OVER (PARTITION BY SPMNNO ORDER BY rk) AS "ID"
            ,DENSE_RANK()OVER (PARTITION BY SPMNNO, rk ORDER BY YEAR_TYPE) AS "ID_2"
        FROM
            (
--####################################################
            --1] 카이즈유 연형 X | '제원연형' 으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,1 AS RK
                    ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN SPCF_MODEL_YEAR ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    AND TKCAR_PSCAP_CO = PERSON(+)
                    AND CAR_BT = EXT_SHAPE(+)
--
        UNION ALL
--
            --2] 카이즈유 연형 X | '제원연형 -1' 으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,2 AS RK
                    ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 1) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -1
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    AND TKCAR_PSCAP_CO = PERSON(+)
                    AND CAR_BT = EXT_SHAPE(+)
--
        UNION ALL
--
            --3] 카이즈유 연형 X | '제원연형 -2' 으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,3 AS RK
                    ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 2) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -2
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    AND TKCAR_PSCAP_CO = PERSON(+)
                    AND CAR_BT = EXT_SHAPE(+)
--
        UNION ALL
--
            --4] 카이즈유 연형 X | '제원연형 -3' 으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,4 AS RK
                    ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 3) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -3
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    AND TKCAR_PSCAP_CO = PERSON(+)
                    AND CAR_BT = EXT_SHAPE(+)
--
        UNION ALL
--
            --5] 카이즈유 연형 X | '제원연형 -4' 으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,5 AS RK
                    ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 4) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -4
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    AND TKCAR_PSCAP_CO = PERSON(+)
                    AND CAR_BT = EXT_SHAPE(+)
--
          UNION ALL
--
            --6] 카이즈유 연형 X | '제원연형 -5' 으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,6 AS RK
                    ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 5) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -5
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    AND TKCAR_PSCAP_CO = PERSON(+)
                    AND CAR_BT = EXT_SHAPE(+)
--
          UNION ALL
--#######################################################################
            --7] 카이즈유 연형 X | 탑승인원 조건 제외 | '제원연형 '으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,7 AS RK
                    ,YEAR_TYPE
                FROM
                  SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN SPCF_MODEL_YEAR ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    AND CAR_BT = EXT_SHAPE(+)
--
        UNION ALL
--
            --8] 카이즈유 연형 X | 탑승인원 조건 제외 | '제원연형-1'으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,8 AS RK
                    ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 1) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -1
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    AND CAR_BT = EXT_SHAPE(+)
--
        UNION ALL
--
            --9] 카이즈유 연형 X | 탑승인원 조건 제외 | '제원연형-2'으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,9 AS RK
                    ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 2) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -2
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    AND CAR_BT = EXT_SHAPE(+)
--
        UNION ALL
--
            --10] 카이즈유 연형 X | 탑승인원 조건 제외 | '제원연형-3'으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,10 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 3) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -3
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    AND CAR_BT = EXT_SHAPE(+)
--
        UNION ALL
--
            --11] 카이즈유 연형 X | 탑승인원 조건 제외 | '제원연형-4'으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,11 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 4) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -4
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    AND CAR_BT = EXT_SHAPE(+)
--
          UNION ALL
--
            --12] 카이즈유 연형 X | 탑승인원 조건 제외 | '제원연형-5'으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,12 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 5) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -5
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    AND CAR_BT = EXT_SHAPE(+)
--
         UNION ALL
--#######################################################################################
            --13] 카이즈유 연형 X | 탑승인원 조건 제외 | 외형 조건 제외 | '제원연형'으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,13 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN SPCF_MODEL_YEAR ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
        UNION ALL
--
            --14] 카이즈유 연형 X | 탑승인원 조건 제외 | 외형 조건 제외 | '제원연형-1'으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,14 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 1) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -1
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
        UNION ALL
--
            --15] 카이즈유 연형 X | 탑승인원 조건 제외 | 외형 조건 제외 | '제원연형-2'으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,15 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 2) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -2
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
        UNION ALL
--
            --16] 카이즈유 연형 X | 탑승인원 조건 제외 | 외형 조건 제외 | '제원연형-3'으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,16 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 3) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -3
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
        UNION ALL
--
            --17] 카이즈유 연형 X | 탑승인원 조건 제외 | 외형 조건 제외 | '제원연형-4'으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,17 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 4) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -4
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
          UNION ALL
--
            --18] 카이즈유 연형 X | 탑승인원 조건 제외 | 외형 조건 제외 | '제원연형-5'으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,18 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 5) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -5
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
          UNION ALL
--#######################################################################################
            --19] 카이즈유 연형 X | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외 | '제원연형'으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,19 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN SPCF_MODEL_YEAR ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
        UNION ALL
--
            --20] 카이즈유 연형 X | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외 | '제원연형-1'으로 대체
               SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,20 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 1) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -1
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
        UNION ALL
--
            --21] 카이즈유 연형 X | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외 | '제원연형-2'으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,21 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 2) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -2
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
        UNION ALL
--
            --22] 카이즈유 연형 X | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외 | '제원연형-3'으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,22 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 3) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -3
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
        UNION ALL
--
            --23] 카이즈유 연형 X | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외 | '제원연형-4'으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,23 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 4) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -4
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
          UNION ALL
--
            --24] 카이즈유 연형 X | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외 | '제원연형-5'으로 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,24 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 5) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -5
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
           UNION ALL
--
--#######################################################################################
            --25] 카이즈유 연형 X | 강제매칭 조건 제외
               SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,25 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    --AND case when CIY_MODEL_YEAR = '-' or CIY_MODEL_YEAR is NULL then TO_CHAR(to_number(SPCF_MODEL_YEAR) - 5) else CIY_MODEL_YEAR end = YEAR_TYPE(+) --강제매칭 조건 제외
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    AND TKCAR_PSCAP_CO = PERSON(+)
                    AND CAR_BT = EXT_SHAPE(+)
--
          UNION ALL
--
            --26] 카이즈유 연형 X | 강제매칭 조건 제외 | 탑승인원 조건 제외
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,26 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    --AND case when CIY_MODEL_YEAR = '-' or CIY_MODEL_YEAR is NULL then TO_CHAR(to_number(SPCF_MODEL_YEAR) - 5) else CIY_MODEL_YEAR end = YEAR_TYPE(+) --강제매칭 조건 제외
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    AND CAR_BT = EXT_SHAPE(+)
--
          UNION ALL
--
            --27] 카이즈유 연형 X | 강제매칭 조건 제외 | 탑승인원 조건 제외 | 외형 조건 제외
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,27 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    --AND case when CIY_MODEL_YEAR = '-' or CIY_MODEL_YEAR is NULL then TO_CHAR(to_number(SPCF_MODEL_YEAR) - 5) else CIY_MODEL_YEAR end = YEAR_TYPE(+) --강제매칭 조건 제외
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
          UNION ALL
--
            --28] 카이즈유 연형 X | 강제매칭 조건 제외 | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,28 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    --AND case when CIY_MODEL_YEAR = '-' or CIY_MODEL_YEAR is NULL then TO_CHAR(to_number(SPCF_MODEL_YEAR) - 5) else CIY_MODEL_YEAR end = YEAR_TYPE(+) --강제매칭 조건 제외
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
          UNION ALL
--
            --29] 카이즈유 연형 X | 강제매칭 조건 제외 | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외 | 배기량 조건 제외
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,29 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    --AND case when CIY_MODEL_YEAR = '-' or CIY_MODEL_YEAR is NULL then TO_CHAR(to_number(SPCF_MODEL_YEAR) - 5) else CIY_MODEL_YEAR end = YEAR_TYPE(+) --강제매칭 조건 제외
                    AND USE_FUEL_NM = FUEL(+)
                    --AND DSPLVL = ENGINESIZE(+)    --배기량 조건 제외
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
           UNION ALL
--
            --29.5] 카이즈유 연형 X | 강제매칭 조건 제외 | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외 | 배기량 조건 제외 || 연료 조건 제외
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,29.5 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    AND CAR_MODEL_KOR = CAR_CLASS_NM(+)
                    --AND case when CIY_MODEL_YEAR = '-' or CIY_MODEL_YEAR is NULL then TO_CHAR(to_number(SPCF_MODEL_YEAR) - 5) else CIY_MODEL_YEAR end = YEAR_TYPE(+) --강제매칭 조건 제외
                    --AND USE_FUEL_NM = FUEL(+) --연료 조건 제외
                    --AND DSPLVL = ENGINESIZE(+)    --배기량 조건 제외
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
          UNION ALL
--
--#######################################################################################
            --30] 카이즈유 연형 X | 상세모델명 조건 제외 | '제원연형' 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,30 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 0) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    AND TKCAR_PSCAP_CO = PERSON(+)
                   AND CAR_BT = EXT_SHAPE(+)
--
           UNION ALL
--
            --31] 카이즈유 연형 X | 상세모델명 조건 제외 | '제원연형-1' 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,31 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 1) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -1
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    AND TKCAR_PSCAP_CO = PERSON(+)
                   AND CAR_BT = EXT_SHAPE(+)
--
          UNION ALL
--
            --32] 카이즈유 연형 X | 상세모델명 조건 제외 | '제원연형-2' 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,32 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 2) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -2
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    AND TKCAR_PSCAP_CO = PERSON(+)
                   AND CAR_BT = EXT_SHAPE(+)
--
          UNION ALL
--
            --33] 카이즈유 연형 X | 상세모델명 조건 제외 | '제원연형-3' 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,33 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 3) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -3
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    AND TKCAR_PSCAP_CO = PERSON(+)
                   AND CAR_BT = EXT_SHAPE(+)
--
          UNION ALL
--
            --34] 카이즈유 연형 X | 상세모델명 조건 제외 | '제원연형-4' 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,34 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 4) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -4
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    AND TKCAR_PSCAP_CO = PERSON(+)
                   AND CAR_BT = EXT_SHAPE(+)
--
          UNION ALL
--
            --35] 카이즈유 연형 X | 상세모델명 조건 제외 | '제원연형-5' 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,35 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 5) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -5
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    AND TKCAR_PSCAP_CO = PERSON(+)
                   AND CAR_BT = EXT_SHAPE(+)
        ----------------------------------------------------------------------------------------------------------------------------------------
--
          UNION ALL
--
--#######################################################################################
            --36] 카이즈유 연형 X | 상세모델명 조건 제외 | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외 |'제원연형' 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,36 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 0) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
           UNION ALL
--
            --37] 카이즈유 연형 X | 상세모델명 조건 제외 | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외 |'제원연형 -1' 대체
               SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,37 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 1) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -1
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
          UNION ALL
--
            --38] 카이즈유 연형 X | 상세모델명 조건 제외 | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외 |'제원연형 -2' 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,38 AS RK ,YEAR_TYPE
                FROM
                 SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 2) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -2
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
          UNION ALL
--
            --39] 카이즈유 연형 X | 상세모델명 조건 제외 | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외 |'제원연형 -3' 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,39 AS RK ,YEAR_TYPE
                FROM
                 SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 3) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -3
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
          UNION ALL
--
            --40] 카이즈유 연형 X | 상세모델명 조건 제외 | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외 |'제원연형 -4' 대체
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,40 AS RK ,YEAR_TYPE
                FROM
                 SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 4) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -4
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
          UNION ALL
--
            --41] 카이즈유 연형 X | 상세모델명 조건 제외 | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외 |'제원연형 -5' 대체
                SELECT
                             SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                            ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                            ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                            ,CNM
                            ,ER
                            ,CL_HMMD_IMP_SE_NM
                            ,41 AS RK ,YEAR_TYPE
                FROM
                 SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    AND CASE WHEN CIY_MODEL_YEAR = '-' OR CIY_MODEL_YEAR IS NULL THEN  TO_CHAR(TO_NUMBER(SPCF_MODEL_YEAR) - 5) ELSE CIY_MODEL_YEAR END = YEAR_TYPE(+) --강제매칭추가 -5
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
          UNION ALL
--
--#######################################################################################
            --42] 카이즈유 연형 X | 강제매칭 조건 제외 | 상세모델명 조건 제외
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,42 AS RK ,YEAR_TYPE
                FROM
                 SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    --AND case when CIY_MODEL_YEAR = '-' or CIY_MODEL_YEAR is NULL then  TO_CHAR(to_number(SPCF_MODEL_YEAR) - 5) else CIY_MODEL_YEAR end = YEAR_TYPE(+) --강제매칭 조건 제외
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    AND TKCAR_PSCAP_CO = PERSON(+)
                    AND CAR_BT = EXT_SHAPE(+)
--
          UNION ALL
--
            --43] 카이즈유 연형 X | 강제매칭 조건 제외 | 상세모델명 조건 제외 | 탑승인원 조건 제외
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,43 AS RK ,YEAR_TYPE
                FROM
                 SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    --AND case when CIY_MODEL_YEAR = '-' or CIY_MODEL_YEAR is NULL then  TO_CHAR(to_number(SPCF_MODEL_YEAR) - 5) else CIY_MODEL_YEAR end = YEAR_TYPE(+) --강제매칭 조건 제외
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    AND CAR_BT = EXT_SHAPE(+)
--
          UNION ALL
--
            --44] 카이즈유 연형 X | 강제매칭 조건 제외 | 상세모델명 조건 제외 | 탑승인원 조건 제외 | 외형 조건 제외
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,44 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    --AND case when CIY_MODEL_YEAR = '-' or CIY_MODEL_YEAR is NULL then  TO_CHAR(to_number(SPCF_MODEL_YEAR) - 5) else CIY_MODEL_YEAR end = YEAR_TYPE(+) --강제매칭 조건 제외
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    AND GRBX_KND_NM = ISTD_TRANS(+)
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
          UNION ALL
--
            --45] 카이즈유 연형 X | 강제매칭 조건 제외 | 상세모델명 조건 제외 | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,45 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    --AND case when CIY_MODEL_YEAR = '-' or CIY_MODEL_YEAR is NULL then  TO_CHAR(to_number(SPCF_MODEL_YEAR) - 5) else CIY_MODEL_YEAR end = YEAR_TYPE(+) --강제매칭 조건 제외
                    AND USE_FUEL_NM = FUEL(+)
                    AND DSPLVL = ENGINESIZE(+)
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
          UNION ALL
--
            --46] 카이즈유 연형 X | 강제매칭 조건 제외 | 상세모델명 조건 제외 | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외 | 배기량 조건 제외
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,46 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    --AND case when CIY_MODEL_YEAR = '-' or CIY_MODEL_YEAR is NULL then  TO_CHAR(to_number(SPCF_MODEL_YEAR) - 5) else CIY_MODEL_YEAR end = YEAR_TYPE(+) --강제매칭추가
                    AND USE_FUEL_NM = FUEL(+)
                    --AND DSPLVL = ENGINESIZE(+)    --배기량 조건 제외
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
--
          UNION ALL
--
            --46] 카이즈유 연형 X | 강제매칭 조건 제외 | 상세모델명 조건 제외 | 탑승인원 조건 제외 | 외형 조건 제외 | 변속기 조건 제외 | 배기량 조건 제외 | 연료 조건 제외
                SELECT
                     SPMNNO,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,SPCF_MODEL_YEAR,TKCAR_PSCAP_CO,USE_FUEL_NM,DSPLVL,GRBX_KND_NM,CAR_BT,CAR_GRADE_NBR
                    ,REPLACE(CAR_GRADE_NM,' ','') AS "CAR_GRADE_NM"
                    ,REPLACE(CAR_GRADE_NM_ENG,' ','') AS "CAR_GRADE_NM_ENG"
                    ,CNM
                    ,ER
                    ,CL_HMMD_IMP_SE_NM
                    ,47 AS RK ,YEAR_TYPE
                FROM
                    SPMNNO_temp S,
                    (
                        SELECT
                            IMPORT_YN,BRAND_NM,BRAND_NBR,REP_CAR_CLASS_NM,REP_CAR_CLASS_NBR,CAR_CLASS_NM,CAR_CLASS_NBR,YEAR_TYPE,CAR_GRADE_NBR,CAR_GRADE_NM,CAR_GRADE_NM_ENG,PERSON
                            ,DECODE(FUEL,'Fuel cell','Hydrogen','Gasoline/Hydrogen','ETC',NULL,'ETC',FUEL) AS "FUEL"
                            ,DECODE(FUEL,'Fuel cell',0,'Hydrogen',0,'Electric',0,ENGINESIZE) AS "ENGINESIZE"
                            ,DECODE(FUEL,'Fuel cell','A/T','Hydrogen','A/T','Electric','A/T',NULL,'A/T',DECODE(ISTD_TRANS,'S/T','A/T','ST','A/T',ISTD_TRANS)) AS "ISTD_TRANS"
                            ,DECODE(EXT_SHAPE,'LIMOUSINE','SEDAN','MINIBUS','ETC','TRUCK','ETC',EXT_SHAPE) AS "EXT_SHAPE"
                        FROM
                            CIY
                        WHERE
                            SALES_SE_CD != '2' AND USE_TYPE = '01'
                    ) C
                WHERE
                    CL_HMMD_IMP_SE_NM = IMPORT_YN(+)
                    AND ORG_CAR_MAKER_KOR = BRAND_NM(+)
                    AND CAR_MOEL_DT = REP_CAR_CLASS_NM(+)
                    --AND CAR_MODEL_KOR = CAR_CLASS_NM(+)   --상세모델명 조건 제외
                    --AND case when CIY_MODEL_YEAR = '-' or CIY_MODEL_YEAR is NULL then  TO_CHAR(to_number(SPCF_MODEL_YEAR) - 5) else CIY_MODEL_YEAR end = YEAR_TYPE(+) --강제매칭추가
                    --AND USE_FUEL_NM = FUEL(+) --연료 조건 제외
                    --AND DSPLVL = ENGINESIZE(+)    --배기량 조건 제외
                    --AND GRBX_KND_NM = ISTD_TRANS(+)   --변속기 조건 제외
                    --AND TKCAR_PSCAP_CO = PERSON(+)    --탑승인원 조건 제외
                    --AND CAR_BT = EXT_SHAPE(+) --외형 조건 제외
            )
        WHERE
        CAR_GRADE_NBR IS NOT NULL
        --CAR_GRADE_NBR is null
        --and SPMNNO = '00000031126000171'
        --order by
        --SPMNNO
        --RK desc, id
    )
WHERE
    ID = 1 AND ID_2 = 1
)
--★STEP3
--★제원 + 등급, 기본 매칭한 것들을 콤마로 등급 뭉침
,WELCOME_ADD2 AS
(
SELECT
A.SPMNNO,
CAR_GRADE_NBR_ALL
FROM
    (
        SELECT
            SPMNNO
            ,LISTAGG(CAR_GRADE_NBR,',') WITHIN GROUP (ORDER BY SPMNNO) CAR_GRADE_NBR_ALL
        FROM CARREGISTDB.WELCOME_ADD
        GROUP BY SPMNNO
    ) A
    ,
    (
        SELECT
            SPMNNO
            ,LISTAGG(CAR_GRADE_NBR,',') WITHIN GROUP (ORDER BY SPMNNO) CAR_GRADE_NBR_REP
            ,ER
        FROM CARREGISTDB.WELCOME_ADD
        GROUP BY SPMNNO,ER
    ) B
WHERE
    A.SPMNNO = B.SPMNNO
)
--★STEP4
--★제원 + 등급, 기본 매칭 한것들 콤마로 등급 뭉침
,N_CAR_SPMNNO_INFO2 AS
(
SELECT
     SPMNNO
    ,CAR_GRADE_NBR_ALL
    ,CAR_GRADE_NBR_REP
    --,CASE WHEN CAR_GRADE_NBR_ALL IS NULL AND ER IS NULL THEN 'E102' ELSE ER END AS "ER"
    ,ER
    ,IMPORT_YN
    ,GB
FROM
    (
        SELECT
            A.SPMNNO,
            CAR_GRADE_NBR_ALL,
            CASE
                WHEN GB IS NULL THEN NULL
            ELSE CAR_GRADE_NBR_REP END AS CAR_GRADE_NBR_REP,
            ER,IMPORT_YN,GB,
            ROW_NUMBER() OVER(PARTITION BY A.SPMNNO ORDER BY GB) AS RANK_GB
        FROM
            (
                SELECT
                    SPMNNO
                    ,LISTAGG(CAR_GRADE_NBR,',') WITHIN GROUP (ORDER BY SPMNNO) CAR_GRADE_NBR_ALL
                FROM CARREGISTDB.WELCOME
                GROUP BY SPMNNO
            ) A
            ,
            (
                SELECT
                    SPMNNO
                    ,GB
                    ,LISTAGG(CAR_GRADE_NBR,',') WITHIN GROUP (ORDER BY SPMNNO) CAR_GRADE_NBR_REP
                    ,ER
                    ,IMPORT_YN
                FROM CARREGISTDB.WELCOME
                GROUP BY SPMNNO, GB, ER, IMPORT_YN
            ) B
        WHERE
            A.SPMNNO = B.SPMNNO
    )
WHERE
    RANK_GB = 1
--and SPMNNO = 'A0810003501593203'
--★STEP5
--★제원 + 등급, 기본 매칭 + 강제 매칭
)
, N_CAR_SPMNNO_INFO AS
(
SELECT
    N.SPMNNO
    ,NVL(N.CAR_GRADE_NBR_ALL,W.CAR_GRADE_NBR_ALL) AS CAR_GRADE_NBR_ALL
    ,CAR_GRADE_NBR_REP
    ,CASE WHEN NVL(N.CAR_GRADE_NBR_ALL,W.CAR_GRADE_NBR_ALL) IS NOT NULL THEN NULL
    WHEN NVL(N.CAR_GRADE_NBR_ALL,W.CAR_GRADE_NBR_ALL) IS NULL AND ER IS NULL THEN 'E999'
    ELSE ER END AS ER
    ,IMPORT_YN,GB
FROM
    N_CAR_SPMNNO_INFO2 N
    ,WELCOME_ADD2 W
WHERE
    N.SPMNNO = W.SPMNNO(+)
)
-- 아래는 상용차
----
------
,C_SPMNNO AS
(SELECT SPMNNO
,CASE WHEN NVL(SUBSTR(SPCF_CONFM_DE,1,4),SPCF_MODEL_YEAR) = '0991' THEN '1990'
WHEN NVL(SUBSTR(SPCF_CONFM_DE,1,4),SPCF_MODEL_YEAR) IS NULL THEN  '1990'
ELSE NVL(SUBSTR(SPCF_CONFM_DE,1,4),SPCF_MODEL_YEAR) END AS CONFM_DE
,CAR_MAKER_KOR,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,CAR_BT,NVL(CAR_SZ,'-') AS CAR_SZ,NVL(CAR_USE,'-') AS CAR_USE ,NVL(CAR_USE_DETAL,'-') AS CAR_USE_DETAL,CNM
FROM TEST_CAR_SPMNNO_DETAIL_INFO
WHERE CAR_BT IN ('버스','트럭','특장') AND SP_LEN = 17)
--135949
-----------------------------------------------------------------------------------------------------------
,NEW_SPMNNO AS
(
SELECT
CV.SPMNNO,ACQS_AMOUNT
FROM
REQST_NEW_CAR_MARKET_INFO N
,C_SPMNNO CV
WHERE
EXTRACT_DE >= '20150701' AND REQST_SE_NM NOT LIKE '%부활%' AND ACQS_AMOUNT >= 1000000 AND ACQS_AMOUNT < 3000000000
AND CV.SPMNNO = N.SPMNNO
UNION ALL
SELECT
CV.SPMNNO,ACQS_AMOUNT
FROM
OLD_NEW_CAR_MARKET_INFO N
,C_SPMNNO CV
WHERE
GUBUN_NM NOT LIKE '%부활%' AND ACQS_AMOUNT >= 1000000 AND ACQS_AMOUNT < 3000000000
AND CV.SPMNNO = N.SPMNNO
UNION ALL
SELECT
CV.SPMNNO,ACQS_AMOUNT
FROM
MSTER_NEW_CAR_MARKET_INFO N
,C_SPMNNO CV
WHERE
GUBUN_NM NOT LIKE '%부활%' AND ACQS_AMOUNT >= 1000000 AND ACQS_AMOUNT < 3000000000
AND CV.SPMNNO = N.SPMNNO
UNION ALL
SELECT
CV.SPMNNO,FRST_ACQS_AMOUNT
FROM
REQST_MRTE_CAR_MARKET_INFO N
,C_SPMNNO CV
WHERE
EXTRACT_DE >= '20190201' AND FRST_REGIST_DE < '200712'
AND FRST_ACQS_AMOUNT >= 1000000 AND FRST_ACQS_AMOUNT < 3000000000
AND CV.SPMNNO = N.SPMNNO
UNION ALL
SELECT
CV.SPMNNO,FRST_ACQS_AMOUNT
FROM
REQST_ERSR_CAR_MARKET_INFO N
,C_SPMNNO CV
WHERE
EXTRACT_DE >= '20190201' AND FRST_REGIST_DE < '200712'
AND FRST_ACQS_AMOUNT >= 1000000 AND FRST_ACQS_AMOUNT < 3000000000
AND CV.SPMNNO = N.SPMNNO
UNION ALL
SELECT
CV.SPMNNO,FRST_ACQS_AMOUNT
FROM
REQST_STMD_CAR_MARKET_INFO N
,C_SPMNNO CV
WHERE
EXTRACT_DE >= '20190201' AND FRST_REGIST_DE < '200712'
AND FRST_ACQS_AMOUNT >= 1000000 AND FRST_ACQS_AMOUNT < 3000000000
AND CV.SPMNNO = N.SPMNNO
)
-----------------------------------------------------------------------------------------------------------
,mode_SPMNNO AS
(
SELECT
SPMNNO
,STATS_MODE(ACQS_AMOUNT) AS mode_AMOUNT
,COUNT(*) AS cnt
FROM
NEW_SPMNNO
GROUP BY
SPMNNO
)
-----------------------------------------------------------------------------------------------------------
,mean_SPMNNO AS
(
SELECT
DISTINCT
SPMNNO
,CEIL(AVG(ACQS_AMOUNT)OVER (PARTITION BY SPMNNO)) AS mean_AMOUNT
,MAX(ACQS_AMOUNT)OVER (PARTITION BY SPMNNO) AS max_AMOUNT
,MIN(ACQS_AMOUNT)OVER (PARTITION BY SPMNNO) AS min_AMOUNT
,MEDIAN(ACQS_AMOUNT)OVER (PARTITION BY SPMNNO) AS mid_AMOUNT
,MAX(ACQS_AMOUNT)OVER (PARTITION BY SPMNNO) / MIN(ACQS_AMOUNT)OVER (PARTITION BY SPMNNO) AS rate
FROM
(
SELECT
SPMNNO
,ACQS_AMOUNT
,COUNT(ACQS_AMOUNT) OVER (PARTITION BY SPMNNO) AS cnt
,ROW_NUMBER() OVER (PARTITION BY SPMNNO ORDER BY ACQS_AMOUNT desc ) AS r
FROM
NEW_SPMNNO
)
WHERE
CEIL (cnt * 0.1) < R
AND R < cnt - CEIL (cnt * 0.1)
)
-----------------------------------------------------------------------------------------------------------
,AMOUNT_SPMNNO AS
(
SELECT
CV.SPMNNO,CV.CONFM_DE,CAR_MAKER_KOR,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,CAR_BT,CAR_SZ,CAR_USE,CAR_USE_DETAL
,CNM
,CASE WHEN CNT = 1 THEN mode_AMOUNT
WHEN rate IS NULL AND CNT > 1 THEN mode_AMOUNT
WHEN rate >= 3 AND CNT > 1 THEN mode_AMOUNT
ELSE mean_AMOUNT END AS AMOUNT
,CASE WHEN (CASE WHEN CNT = 1 OR (rate IS NULL AND CNT > 1) OR (rate >= 3 AND CNT > 1) THEN mode_AMOUNT ELSE mean_AMOUNT END) IS NULL THEN NULL
WHEN CNT = 1 THEN 'CNT1'
WHEN rate IS NULL AND CNT > 1 THEN 'mode'
WHEN rate >= 3 AND CNT > 1 THEN 'mode'
ELSE 'mean' END AS GB
FROM
C_SPMNNO CV
,mode_SPMNNO V
,mean_SPMNNO M
WHERE
CV.SPMNNO = V.SPMNNO (+)
AND CV.SPMNNO = M.SPMNNO (+)
)
-------------------------------------------------------------------------------------------------------최초 등록 가격을 찾는다. 전체 135949 가격 없는 58425
,AMOUNT_GR1 AS
(
SELECT
CAR_MAKER_KOR,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,CAR_BT,CAR_SZ,CAR_USE,CAR_USE_DETAL,CNM,AMOUNT,GB
,ROW_NUMBER()OVER(PARTITION BY CAR_MAKER_KOR,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,CAR_BT,CAR_SZ,CAR_USE,CAR_USE_DETAL,CNM ORDER BY DECODE(GB,'mode',1,'mean',2,'CNT1',3,100),AMOUNT) AS RN
FROM
AMOUNT_SPMNNO
WHERE
AMOUNT IS NOT NULL
)
,AMOUNT_SPMNNO1 AS
(
SELECT
S.SPMNNO,S.CONFM_DE,S.CAR_MAKER_KOR,S.ORG_CAR_MAKER_KOR,S.CAR_MOEL_DT,S.CAR_MODEL_KOR,S.CAR_BT,S.CAR_SZ,S.CAR_USE,S.CAR_USE_DETAL,S.CNM
,DECODE(S.AMOUNT,NULL,G.AMOUNT,S.AMOUNT) AS AMOUNT
,DECODE(S.GB,NULL,G.GB,S.GB) AS GB
FROM
AMOUNT_SPMNNO S
,(SELECT * FROM AMOUNT_GR1 WHERE RN = 1) G
WHERE
S.CAR_MAKER_KOR = G.CAR_MAKER_KOR (+)
AND S.ORG_CAR_MAKER_KOR = G.ORG_CAR_MAKER_KOR (+)
AND S.CAR_MOEL_DT = G.CAR_MOEL_DT (+)
AND S.CAR_MODEL_KOR = G.CAR_MODEL_KOR (+)
AND S.CAR_BT = G.CAR_BT (+)
AND S.CAR_SZ = G.CAR_SZ (+)
AND S.CAR_USE = G.CAR_USE (+)
AND S.CAR_USE_DETAL = G.CAR_USE_DETAL (+)
AND S.CNM = G.CNM (+)
)
----------------------------------------------------------------------------------------------------제원 연형 빼고 동일 차량 가격 땡겨오기 전체 135949 가격 없는 6264
,AMOUNT_GR2 AS
(
SELECT
CAR_MAKER_KOR,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,CAR_BT,CAR_SZ,CAR_USE,CAR_USE_DETAL,AMOUNT,GB
,ROW_NUMBER()OVER(PARTITION BY CAR_MAKER_KOR,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,CAR_BT,CAR_SZ,CAR_USE,CAR_USE_DETAL ORDER BY DECODE(GB,'mode',1,'mean',2,'CNT1',3,100),AMOUNT) AS RN
FROM
AMOUNT_SPMNNO
WHERE
AMOUNT IS NOT NULL
)
,AMOUNT_SPMNNO2 AS
(
SELECT
S.SPMNNO,S.CONFM_DE,S.CAR_MAKER_KOR,S.ORG_CAR_MAKER_KOR,S.CAR_MOEL_DT,S.CAR_MODEL_KOR,S.CAR_BT,S.CAR_SZ,S.CAR_USE,S.CAR_USE_DETAL,S.CNM
,DECODE(S.AMOUNT,NULL,G.AMOUNT,S.AMOUNT) AS AMOUNT
,DECODE(S.GB,NULL,G.GB,S.GB) AS GB
FROM
AMOUNT_SPMNNO1 S
,(SELECT * FROM AMOUNT_GR2 WHERE RN = 1) G
WHERE
S.CAR_MAKER_KOR = G.CAR_MAKER_KOR (+)
AND S.ORG_CAR_MAKER_KOR = G.ORG_CAR_MAKER_KOR (+)
AND S.CAR_MOEL_DT = G.CAR_MOEL_DT (+)
AND S.CAR_MODEL_KOR = G.CAR_MODEL_KOR (+)
AND S.CAR_BT = G.CAR_BT (+)
AND S.CAR_SZ = G.CAR_SZ (+)
AND S.CAR_USE = G.CAR_USE (+)
AND S.CAR_USE_DETAL = G.CAR_USE_DETAL (+)
)
-----------------------------------------------------------------제원 연형 등록차명빼고 동일 차량 가격 땡겨오기 전체 135949 가격 없는 2434
,AMOUNT_GR3 AS
(
SELECT
CAR_MAKER_KOR,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_BT,CAR_SZ,CAR_USE,CAR_USE_DETAL,AMOUNT,GB
,ROW_NUMBER()OVER(PARTITION BY CAR_MAKER_KOR,ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_BT,CAR_SZ,CAR_USE,CAR_USE_DETAL ORDER BY DECODE(GB,'mode',1,'mean',2,'CNT1',3,100),AMOUNT) AS RN
FROM
AMOUNT_SPMNNO
WHERE
AMOUNT IS NOT NULL
)
,AMOUNT_SPMNNO3 AS
(
SELECT
S.SPMNNO,S.CONFM_DE,S.CAR_MAKER_KOR,S.ORG_CAR_MAKER_KOR,S.CAR_MOEL_DT,S.CAR_MODEL_KOR,S.CAR_BT,S.CAR_SZ,S.CAR_USE,S.CAR_USE_DETAL,S.CNM
,DECODE(S.AMOUNT,NULL,G.AMOUNT,S.AMOUNT) AS AMOUNT
,DECODE(S.GB,NULL,G.GB,S.GB) AS GB
FROM
AMOUNT_SPMNNO1 S
,(SELECT * FROM AMOUNT_GR3 WHERE RN = 1) G
WHERE
S.CAR_MAKER_KOR = G.CAR_MAKER_KOR (+)
AND S.ORG_CAR_MAKER_KOR = G.ORG_CAR_MAKER_KOR (+)
AND S.CAR_MOEL_DT = G.CAR_MOEL_DT (+)
AND S.CAR_BT = G.CAR_BT (+)
AND S.CAR_SZ = G.CAR_SZ (+)
AND S.CAR_USE = G.CAR_USE (+)
AND S.CAR_USE_DETAL = G.CAR_USE_DETAL (+)
)
-----------------------------------------------------------------제원 연형 등록차명 베이스 모델명 빼고 동일 차량 가격 땡겨오기 전체 135949 가격 없는
,AMOUNT_GR4 AS
(
SELECT
ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,CAR_BT,CAR_SZ,CAR_USE,CAR_USE_DETAL,AMOUNT,GB
,ROW_NUMBER()OVER(PARTITION BY ORG_CAR_MAKER_KOR,CAR_MOEL_DT,CAR_MODEL_KOR,CAR_BT,CAR_SZ,CAR_USE,CAR_USE_DETAL ORDER BY DECODE(GB,'mode',1,'mean',2,'CNT1',3,100),AMOUNT) AS RN
FROM
AMOUNT_SPMNNO
WHERE
AMOUNT IS NOT NULL
)
,AMOUNT_SPMNNO4 AS
(
SELECT
S.SPMNNO,S.CONFM_DE,S.CAR_MAKER_KOR,S.ORG_CAR_MAKER_KOR,S.CAR_MOEL_DT,S.CAR_MODEL_KOR,S.CAR_BT,S.CAR_SZ,S.CAR_USE,S.CAR_USE_DETAL,S.CNM
,DECODE(S.AMOUNT,NULL,G.AMOUNT,S.AMOUNT) AS AMOUNT
,DECODE(S.GB,NULL,G.GB,S.GB) AS GB
FROM
AMOUNT_SPMNNO2 S
,(SELECT * FROM AMOUNT_GR4 WHERE RN = 1) G
WHERE
S.ORG_CAR_MAKER_KOR = G.ORG_CAR_MAKER_KOR (+)
AND S.CAR_MOEL_DT = G.CAR_MOEL_DT (+)
AND S.CAR_MODEL_KOR = G.CAR_MODEL_KOR (+)
AND S.CAR_BT = G.CAR_BT (+)
AND S.CAR_SZ = G.CAR_SZ (+)
AND S.CAR_USE = G.CAR_USE (+)
AND S.CAR_USE_DETAL = G.CAR_USE_DETAL (+)
)
-----------------------------------------------------------------제원 연형 등록차명 제작사 빼고 동일 차량 가격 땡겨오기 전체 135949 가격 없는 823
,AMOUNT_GR5 AS
(
SELECT
CAR_MOEL_DT,CAR_MODEL_KOR,CAR_BT,CAR_SZ,CAR_USE,CAR_USE_DETAL,AMOUNT,GB
,ROW_NUMBER()OVER(PARTITION BY CAR_MOEL_DT,CAR_MODEL_KOR,CAR_BT,CAR_SZ,CAR_USE,CAR_USE_DETAL ORDER BY DECODE(GB,'mode',1,'mean',2,'CNT1',3,100),AMOUNT) AS RN
FROM
AMOUNT_SPMNNO
WHERE
AMOUNT IS NOT NULL
)
,AMOUNT_SPMNNO5 AS
(
SELECT
S.SPMNNO,S.CONFM_DE,S.CAR_MAKER_KOR,S.ORG_CAR_MAKER_KOR,S.CAR_MOEL_DT,S.CAR_MODEL_KOR,S.CAR_BT,S.CAR_SZ,S.CAR_USE,S.CAR_USE_DETAL,S.CNM
--,decode(decode(S.AMOUNT,NULL,G.AMOUNT,S.AMOUNT),NULL,0) as AMOUNT  -- ,nvl(nvl(S.AMOUNT,G.AMOUNT),0) as AMOUNT
,NVL(NVL(S.AMOUNT,G.AMOUNT),0) AS AMOUNT
,DECODE(S.GB,NULL,G.GB,S.GB) AS GB
FROM
AMOUNT_SPMNNO3 S
,(SELECT * FROM AMOUNT_GR5 WHERE RN = 1) G
WHERE
S.CAR_MOEL_DT = G.CAR_MOEL_DT (+)
AND S.CAR_MODEL_KOR = G.CAR_MODEL_KOR (+)
AND S.CAR_BT = G.CAR_BT (+)
AND S.CAR_SZ = G.CAR_SZ (+)
AND S.CAR_USE = G.CAR_USE (+)
AND S.CAR_USE_DETAL = G.CAR_USE_DETAL (+)
)
--------------------------------------------------------------제원 연형 등록차명 제작사 원제작사빼고 동일 차량 가격 땡겨오기 전체 135949 가격 없는 428 여기서 마무리
SELECT
    CIW9.*
    ,AMOUNT_SPMNNO5.AMOUNT
    ,AMOUNT_SPMNNO5.GB AS AMOUNT_GB
--ER,count(*)
FROM (
SELECT
    CIW5.*
    ,F.F_SPMNNO AS CV_CAR_CODE
FROM
    (
     --★STEP6
     --★CIW용 조회항목 추가
     --★상용차시세용 조회항목 추가
     SELECT
          N.SPMNNO
         ,CAR_GRADE_NBR_ALL
         ,CAR_GRADE_NBR_REP
         ,ER
         ,NVL(N.IMPORT_YN,CL_HMMD_IMP_SE_NM)AS IMPORT_YN
         ,GB --여기까지 카이즈유
         ,S.USE_FUEL_NM AS "CIW_USE_FUEL_NM"
         ,TKCAR_PSCAP_CO AS "CIW_TKCAR_PSCAP_CO"
         ,DSPLVL AS "CIW_DSPLVL"
         ,DECODE(HMMD_IMP_SE_NM,'국산','N','외산','Y') AS "CIW_HMMD_IMP_SE_NM"
         ,DECODE(CAR_GRADE_NBR_ALL, NULL, S.ORG_CAR_MAKER_KOR) AS "CIW_BRAND_NM"
         ,DECODE(CAR_GRADE_NBR_ALL, NULL, S.CAR_MOEL_DT) AS "CIW_REP_CAR_CLASS_NM"
         ,DECODE(CAR_GRADE_NBR_ALL, NULL, S.CAR_MODEL_KOR) AS "CIW_CAR_CLASS_NM"
         ,DECODE(CAR_GRADE_NBR_ALL, NULL, CASE
                                             WHEN S.USE_FUEL_NM IN ('휘발유','휘발유(유연)','휘발유(무연)') THEN 'Gasoline'
                                             WHEN S.USE_FUEL_NM IN ('경유') THEN 'Diesel'
                                             WHEN S.USE_FUEL_NM IN ('엘피지') THEN 'LPG'
                                             WHEN S.USE_FUEL_NM IN ('하이브리드(휘발유+전기)') THEN 'Gasoline/Hybrid'
                                             WHEN S.USE_FUEL_NM IN ('하이브리드(경유+전기)') THEN 'Diesel/Hybrid'
                                             WHEN S.USE_FUEL_NM IN ('하이브리드(LPG+전기)') THEN 'LPG/Hybrid'
                                             WHEN S.USE_FUEL_NM LIKE '하이브리드%' THEN 'Hybrid'
                                             WHEN S.USE_FUEL_NM IN ('전기') THEN 'Electric'
                                             WHEN S.USE_FUEL_NM IN ('수소') THEN 'Hydrogen'
                                         ELSE 'ETC' END) AS "CIW_FUEL"
         ,DECODE(CAR_GRADE_NBR_ALL, NULL, DECODE(S.USE_FUEL_NM, '전기', 0, '수소', 0, S.DSPLVL)) AS "CIW_ENGINESIZE"
         ,DECODE(CAR_GRADE_NBR_ALL, NULL, DECODE(S.USE_FUEL_NM, '전기', 'A/T', '수소', 'A/T', DECODE(S.GRBX_KND_NM, '수동', 'M/T', '자동', 'A/T', '변속기 없음', 'A/T', '반자동', 'A/T', '무단', 'CVT', 'A/T'))) AS "CIW_ISTD_TRANS"
         ,DECODE(CAR_GRADE_NBR_ALL, NULL, DECODE(S.CAR_BT,'버스','ETC','특장','ETC','트럭','ETC','세단','SEDAN','컨버터블','CONVERTIBLE','해치백','HATCHBACK','SUV','SUV','왜건','WAGON','쿠페','COUPE','RV','RV','픽업트럭','PICKUPTRUCK','-','ETC','리무진','SEDAN','ETC')) AS "CIW_EXT_SHAPE"
         ,DECODE(CAR_GRADE_NBR_ALL, NULL, S.TKCAR_PSCAP_CO) AS "CIW_PERSON"
         ,DECODE(CAR_GRADE_NBR_ALL, NULL, '') AS "FIRST_PRICE"
             -----------------------------------------------------------------------------이아래부터 상용차 조회 항목입니다.
         ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN 1 ELSE 0 END AS CV_CARINFO
         ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN SPCF_MODEL_YEAR  ELSE '' END AS "CV_YEAR_TYPE"
         --	,'' as CV_ORG_BRAND_NBR
         ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN ORG_CAR_MAKER_KOR  ELSE '' END AS "CV_ORG_BRAND_NM"
     --		,'' as CV_BRAND_NBR
         ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN DECODE(CAR_MAKER_KOR,'-',ORG_CAR_MAKER_KOR,CAR_MAKER_KOR) ELSE '' END AS "CV_BRAND_NM"
     --		,'' as CV_REP_CAR_CLASS_NBR
         ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN CAR_MOEL_DT  ELSE '' END AS "CV_REP_CAR_CLASS_NM"
     --		,'' as CV_CAR_CLASS_NBR
         ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN CAR_MODEL_KOR  ELSE '' END AS "CV_CAR_CLASS_NM"
     --      ,'' AS CV_CAR_GRADE_NBR
         ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN cnm  ELSE '' END AS CV_CAR_GRADE_NM
--                                    ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN '15000000'  ELSE '' END AS CV_GRADE_SALE_PRICE
         ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN FUEL_CNMSMP_RT  ELSE '' END AS CV_GRADE_FUEL_RATE
         ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN CASE
                                                             WHEN USE_FUEL_NM IN ('휘발유','휘발유(유연)','휘발유(무연)') THEN 'Gasoline'
                                                             WHEN USE_FUEL_NM IN ('경유') THEN 'Diesel'
                                                             WHEN USE_FUEL_NM IN ('엘피지') THEN 'LPG'
                                                             WHEN USE_FUEL_NM IN ('하이브리드(휘발유+전기)') THEN 'Gasoline/Hybrid'
                                                             WHEN USE_FUEL_NM IN ('하이브리드(경유+전기)') THEN 'Diesel/Hybrid'
                                                             WHEN USE_FUEL_NM IN ('하이브리드(LPG+전기)') THEN 'LPG/Hybrid'
                                                             WHEN USE_FUEL_NM LIKE '하이브리드%' THEN 'Hybrid'
                                                             WHEN USE_FUEL_NM IN ('전기','태양열') THEN 'Electric'
                                                             WHEN USE_FUEL_NM IN ('수소') THEN 'Hydrogen'
                                                             WHEN USE_FUEL_NM IN ('등유','기타연료') THEN 'ETC'
                                                         ELSE USE_FUEL_NM END
         ELSE '' END AS CV_FUEL
         ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN DECODE(USE_FUEL_NM, '전기', NULL, '수소', NULL, '태양열', NULL, DSPLVL)  ELSE '' END AS CV_ENGINESIZE
         ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN DECODE(USE_FUEL_NM, '전기', 'A/T', '수소', 'A/T', DECODE(GRBX_KND_NM, '수동', 'M/T', '자동', 'A/T', '변속기 없음', 'A/T', '반자동', 'A/T', '무단', 'CVT', 'A/T'))  ELSE '' END AS CV_ISTD_TRANS
         ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN DECODE(CAR_BT,'버스','BUS','특장','SPECIALVEHICLE','트럭','TRUCK','세단','SEDAN','컨버터블','CONVERTIBLE','해치백','HATCHBACK','SUV','SUV','왜건','WAGON','쿠페','COUPE','RV','RV','픽업트럭','PICKUPTRUCK','-','ETC','리무진','SEDAN','ETC')  ELSE '' END AS CV_EXT_SHAPE
         ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN TKCAR_PSCAP_CO ELSE NULL END AS CV_PERSON
         ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN MXMM_LDG  ELSE NULL END AS CV_MXMM_LDG
         ,'' AS CV_ENGINE_FORM
         ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN CAR_SZ ELSE '' END AS CAR_SIZE
         ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN CAR_USE  ELSE '' END AS CAR_USE
         ,CASE WHEN CAR_BT IN ('버스','트럭','특장') THEN CAR_USE_DETAL  ELSE '' END AS CAR_USE_DETAIL
     FROM
          N_CAR_SPMNNO_INFO N
         ,TEST_CAR_SPMNNO_DETAIL_INFO S
     WHERE
         N.SPMNNO = S.SPMNNO(+)
             --총 개수 331195
    ) CIW5
    , TEST_FAKE_SPMNNO F
WHERE
    CIW5.SPMNNO = F.SPMNNO(+)
) CIW9
, AMOUNT_SPMNNO5
WHERE
    CIW9.SPMNNO = AMOUNT_SPMNNO5.SPMNNO(+)
		--and ER = 'E123'
--group by ER
--order by 1
;
