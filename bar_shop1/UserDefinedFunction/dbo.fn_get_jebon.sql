IF OBJECT_ID (N'dbo.fn_get_jebon', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_get_jebon', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_get_jebon', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_get_jebon', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_get_jebon', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.fn_get_jebon
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
SELECT [dbo].[fn_get_jebon](2650134)
*/
CREATE FUNCTION [dbo].[fn_get_jebon]
(
	@order_seq int
)
RETURNS VARCHAR(100)
AS 
BEGIN 
	DECLARE @result varchar(100) = ''

	DECLARE @isInpaper int -- 내지제본
	DECLARE @isHandmade int -- 부속품제본
	DECLARE @isEnvInsert int --  봉투삽입
	DECLARE @isEnvSpecial int -- 스페셜봉투
	DECLARE @isPerfume int -- 향기서비스

	SELECT @isInpaper=isInpaper, @isHandmade=isHandmade, @isEnvInsert=isEnvInsert, @isEnvSpecial=isEnvSpecial, @isPerfume=isPerfume from custom_order where order_seq = @order_seq

	IF @isInpaper > 0
		SET @result = @result + '/내지제본'
	IF @isHandmade > 0
		SET @result = @result + '/부속품제본'
	IF @isEnvInsert > 0
		SET @result = @result + '/봉투삽입'
	/*
	IF @isEnvSpecial > 0
		SET @result = @result + '/스페셜봉투'
	*/
	IF @isPerfume > 0
		SET @result = @result + '/향기서비스'
	

	SET @result = SUBSTRING(@result,2,LEN(@result))

	RETURN @result
	
END

GO
