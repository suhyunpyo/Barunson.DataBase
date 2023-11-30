IF OBJECT_ID (N'dbo.SP_UPDATE_GREETING_CATEGORY', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_UPDATE_GREETING_CATEGORY
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DHLIM   
-- Description:	인사말 카테고리 수정
-- =============================================

CREATE PROCEDURE [dbo].[SP_UPDATE_GREETING_CATEGORY]
    @CATEGORY_INDEX as int,
    @CATEGORY_NAME as varchar(500),
    @CATEGORY_COMMENT as varchar(1000),
    @DATE as datetime,
    @USER as varchar(50)
AS
BEGIN

    UPDATE CC_GREETING_CATEGORY SET CATEGORY_NAME = @CATEGORY_NAME
                                  , CATEGORY_COMMENT = @CATEGORY_COMMENT
                                  , UPDATE_DATE = @DATE
                                  , UPDATE_USER = @USER
     WHERE CATEGORY_INDEX = @CATEGORY_INDEX
    ;

END
GO
