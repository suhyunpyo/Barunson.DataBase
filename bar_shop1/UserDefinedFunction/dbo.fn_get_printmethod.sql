IF OBJECT_ID (N'dbo.fn_get_printmethod', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_get_printmethod', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_get_printmethod', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_get_printmethod', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_get_printmethod', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.fn_get_printmethod
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
SELECT [dbo].[fn_get_printmethod]('001')
SELECT [dbo].[fn_get_printmethod]('000')
SELECT [dbo].[fn_get_printmethod]('G11')
*/
CREATE FUNCTION [dbo].[fn_get_printmethod](
	@printmethod CHAR(3)
)

RETURNS VARCHAR(100)
 
AS 
BEGIN 
	DECLARE @printmethodname VARCHAR(100)
	DECLARE @p1 CHAR(1) = SUBSTRING(@printmethod, 1, 1)
	DECLARE @p2 CHAR(1) = SUBSTRING(@printmethod, 2, 1)
	DECLARE @p3 CHAR(1) = SUBSTRING(@printmethod, 3, 1)
	DECLARE @c1 VARCHAR(10) = ''
	DECLARE @c2 VARCHAR(10) = ''
	DECLARE @c3 VARCHAR(10) = ''

	IF(@p1 <> '0')
	BEGIN
		--박 정보 세팅
		SELECT @c1 = ISNULL(code_value,'') + ' ' FROM manage_code WHERE code_type = 'print_mount' AND code = @p1
	
		--광 정보 세팅
		IF(@p2 = '1')
		BEGIN
			SET @c2 = '유광 '
		END
		ELSE
		BEGIN
			SET @c2 = '무광 '
		END
	END
	--형 정보 세팅
	IF(@p3 = '1')
	BEGIN
		SET @c3 = '형압'
	END
	ELSE
	BEGIN
		SET @c3 = ''
	END

	SET @printmethodname = @c1 + @c2 + @c3

	RETURN @printmethodname
END
GO
