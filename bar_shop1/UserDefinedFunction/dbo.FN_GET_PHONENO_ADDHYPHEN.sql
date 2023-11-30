IF OBJECT_ID (N'dbo.FN_GET_PHONENO_ADDHYPHEN', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_PHONENO_ADDHYPHEN', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_PHONENO_ADDHYPHEN', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_PHONENO_ADDHYPHEN', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_GET_PHONENO_ADDHYPHEN', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.FN_GET_PHONENO_ADDHYPHEN
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FN_GET_PHONENO_ADDHYPHEN]
(
	@PhoneNo varchar(20)
)
RETURNS varchar(20)
AS
BEGIN
	Declare @result varchar(20)
	Set @result = @PhoneNo

	IF Len(@PhoneNo) = 9
	 BEGIN
		Set @result = CONCAT(left(@PhoneNo,2), '-', substring(@PhoneNo, 3,3), '-', RIGHT(@PhoneNo,4))
	 END
	Else IF Len(@PhoneNo) = 10
	 BEGIN
		IF left(@PhoneNo,2) = '02' 
		 Begin
			Set @result = CONCAT(left(@PhoneNo,2), '-', substring(@PhoneNo, 3,4), '-', RIGHT(@PhoneNo,4))
		 End
		Else
		 Begin
			Set @result = CONCAT(left(@PhoneNo,3), '-', substring(@PhoneNo, 4,3), '-', RIGHT(@PhoneNo,4))
		 End
	 END
	Else IF Len(@PhoneNo) = 11
	 BEGIN
		Set @result = CONCAT(left(@PhoneNo,3), '-', substring(@PhoneNo, 4,4), '-', RIGHT(@PhoneNo,4))
	 END
	Else IF Len(@PhoneNo) = 12
	 BEGIN
		Set @result = CONCAT(left(@PhoneNo,4), '-', substring(@PhoneNo, 5,4), '-', RIGHT(@PhoneNo,4))
	 END

	RETURN @result

END
GO
