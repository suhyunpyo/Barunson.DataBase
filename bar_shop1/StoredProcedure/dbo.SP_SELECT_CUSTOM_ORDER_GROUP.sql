IF OBJECT_ID (N'dbo.SP_SELECT_CUSTOM_ORDER_GROUP', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CUSTOM_ORDER_GROUP
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

/*

SELECT  TOP 20 *
FROM    CUSTOM_ORDER_GROUP
WHERE	1 = 1
AND     ORDER_DATE >= '2015-09-01 00:00:00'
AND     ORDER_DATE < '2015-09-11 00:00:00'
ORDER BY ORDER_DATE DESC, ORDER_G_SEQ DESC

EXEC SP_SELECT_CUSTOM_ORDER_GROUP '2015-09-01', '2015-09-10', '', '', 50, 1

*/

CREATE PROCEDURE [dbo].[SP_SELECT_CUSTOM_ORDER_GROUP]
    @START_DATE             AS VARCHAR(10)
,   @END_DATE               AS VARCHAR(10)
,   @USER_ID                AS VARCHAR(10) = ''
,   @ORDER_NAME             AS VARCHAR(10) = ''
,   @RECORD_PER_PAGE        AS INT = 50
,   @CURRENT_PAGE           AS INT = 1

AS
BEGIN
    
    SET NOCOUNT ON;

    DECLARE @TOT_CNT AS INT
    DECLARE @TOT_PAGE_CNT AS INT

    SELECT	@TOT_CNT = COUNT(*)
        ,   @TOT_PAGE_CNT = CEILING(1.0 * COUNT(*) / @RECORD_PER_PAGE)
	FROM	CUSTOM_ORDER_GROUP
	WHERE	1 = 1
    AND     ORDER_DATE >= @START_DATE + ' 00:00:00'
    AND     ORDER_DATE < DATEADD(DAY, 1, @END_DATE + ' 00:00:00')
    AND     CASE WHEN @USER_ID      = '' THEN '' ELSE MEMBER_ID     END = @USER_ID
    AND     CASE WHEN @ORDER_NAME   = '' THEN '' ELSE ORDER_NAME    END = @ORDER_NAME



    SELECT  *
        ,   @TOT_CNT AS TOT_CNT
        ,   @TOT_PAGE_CNT AS TOT_PAGE_CNT
    FROM    (
	            SELECT	ROW_NUMBER() OVER(ORDER BY ORDER_DATE DESC, ORDER_G_SEQ DESC) AS ROW_NUM
                    ,   ORDER_G_SEQ
                    ,   ISNULL(STATUS_SEQ, 0)           AS STATUS_SEQ
                    ,   ISNULL(SETTLE_STATUS, 0)        AS SETTLE_STATUS
                    ,   ORDER_DATE
                    ,   MEMBER_ID
                    ,   ORDER_NAME
                    ,   ORDER_EMAIL
                    ,   ORDER_PHONE
                    ,   ORDER_HPHONE
                    ,   ORDER_ETC_COMMENT
		            ,   ETC_PRICE_MENT
                    ,   ORDER_PRICE
                    ,   ORDER_TOTAL_PRICE
                    ,   DELIVERY_PRICE
                    ,   ETC_PRICE
                    ,   SETTLE_PRICE
                    ,   SETTLE_DATE
                    ,   SETTLE_CANCEL_DATE
                    ,   SETTLE_METHOD
                    ,   PG_SHOPID
                    ,   PG_TID
                    ,   DACOM_TID
                    ,   PG_RESULTINFO
        
	            FROM	CUSTOM_ORDER_GROUP
	
	            WHERE	1 = 1
                AND     ORDER_DATE >= @START_DATE + ' 00:00:00'
                AND     ORDER_DATE < DATEADD(DAY, 1, @END_DATE + ' 00:00:00')
                AND     CASE WHEN @USER_ID      = '' THEN '' ELSE MEMBER_ID     END = @USER_ID
                AND     CASE WHEN @ORDER_NAME   = '' THEN '' ELSE ORDER_NAME    END = @ORDER_NAME
            ) A

    WHERE   1 = 1
    AND     ROW_NUM >= (((@CURRENT_PAGE - 1) * @RECORD_PER_PAGE) + 1)
    AND     ROW_NUM <= (@CURRENT_PAGE * @RECORD_PER_PAGE)

    ORDER BY ROW_NUM ASC



	
END
GO
