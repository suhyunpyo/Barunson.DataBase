IF OBJECT_ID (N'dbo.SP_SELECT_COMMON_CODE_FOR_CLSS_CODE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_COMMON_CODE_FOR_CLSS_CODE
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

-- EXEC [SP_SELECT_CARD_INFO_LIST]

CREATE PROCEDURE [dbo].[SP_SELECT_COMMON_CODE_FOR_CLSS_CODE]
    @CLSS_CODE          AS VARCHAR(3)
AS
BEGIN

    SELECT  ROW_NUMBER() OVER(ORDER BY SORT_NUM ASC) AS ROW_NUM, CMMN_CODE, DTL_NAME
    FROM    COMMON_CODE
    WHERE   CLSS_CODE = @CLSS_CODE
    ORDER BY SORT_NUM ASC

END
GO