IF OBJECT_ID (N'dbo.up_select_zipcode_street_gungu_all', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_zipcode_street_gungu_all
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[up_select_zipcode_street_gungu_all] (
	-- Add the parameters for the stored procedure here
	@street_name nvarchar(50),
	@street_gu_name nvarchar(50)
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @arr_cnt int
	declare @arr_len int
	declare @dong_name nvarchar(20)
	declare @jibun	nvarchar(10)
	declare @address2  nvarchar(200)
	declare @array_cnt int
	
	set @array_cnt = LEN(@street_name) - LEN(REPLACE(@street_name, ' ', ''))


	set @arr_len = len(@street_name)

	if CHARINDEX(' ', @street_name) <> 0	
		begin
			set @jibun = right(@street_name, CHARINDEX(' ',reverse(@street_name))-1)
			set @arr_len =@arr_len- len(right(@street_name, CHARINDEX(' ',reverse(@street_name))-1))
			set @dong_name = SUBSTRING(@street_name, 0, @arr_len)
		end
	else
		begin
			set @jibun = ''
			set @arr_len = 0
			set @dong_name = @street_name
		end
	--set @street_name = SUBSTRING(@street_name, 0, @arr_len)

	set @address2 = ''


	if RIGHT(@dong_name,1) = '동'	--동으로 끝나면
		begin
			if  CHARINDEX('-', @jibun) <> 0	-- 지번정보가 있으면
				begin
					/*
					select @address2 = gungu +' '+ street_name + convert(varchar(10),build_no) from zipcode_street with(nolock)
					where b_name=@street_name and jibun_no=SUBSTRING(@jibun,0, CHARINDEX('-', @jibun)) 
					and jibun_sub_no=right(@jibun, CHARINDEX('-',reverse(@jibun))-1)	
					*/
					select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street with(nolock)
					where gungu=@street_gu_name and b_name=@dong_name and jibun_no=SUBSTRING(@jibun,0, CHARINDEX('-', @jibun)) 
					and jibun_sub_no=right(@jibun, CHARINDEX('-',reverse(@jibun))-1)
					order by sido, gungu, zipcode;	
				end
			else
				begin
					/*
					select  gungu, street_name, build_no, build_sub_no, sigungu_build_name, b_name, jibun_no from zipcode_street with(nolock)
					where b_name=@street_name and jibun_no=@jibun
					*/
					if ISNUMERIC(@jibun) = 1
					begin
						select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street with(nolock)
						where gungu=@street_gu_name and b_name=@dong_name and jibun_no=@jibun
						order by sido, gungu, zipcode;
					end
					
					else if @jibun = ''
						begin
							select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street with(nolock)
							where gungu=@street_gu_name and  b_name=@dong_name
							order by sido, gungu, zipcode;
						end
					else
						begin
							select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street with(nolock)
							where gungu=@street_gu_name and  b_name=@dong_name and sigungu_build_name like '%'+@jibun+'%'
							--where b_name=@dong_name and sigungu_build_name =@jibun
							order by sido, gungu, zipcode;
						end
						
				end
		end
		
	else if (ISNUMERIC(@street_name)=1 and LEN(@street_name) = 6)
		begin
			select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street with(nolock)
			where zipcode=@dong_name 
			order by zipcode,street_name, build_no, build_sub_no;
		end
	
	else	--도로명으로 끝나면
		begin
			if  CHARINDEX('-', @jibun) <> 0	-- 지번정보가 있으면
				begin
					select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street with(nolock)
					where  gungu=@street_gu_name and street_name like '%'+@dong_name+'%' and build_no=SUBSTRING(@jibun,0, CHARINDEX('-', @jibun)) 
					and build_sub_no=right(@jibun, CHARINDEX('-',reverse(@jibun))-1)
					order by sido, gungu, zipcode;	
				end
			else
				begin
					
					if ISNUMERIC(@jibun) = 1	--해당값이 숫자이면 건물번호, 아니면 건물명
						begin
							select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street with(nolock)
							where  gungu=@street_gu_name and street_name like '%'+@dong_name+'%' and build_no=@jibun
							order by sido, gungu, zipcode;
						end
					
					else if @jibun = ''
						begin
							select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street with(nolock)
							where  gungu=@street_gu_name and (street_name like '%'+@dong_name+'%') or (sigungu_build_name like '%'+@dong_name+'%')
							--where (street_name=@dong_name) or (sigungu_build_name = @dong_name)
							order by sido, gungu, zipcode;
						end
					else
						begin
							select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street with(nolock)
							where  gungu=@street_gu_name and (street_name like '%'+@dong_name+'%' and sigungu_build_name like '%'+@jibun+'%') or (sigungu_build_name like '%'+@dong_name+'%')
							--where (street_name=@dong_name and sigungu_build_name = @jibun) or (sigungu_build_name =@dong_name)
							order by sido, gungu, zipcode;
						end	
				end
		end

	--print @address2

END
GO
