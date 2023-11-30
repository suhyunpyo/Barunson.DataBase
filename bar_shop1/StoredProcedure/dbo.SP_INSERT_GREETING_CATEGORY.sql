IF OBJECT_ID (N'dbo.SP_INSERT_GREETING_CATEGORY', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_GREETING_CATEGORY
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DHLIM   
-- Description:	인사말 카테고리 입력
-- =============================================

CREATE PROCEDURE [dbo].[SP_INSERT_GREETING_CATEGORY]
    @CATEGORY_INDEX as int,
    @CATEGORY_NAME as varchar(500),
    @CATEGORY_COMMENT as varchar(1000),
    @DATE as datetime,
    @USER as varchar(50)
AS
BEGIN

    INSERT INTO CC_GREETING_CATEGORY(CATEGORY_INDEX
                                   , CATEGORY_NAME
                                   , CATEGORY_COMMENT
                                   , CREATE_DATE
                                   , CREATE_USER)
    VALUES (@CATEGORY_INDEX
          , @CATEGORY_NAME
          , @CATEGORY_COMMENT
          , @DATE
          , @USER)
    ;

END
GO
