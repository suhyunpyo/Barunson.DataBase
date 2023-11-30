IF OBJECT_ID (N'dbo.arr_split', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.arr_split', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.arr_split', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.arr_split', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.arr_split', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.arr_split
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[arr_split](
 @sText  VARCHAR(500),  -- 대상 문자열
 @str   CHAR(1) = '|',       -- 구분기호(Default '|')
 @idx  INT                       -- 배열 인덱스
 
)
RETURNS VARCHAR(20)
AS
BEGIN
 DECLARE @word    CHAR(20),    -- 반환할 문자
      @sTextData  VARCHAR(600), 
      @num    SMALLINT;
      
 SET @num = 1;
 SET @str = LTRIM(RTRIM(@str));
 SET @sTextData = LTRIM(RTRIM(@sText)) + @str; 
  
 WHILE @idx >= @num
 BEGIN
  IF CHARINDEX(@str, @sTextData) > 0
  BEGIN
   -- 문자열의 인덱스 위치의 요소를 반환
   SET @word = SUBSTRING(@sTextData, 1, CHARINDEX(@str, @sTextData) - 1);
   SET @word = LTRIM(RTRIM(@word));
 
   -- 반환된 문자는 버린후 좌우공백 제거   
   SET @sTextData = LTRIM(RTRIM(RIGHT(@sTextData, LEN(@sTextData) - (LEN(@word) + 1))))
  END ELSE BEGIN
   SET @word = NULL;
  END
  SET @num = @num + 1
 END
 RETURN(@word);
END
GO
