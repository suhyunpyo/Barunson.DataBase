IF OBJECT_ID (N'dbo.up_insert_happy_price_main', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_happy_price_main
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2015-04-08
-- Description:	해피프라이스  등록
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_happy_price_main]
	-- Add the parameters for the stored procedure here
	@hp_title		nvarchar(200),
	@hp_sdate		nvarchar(10),
	@hp_edate		nvarchar(10),
	@result_code	int = 0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET ARITHABORT ON;
	
	declare @result	int
	
	BEGIN TRAN
	
	insert into S5_Happy_Price_Main (hp_title, hp_Sdate, hp_Edate) values (@hp_title, @hp_sdate, @hp_edate)
	set @result_code = SCOPE_IDENTITY()

	
	SET @result = @@Error		--에러발생 cnt
	IF (@result <> 0) 
		BEGIN
			ROLLBACK TRAN
		END
	ELSE
		BEGIN
			COMMIT TRAN
		END 

	RETURN @result_code
END
GO
