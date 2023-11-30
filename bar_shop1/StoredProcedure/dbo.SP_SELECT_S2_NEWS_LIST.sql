IF OBJECT_ID (N'dbo.SP_SELECT_S2_NEWS_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_S2_NEWS_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT * FROM S2_News

*/

CREATE PROCEDURE [dbo].[SP_SELECT_S2_NEWS_LIST]

    @START_DATE         AS VARCHAR(19)
,   @END_DATE           AS VARCHAR(19)
,   @SEARCH_TYPE_CODE   AS VARCHAR(1)
,   @SEARCH_VALUE       AS VARCHAR(100)


AS
BEGIN

    SELECT  ROW_NUMBER() OVER(ORDER BY SEQ ASC) AS ROW_NUM
        ,   *
        ,   ISNULL((SELECT TOP 1 CMMN_CODE FROM COMMON_CODE WHERE CLSS_CODE = '112' AND DTL_NAME = ''), '') AS CATEGORY_TYPE_CODE
        ,   CONVERT(VARCHAR(16), REG_DATE, 120) AS WRITE_DATE
    FROM    S2_NEWS

    WHERE   1 = 1
    AND     REG_DATE >= @START_DATE
    AND     REG_DATE <= DATEADD(DAY, 1, CAST(@END_DATE AS DATETIME))

    AND     (CASE WHEN @SEARCH_TYPE_CODE = '2' THEN TITLE ELSE '' END) LIKE (CASE WHEN @SEARCH_TYPE_CODE = '2' THEN '%' + @SEARCH_VALUE + '%' ELSE '' END)
    AND     (CASE WHEN @SEARCH_TYPE_CODE = '3' THEN CATEGORY ELSE '' END) LIKE (CASE WHEN @SEARCH_TYPE_CODE = '3' THEN '%' + @SEARCH_VALUE + '%' ELSE '' END)

    AND     (
                (CASE WHEN @SEARCH_TYPE_CODE = '1' THEN TITLE ELSE '' END) LIKE (CASE WHEN @SEARCH_TYPE_CODE = '1' THEN '%' + @SEARCH_VALUE + '%' ELSE '' END)
            OR  (CASE WHEN @SEARCH_TYPE_CODE = '1' THEN CATEGORY ELSE '' END) LIKE (CASE WHEN @SEARCH_TYPE_CODE = '1' THEN '%' + @SEARCH_VALUE + '%' ELSE '' END)
            )


    ORDER BY SEQ DESC
    --WHERE   SEQ = @SEQ

END

GO