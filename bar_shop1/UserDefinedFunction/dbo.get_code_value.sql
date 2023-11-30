IF OBJECT_ID (N'dbo.get_code_value', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.get_code_value', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.get_code_value', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.get_code_value', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.get_code_value', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.get_code_value
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[get_code_value](

@code_type char(20),
@code char(10)

)

RETURNS 
	nvarchar(20)
AS  
BEGIN 
 	
	DECLARE @code_value varchar (20)
	
	select @code_value = code_value from manage_code with(nolock)
	where code_type=@code_type and code=@code
	
	
	return @code_value
	
END

GO
