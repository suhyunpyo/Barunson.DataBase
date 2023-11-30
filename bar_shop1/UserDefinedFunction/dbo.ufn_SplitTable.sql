IF OBJECT_ID (N'dbo.ufn_SplitTable', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.ufn_SplitTable', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.ufn_SplitTable', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.ufn_SplitTable', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.ufn_SplitTable', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.ufn_SplitTable
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION  [dbo].[ufn_SplitTable]
(
    @strValue varchar(MAX) -- 분리할 문자열
    , @splitChar  varchar(1)  -- 구분할 문자
) RETURNS @tmpSplitTable TABLE ( value VARCHAR(4000) )
AS  
Begin

    DECLARE @oPos INT, @nPos INT

    DECLARE @TmpVar VARCHAR(4000) -- 분리된 문자열 임시 저장변수

 

    SET @oPos = 1 -- 구분문자 검색을 시작할 위치

    SET @nPos = 1 -- 구분문자 위치


    WHILE (@nPos > 0)
    BEGIN

        SET @nPos = CHARINDEX(@splitChar, @strValue, @oPos)

 

        IF @nPos = 0

            SET @TmpVar = RIGHT(@strValue, LEN(@strValue)-@oPos+1)

        ELSE

            SET @TmpVar = SUBSTRING(@strValue, @oPos, @nPos-@oPos)

 

        IF LEN(@TmpVar) > 0

            INSERT INTO @tmpSplitTable  VALUES( @TmpVar )

 

        SET @oPos = @nPos + 1
    END

 

    RETURN
END

GO
