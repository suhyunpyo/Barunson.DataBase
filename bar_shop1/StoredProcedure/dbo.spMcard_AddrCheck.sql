IF OBJECT_ID (N'dbo.spMcard_AddrCheck', N'P') IS NOT NULL DROP PROCEDURE dbo.spMcard_AddrCheck
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spMcard_AddrCheck]
	@user_Addr 	NVARCHAR(50),
	@result nvarchar(50) output
AS

SET NOCOUNT ON 



--Addr ID Check

DECLARE @Result_Addr varchar(50) 
SET @Result_Addr = ''


		
SELECT @Result_Addr = @user_Addr + ISNULL( '_'+SUBSTRING( '0', 1, 2-LEN(CONVERT(INT, MAX(addrNo))+1)) --자리수 
											+ CONVERT(VARCHAR, CONVERT(INT, MAX(addrNo))+1)	--시리얼번호
										, '')
FROM(	


	SELECT addr, CASE WHEN LTRIM(RTRIM(addr)) = @user_Addr THEN '' ELSE RIGHT(RTRIM(addr), 2) END AS addrNo
	FROM S2_mCardOrder 
	WHERE company_seq NOT IN (5001, 5007)  
		AND LTRIM(RTRIM(addr)) LIKE @user_Addr+'%'
		AND LTRIM(RTRIM(addr)) != @Result_Addr
	UNION ALL
	SELECT addr, CASE WHEN LTRIM(RTRIM(addr)) = @user_Addr THEN '' ELSE RIGHT(RTRIM(addr), 2) END AS addrNo
	FROM S5_nmCardOrder 
	WHERE company_seq NOT IN (5001, 5007)
		AND LTRIM(RTRIM(addr)) LIKE @user_Addr+'%'
		AND LTRIM(RTRIM(addr)) != @Result_Addr

) A
WHERE LTRIM(RTRIM(addr)) = @user_Addr
	OR  ( LEN(LTRIM(RTRIM(@user_Addr)))+3 = LEN(addr) AND ISNUMERIC(RIGHT(RTRIM(addr), 2)) = 1 AND LTRIM(RTRIM(addr)) like @user_Addr+'[_]%')
	

SET @Result_Addr = RTRIM(LTRIM(@Result_Addr))



IF EXISTS (

	SELECT addr, CASE WHEN LTRIM(RTRIM(addr)) = @user_Addr THEN '' ELSE RIGHT(RTRIM(addr), 2) END AS addrNo
	FROM S2_mCardOrder 
	WHERE company_seq NOT IN (5001, 5007)  
		AND LTRIM(RTRIM(addr)) = @Result_Addr
	UNION ALL
	SELECT addr, CASE WHEN LTRIM(RTRIM(addr)) = @user_Addr THEN '' ELSE RIGHT(RTRIM(addr), 2) END AS addrNo
	FROM S5_nmCardOrder 
	WHERE company_seq NOT IN (5001, 5007)
		AND LTRIM(RTRIM(addr)) = @Result_Addr		
)
BEGIN 
	SET @Result_Addr = ''	
END 


SET @result = @Result_Addr


SELECT @result AS result

GO
