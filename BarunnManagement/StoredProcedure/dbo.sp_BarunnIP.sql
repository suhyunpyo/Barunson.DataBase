IF OBJECT_ID (N'dbo.sp_BarunnIP', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_BarunnIP
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[sp_BarunnIP]
    @ID			int = null,
	@IP_No		nvarchar(15) = null,
    @UserName	nvarchar(50) = null,
    @Descr		nvarchar(200) = null
AS
BEGIN

	IF ( @ID <> 999 )
	BEGIN 
		SELECT ID, IP_No, UserName, Descr
		FROM BarunnIP 
		WHERE ID = @ID
		ORDER BY ID
	END 
	ELSE 
	BEGIN
		SELECT ID, IP_No, UserName, Descr
		FROM BarunnIP 
		WHERE 1=1
		ORDER BY ID
	END



		--, SUBSTRING( '000', 1, 3-LEN(SUBSTRING(IP_No,12,LEN(IP_No)))) + CONVERT (VARCHAR, SUBSTRING(IP_No,12,LEN(IP_No)))

		

END
GO
