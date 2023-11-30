IF OBJECT_ID (N'dbo.SP_SELECT_USER_FOR_ORDER_INFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_USER_FOR_ORDER_INFO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***

EXEC SP_SELECT_USER_FOR_ORDER_INFO  '2017-06-01', '2017-06-30', '2017-12-01', '2017-12-31', '', 'B'

***/
CREATE Procedure [dbo].[SP_SELECT_USER_FOR_ORDER_INFO]  
	--  @P_DATE_GUBUN AS VARCHAR(10)
      @P_START_DATE AS VARCHAR(20)
    , @P_END_DATE AS VARCHAR(20)
    , @P_START_WEDD_DATE AS VARCHAR(20)
    , @P_END_WEDD_DATE AS VARCHAR(20)
    , @P_INFLOW AS VARCHAR(10)
    , @P_BRAND_GUBUN AS VARCHAR(10)
AS  

BEGIN
    
    DECLARE @P_DATE_GUBUN AS VARCHAR(20)

    IF ISNULL(@P_START_WEDD_DATE, '') <> ''
        BEGIN
            SET @P_DATE_GUBUN = 'WEDD';
        END

    IF ISNULL(@P_END_WEDD_DATE, '') = ''
        BEGIN
            SET @P_END_WEDD_DATE = GETDATE();
        END

    --SELECT @P_DATE_GUBUN, @P_START_WEDD_DATE, @P_END_WEDD_DATE

    SET NOCOUNT ON;

    SELECT  MAX(UNAME)                          AS UNAME
    ,   CASE WHEN MAX(GENDER) = '1' THEN '남성'
             ELSE '여성' 
        END AS GENDER
    ,   MAX(ADDRESS)                            AS ADDRESS
    ,   MAX(UID)                                AS UID
    ,   MAX(UMAIL)                              AS UMAIL
    ,   (DATEDIFF(DAY, MAX(BIRTHDATE),GETDATE())-DATEDIFF(YEAR,MAX(BIRTHDATE),GETDATE())/4)/365  AS AGE
    ,   MAX(BIRTHDATE)                          AS BIRTH
    ,   MAX(WEDDING_DAY)                        AS WEDDING_DAY
    ,   MAX(REGIST_DATE)                        AS REGIST_DATE
    ,   MAX(LOGIN_DATE)                         AS LOGIN_DATE
    ,   CASE WHEN MAX(SIGN_IN_SITE) = 'SB' THEN '바른손'
             WHEN MAX(SIGN_IN_SITE) = 'SA' THEN '비핸즈'
             WHEN MAX(SIGN_IN_SITE) = 'ST' THEN '더카드'
             WHEN MAX(SIGN_IN_SITE) = 'SS' THEN '프리미어'
             WHEN MAX(SIGN_IN_SITE) IN ('B','H','C') THEN '바른몰'
             WHEN MAX(SIGN_IN_SITE) = 'BE' THEN '비웨딩'
             ELSE MAX(SIGN_IN_SITE)
        END AS SIGN_IN_SITE
    ,   MAX(INFLOW_ROUTE)                       AS INFLOW_ROUTE
    ,   MAX(BARUNSONCARD_SAMPLE_ORDER_DATE)     AS BARUNSONCARD_SAMPLE_ORDER_DATE
    ,   MAX(BHANDSCARD_SAMPLE_ORDER_DATE)       AS BHANDSCARD_SAMPLE_ORDER_DATE
    ,   MAX(THECARD_SAMPLE_ORDER_DATE)          AS THECARD_SAMPLE_ORDER_DATE
    ,   MAX(PREMIERPAPER_SAMPLE_ORDER_DATE)     AS PREMIERPAPER_SAMPLE_ORDER_DATE
    ,   MAX(BARUNSONMALL_SAMPLE_ORDER_DATE)     AS BARUNSONMALL_SAMPLE_ORDER_DATE
    ,   MAX(BARUNSONCARD_ORDER_DATE)            AS BARUNSONCARD_ORDER_DATE
    ,   MAX(BHANDSCARD_ORDER_DATE)              AS BHANDSCARD_ORDER_DATE
    ,   MAX(THECARD_ORDER_DATE)                 AS THECARD_ORDER_DATE
    ,   MAX(PREMIERPAPER_ORDER_DATE)            AS PREMIERPAPER_ORDER_DATE
    ,   MAX(BARUNSONMALL_ORDER_DATE)            AS BARUNSONMALL_ORDER_DATE
    ,   MAX(BARUNSONCARD_SETTLE_DATE)           AS BARUNSONCARD_SETTLE_DATE
    ,   MAX(BHANDSCARD_SETTLE_DATE)             AS BHANDSCARD_SETTLE_DATE
    ,   MAX(THECARD_SETTLE_DATE)                AS THECARD_SETTLE_DATE
    ,   MAX(PREMIERPAPER_SETTLE_DATE)           AS PREMIERPAPER_SETTLE_DATE
    ,   MAX(BARUNSONMALL_SETTLE_DATE)           AS BARUNSONMALL_SETTLE_DATE

    FROM    (

                SELECT  SUI.UNAME
                    ,   SUI.GENDER
                    ,   LEFT(SUI.ADDRESS, 2) AS ADDRESS
                    ,   SUI.UID
                    ,   SUI.UMAIL
					,   ISNULL(SUI.BIRTHDATE , replace(SUI.Birth, '-', '')) AS BIRTHDATE
                    ,   CASE WHEN ISDATE(SUI.WEDD_YEAR + '-' + SUI.WEDD_MONTH + '-' + SUI.WEDD_DAY) = 1 THEN SUI.WEDD_YEAR + '-' + SUI.WEDD_MONTH + '-' + SUI.WEDD_DAY ELSE '' END AS WEDDING_DAY
                    ,   ISNULL(SUI.REG_DATE , '') AS REGIST_DATE
                    ,   ISNULL(CONVERT(VARCHAR(10), SLII.REG_DATE , 120), '') AS LOGIN_DATE
                    ,   ISNULL(SUI.SELECT_SALES_GUBUN, SUI.REFERER_SALES_GUBUN) AS SIGN_IN_SITE
                    ,   ISNULL(SUI.INFLOW_ROUTE, '') AS INFLOW_ROUTE
        
                    --,   CASE WHEN CSO.SALES_GUBUN = 'SB' THEN CONVERT(VARCHAR(10), CSO.REQUEST_DATE, 120) ELSE '' END AS BARUNSONCARD_SAMPLE_ORDER_DATE
                    --,   CASE WHEN CSO.SALES_GUBUN = 'SA' THEN CONVERT(VARCHAR(10), CSO.REQUEST_DATE, 120) ELSE '' END AS BHANDSCARD_SAMPLE_ORDER_DATE
                    --,   CASE WHEN CSO.SALES_GUBUN = 'ST' THEN CONVERT(VARCHAR(10), CSO.REQUEST_DATE, 120) ELSE '' END AS THECARD_SAMPLE_ORDER_DATE
                    --,   CASE WHEN CSO.SALES_GUBUN = 'SS' THEN CONVERT(VARCHAR(10), CSO.REQUEST_DATE, 120) ELSE '' END AS PREMIERPAPER_SAMPLE_ORDER_DATE
                    --,   CASE WHEN CSO.SALES_GUBUN IN ('B', 'H', 'C') THEN CONVERT(VARCHAR(10), CSO.REQUEST_DATE, 120) ELSE '' END AS BARUNSONMALL_SAMPLE_ORDER_DATE

                    ,   ISNULL(BARUNSONCARD_SAMPLE_ORDER_DATE, '') AS BARUNSONCARD_SAMPLE_ORDER_DATE
                    ,   ISNULL(BHANDSCARD_SAMPLE_ORDER_DATE, '') AS BHANDSCARD_SAMPLE_ORDER_DATE
                    ,   ISNULL(THECARD_SAMPLE_ORDER_DATE, '') AS THECARD_SAMPLE_ORDER_DATE
                    ,   ISNULL(PREMIERPAPER_SAMPLE_ORDER_DATE, '') AS PREMIERPAPER_SAMPLE_ORDER_DATE
                    ,   ISNULL(BARUNSONMALL_SAMPLE_ORDER_DATE, '') AS BARUNSONMALL_SAMPLE_ORDER_DATE

                    --,   CASE WHEN CO.SALES_GUBUN = 'SB' THEN CONVERT(VARCHAR(10), CO.ORDER_DATE, 120) ELSE '' END AS BARUNSONCARD_ORDER_DATE
                    --,   CASE WHEN CO.SALES_GUBUN = 'SA' THEN CONVERT(VARCHAR(10), CO.ORDER_DATE, 120) ELSE '' END AS BHANDSCARD_ORDER_DATE
                    --,   CASE WHEN CO.SALES_GUBUN = 'ST' THEN CONVERT(VARCHAR(10), CO.ORDER_DATE, 120) ELSE '' END AS THECARD_ORDER_DATE
                    --,   CASE WHEN CO.SALES_GUBUN = 'SS' THEN CONVERT(VARCHAR(10), CO.ORDER_DATE, 120) ELSE '' END AS PREMIERPAPER_ORDER_DATE
                    --,   CASE WHEN CO.SALES_GUBUN IN ('B', 'H', 'C') THEN CONVERT(VARCHAR(10), CO.ORDER_DATE, 120) ELSE '' END AS BARUNSONMALL_ORDER_DATE
                    ,   ISNULL(BARUNSONCARD_ORDER_DATE, '') AS BARUNSONCARD_ORDER_DATE
                    ,   ISNULL(BHANDSCARD_ORDER_DATE, '') AS BHANDSCARD_ORDER_DATE
                    ,   ISNULL(THECARD_ORDER_DATE, '') AS THECARD_ORDER_DATE
                    ,   ISNULL(PREMIERPAPER_ORDER_DATE, '') AS PREMIERPAPER_ORDER_DATE
                    ,   ISNULL(BARUNSONMALL_ORDER_DATE, '') AS BARUNSONMALL_ORDER_DATE
                                                         
                    --,   CASE WHEN CO.SALES_GUBUN = 'SB' THEN CONVERT(VARCHAR(10), CO.SETTLE_DATE, 120) ELSE '' END AS BARUNSONCARD_SETTLE_DATE
                    --,   CASE WHEN CO.SALES_GUBUN = 'SA' THEN CONVERT(VARCHAR(10), CO.SETTLE_DATE, 120) ELSE '' END AS BHANDSCARD_SETTLE_DATE
                    --,   CASE WHEN CO.SALES_GUBUN = 'ST' THEN CONVERT(VARCHAR(10), CO.SETTLE_DATE, 120) ELSE '' END AS THECARD_SETTLE_DATE
                    --,   CASE WHEN CO.SALES_GUBUN = 'SS' THEN CONVERT(VARCHAR(10), CO.SETTLE_DATE, 120) ELSE '' END AS PREMIERPAPER_SETTLE_DATE
                    --,   CASE WHEN CO.SALES_GUBUN IN ('B', 'H', 'C') THEN CONVERT(VARCHAR(10), CO.SETTLE_DATE, 120) ELSE '' END AS BARUNSONMALL_SATTLE_DATE
                    ,   ISNULL(BARUNSONCARD_SETTLE_DATE, '') AS BARUNSONCARD_SETTLE_DATE
                    ,   ISNULL(BHANDSCARD_SETTLE_DATE, '') AS BHANDSCARD_SETTLE_DATE
                    ,   ISNULL(THECARD_SETTLE_DATE, '') AS THECARD_SETTLE_DATE
                    ,   ISNULL(PREMIERPAPER_SETTLE_DATE, '') AS PREMIERPAPER_SETTLE_DATE
                    ,   ISNULL(BARUNSONMALL_SETTLE_DATE, '') AS BARUNSONMALL_SETTLE_DATE

                FROM    S2_USERINFO SUI
                --LEFT
                --JOIN    CUSTOM_ORDER CO         ON SUI.UID = CO.MEMBER_ID
                LEFT
                JOIN    (
                            SELECT  MEMBER_ID
                                ,   MAX(CASE WHEN SALES_GUBUN = 'SB' THEN CONVERT(VARCHAR(10), ORDER_DATE, 120) ELSE '' END) AS BARUNSONCARD_ORDER_DATE
                                ,   MAX(CASE WHEN SALES_GUBUN = 'SA' THEN CONVERT(VARCHAR(10), ORDER_DATE, 120) ELSE '' END) AS BHANDSCARD_ORDER_DATE
                                ,   MAX(CASE WHEN SALES_GUBUN = 'ST' THEN CONVERT(VARCHAR(10), ORDER_DATE, 120) ELSE '' END) AS THECARD_ORDER_DATE
                                ,   MAX(CASE WHEN SALES_GUBUN = 'SS' THEN CONVERT(VARCHAR(10), ORDER_DATE, 120) ELSE '' END) AS PREMIERPAPER_ORDER_DATE
                                ,   MAX(CASE WHEN SALES_GUBUN IN ('B', 'H', 'C') THEN CONVERT(VARCHAR(10), ORDER_DATE, 120) ELSE '' END) AS BARUNSONMALL_ORDER_DATE
                            FROM    CUSTOM_ORDER 
                            WHERE   1 = 1
                            AND     ORDER_DATE >= '2016-07-01'
                            AND     STATUS_SEQ NOT IN ( 0, 3, 5)
                            AND     MEMBER_ID IS NOT NULL

                            GROUP BY MEMBER_ID
                        ) CO ON SUI.UID = CO.MEMBER_ID

                LEFT
                JOIN    (
                            SELECT  MEMBER_ID
                                ,   MAX(CASE WHEN SALES_GUBUN = 'SB' THEN CONVERT(VARCHAR(10), SETTLE_DATE, 120) ELSE '' END) AS BARUNSONCARD_SETTLE_DATE
                                ,   MAX(CASE WHEN SALES_GUBUN = 'SA' THEN CONVERT(VARCHAR(10), SETTLE_DATE, 120) ELSE '' END) AS BHANDSCARD_SETTLE_DATE
                                ,   MAX(CASE WHEN SALES_GUBUN = 'ST' THEN CONVERT(VARCHAR(10), SETTLE_DATE, 120) ELSE '' END) AS THECARD_SETTLE_DATE
                                ,   MAX(CASE WHEN SALES_GUBUN = 'SS' THEN CONVERT(VARCHAR(10), SETTLE_DATE, 120) ELSE '' END) AS PREMIERPAPER_SETTLE_DATE
                                ,   MAX(CASE WHEN SALES_GUBUN IN ('B', 'H', 'C') THEN CONVERT(VARCHAR(10), SETTLE_DATE, 120) ELSE '' END) AS BARUNSONMALL_SETTLE_DATE
                            FROM    CUSTOM_ORDER 
                            WHERE   1 = 1
                            AND     ORDER_DATE >= '2016-07-01'
                            AND     SETTLE_STATUS = '2'
                            AND     MEMBER_ID IS NOT NULL
                            GROUP BY MEMBER_ID
                        ) SETTLECO ON SUI.UID = SETTLECO.MEMBER_ID

                --LEFT
                --JOIN    CUSTOM_SAMPLE_ORDER CSO ON SUI.UID = CSO.MEMBER_ID
                LEFT
                JOIN    (
                            SELECT  MEMBER_ID
                                ,   MAX(CASE WHEN SALES_GUBUN = 'SB' THEN CONVERT(VARCHAR(10), REQUEST_DATE, 120) ELSE '' END) AS BARUNSONCARD_SAMPLE_ORDER_DATE
                                ,   MAX(CASE WHEN SALES_GUBUN = 'SA' THEN CONVERT(VARCHAR(10), REQUEST_DATE, 120) ELSE '' END) AS BHANDSCARD_SAMPLE_ORDER_DATE
                                ,   MAX(CASE WHEN SALES_GUBUN = 'ST' THEN CONVERT(VARCHAR(10), REQUEST_DATE, 120) ELSE '' END) AS THECARD_SAMPLE_ORDER_DATE
                                ,   MAX(CASE WHEN SALES_GUBUN = 'SS' THEN CONVERT(VARCHAR(10), REQUEST_DATE, 120) ELSE '' END) AS PREMIERPAPER_SAMPLE_ORDER_DATE
                                ,   MAX(CASE WHEN SALES_GUBUN IN ('B', 'H', 'C') THEN CONVERT(VARCHAR(10), REQUEST_DATE, 120) ELSE '' END) AS BARUNSONMALL_SAMPLE_ORDER_DATE
                            FROM    CUSTOM_SAMPLE_ORDER 
                            WHERE   1 = 1
                            AND     REQUEST_DATE >= '2016-07-01'
                            AND     MEMBER_ID <> ''
                            AND     STATUS_SEQ NOT IN (3, 5)

                            GROUP BY MEMBER_ID
                        ) CSO ON SUI.UID = CSO.MEMBER_ID

                LEFT
                JOIN    (SELECT ISNULL(MAX(REGDATE), '') AS REG_DATE, UID FROM S4_LOGINIPINFO WHERE REGDATE >= '2016-07-01' GROUP BY UID) SLII     ON SUI.UID = SLII.UID

                WHERE   1 = 1
                AND     SUI.SITE_DIV = 'SB'
                AND     SUI.INTERGRATION_DATE >= '2016-07-01'
                AND     SUI.REG_DATE >= @P_START_DATE  AND SUI.REG_DATE < DATEADD(DD, 1, @P_END_DATE)
                AND     (   
                            ISNULL(@P_INFLOW, '' ) = '' OR SUI.INFLOW_ROUTE = @P_INFLOW
                        )
            
            ) A
    WHERE   1 = 1
    AND     (
            ISNULL(@P_DATE_GUBUN, '') <> 'WEDD' 
            OR (
                A.WEDDING_DAY >= @P_START_WEDD_DATE  AND A.WEDDING_DAY < DATEADD(DD, 1, @P_END_WEDD_DATE)
            )
        )

    GROUP BY A.UID

End


GO
