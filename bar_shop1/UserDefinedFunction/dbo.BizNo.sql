IF OBJECT_ID (N'dbo.BizNo', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.BizNo', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.BizNo', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.BizNo', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.BizNo', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.BizNo
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[BizNo](@number char(10))

returns char(1)

 

begin 

DECLARE @returnValue as char(1), @value int

select @returnValue='0'

select @value=0

select @value=@value+substring(@number,1,1)*1

select @value=@value+substring(@number,2,1)*3

select @value=@value+substring(@number,3,1)*7

select @value=@value+substring(@number,4,1)*1

select @value=@value+substring(@number,5,1)*3

select @value=@value+substring(@number,6,1)*7

select @value=@value+substring(@number,7,1)*1

select @value=@value+substring(@number,8,1)*3

select @value=@value+round((substring(@number,9,1)*5.5+0.5),0)-1

select @value=10-(@value%10)

 

if convert(char(1),@value)=substring(@number,10,1) and len(@number)=10

select @returnValue='1'

return @returnValue

end

GO
