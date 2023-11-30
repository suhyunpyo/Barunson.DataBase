IF OBJECT_ID (N'dbo.SP_S_SCHEDULE_STANDARD_DATE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_SCHEDULE_STANDARD_DATE
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
CREATE PROCEDURE [dbo].[SP_S_SCHEDULE_STANDARD_DATE]
	@Date VARCHAR(8) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	Declare @Cnt int;

	Declare @Month VARCHAR(6);
	Declare @Year VARCHAR(4);

	SET @Cnt = 0;

	SET @Date = ISNULL(@Date, CONVERT(VARCHAR(10), GETDATE(), 112))
	SET @Month = LEFT(@Date, 6)
	SET @Year = LEFT(@Date, 4)

	SELECT @Cnt = COUNT(1) FROM TB_Standard_Date WHERE Standard_Date = @Date

	IF @Cnt = 0 BEGIN
		INSERT INTO TB_Standard_Date (Standard_Date, Standard_Month, Standard_Year) VALUES (@Date, @Month, @Year)
	END 

END
GO
