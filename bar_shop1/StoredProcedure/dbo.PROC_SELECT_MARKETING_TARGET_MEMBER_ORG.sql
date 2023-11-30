IF OBJECT_ID (N'dbo.PROC_SELECT_MARKETING_TARGET_MEMBER_ORG', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_SELECT_MARKETING_TARGET_MEMBER_ORG
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PROC_SELECT_MARKETING_TARGET_MEMBER_ORG]
	@P_SITE_DIV VARCHAR(20) = 'SB|SA|ST|SS|B|BM',
	@P_SMS_YN CHAR(1) = 'Y',
	@P_ORDER_YN CHAR(1) = 'Y',
	@P_ORDER_T_YN CHAR(1) = 'N',
	@P_SAMPLE_YN CHAR(1) = 'Y',
	@P_MARKETING_YN CHAR(1) = 'Y',
	@P_AREA VARCHAR(100) = '서울|경기|인천|대전|대구|세종|제주|광주|부산|울산|경남|경북|전남|전북|충남|충북|강원',
	@P_GENDER VARCHAR(2) = NULL,
	@P_REG_S_DT VARCHAR(10) = '2022-01-01',
	@P_REG_E_DT VARCHAR(10) = NULL,
	@P_WED_S_DT VARCHAR(10) = '2022-01-01',
	@P_WED_E_DT VARCHAR(10) = NULL,
	@P_BIRTH_S_YEAR VARCHAR(4) = '1990',
	@P_BIRTH_E_YEAR VARCHAR(4) = NULL,

  	@P_SAMSUNG_MEM_YN CHAR(1) = 'Y',
	@P_LG_MEM_YN CHAR(1) = 'Y',
	@P_CASAMIA_MEM_YN CHAR(1) = 'N',
	@P_CUCKOO_MEM_YN CHAR(1) = 'N',
	@P_HYUNDAI_MEM_YN CHAR(1) = 'N',
	@P_KT_MEM_YN CHAR(1) = 'N',

	@P_PAGE_SIZE INT = 50,
	@P_PAGE_NUMBER INT = 1,
	@P_RESULT_TYPE CHAR(1) = 'L'

AS
BEGIN

DECLARE @T_SITE_DIV TABLE ( Brand VARCHAR(2) )
DECLARE @T_AREA TABLE ( AREA VARCHAR(8) )
DECLARE @T_BRAND TABLE ( Brand VARCHAR(2), BrandName NVARCHAR(10) )

INSERT INTO @T_SITE_DIV (Brand)
SELECT VALUE FROM dbo.[ufn_SplitTable] (@P_SITE_DIV, '|')

INSERT INTO @T_AREA (AREA)
SELECT VALUE FROM dbo.[ufn_SplitTable] (@P_AREA, '|')


INSERT INTO @T_BRAND (Brand, BrandName) VALUES
('SB', '바른손'),
('SA', '비핸즈'),
('SS', '프리미어'),
('ST', '더카드'),
('B', '바른손몰'),
('BM', '모초')


SELECT
	CONVERT(INT, ROW_NUMBER() OVER(ORDER BY REGDATE DESC)) AS ROW_NUM
	,(SELECT BrandName FROM @T_BRAND WHERE Brand = SITE_DIV) AS SITE_NAME
	, T2.*
	INTO #TEMP
