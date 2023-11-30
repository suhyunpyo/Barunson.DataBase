IF OBJECT_ID (N'dbo.SP_SELECT_DEARDEER_SAMPLE_ORDER_MST_SEARCH', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_DEARDEER_SAMPLE_ORDER_MST_SEARCH
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
    EXEC SP_SELECT_DEARDEER_SAMPLE_ORDER_MST_SEARCH '0', '', 0, 0, '2017-01-01', '2018-02-01', 0
    EXEC SP_SELECT_DEARDEER_SAMPLE_ORDER_MST_SEARCH    '0'  , ''  ,  0 , '0'  , '2018-01-08'  , '2018-01-15'  ,  0 
*/

CREATE PROCEDURE [dbo].[SP_SELECT_DEARDEER_SAMPLE_ORDER_MST_SEARCH]
    @P_SEARCH_TYPE          AS VARCHAR(10)
,   @P_SEARCH_VALUE         AS VARCHAR(10)
,   @P_STATUS_SEQ           AS INT
,   @P_SEARCH_DATE_TYPE     AS VARCHAR(10)
,   @P_SEARCH_START_DATE    AS VARCHAR(10)
,   @P_SEARCH_END_DATE      AS VARCHAR(10)
,   @P_ORDER_BY             AS INT

AS  
BEGIN
    
    SELECT  
            DEARDEER_SAMPLE_ORDER_MST_SEQ
        ,   SAMPLE_ORDER_NO
        ,   STATUS_SEQ
        ,   USER_ID
        ,   USER_EMAIL
        ,   USER_NAME
        ,   HOME_PHONE_NUMBER
        ,   MOBILE_PHONE_NUMBER
        ,   ZIP_CODE
        ,   ADDRESS
        ,   ADDRESS_DETAIL
        ,   DELIVERY_COMPANY_CODE
        ,   TRACKING_NUMBER
        ,   INVOICE_PRINT_YORN
        ,   JOB_ORDER_PRINT_YORN
        ,   DSP_PRINT_YORN
        ,   ISNULL(CONVERT(VARCHAR(10), PREPARE_DATE, 120), '') AS PREPARE_DATE
        ,   ISNULL(CONVERT(VARCHAR(10), DELIVERY_DATE, 120), '') AS DELIVERY_DATE
        ,   ISNULL(CONVERT(VARCHAR(10), REG_DATE, 120), '') AS REG_DATE

    FROM    DEARDEER_SAMPLE_ORDER_MST
    WHERE   1 = 1
    AND     (
                    (@P_SEARCH_TYPE = 0 AND USER_NAME LIKE '%' + @P_SEARCH_VALUE + '%')
                OR  (@P_SEARCH_TYPE = 1 AND USER_ID LIKE '%' + @P_SEARCH_VALUE + '%')
                OR  (@P_SEARCH_TYPE = 2 AND (HOME_PHONE_NUMBER LIKE '%' + @P_SEARCH_VALUE + '%' OR MOBILE_PHONE_NUMBER LIKE '%' + @P_SEARCH_VALUE + '%'))
                OR  (@P_SEARCH_TYPE = 3 AND (ADDRESS LIKE '%' + @P_SEARCH_VALUE + '%' OR ADDRESS_DETAIL LIKE '%' + @P_SEARCH_VALUE + '%'))
                OR  (@P_SEARCH_TYPE = 4 AND SAMPLE_ORDER_NO LIKE '%' + @P_SEARCH_VALUE + '%')
            )
    AND     (
                    @P_STATUS_SEQ = 0
                OR  STATUS_SEQ = @P_STATUS_SEQ
            )
    AND     (
                    (@P_SEARCH_DATE_TYPE = 0 AND REG_DATE >= @P_SEARCH_START_DATE AND REG_DATE < DATEADD(DAY, 1, @P_SEARCH_END_DATE))
                OR  (@P_SEARCH_DATE_TYPE = 1 AND PREPARE_DATE >= @P_SEARCH_START_DATE AND PREPARE_DATE < DATEADD(DAY, 1, @P_SEARCH_END_DATE))
                OR  (@P_SEARCH_DATE_TYPE = 2 AND DELIVERY_DATE >= @P_SEARCH_START_DATE AND DELIVERY_DATE < DATEADD(DAY, 1, @P_SEARCH_END_DATE))
            )
    ORDER
    BY      CASE 
                    WHEN @P_ORDER_BY = 0 THEN REG_DATE 
                    WHEN @P_ORDER_BY = 1 THEN PREPARE_DATE 
                    WHEN @P_ORDER_BY = 2 THEN DELIVERY_DATE 
                    ELSE REG_DATE
            END DESC

END
GO