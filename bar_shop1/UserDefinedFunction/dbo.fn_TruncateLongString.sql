IF OBJECT_ID (N'dbo.fn_TruncateLongString', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_TruncateLongString', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_TruncateLongString', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_TruncateLongString', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_TruncateLongString', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.fn_TruncateLongString
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION  [dbo].[fn_TruncateLongString]
(  
        @iValue         VARCHAR(MAX)       -- Seq값   
    ,   @iLength        INT                -- 제한길이수  
    ,   @iTail          VARCHAR(10)     = '...'    
)   RETURNS VARCHAR(MAX)
AS   
BEGIN 
 
    -- 사용 예제
    /*
        SELECT dbo.fn_TruncateLongString('가나다라마바사 아자차카타파하', 6, '...') --> '가나다라마바...'
    */
  
    -- 사용할 변수 선언  
    ----------------------------------------------------------------------------------------------------      
    DECLARE     @wReturn        VARCHAR(MAX)    -- Return 변수  
            ,   @wSize          INT             -- Seq 크기  
  
    -- 변수 Default값 셋팅  
    ----------------------------------------------------------------------------------------------------      
    SELECT  @wSize = LEN(@iValue)  
      
    IF @wSize > @iLength      
        BEGIN  
            SELECT  @wReturn = SUBSTRING(@iValue, 1, @iLength) + @iTail  
        END  
    ELSE  
        BEGIN  
            SELECT  @wReturn = @iValue  
        END  
  
    RETURN  @wReturn  
      
END  
GO
