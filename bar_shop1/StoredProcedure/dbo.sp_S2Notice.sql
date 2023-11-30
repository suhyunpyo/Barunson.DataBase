IF OBJECT_ID (N'dbo.sp_S2Notice', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2Notice
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
--exec sp_S2Notice 'T'
CREATE Proc [dbo].[sp_S2Notice] 
	@Site char(1)
AS
	IF @site = 'T' 
		BEGIN
			SELECT * 
			FROM S2_Notice 
			ORDER BY Reg_Date DESC
		END
	ELSE
		BEGIN
			DECLARE @company_seq as int
			SELECT @company_seq = 	Case
										When @site = 'B' Then 5001
										When @site = 'W' Then 5002
										When @site = 'S' Then 5003
										When @site = 'H' Then 5004
										When @site = 'P' Then 5005
									End 
		
		
			SELECT * 
			FROM S2_Notice 
			WHERE company_seq = 5001
			ORDER BY Reg_Date DESC
		END
GO
