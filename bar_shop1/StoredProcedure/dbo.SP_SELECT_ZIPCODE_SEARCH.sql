IF OBJECT_ID (N'dbo.SP_SELECT_ZIPCODE_SEARCH', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_ZIPCODE_SEARCH
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_SELECT_ZIPCODE_SEARCH 0, '동패'
EXEC SP_SELECT_ZIPCODE_SEARCH 1, '한울'

*/

CREATE PROCEDURE [dbo].[SP_SELECT_ZIPCODE_SEARCH]
	    @ADDRESS_TYPE AS CHAR(1)
    ,   @SEARCH_VALUE AS VARCHAR(50)
AS

BEGIN



    DECLARE @STREET_NAME AS VARCHAR(50)
    DECLARE @BUILD_NO AS VARCHAR(10)

    SET @STREET_NAME = @SEARCH_VALUE
    SET @BUILD_NO = ''
    IF CHARINDEX(' ', @STREET_NAME) > 0
        BEGIN
            SET @BUILD_NO = ISNULL(SUBSTRING(@STREET_NAME, CHARINDEX(' ', @STREET_NAME) + 1, LEN(@STREET_NAME)), '')
            SET @STREET_NAME = SUBSTRING(@STREET_NAME, 0, CHARINDEX(' ', @STREET_NAME))
        END

    IF @ADDRESS_TYPE = '0' 
    BEGIN
        
        SELECT  ZIPCODE, SIDO, GUGUN, DONG, STREET_NAME, REPLACE(OLD_JUSO, SIDO + ' ' + GUGUN + ' ' + DONG, '') AS DETAIL
            --,   REPLACE(OLD_JUSO, SIDO + ' ' + GUGUN + ' ' + DONG, '') AS OLD_JUSO
            --,   NEW_JUSO
            ,   BUILD_NO, BUILD_SUB_NO
            ,   JIBUN_NO, JIBUN_SUB_NO
        FROM    (
            SELECT  ZIPCODE
                ,   ISNULL(SIDO, '') AS SIDO
                ,   ISNULL(GUGUN, '') AS GUGUN
                ,   ISNULL(DONG, '') AS DONG
                ,   '' AS STREET_NAME
                ,   ISNULL(DETAIL, '') AS DETAIL
                ,   ISNULL(JUSO, '') AS OLD_JUSO, '' AS NEW_JUSO
                ,   '' AS BUILD_NO, '' AS BUILD_SUB_NO
                ,   '' AS JIBUN_NO, '' AS JIBUN_SUB_NO
            FROM    ZIPCODE WITH ( NOLOCK )
            WHERE   1 = 1
            AND     (       DONG LIKE '%' + @SEARCH_VALUE + '%' 
                        --OR  DETAIL LIKE '%' + @SEARCH_VALUE + '%' 
                    )
        ) A

    END

    ELSE
    BEGIN
        
        SELECT  ZIPCODE, SIDO, GUGUN, DONG, STREET_NAME, DETAIL
            --,   SIDO + ' ' + GUGUN + ' ' + DONG + ' ' + JIBUN_NO + '-' + JIBUN_SUB_NO + CASE WHEN DETAIL <> '' THEN ' (' + DETAIL + ')' ELSE '' END AS OLD_JUSO
            --,   SIDO + ' ' + GUGUN + ' ' + STREET_NAME + ' ' + BUILD_NO + '-' + BUILD_SUB_NO + CASE WHEN DETAIL <> '' THEN ' (' + DETAIL + ')' ELSE '' END AS NEW_JUSO
            ,   BUILD_NO, BUILD_SUB_NO
            ,   JIBUN_NO, JIBUN_SUB_NO
        FROM    (

            SELECT  ZIPCODE
                ,   ISNULL(SIDO, '') AS SIDO
                ,   ISNULL(GUNGU, '') AS GUGUN
                ,   ISNULL(B_NAME, '') AS DONG
                ,   ISNULL(STREET_NAME, '') AS STREET_NAME
                ,   ISNULL(SIGUNGU_BUILD_NAME, '') AS DETAIL
                ,   ISNULL(CAST(BUILD_NO AS VARCHAR(6)), '') AS BUILD_NO, ISNULL(CAST(BUILD_SUB_NO AS VARCHAR(6)), '') AS BUILD_SUB_NO
                ,   ISNULL(CAST(JIBUN_NO AS VARCHAR(6)), '') AS JIBUN_NO, ISNULL(CAST(JIBUN_SUB_NO AS VARCHAR(6)), '') AS JIBUN_SUB_NO

            FROM    ZIPCODE_STREET WITH ( index=[IDX_search1], NOLOCK )
        
            WHERE   1 = 1
            AND     (       
                            STREET_NAME like @STREET_NAME + '%'
                        --OR  SIGUNGU_BUILD_NAME LIKE (@STREET_NAME + '%') 
                        --OR  B_NAME LIKE (@STREET_NAME + '%') 
                    )
            AND     BUILD_NO LIKE (@BUILD_NO + '%')
            
            --GROUP BY ZIPCODE, SIDO, GUNGU, STREET_NAME, SIGUNGU_BUILD_NAME, BUILD_NO, BUILD_SUB_NO
        ) A
        
        ORDER BY SIDO ASC, GUGUN ASC, STREET_NAME ASC, CAST(ISNULL(BUILD_NO, 0) AS INT) ASC, CAST(ISNULL(BUILD_SUB_NO, 0) AS INT) ASC, DETAIL ASC



    END

END
GO
