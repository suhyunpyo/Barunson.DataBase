IF OBJECT_ID (N'dbo.FN_YYYYMMDD', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_YYYYMMDD', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_YYYYMMDD', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_YYYYMMDD', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_YYYYMMDD', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.FN_YYYYMMDD
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************
-- SP Name       : FN_YYYYMMDD
-- Author        : 변미정
-- Create date   : 2023-03-02
-- Description   : 날짜 반환 함수 (YYYY-MM-DD)
-- Update History:
-- Comment       : 
*******************************************************/
CREATE FUNCTION [dbo].[FN_YYYYMMDD]
(
    @StartDate    DATETIME,   -- 시작일
    @EndDate      DATETIME    -- 종료일
) 

RETURNS @Tb TABLE  ( VALUE VARCHAR(10) )
AS 

BEGIN

    WHILE (@StartDate <= @EndDate) BEGIN       

        INSERT INTO @Tb VALUES( CONVERT(VARCHAR(10),@StartDate,121) )
        SET @StartDate = DATEADD(DAY,1,@StartDate) 
    END

   RETURN 

END
GO
