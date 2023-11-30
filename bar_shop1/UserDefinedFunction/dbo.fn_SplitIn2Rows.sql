IF OBJECT_ID (N'dbo.fn_SplitIn2Rows', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_SplitIn2Rows', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_SplitIn2Rows', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_SplitIn2Rows', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_SplitIn2Rows', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.fn_SplitIn2Rows
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_SplitIn2Rows]
    (
      @PInStrSource varchar(8000) = NULL, 
      @pInChrSeparator char(1) = ','
        )
        RETURNS 
                @ARRAY TABLE (ItemValue VARCHAR(1000))
AS
BEGIN
        DECLARE @CurrentStr varchar(2000)
        DECLARE @ItemStr varchar(200)
        
        SET @CurrentStr = @PInStrSource
         
        WHILE Datalength(@CurrentStr) > 0
        BEGIN
                IF CHARINDEX(@pInChrSeparator, @CurrentStr,1) > 0 
                        BEGIN
                        SET @ItemStr = SUBSTRING (@CurrentStr, 1, CHARINDEX(@pInChrSeparator, @CurrentStr,1) - 1)
                    SET @CurrentStr = SUBSTRING (@CurrentStr, CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1, (Datalength(@CurrentStr) - CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1))
                                INSERT @ARRAY (ItemValue) VALUES (@ItemStr)
                        END
                 ELSE
                        BEGIN                
                                INSERT @ARRAY (ItemValue) VALUES (@CurrentStr)                  
                        BREAK;
                 END 
        END
        RETURN
END
GO
