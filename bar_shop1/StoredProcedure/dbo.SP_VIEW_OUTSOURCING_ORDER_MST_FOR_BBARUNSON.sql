IF OBJECT_ID (N'dbo.SP_VIEW_OUTSOURCING_ORDER_MST_FOR_BBARUNSON', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_VIEW_OUTSOURCING_ORDER_MST_FOR_BBARUNSON
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
CREATE PROCEDURE [dbo].[SP_VIEW_OUTSOURCING_ORDER_MST_FOR_BBARUNSON]
	-- Add the parameters for the stored procedure here
	@CARD_CODE VARCHAR(50)
AS
BEGIN
	select top 1 CHILDITEMSPEC, PAPER_COMPOSITION, PAPER_NAME 
	from [erpdb.bhandscard.com].[XERP].dbo.VW_CARD_PRINT_INFO_WITH_WEPOD where CARD_CODE like '%' +@CARD_CODE + '%'
END
GO
