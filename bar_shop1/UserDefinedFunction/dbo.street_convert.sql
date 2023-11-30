IF OBJECT_ID (N'dbo.street_convert', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.street_convert', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.street_convert', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.street_convert', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.street_convert', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.street_convert
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[street_convert](
	@address nvarchar(200)
)

returns nvarchar(200)
 

begin 

declare @arr_cnt int
declare @arr_len int
declare @street_name nvarchar(200)
declare @dong_name nvarchar(20)
declare @jibun	nvarchar(10)
declare @address2 nvarchar(200)
declare @table_name nvarchar(20)
declare @sido_name nvarchar(20)
declare @sql nvarchar(2000)
set @address2 = ''



set @street_name = replace(@address, ',', '')

if len(@street_name) < 16
	begin
		return @address2
	end
else 
	begin
	set @sido_name = SUBSTRING(@street_name, 1, 2)
	
	if CHARINDEX(' ',@street_name) > 0 and  @sido_name='경기'  
	
	
	
	
		begin
			set @arr_len = len(@street_name)

			set @jibun = right(@street_name, CHARINDEX(' ',reverse(@street_name))-1)
			set @arr_len = @arr_len - len(right(@street_name, CHARINDEX(' ',reverse(@street_name))-1))
			set @street_name = SUBSTRING(@street_name, 0, @arr_len)
			set @dong_name = right(@street_name, CHARINDEX(' ',reverse(@street_name))-1)

				--set XACT_ABORT ON
				if  CHARINDEX('-',convert(varchar(10),@jibun)) <> 0
					begin 
						if  isnumeric(SUBSTRING(@jibun,0, CHARINDEX('-', @jibun))) = 1 and  isnumeric(right(@jibun, CHARINDEX('-',reverse(@jibun))-1)) = 1 
						begin 
							
							select top 1 @address2 = (gungu + ' ' + street_name  + ' ' +  convert(varchar(10),build_no)  + '-' + convert(varchar(10),build_sub_no)) from zipcode_street with(nolock)
							where SUBSTRING(sido, 1, 2)=@sido_name and  b_name=@dong_name and jibun_no=SUBSTRING(@jibun,0, CHARINDEX('-', @jibun)) 
							and jibun_sub_no=convert(varchar(10),right(@jibun, CHARINDEX('-',reverse(@jibun))-1))	
							
							/*
							set @sql = 'select top 1 (gungu + '' '' + street_name  + '' '' +  convert(varchar(10),build_no)  + ''-'' + convert(varchar(10),build_sub_no)) from '+@table_name+' with(nolock)'
							set @sql = @sql + ' where b_name='+@dong_name+' and jibun_no=SUBSTRING('+@jibun+',0, CHARINDEX(''-'', '+@jibun+')) '
							set @sql = @sql + 'and jibun_sub_no=convert(varchar(10),right('+@jibun+', CHARINDEX(''-'',reverse('+@jibun+'))-1))	'
							set @address2 = @sql
							*/
						end 
					end 
				else
					begin 
						if isnumeric(@jibun) = 1
							begin 
								select top 1  @address2 = (gungu + ' ' + street_name  + ' ' +  convert(varchar(10),build_no)  + '-' + convert(varchar(10),build_sub_no)) from zipcode_street with(nolock)
								where SUBSTRING(sido, 1, 2)=@sido_name and  b_name=@dong_name and jibun_no=convert(varchar(10),@jibun )
							end 
					end 
		end
	end
 
return @address2
end


GO
