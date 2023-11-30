IF OBJECT_ID (N'dbo.SP_TEST3', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_TEST3
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	create PROCEDURE [dbo].[SP_TEST3] --@gubun = 1
	@code varchar(20) 
AS
	
	update LT_DELCODE
	set IMG_YN = 'Y'
	where code = @code

	-- select DESTINATION_CODE from LT_ZIPCODE group by DESTINATION_CODE
GO
