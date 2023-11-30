IF OBJECT_ID (N'dbo.up_select_zipcode_street_all', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_zipcode_street_all
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		daniel,kim
-- Create date: 2014-03-05
-- Description:	신도로 우편번호 검색색
-- =============================================
CREATE PROCEDURE [dbo].[up_select_zipcode_street_all] (
	-- Add the parameters for the stored procedure here
	@street_name nvarchar(50),
	@street_gu_name nvarchar(50),
	@search_convert	nvarchar(1)
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @arr_cnt int
	DECLARE @arr_len int
	DECLARE @dong_name nvarchar(20)
	DECLARE @jibun	nvarchar(10)
	DECLARE @address2  nvarchar(200)
	DECLARE @dong_name2 nvarchar(20)
	DECLARE @ROW INT
	DECLARE @TEMP NVARCHAR(50)



	set @arr_len = len(@street_name)
	SET @ROW = 0
	SET @TEMP = ''

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
		
		WHILE @ROW<=LEN(@dong_name)
		BEGIN
		 
			 -- 한글자씩 아스키 코드 비교해서 숫자 영역인지 체크
			 IF NOT ((ASCII(SUBSTRING(@dong_name,@ROW,1)) >= 48) AND (ASCII(SUBSTRING(@dong_name,@ROW,1)) <= 57))
			  SET @TEMP = @TEMP + SUBSTRING(@dong_name,@ROW,1)  -- 숫자가 아니라면 @TEMP 변수에 누적 저장.
		 
			 SET @ROW = @ROW+1
		END
		
		set @dong_name2 = @TEMP
		
			if  CHARINDEX('-', @jibun) <> 0	-- 지번정보가 있으면
				begin
					/*
					select @address2 = gungu +' '+ street_name + convert(varchar(10),build_no) from zipcode_street with(nolock)
					where b_name=@street_name and jibun_no=SUBSTRING(@jibun,0, CHARINDEX('-', @jibun)) 
					and jibun_sub_no=right(@jibun, CHARINDEX('-',reverse(@jibun))-1)	
					*/
					if @search_convert ='1'
					begin
						select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
						where (b_name=@dong_name or b_name=@dong_name2) and jibun_no=SUBSTRING(@jibun,0, CHARINDEX('-', @jibun)) 
						and jibun_sub_no=right(@jibun, CHARINDEX('-',reverse(@jibun))-1)
						order by sido, gungu, zipcode, b_name, jibun_no asc;	
					end
					else
					begin
						select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
						where (b_name=@dong_name or b_name=@dong_name2) and jibun_no=SUBSTRING(@jibun,0, CHARINDEX('-', @jibun)) 
						and jibun_sub_no=right(@jibun, CHARINDEX('-',reverse(@jibun))-1)
						order by sido, gungu,street_name, build_no, build_sub_no asc;	
					end
				end
			else
				begin
					/*
					select  gungu, street_name, build_no, build_sub_no, sigungu_build_name, b_name, jibun_no from zipcode_street with(nolock)
					where b_name=@street_name and jibun_no=@jibun
					*/
					if @search_convert ='1'
						begin
							if ISNUMERIC(@jibun) = 1
								begin
									select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
									where (b_name=@dong_name or b_name=@dong_name2) and jibun_no=@jibun
									order by sido, gungu, zipcode, b_name, jibun_no asc;
								end
								
								else if @jibun = ''
									begin
										select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
										where (b_name=@dong_name or b_name=@dong_name2)
										order by sido, gungu, zipcode, b_name, jibun_no asc;
									end
								else
									begin
										select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
										where (b_name=@dong_name or b_name=@dong_name2) and sigungu_build_name like '%'+@jibun+'%'
										--where b_name=@dong_name and sigungu_build_name =@jibun
										order by sido, gungu, zipcode, b_name, jibun_no asc;
									end
						end
						
					else
						begin
							if ISNUMERIC(@jibun) = 1
								begin
									select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
									where (b_name=@dong_name or b_name=@dong_name2) and jibun_no=@jibun
									order by sido, gungu,street_name, build_no, build_sub_no;
								end
								
								else if @jibun = ''
									begin
										select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
										where (b_name=@dong_name or b_name=@dong_name2)
										order by sido, gungu,street_name, build_no, build_sub_no asc;
									end
								else
									begin
										select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
										where (b_name=@dong_name or b_name=@dong_name2) and sigungu_build_name like '%'+@jibun+'%'
										--where b_name=@dong_name and sigungu_build_name =@jibun
										order by sido, gungu,street_name, build_no, build_sub_no asc;
									end
						end
					
					
						
				end
		end
	
	else if (ISNUMERIC(@street_name)=1 and LEN(@street_name) = 6)
		begin
			if @search_convert ='1'
			begin
				select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
				where zipcode=@dong_name 
				order by sido, gungu, zipcode, b_name, jibun_no asc;
			end
			else
			begin
				select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
				where zipcode=@dong_name 
				order by sido, gungu,street_name, build_no, build_sub_no asc;
			end
		end 
	
	else	--도로명으로 끝나면
		begin
			if @search_convert ='1'
				begin
				
					if  CHARINDEX('-', @jibun) <> 0	-- 지번정보가 있으면
						begin
							select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
							where street_name=@dong_name and build_no=SUBSTRING(@jibun,0, CHARINDEX('-', @jibun)) 
							and build_sub_no=right(@jibun, CHARINDEX('-',reverse(@jibun))-1)
							order by sido, gungu, zipcode, b_name, jibun_no asc;
						end
					else
						begin
							
							if ISNUMERIC(@jibun) = 1	--해당값이 숫자이면 건물번호, 아니면 건물명
								begin
									select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
									where street_name=@dong_name and build_no=@jibun
									order by sido, gungu, zipcode, b_name, jibun_no asc;
								end
							
							else if @jibun = ''
								begin
									select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
									where (street_name like ''+@dong_name+'%' or b_name=@dong_name) or (sigungu_build_name like '%'+@dong_name+'%')
									--where (street_name=@dong_name) or (sigungu_build_name = @dong_name)
									order by sido, gungu, zipcode, b_name, jibun_no asc;
								end
							else
								begin
									select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
									where (street_name=@dong_name and sigungu_build_name like '%'+@jibun+'%') or (sigungu_build_name like '%'+@dong_name+'%')
									--where (street_name=@dong_name and sigungu_build_name = @jibun) or (sigungu_build_name =@dong_name)
									order by sido, gungu, zipcode, b_name, jibun_no asc;
								end	
						end
				
				end
			
			else
				begin
					if  CHARINDEX('-', @jibun) <> 0	-- 지번정보가 있으면
						begin
							select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
							where street_name=@dong_name and build_no=SUBSTRING(@jibun,0, CHARINDEX('-', @jibun)) 
							and build_sub_no=right(@jibun, CHARINDEX('-',reverse(@jibun))-1)
							order by sido, gungu,street_name, build_no, build_sub_no;	
						end
					else
						begin
							
							if ISNUMERIC(@jibun) = 1	--해당값이 숫자이면 건물번호, 아니면 건물명
								begin
									select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
									where street_name=@dong_name and build_no=@jibun
									order by sido, gungu,street_name, build_no, build_sub_no;	
								end
							
							else if @jibun = ''
								begin
									select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
									where (street_name=@dong_name or b_name=@dong_name) or (sigungu_build_name like '%'+@dong_name+'%')
									--where (street_name=@dong_name) or (sigungu_build_name = @dong_name)
									order by sido, gungu,street_name, build_no, build_sub_no;	
								end
							else
								begin
									select zipcode, sido, gungu, myoun, street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
									where (street_name=@dong_name and sigungu_build_name like '%'+@jibun+'%') or (sigungu_build_name like '%'+@dong_name+'%')
									--where (street_name=@dong_name and sigungu_build_name = @jibun) or (sigungu_build_name =@dong_name)
									order by sido, gungu,street_name, build_no, build_sub_no;	
								end	
						end
				end
			
		end

	--print @address2

END
GO
