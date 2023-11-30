IF OBJECT_ID (N'dbo.fn_SplitIn5Rows', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_SplitIn5Rows', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_SplitIn5Rows', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_SplitIn5Rows', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_SplitIn5Rows', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.fn_SplitIn5Rows
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_SplitIn5Rows]
    (
      @PInStrSource varchar(4000) = NULL, 
      @PInStrSource2 varchar(4000) = NULL,
      @pInChrSeparator char(1) = ',',
	  @company_seq	int
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
		DECLARE @row	int=0
        
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
					set @row=0
								select @row = count(B.card_seq) from S2_CardSalesSite AS B
								join s2_cardkind AS I on B.card_seq = I.Card_Seq
								join s2_cardkindinfo AS j on I.CardKind_Seq = j.CardKind_Seq
								and J.CardKind_Seq=1
								and B.card_seq=@ItemStr and IsDisplay=1 and Company_Seq=@company_seq

								
								if @row > 0
								begin
									INSERT @ARRAY (ItemSEQ, ItemValue,ItemValue2, brand_all) VALUES (@ItemINTS, @ItemStr, @ItemStr2, 'all')
								end
                        END
                 ELSE
                        BEGIN                
                                INSERT @ARRAY (ItemSEQ, ItemValue,ItemValue2, brand_all) VALUES (@ItemINTS, @ItemStr, @ItemStr2, 'all')
                        BREAK;
                 END 
        END
        RETURN
END
GO
