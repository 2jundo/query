--현대캐피탈 중고차시세 ai 학습데이터 추출용
--#시트1
SELECT
    SS.IMPORT_YN,
    SS.BRAND_NM,
    SS.BRAND_NBR,
    SS.REP_CAR_CLASS_NM,
    SS.REP_CAR_CLASS_NBR,
    SS.MID_CAR_CLASS_NM,
    SS.MID_CAR_CLASS_NBR,
--    SS.CAR_CLASS_NM,
    CASE 
        WHEN INSTR(SS.CAR_CLASS_NM, '(-)') > 0 THEN SUBSTR(SS.CAR_CLASS_NM, 1, INSTR(SS.CAR_CLASS_NM, '(', 1, 2) -1)||SS.M_YEAR_TYPE
    ELSE SS.CAR_CLASS_NM END AS "CAR_CLASS_NM",
    SS.CAR_CLASS_NBR,
    SS.YEAR_TYPE,
    SUBSTR(CIY.RELEASE_DT,1,4) AS "년",
    SUBSTR(CIY.RELEASE_DT,5,2) AS "월",
    SS.CAR_GRADE_NM,
    SS.CAR_GRADE_NBR,
    SS.DSPLVL,
    SS.TKCAR_PSCAP_CO,
    SS.M_YEAR_TYPE,
    SS.USE_FUEL_NM,
    SS.USE_FUEL_NBR,
    SS.GRBX_KND_NM,
    SS.GRBX_KND_NBR,
    SS.SALE_PRICE,
    SS.USE_TYPE
