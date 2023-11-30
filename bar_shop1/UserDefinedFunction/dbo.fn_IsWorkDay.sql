IF OBJECT_ID (N'dbo.fn_IsWorkDay', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_IsWorkDay', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_IsWorkDay', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_IsWorkDay', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_IsWorkDay', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.fn_IsWorkDay
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_IsWorkDay](
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

	SET @chk_dt = convert(datetime, @sch_dt);
	--set @loop_cnt = @order_d - @loop_cnt;
	
	While ( @chk_count <  @order_d )
	
		begin
	
			select @r_weekday = datepart(dw, convert(datetime, @chk_dt) )
		
			-- 주말(토,일)
			IF @r_weekday = 1 OR @r_weekday = 7 
				SET @chk_d = 0
			ELSE 
				begin
				
					-- 휴일
					IF (EXISTS(SELECT YDate FROM VW_holidays WHERE ydate = @chk_dt) )
						SET @chk_d = 0	
					ELSE	
						SET @chk_d = 1	
				END 			
			
			SET @chk_count =  @chk_count + @chk_d

			if @chk_count = @order_d
				break;
						
			select @chk_dt = dateadd(day , 1 ,@chk_dt );
			
		END 	

return convert(varchar(10), @chk_dt, 120)
end
GO
