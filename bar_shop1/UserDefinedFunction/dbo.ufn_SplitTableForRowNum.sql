IF OBJECT_ID (N'dbo.ufn_SplitTableForRowNum', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.ufn_SplitTableForRowNum', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.ufn_SplitTableForRowNum', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.ufn_SplitTableForRowNum', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.ufn_SplitTableForRowNum', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.ufn_SplitTableForRowNum
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION  [dbo].[ufn_SplitTableForRowNum]
(
    @strValue varchar(4000) -- 분리할 문자열
    , @splitChar  varchar(1)  -- 구분할 문자
) RETURNS @tmpSplitTable TABLE ( value VARCHAR(4000), row_num INT )
AS  
Begin

    DECLARE @oPos INT, @nPos INT

    DECLARE @TmpVar VARCHAR(4000) -- 분리된 문자열 임시 저장변수

	DECLARE @ROW_NUM INT

 

    SET @oPos = 1 -- 구분문자 검색을 시작할 위치

    SET @nPos = 1 -- 구분문자 위치

	SET @ROW_NUM = 1

    WHILE (@nPos > 0)
    BEGIN

        SET @nPos = CHARINDEX(@splitChar, @strValue, @oPos)

 

        IF @nPos = 0

            SET @TmpVar = RIGHT(@strValue, LEN(@strValue)-@oPos+1)

        ELSE

            SET @TmpVar = ltrim(SUBSTRING(@strValue, @oPos, @nPos-@oPos))

 

        IF LEN(@TmpVar) > 0

            INSERT INTO @tmpSplitTable  VALUES( ltrim(@TmpVar), @ROW_NUM )

 

        SET @oPos = @nPos + 1

		SET @ROW_NUM = @ROW_NUM + 1
    END

 

    RETURN
END

GO
