IF OBJECT_ID (N'dbo.GetRegExReplace', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.GetRegExReplace', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.GetRegExReplace', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.GetRegExReplace', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.GetRegExReplace', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.GetRegExReplace
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetRegExReplace] ( 
@TargetText VarChar(MAX), -- 원본 문자열 값 
@Expression VarChar(80),-- 정규 식 형태 문자열 
@ReplaceValue VarChar(80) -- 교체할 문자 
) 
RETURNS VARCHAR(MAX) AS BEGIN DECLARE @ReturnValue VARCHAR(MAX) = @TargetText; IF ISNULL(@ReturnValue,'') = '' 
RETURN @ReturnValue;

WHILE 1 =1 BEGIN IF PATINDEX('%' + @Expression + '%' , @ReturnValue) = 0 BREAK; 
SET @ReturnValue = STUFF(@ReturnValue,PATINDEX('%' + @Expression + '%' , @ReturnValue),1,@ReplaceValue) END 

RETURN @ReturnValue END 

GO
