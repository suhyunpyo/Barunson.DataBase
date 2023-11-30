IF OBJECT_ID (N'dbo.SP_PP_MAIN_EVT_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_PP_MAIN_EVT_LIST
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
CREATE PROCEDURE [dbo].[SP_PP_MAIN_EVT_LIST] 
	@V_MD_SEQ int,
	@V_SORTING_NUM int,
	@V_IMGFILE_PATH varchar(500),
	@V_CARD_TEXT varchar(500),
	@V_MD_CONTENT  varchar(1000),
	@V_LINK_URL varchar(200),
	@V_VIEW_DIV varchar(1),
	@V_JEHU_VIEW_DIV varchar(1),
	@V_LINK_TARGET varchar(50),
	@V_ADMIN_ID varchar(16),
	@V_SEQ int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE S4_MD_Choice SET 
		SORTING_NUM = @V_SORTING_NUM
	   ,IMGFILE_PATH= @V_IMGFILE_PATH
	   ,CARD_TEXT= @V_CARD_TEXT
	   ,MD_CONTENT = @V_MD_CONTENT
	   ,LINK_URL= @V_LINK_URL
	   ,VIEW_DIV= @V_VIEW_DIV
	   ,JEHU_VIEW_DIV= @V_JEHU_VIEW_DIV
	   ,LINK_TARGET= @V_LINK_TARGET
	   ,ADMIN_ID= @V_ADMIN_ID
	WHERE MD_SEQ = @V_MD_SEQ
	AND SEQ=@V_SEQ

END
GO
