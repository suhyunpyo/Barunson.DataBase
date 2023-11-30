IF OBJECT_ID (N'dbo.up_select_zipcode_street_all_N', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_zipcode_street_all_N
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		daniel,kim
-- Create date: 2014-03-05
-- Description:	신도로 우편번호 검색
-- =============================================
CREATE PROCEDURE [dbo].[up_select_zipcode_street_all_N] (
	-- Add the parameters for the stored procedure here
	@street_name nvarchar(50),
	@search_convert	nvarchar(1)
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @ROW INT
DECLARE @TEMP NVARCHAR(50)
DECLARE @arr_len int
DECLARE @jibun	nvarchar(10)
DECLARE @dong_name nvarchar(20)
	

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

	WHILE @ROW<=LEN(@dong_name)
		BEGIN
		 
			 -- 한글자씩 아스키 코드 비교해서 숫자 영역인지 체크
			 IF NOT ((ASCII(SUBSTRING(@dong_name,@ROW,1)) >= 48) AND (ASCII(SUBSTRING(@dong_name,@ROW,1)) <= 57))
			  SET @TEMP = @TEMP + SUBSTRING(@dong_name,@ROW,1)  -- 숫자가 아니라면 @TEMP 변수에 누적 저장.
		 
			 SET @ROW = @ROW+1
		END
		
	
	if @search_convert = '1'	--지번검색
		begin
			if LEN(@jibun) > 0
				begin
					if  CHARINDEX('-', @jibun) <> 0	-- 지번정보가 있으면
						begin
							select top 1001 zipcode, sido, gungu, isnull(myoun, ''), street_name, build_no, build_sub_no, sigungu_build_name, isnull(b_name,b_ri) as b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
							where 
							(b_name=@TEMP or b_ri=@TEMP or b_name=@dong_name)
							and 
							jibun_no=SUBSTRING(@jibun,0, CHARINDEX('-', @jibun)) 
							and jibun_sub_no=right(@jibun, CHARINDEX('-',reverse(@jibun))-1)
							order by sido, gungu, jibun_no, jibun_sub_no
						end
					else
						begin
							if ISNUMERIC(@jibun) = 1	-- 지번이 숫자만 있을경우
								begin
									select top 1001 zipcode, sido, gungu,  isnull(myoun, ''), street_name, build_no, build_sub_no, sigungu_build_name, isnull(b_name,b_ri) as b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
									where 
									(b_name=@TEMP or b_ri=@TEMP or b_name=@dong_name)
									and 
									jibun_no=@jibun
									order by sido, gungu, jibun_no, jibun_sub_no
								end
							else
								begin
									select top 1001 zipcode, sido, gungu,  isnull(myoun, ''), street_name, build_no, build_sub_no, sigungu_build_name, isnull(b_name,b_ri) as b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
									where 
									(b_name=@TEMP or b_ri=@TEMP or b_name=@dong_name)
									and 
									(sigungu_build_name like '%'+@jibun+'%' ) 
									order by sido, gungu, jibun_no, jibun_sub_no
								end		
						end 
					
				end
			else
				begin
					select top 1001 zipcode, sido, gungu,  isnull(myoun, ''), street_name, build_no, build_sub_no, sigungu_build_name, isnull(b_name,b_ri) as b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
							where 
							(b_name = @TEMP or b_ri=@TEMP or b_name=@dong_name)
							order by sido, gungu, jibun_no, jibun_sub_no
				end
		end
		
	if @search_convert = '2'	--도로명검색
		begin
			if LEN(@jibun) > 0
				begin
					if  CHARINDEX('-', @jibun) <> 0	-- 지번정보가 있으면
						begin
							select top 1001 zipcode, sido, gungu,  isnull(myoun, ''), street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
							where 
							street_name like @dong_name+'%' 
							and 
							build_no=SUBSTRING(@jibun,0, CHARINDEX('-', @jibun)) 
							and build_sub_no=right(@jibun, CHARINDEX('-',reverse(@jibun))-1)
							order by sido, gungu, street_name, build_no, build_sub_no
						end
					else
						begin
							if ISNUMERIC(@jibun) = 1
								begin
									select top 1001 zipcode, sido, gungu,  isnull(myoun, ''), street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
									where 
									street_name like @dong_name+'%' 
									and 
									build_no=@jibun
									order by sido, gungu, street_name, build_no, build_sub_no
								end
							else
								begin
									select top 1001 zipcode, sido, gungu,  isnull(myoun, ''), street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
									where 
									street_name like @dong_name+'%' 
									and 
									(sigungu_build_name like '%'+@jibun+'%' )
									order by sido, gungu, street_name, build_no, build_sub_no
								end
						end
					
					
				end
			else
				begin
					select top 1001 zipcode, sido, gungu,  isnull(myoun, ''), street_name, build_no, build_sub_no, sigungu_build_name, b_name, b_ri, jibun_no, jibun_sub_no from zipcode_street_N with(nolock)
							where 
							street_name like @street_name+'%'
							
							order by sido, gungu, street_name, build_no, build_sub_no
				end	
		end

END
GO
