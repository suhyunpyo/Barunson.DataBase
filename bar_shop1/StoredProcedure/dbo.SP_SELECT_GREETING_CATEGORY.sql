IF OBJECT_ID (N'dbo.SP_SELECT_GREETING_CATEGORY', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_GREETING_CATEGORY
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		DHLIM   
-- Description:	인사말 카테고리 조회
-- =============================================

CREATE PROCEDURE [dbo].[SP_SELECT_GREETING_CATEGORY]
AS
BEGIN

    SELECT CATEGORY_INDEX
         , CATEGORY_NAME
         , CATEGORY_COMMENT
         , CREATE_DATE
         , CREATE_USER
         , UPDATE_DATE
         , UPDATE_USER
      FROM CC_GREETING_CATEGORY
     ORDER BY CATEGORY_INDEX
      ;

END
GO