FROM 
(
SELECT 
    HCS.IMPORT_YN,
    HCS.BRAND_NM,
    HCS.BRAND_NBR,
    HCS.REP_CAR_CLASS_NM,
    HCS.REP_CAR_CLASS_NBR,
    LV2.MID_CAR_CLASS_NM,
    LV2.MID_CAR_CLASS_NBR,
    HCS.CAR_CLASS_NM,
    HCS.CAR_CLASS_NBR,
    HCS.YEAR_TYPE,
    HCS.CAR_GRADE_NM,
    HCS.CAR_GRADE_NBR,
    HCS.DSPLVL,
    HCS.TKCAR_PSCAP_CO,
    HCS.M_YEAR_TYPE,
    HCS.USE_FUEL_NM,
    HCS.USE_FUEL_NBR,
    HCS.GRBX_KND_NM,
    HCS.GRBX_KND_NBR,
    HCS.SALE_PRICE,
    HCS.USE_TYPE
FROM
    (--15,305
    SELECT
            IMPORT_YN,
            BRAND_NM,
            BRAND_NBR,
            REP_CAR_CLASS_NM,
            REP_CAR_CLASS_NBR,
--            CASE 
--                WHEN CAR_GRADE_PROJECT_CD IS NOT NULL THEN REP_CAR_CLASS_NM||' ('||CAR_GRADE_PROJECT_CD||')'|| ' '||YEAR_TYPE
--                WHEN CAR_GRADE_PROJECT_CD IS NULL THEN REP_CAR_CLASS_NM|| ' '||YEAR_TYPE
--                WHEN CAR_GRADE_PROJECT_CD = '-' THEN REP_CAR_CLASS_NM|| ' '||YEAR_TYPE
--            ELSE '확인필요' END AS "CAR_CLASS_NM",
            CASE
                WHEN INSTR(CAR_CLASS_NM,'('||CAR_GRADE_PROJECT_CD||')') IN (0,NULL) THEN CAR_CLASS_NM||' ('||DECODE(CAR_GRADE_PROJECT_CD,NULL,'-',CAR_GRADE_PROJECT_CD)||') '||YEAR_TYPE
                WHEN INSTR(CAR_CLASS_NM,'('||CAR_GRADE_PROJECT_CD||')') > 0 THEN CAR_CLASS_NM||' '||YEAR_TYPE
            END AS "CAR_CLASS_NM",
            CAR_CLASS_NBR,
            YEAR_TYPE,
            CAR_GRADE_NM,
            CAR_GRADE_NBR,
            ENGINESIZE AS "DSPLVL",
            PERSON AS "TKCAR_PSCAP_CO",
            M_YEAR_TYPE,
            FUEL AS "USE_FUEL_NM",
            FUEL_NBR AS "USE_FUEL_NBR",
            ISTD_TRANS AS "GRBX_KND_NM",
            ISTD_TRANS_NBR AS "GRBX_KND_NBR",
            NEW_SALE_PRICE AS "SALE_PRICE",
            USE_TYPE
    FROM HCS_20191125
    WHERE
    --과소 브랜드 제거
        BRAND_NBR NOT IN ('284','362','435','664','690','719','773','1505','1677','1752','2002','2095','2226','3212','3223','3275','3276','3284','3300','3433','3554','4643','4716','5211','5212','5213','5214', '5216', '5217', '5218')
        --고가차량 제거
        AND NEW_SALE_PRICE < '20000'
        --렌트카 제거
        AND USE_TYPE IS NULL
--        AND REP_CAR_CLASS_NBR IN ('2387', '60')
    ) HCS
    ,
    (
        SELECT
            IMPORT_YN,
            BRAND_NM,
            BRAND_NBR,
            REP_CAR_CLASS_NM,
            REP_CAR_CLASS_NBR,
            CASE
                WHEN INSTR(CAR_CLASS_NM,'('||CAR_GRADE_PROJECT_CD||')') IN (0,NULL) THEN DECODE(CAR_GRADE_PROJECT_CD, NULL, CAR_CLASS_NM||' '||YEAR_TYPE,CAR_CLASS_NM||' ('||CAR_GRADE_PROJECT_CD||') '||YEAR_TYPE)
                WHEN INSTR(CAR_CLASS_NM,'('||CAR_GRADE_PROJECT_CD||')') >0 THEN CAR_CLASS_NM||' '||YEAR_TYPE
            END AS "CAR_CLASS_NM",
            CAR_CLASS_NBR,
            CAR_CLASS_NM AS "MID_CAR_CLASS_NM",
            LV2 AS "MID_CAR_CLASS_NBR",
            YEAR_TYPE,
            CAR_GRADE_NM,
            CAR_GRADE_NBR,
            CASE WHEN ENGINESIZE IS NULL THEN 0 ELSE ENGINESIZE END AS "DSPLVL",
            PERSON AS "TKCAR_PSCAP_CO",
            M_YEAR_TYPE,
            FUEL AS "USE_FUEL_NM",
            FUEL_NBR AS "USE_FUEL_NBR",
            ISTD_TRANS AS "GRBX_KND_NM",
            ISTD_TRANS_NBR AS "GRBX_KND_NBR",
            NEW_SALE_PRICE AS "SALE_PRICE",
            USE_TYPE   
        FROM HCS_CIY_MASTER_LV2
--        WHERE REP_CAR_CLASS_NBR IN ('2387', '60')
    ) LV2
WHERE
        HCS.IMPORT_YN = LV2.IMPORT_YN
    AND HCS.BRAND_NM = LV2.BRAND_NM
    AND HCS.BRAND_NBR = LV2.BRAND_NBR
    AND HCS.REP_CAR_CLASS_NM = LV2.REP_CAR_CLASS_NM
    AND HCS.REP_CAR_CLASS_NBR = LV2.REP_CAR_CLASS_NBR
    AND HCS.CAR_CLASS_NM = LV2.CAR_CLASS_NM
    AND HCS.CAR_CLASS_NBR = LV2.CAR_CLASS_NBR
    AND HCS.M_YEAR_TYPE = LV2.M_YEAR_TYPE
    AND HCS.YEAR_TYPE = LV2.YEAR_TYPE
    AND HCS.CAR_GRADE_NM = LV2.CAR_GRADE_NM
    AND HCS.CAR_GRADE_NBR = LV2.CAR_GRADE_NBR
    AND HCS.DSPLVL = LV2.DSPLVL
    AND HCS.TKCAR_PSCAP_CO = LV2.TKCAR_PSCAP_CO
    AND HCS.USE_FUEL_NM = LV2.USE_FUEL_NM
    AND HCS.GRBX_KND_NM = LV2.GRBX_KND_NM
    AND HCS.GRBX_KND_NBR = LV2.GRBX_KND_NBR
    AND HCS.SALE_PRICE = LV2.SALE_PRICE
) SS
, CIY
WHERE
    SS.CAR_GRADE_NBR = CIY.CAR_GRADE_NBR
;

---
--#시트2
SELECT 
    HCS.IMPORT_YN,
    HCS.BRAND_NM,
    HCS.BRAND_NBR,
    HCS.REP_CAR_CLASS_NM,
    HCS.REP_CAR_CLASS_NBR,
    LV2.MID_CAR_CLASS_NM,
    LV2.MID_CAR_CLASS_NBR,
    HCS.CAR_CLASS_NM,
    HCS.CAR_CLASS_NBR,
    HCS.YEAR_TYPE,
    HCS.CAR_GRADE_NM,
    HCS.CAR_GRADE_NBR,
    HCS.DSPLVL,
    HCS.TKCAR_PSCAP_CO,
    HCS.M_YEAR_TYPE,
    HCS.USE_FUEL_NM,
    HCS.USE_FUEL_NBR,
    HCS.GRBX_KND_NM,
    HCS.GRBX_KND_NBR,
    HCS.SALE_PRICE,
    HCS.USE_TYPE
