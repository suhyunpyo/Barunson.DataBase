IF OBJECT_ID (N'dbo.SplitTableStr', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.SplitTableStr', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.SplitTableStr', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.SplitTableStr', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.SplitTableStr', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.SplitTableStr
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[SplitTableStr]
(   
   @vcList VARCHAR(MAX),
   @vcDelimiter    VARCHAR(2)
)
RETURNS @Arrary TABLE (IndexNo int identity, Value varchar(500), PRIMARY KEY (IndexNo))

BEGIN
    DECLARE    @iPosStart    INT,
        @iPosEnd    int,
        @iLenDelim    tinyint,
        @iExit        tinyint,
        @vcStr        varchar(1000)

    SET @iPosStart = 1
    SET @iPosEnd = 1
    SET @iLenDelim = LEN(@vcDelimiter)

    SET @iExit = 0
    IF @vcList IS NOT NULL AND @vcList <> ''
    BEGIN
      -- 모든 항목을 검색할 때까지 루트 처리
      WHILE @iExit = 0
      BEGIN
         -- 구분문자를 기준으로 다음 항목의 위치 검색
         SET @iPosEnd = CHARINDEX(@vcDelimiter, @vcList, @iPosStart)

         IF @iPosEnd <= 0
         BEGIN
               SET @iPosEnd = LEN(@vcList) + 1
               SET @iExit = 1
         END

         -- 아래 @vcStr은 필요한 경우 LTRIM, RTRIM을 적용해야 한다.
         SET @vcStr = LTRIM(RTRIM(SUBSTRING(@vcList, @iPosStart, @iPosEnd - @iPosStart)))

         -- 테이블 변수에 저장
         IF @vcStr <> 'NULL'
            INSERT INTO @Arrary (Value) VALUES (@vcStr)
         ELSE
            INSERT INTO @Arrary (Value) VALUES (NULL)

         -- 다음 검색 위치로 이동
         SET @iPosStart = @iPosEnd + @iLenDelim
      END
    END
    ELSE
    BEGIN
       INSERT INTO @Arrary (Value) VALUES (NULL)
    END

    RETURN
END 

GO