FROM (
		SELECT 
			(SELECT CASE WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN 
                        CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(REFERER_SALES_GUBUN, 'SB') END
					ELSE 
                        CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(SELECT_SALES_GUBUN, 'SB') END
					END
			   FROM S2_USERINFO_THECARD WHERE uid = T1.uid) AS SITE_DIV
			 , CONVERT(CHAR(19), Reg_Date, 20) AS REGDATE
			 , UNAME AS NAME
			 , ISNULL(gender,'') AS GENDER
			 , CONVERT(INT,LEFT(T1.BIRTH_DATE, 4))  AS BIRTH_YEAR
			 , HPHONE AS MOBILE
			 , UID   AS USER_ID
			 , address_d AS ADDR
			 , WEDDING_DAY 
			 , ISNULL((SELECT TOP  1 'Y' FROM CUSTOM_SAMPLE_ORDER WHERE member_id = uid AND status_Seq > 0  AND status_seq NOT IN ('3','5') ),'N') AS SAMPLE_YN
			 , ISNULL((SELECT TOP  1 'Y' FROM CUSTOM_ORDER WHERE member_id = uid AND status_Seq > 0 AND status_seq NOT IN ('3','5') AND order_type IN ('1','6','7') ),'N') AS ORDER_YN
			 , ISNULL((SELECT TOP  1 'Y' FROM CUSTOM_ORDER WHERE member_id = uid AND status_Seq > 0 AND status_seq NOT IN ('3','5') AND order_type= '2' ),'N') AS ORDER_T_YN
			 , chk_sms AS SMS_YN
			 , MarketingYN AS MARKETING_YN
  			 , SAMSUNG_MEM_YN
			 , LG_MEM_YN
			 , CASAMIA_MEM_YN
			 , CUCKOO_MEM_YN
			 , HYUNDAI_MEM_YN
			 , KT_MEM_YN

		 FROM ( 
				SELECT CASE WHEN INTEGRATION_MEMBER_YORN = 'N' THEN row_number() over(partition by A.HPHONE order by A.reg_date)
					   ELSE row_number()over(partition by A.UID order by A.reg_date) END RM
					 , SITE_DIV_NAME
					 , A.Reg_Date  
					 , A.UID 
					 , A.UNAME 
					 , A.BIRTH_DATE 
					 , A.HPHONE 
					 , A.address_d
					 , A.WEDDING_DAY 
					 , CASE WHEN B.Seq IS NOT NULL THEN 'Y' ELSE 'N' END AS MarketingYN   
					 , REFERER_SALES_GUBUN 
					 , CASE WHEN A.gender  = 0 THEN '여' WHEN A.gender = 1 THEN '남' END AS gender
					 , chk_sms
					 , SAMSUNG_MEM_YN
					 , LG_MEM_YN
					 , CASAMIA_MEM_YN
					 , CUCKOO_MEM_YN
					 , HYUNDAI_MEM_YN
					 , KT_MEM_YN
				  FROM ( 
						SELECT SITE_DIV_NAME
						     , A.INTERGRATION_DATE Reg_Date  
							 --, A.Reg_Date  
							 , A.UID 
							 , A.UNAME 
							 , A.BIRTH_DATE 
							 , A.HPHONE   
							 , (A.address  + A.addr_detail) AS address_d
							 , A.WEDDING_DAY   
							 , A.REFERER_SALES_GUBUN 
							 , ISNULL(A.INTEGRATION_MEMBER_YORN , 'N') INTEGRATION_MEMBER_YORN 
							 , A.gender 
							 , A.chk_sms
							 , ISNULL(A.CHOICE_AGREEMENT_FOR_SAMSUNG_MEMBERSHIP, 'N') SAMSUNG_MEM_YN
							 , ISNULL(A.chk_lgmembership, 'N') LG_MEM_YN
							 , ISNULL(A.chk_casamiamembership, 'N') CASAMIA_MEM_YN
							 , ISNULL(A.chk_cuckoosmembership, 'N') CUCKOO_MEM_YN
							 , ISNULL(A.chk_hyundaimembership, 'N') HYUNDAI_MEM_YN
							 , ISNULL(A.chk_ktmembership, 'N') KT_MEM_YN
						  FROM VW_USER_INFO AS A
						 WHERE LEN(A.HPHONE) > 12
						   AND A.DupInfo IS NOT NULL    
 						   AND A.ConnInfo IS NOT NULL
 						  AND (@P_REG_S_DT IS NULL OR A.INTERGRATION_DATE >= @P_REG_S_DT)
						  AND (@P_REG_E_DT IS NULL OR A.INTERGRATION_DATE < DATEADD(DAY,1,CONVERT(DATE, @P_REG_E_DT)))  
						  AND (@P_SMS_YN IS NULL OR A.chk_sms = @P_SMS_YN)
						) AS A LEFT OUTER JOIN S4_Event_Raina AS B ON (A.UID = B.UID AND B.event_div = 'MKevent')   
					) AS T1 
				WHERE RM = 1 
			) T2
		INNER JOIN @T_AREA AS A
			ON T2.ADDR LIKE A.AREA+'%'
WHERE 1 = 1
  AND SITE_DIV IN (SELECT BRAND FROM @T_SITE_DIV)
  AND (@P_SAMPLE_YN IS NULL OR SAMPLE_YN = @P_SAMPLE_YN)
  AND (@P_ORDER_YN IS NULL OR ORDER_YN = @P_ORDER_YN)
  AND (@P_ORDER_T_YN IS NULL OR ORDER_T_YN = @P_ORDER_T_YN)
  AND (@P_BIRTH_S_YEAR IS NULL OR BIRTH_YEAR >= @P_BIRTH_S_YEAR)
  AND (@P_BIRTH_E_YEAR IS NULL OR BIRTH_YEAR <= @P_BIRTH_E_YEAR)
  AND (@P_GENDER IS NULL OR GENDER = @P_GENDER)
  AND (@P_MARKETING_YN IS NULL OR MARKETING_YN = @P_MARKETING_YN)
  AND (@P_SAMSUNG_MEM_YN IS NULL OR SAMSUNG_MEM_YN = @P_SAMSUNG_MEM_YN)
  AND (@P_LG_MEM_YN IS NULL OR LG_MEM_YN = @P_LG_MEM_YN)
  AND (@P_CASAMIA_MEM_YN IS NULL OR CASAMIA_MEM_YN = @P_CASAMIA_MEM_YN)
  AND (@P_CUCKOO_MEM_YN IS NULL OR CUCKOO_MEM_YN = @P_CUCKOO_MEM_YN)
  AND (@P_HYUNDAI_MEM_YN IS NULL OR HYUNDAI_MEM_YN = @P_HYUNDAI_MEM_YN)
  AND (@P_KT_MEM_YN IS NULL OR KT_MEM_YN = @P_KT_MEM_YN)

  AND (@P_WED_S_DT IS NULL OR WEDDING_DAY >= @P_WED_S_DT)
  AND (@P_WED_E_DT IS NULL OR WEDDING_DAY < DATEADD(DAY,1,CONVERT(DATE, @P_WED_E_DT)))
ORDER BY ROW_NUM DESC

IF @P_RESULT_TYPE = 'L'
BEGIN
	SELECT * FROM #TEMP
	ORDER BY ROW_NUM ASC
END
ELSE IF @P_RESULT_TYPE = 'P'
BEGIN
	SELECT * FROM #TEMP
	WHERE 1 = 1
		AND		ROW_NUM > ((@P_PAGE_NUMBER - 1) * @P_PAGE_SIZE)
		AND		ROW_NUM <= (@P_PAGE_NUMBER * @P_PAGE_SIZE)
	ORDER BY ROW_NUM ASC
END
ELSE
BEGIN
	SELECT COUNT(1) CNT FROM #TEMP
END



END
GO