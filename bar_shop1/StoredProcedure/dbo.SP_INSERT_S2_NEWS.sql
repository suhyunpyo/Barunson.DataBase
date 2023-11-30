IF OBJECT_ID (N'dbo.SP_INSERT_S2_NEWS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_S2_NEWS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT * FROM S2_News

*/

CREATE PROCEDURE [dbo].[SP_INSERT_S2_NEWS]
    @CATEGORY_TYPE_CODE         AS VARCHAR(6)
,   @COMPANY_SEQ                AS INT
,   @TITLE                      AS NVARCHAR(200)
,   @MEDIUM_NAME                AS NVARCHAR(200)
,   @URL_TARGET                 AS NVARCHAR(200)
,   @URL_TARGET_BLANK_YORN      AS CHAR(1)
,   @DP_YORN                    AS CHAR(1)
,   @CONTENTS                   AS NVARCHAR(4000)
,   @SEQ                        AS INT
AS
BEGIN



    IF @SEQ = 0 
        BEGIN

            INSERT INTO S2_NEWS   
            (
                    CATEGORY     
                ,   COMPANY_SEQ      
                ,   TITLE              
                ,   MEDIUM_NAME     
                ,   URL_TAGET
                ,   URL_TARGET_BLANK_YORN
                ,   ISDP                   
                ,   CONTENTS
                ,   REG_DATE
            )                                   
                                    
            VALUES  
            (
                    ISNULL((SELECT TOP 1 DTL_NAME FROM COMMON_CODE WHERE CMMN_CODE = @CATEGORY_TYPE_CODE), '기타')
                ,   @COMPANY_SEQ       
                ,   @TITLE             
                ,   @MEDIUM_NAME       
                ,   @URL_TARGET   
                ,   @URL_TARGET_BLANK_YORN     
                ,   @DP_YORN           
                ,   @CONTENTS
                ,   GETDATE()
            )

        END

    ELSE
        BEGIN
    
            UPDATE  S2_NEWS
            SET     CATEGORY = ISNULL((SELECT TOP 1 DTL_NAME FROM COMMON_CODE WHERE CMMN_CODE = @CATEGORY_TYPE_CODE), '기타')
                ,   TITLE = @TITLE
                --,   MEDIUM_NAME = @MEDIUM_NAME
                ,   URL_TAGET = @URL_TARGET
                ,   URL_TARGET_BLANK_YORN = @URL_TARGET_BLANK_YORN
                ,   ISDP = @DP_YORN
                ,   CONTENTS = @CONTENTS
            WHERE   SEQ = @SEQ

        END



END

GO
