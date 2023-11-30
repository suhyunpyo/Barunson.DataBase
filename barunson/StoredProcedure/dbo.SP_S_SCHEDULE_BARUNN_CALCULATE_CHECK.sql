IF OBJECT_ID (N'dbo.SP_S_SCHEDULE_BARUNN_CALCULATE_CHECK', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_SCHEDULE_BARUNN_CALCULATE_CHECK
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
CREATE PROCEDURE [dbo].[SP_S_SCHEDULE_BARUNN_CALCULATE_CHECK]
	@RemitId int
AS
BEGIN
	SET NOCOUNT ON;

	select top 1 
		Calculate_ID,
		Remit_ID,
		Unique_Number,
		Request_Date,
		Status_Code,
		Error_Code
	from TB_Calculate
	where Remit_ID = @RemitId
	order by Calculate_ID desc


END
GO