FROM
    (--15,305
    SELECT
            IMPORT_YN,
            BRAND_NM,
            BRAND_NBR,
            REP_CAR_CLASS_NM,
            REP_CAR_CLASS_NBR,
            CASE 
                WHEN CAR_GRADE_PROJECT_CD IS NOT NULL THEN REP_CAR_CLASS_NM||' ('||CAR_GRADE_PROJECT_CD||')'
                WHEN CAR_GRADE_PROJECT_CD IS NULL THEN REP_CAR_CLASS_NM
                WHEN CAR_GRADE_PROJECT_CD = '-' THEN REP_CAR_CLASS_NM
            ELSE '확인필요' END AS "CAR_CLASS_NM",
            CAR_CLASS_NBR,
            YEAR_TYPE,
            CAR_GRADE_NM,
            CAR_GRADE_NBR,
            CASE WHEN ENGINESIZE IS NULL THEN 0 ELSE ENGINESIZE END AS "DSPLVL",
            PERSON AS "TKCAR_PSCAP_CO",
            M_YEAR_TYPE,
            FUEL AS "USE_FUEL_NM",
            FUEL_NBR AS "USE_FUEL_NBR",
            ISTD_TRANS AS "GRBX_KND_NM",
            ISTD_TRANS_NBR AS "GRBX_KND_NBR",
            NEW_SALE_PRICE AS "SALE_PRICE",
            USE_TYPE
    FROM HCS_20191125
    WHERE
        NEW_SALE_PRICE >= '20000'
        AND USE_TYPE IS NULL
        AND BRAND_NBR NOT IN ('5216', '5217', '5218')
    ) HCS
    ,
    (
    SELECT
        IMPORT_YN,
        BRAND_NM,
        BRAND_NBR,
        REP_CAR_CLASS_NM,
        REP_CAR_CLASS_NBR,
        CASE 
            WHEN CAR_GRADE_PROJECT_CD IS NOT NULL THEN REP_CAR_CLASS_NM||' ('||CAR_GRADE_PROJECT_CD||')'
            WHEN CAR_GRADE_PROJECT_CD IS NULL THEN REP_CAR_CLASS_NM
            WHEN CAR_GRADE_PROJECT_CD = '-' THEN REP_CAR_CLASS_NM
        ELSE '확인필요' END AS "CAR_CLASS_NM",
        CAR_CLASS_NBR,
        CAR_CLASS_NM AS "MID_CAR_CLASS_NM",
        LV2 AS "MID_CAR_CLASS_NBR",
        YEAR_TYPE,
        CAR_GRADE_NM,
        CAR_GRADE_NBR,
        CASE WHEN ENGINESIZE IS NULL THEN 0 ELSE ENGINESIZE END AS "DSPLVL",
        PERSON AS "TKCAR_PSCAP_CO",
        M_YEAR_TYPE,
        FUEL AS "USE_FUEL_NM",
        FUEL_NBR AS "USE_FUEL_NBR",
        ISTD_TRANS AS "GRBX_KND_NM",
        ISTD_TRANS_NBR AS "GRBX_KND_NBR",
        NEW_SALE_PRICE AS "SALE_PRICE",
        USE_TYPE   
    FROM HCS_CIY_MASTER_LV2
    ) LV2
WHERE
        HCS.IMPORT_YN = LV2.IMPORT_YN
    AND HCS.BRAND_NM = LV2.BRAND_NM
    AND HCS.BRAND_NBR = LV2.BRAND_NBR
    AND HCS.REP_CAR_CLASS_NM = LV2.REP_CAR_CLASS_NM
    AND HCS.REP_CAR_CLASS_NBR = LV2.REP_CAR_CLASS_NBR
    AND HCS.CAR_CLASS_NM = LV2.CAR_CLASS_NM
    AND HCS.CAR_CLASS_NBR = LV2.CAR_CLASS_NBR
    AND HCS.M_YEAR_TYPE = LV2.M_YEAR_TYPE
    AND HCS.YEAR_TYPE = LV2.YEAR_TYPE
    AND HCS.CAR_GRADE_NM = LV2.CAR_GRADE_NM
    AND HCS.CAR_GRADE_NBR = LV2.CAR_GRADE_NBR
    AND HCS.DSPLVL = LV2.DSPLVL
    AND HCS.TKCAR_PSCAP_CO = LV2.TKCAR_PSCAP_CO
    AND HCS.USE_FUEL_NM = LV2.USE_FUEL_NM
    AND HCS.GRBX_KND_NM = LV2.GRBX_KND_NM
    AND HCS.GRBX_KND_NBR = LV2.GRBX_KND_NBR
    AND HCS.SALE_PRICE = LV2.SALE_PRICE
;
--