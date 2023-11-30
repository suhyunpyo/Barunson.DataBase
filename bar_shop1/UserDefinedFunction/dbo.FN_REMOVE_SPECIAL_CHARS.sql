IF OBJECT_ID (N'dbo.FN_REMOVE_SPECIAL_CHARS', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_REMOVE_SPECIAL_CHARS', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_REMOVE_SPECIAL_CHARS', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_REMOVE_SPECIAL_CHARS', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_REMOVE_SPECIAL_CHARS', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.FN_REMOVE_SPECIAL_CHARS
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--특수문자 제거 함수 
CREATE FUNCTION [dbo].[FN_REMOVE_SPECIAL_CHARS] (
   @S VARCHAR(256))

 RETURNS VARCHAR(256)

 

 BEGIN

   IF @S IS NULL

      RETURN NULL

     

   DECLARE @S2 VARCHAR(256)

   DECLARE @L INT

   DECLARE @P INT

  

   SET @S2 = ''

   SET @L = LEN(@S)

   SET @P = 1

  

   WHILE @P <= @L

   BEGIN

      DECLARE @C INT

      SET @C = ASCII(SUBSTRING(@S, @P, 1))

      IF @C BETWEEN 48 AND 57

      OR @C BETWEEN 65 AND 90

      OR @C BETWEEN 97 AND 122

         SET @S2 = @S2 + CHAR(@C)

      SET @P = @P + 1

   END

   IF LEN(@S2) = 0

      RETURN NULL

   RETURN @S2

 END

 
GO
