IF OBJECT_ID (N'dbo.fn_SplitIn4Rows', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_SplitIn4Rows', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_SplitIn4Rows', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_SplitIn4Rows', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_SplitIn4Rows', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.fn_SplitIn4Rows
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_SplitIn4Rows]
    (
      @PInStrSource varchar(4000) = NULL, 
      @PInStrSource2 varchar(4000) = NULL,
      @pInChrSeparator char(1) = ','
        )
        RETURNS 
                @ARRAY TABLE (ItemSEQ INT, ItemValue VARCHAR(1000), ItemValue2 VARCHAR(1000), brand_all varchar(10))
AS
BEGIN
        DECLARE @CurrentStr varchar(2000)
        DECLARE @CurrentStr2 varchar(2000)
        DECLARE @ItemStr varchar(200)
        DECLARE @ItemStr2 varchar(200)
        DECLARE @ItemINTS	int=0
        
        SET @CurrentStr = @PInStrSource
        SET @CurrentStr2 = @PInStrSource2
         
        WHILE Datalength(@CurrentStr) > 0
        BEGIN
			SET @ItemINTS = @ItemINTS + 1
                IF CHARINDEX(@pInChrSeparator, @CurrentStr,1) > 0 
                        BEGIN
                        SET @ItemStr = SUBSTRING (@CurrentStr, 1, CHARINDEX(@pInChrSeparator, @CurrentStr,1) - 1)
                        SET @ItemStr2 = SUBSTRING (@CurrentStr2, 1, CHARINDEX(@pInChrSeparator, @CurrentStr2,1) - 1)
                    SET @CurrentStr = SUBSTRING (@CurrentStr, CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1, (Datalength(@CurrentStr) - CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1))
                    SET @CurrentStr2 = SUBSTRING (@CurrentStr2, CHARINDEX(@pInChrSeparator, @CurrentStr2,1) + 1, (Datalength(@CurrentStr2) - CHARINDEX(@pInChrSeparator, @CurrentStr2,1) + 1))
                                INSERT @ARRAY (ItemSEQ, ItemValue,ItemValue2, brand_all) VALUES (@ItemINTS, @ItemStr, @ItemStr2, 'all')
                        END
                 ELSE
                        BEGIN                
                                INSERT @ARRAY (ItemSEQ, ItemValue,ItemValue2, brand_all) VALUES (@ItemINTS, @CurrentStr, @CurrentStr2, 'all')
                                --INSERT @ARRAY (ItemValue,ItemValue2) VALUES (@CurrentStr, @CurrentStr2)
                        BREAK;
                 END 
        END
        RETURN
END
GO
