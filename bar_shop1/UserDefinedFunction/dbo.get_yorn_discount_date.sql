IF OBJECT_ID (N'dbo.get_yorn_discount_date', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.get_yorn_discount_date', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.get_yorn_discount_date', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.get_yorn_discount_date', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.get_yorn_discount_date', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.get_yorn_discount_date
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
1. [get_yorn_discount_date]
삼성 에프터페이 일일 배치에서

에프터페이 신청일때는 신청날짜를 
에프터페이 취소일때는 취소날짜를 설정해줌

select dbo.get_yorn_discount_date('1')

*/
CREATE function [dbo].[get_yorn_discount_date] (  
 @str_seq nvarchar(10)   
) 
RETURNS varchar(20)   
AS 
BEGIN 

	DECLARE @discount_in_advance varchar(20)   

	select @discount_in_advance  = discount_in_advance from [bar_shop1].[dbo].[SAMSUNG_DAILY_DISCOUNT] where seq = @str_seq
	
	if @discount_in_advance ='N'
		select @discount_in_advance = left(convert(varchar(10),discount_in_advance_cancel_date,112) + replace(convert(varchar(10),discount_in_advance_cancel_date,24),':',''),12)
		from [bar_shop1].[dbo].[SAMSUNG_DAILY_DISCOUNT] where seq = @str_seq
	
	
	else
		select @discount_in_advance = left(convert(varchar(10),discount_in_advance_reg_date,112) + replace(convert(varchar(10),discount_in_advance_reg_date,24),':',''),12)
		from [bar_shop1].[dbo].[SAMSUNG_DAILY_DISCOUNT] where seq = @str_seq

	RETURN @discount_in_advance 

END 
GO
