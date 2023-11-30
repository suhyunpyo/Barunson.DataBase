IF OBJECT_ID (N'dbo.fn_PrintDate_Reason', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_PrintDate_Reason', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_PrintDate_Reason', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_PrintDate_Reason', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.fn_PrintDate_Reason', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.fn_PrintDate_Reason
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT [dbo].[fn_PrintDate]('2021-01-15 16:45:00.000','X')
SELECT [dbo].[fn_PrintDate_Reason]('2021-01-15 16:45:00.000','X')
*/
CREATE FUNCTION [dbo].[fn_PrintDate_Reason]
(
	@confirm_date DATETIME,
	@card_brand VARCHAR(1) 
)
RETURNS VARCHAR(100)
AS 
BEGIN 
	DECLARE @stop int = 0
	DECLARE @r_weekday INT = 0 
	DECLARE @chk_dt  DATETIME 
	DECLARE @chk_d int = 0
	DECLARE @sch_tm int
	DECLARE @reason_txt varchar(100)


	SET @chk_dt = convert(datetime, @confirm_date);

	IF DATEPART(dw, CONVERT(datetime, @confirm_date) ) IN (1,7) OR EXISTS(SELECT YDate FROM VW_holidays WHERE ydate = @confirm_date) 
	BEGIN
		SET @reason_txt = '휴일'
	END
	ELSE 
	BEGIN
		SET @sch_tm = (DATEPART("hh",@chk_dt) * 60 ) +  DATEPART("mi",@chk_dt)

		IF UPPER(@card_brand) = 'S' 
		BEGIN
			IF @sch_tm > 809
			BEGIN
				SET @reason_txt = '오후1시30분이후'
				SELECT @chk_dt = DATEADD(DAY , 1 ,@chk_dt );
			END
			ELSE
				SET @reason_txt = '오후1시30분이전'
		END
		ELSE
		BEGIN
			IF @sch_tm > 899
			BEGIN
				SET @reason_txt = '오후3시이후'
				SELECT @chk_dt = DATEADD(DAY , 1 ,@chk_dt );
			END
			ELSE
				SET @reason_txt = '오후3시이전'
		END
	END

	WHILE @stop < 1
	BEGIN
		SET @chk_d = 0

		SELECT @r_weekday = DATEPART(dw, CONVERT(DATETIME, @chk_dt))

		-- 주말(토,일)
		IF @r_weekday = 1 OR @r_weekday = 7 
		BEGIN
			SET @chk_d = 1
		END
		ELSE 
		BEGIN	
			-- 휴일
			IF (EXISTS(SELECT YDate FROM VW_holidays WHERE ydate = @chk_dt))
				SET @chk_d = 1
			ELSE
				SET @stop = 1
		END

		SELECT @chk_dt = DATEADD(DAY , @chk_d ,@chk_dt );

	END

	--RETURN convert(char(10),@chk_dt,121)
	RETURN @reason_txt
	--RETURN @reason_txt + '|' + convert(char(10),@chk_dt,121)
	
END


GO
