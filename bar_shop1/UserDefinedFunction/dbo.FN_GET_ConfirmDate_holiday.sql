IF OBJECT_ID (N'dbo.FN_GET_ConfirmDate_holiday', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'.dbo.FN_GET_ConfirmDate_holiday', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'.dbo.FN_GET_ConfirmDate_holiday', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'.dbo.FN_GET_ConfirmDate_holiday', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'.dbo.FN_GET_ConfirmDate_holiday', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.FN_GET_ConfirmDate_holiday
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-- =============================================  
-- Author: 개발팀 김은석
-- Create date: 2023-06-07
-- Description: 컨펌 날짜가 휴일이라면 가장 가까운 평일 오전 9시를 반환합니다.
-- =============================================  
*/
CREATE FUNCTION [dbo].[FN_GET_ConfirmDate_holiday](
	@confirm_date	datetime		-- 컨펌일시	
)
RETURNS @TEMP TABLE (
	confirm_date datetime,			-- 휴일이라면 가장 가까운 평일 오전 9시, 아니라면 원래 값 그대로
	is_change int					-- 휴일이라서 반환값에 변경이 있었다면 1, 아니라면 0
)
AS
BEGIN
	-- 확정일이 휴일이라면 가장 가까운 평일 오전 9시를 확정일로 변경합니다.
	DECLARE @r_weekday INT
	DECLARE @r_date varchar(8)
	DECLARE @r_change INT

	SET @r_change = 0		-- 휴일이 아니라고 가정

	While(1 = 1)
	BEGIN
		SELECT @r_weekday = DATEPART(WEEKDAY, @confirm_date)

		IF @r_weekday = 1 OR @r_weekday = 7
		BEGIN
			SET @confirm_date = DATEADD(DAY, 1, @confirm_date)
			SET @r_change = 1
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT YDate FROM VW_holidays WHERE ydate = CONVERT(varchar(8), @confirm_date, 112))
			BEGIN
				SET @confirm_date = DATEADD(DAY, 1, @confirm_date)
				SET @r_change = 1
			END
			ELSE
			BEGIN
				-- 확정일자가 휴일이 아니므로 탈출
				IF @r_change = 1
				BEGIN
					-- 휴일로 인해 확정일자가 변경 되었다면 시각을 오전 9시로 변경합니다.
					SET @confirm_date = CONVERT(varchar(10), @confirm_date, 120) + ' 09:00:00'
				END

				break
			END
		END
	END
	-- 확정일이 휴일 처리 끝

	-- 결과 반환	
	INSERT INTO @TEMP (confirm_date, is_change) VALUES (@confirm_date, @r_change)

	RETURN
END
GO