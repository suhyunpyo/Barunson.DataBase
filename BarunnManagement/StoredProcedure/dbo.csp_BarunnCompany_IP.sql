IF OBJECT_ID (N'dbo.csp_BarunnCompany_IP', N'P') IS NOT NULL DROP PROCEDURE dbo.csp_BarunnCompany_IP
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[csp_BarunnCompany_IP]
	@IP_No		nvarchar(15) = null,
    @UserName	nvarchar(50) = null,
    @Descr		nvarchar(200) = null
AS
BEGIN

	SELECT A.IP_Group
		, A.IP_NO
		, A.UserName
		, A.ActionDate
	FROM [dbo].[BarunnCompany_IP] A
	WHERE A.IP_Group = 'PA01'
	ORDER BY A.IP_ID

	select * from [BarunnCompany_IP]
	--IF ( @ID <> 999 )
	--BEGIN 
	--	SELECT ID, IP_No, UserName, Descr
	--	FROM BarunnIP 
	--	WHERE ID = @ID
	--	ORDER BY ID
	--END 
	--ELSE 
	--BEGIN
	--	SELECT ID, IP_No, UserName, Descr
	--	FROM BarunnIP 
	--	WHERE 1=1
	--	ORDER BY ID
	--END

	

		--, SUBSTRING( '000', 1, 3-LEN(SUBSTRING(IP_No,12,LEN(IP_No)))) + CONVERT (VARCHAR, SUBSTRING(IP_No,12,LEN(IP_No)))

		

END
GO
