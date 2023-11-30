IF OBJECT_ID (N'dbo.FN_SPLIT', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_SPLIT', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_SPLIT', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_SPLIT', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_SPLIT', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.FN_SPLIT
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[FN_SPLIT]

(

    @StrValue VARCHAR(MAX),   -- 분리할 문자열

    @SplitChar VARCHAR(1)         -- 구분할 문자

) 

RETURNS @SPLIT_TEMP TABLE  ( VALUE VARCHAR(50) )

AS 

BEGIN   

    DECLARE @oPos INT, @nPos INT

    DECLARE @TmpVar VARCHAR(1000) -- 분리된 문자열 임시 저장변수




    SET @oPos = 1 -- 구분문자 검색을 시작할 위치

    SET @nPos = 1 -- 구분문자 위치




    WHILE (@nPos > 0)

    BEGIN

        SET @nPos = CHARINDEX(@SplitChar, @StrValue, @oPos )




        IF @nPos = 0 

            SET @TmpVar = RIGHT(@StrValue, LEN(@StrValue)-@oPos+1 )

        ELSE

            SET @TmpVar = SUBSTRING(@StrValue, @oPos, @nPos-@oPos)




        IF LEN(@TmpVar)>0

            INSERT INTO @SPLIT_TEMP VALUES( @TmpVar )

        SET @oPos = @nPos +1 

    END

   RETURN 

END
GO
