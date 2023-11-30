IF OBJECT_ID (N'dbo.fn_IsWorkDay_', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_IsWorkDay_', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_IsWorkDay_', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_IsWorkDay_', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_IsWorkDay_', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.fn_IsWorkDay_
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
SELECT[dbo].[fn_IsWorkDay_]('2021-01-17',5)


SELECT[dbo].[fn_IsWorkDay_]('2021-02-10',4)

*/
CREATE function [dbo].[fn_IsWorkDay_](
	@sch_dt varchar(10),	--시작날짜
	@order_d int --3일 가져오기
)

returns varchar(10)
 
as 
begin 
	
	declare @r_weekday INT = 0 --주말체크
	declare @chk_count INT = 0 --체크카운트
	declare @chk_dt  datetime
	declare @chk_d int = 0 -- 비교 체크
	declare @loop_cnt int = 0
	declare @holiday_cnt int = 0

	SET @chk_dt = convert(datetime, @sch_dt);
	--set @loop_cnt = @order_d - @loop_cnt;
	
	While ( @chk_count <  @order_d )
	
		begin
	
			select @r_weekday = datepart(dw, convert(datetime, @chk_dt) )
		
			-- 주말(토,일)
			IF @r_weekday = 1 OR @r_weekday = 7 
			BEGIN
				SET @chk_d = 0
				SET @holiday_cnt = @holiday_cnt + 1
			END
			ELSE 
				begin
				
					-- 휴일
					IF (EXISTS(SELECT YDate FROM VW_holidays WHERE ydate = @chk_dt) )
					BEGIN
						SET @chk_d = 0	
						SET @holiday_cnt = @holiday_cnt + 1
					END
					ELSE	
					BEGIN
						SET @chk_d = 1	
					END
				END 			
			
			SET @chk_count =  @chk_count + @chk_d

			if @chk_count = @order_d
				break;
						
			select @chk_dt = dateadd(day , 1 ,@chk_dt );
			
		END 	

return @holiday_cnt
end

GO
