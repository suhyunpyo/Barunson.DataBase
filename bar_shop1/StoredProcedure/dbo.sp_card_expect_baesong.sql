IF OBJECT_ID (N'dbo.sp_card_expect_baesong', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_card_expect_baesong
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-- =============================================  
-- Author: 개발팀 김은석
-- Create date: 2023-06-07  
-- Description: 카드 제작 예상 일정   

exec sp_card_expect_baesong '1', '2019-08-09', '9', '36724', '5007' 
exec sp_card_expect_baesong '2', '2019-08-09', '9', '36724', '5007' 

-- =============================================  
*/
CREATE proc [dbo].[sp_card_expect_baesong]  
	@sch_gb   varchar(1), -- 1.초안, 2.배송  
	@sch_dt   varchar(10), -- 날짜  
	@sch_tm   int, -- 시간  
	@card_seq  int, -- 카드번호  
	@company_seq int  -- 사이트 구분  
AS
BEGIN   
	DECLARE @confirm_date datetime

	IF @sch_tm > 9
	BEGIN
		SET @confirm_date = @sch_dt + ' ' + CAST(@sch_tm AS varchar) + ':00:00'
	END
	ELSE
	BEGIN
		SET @confirm_date = @sch_dt + ' 0' + CAST(@sch_tm AS varchar) + ':00:00'
	END

	-- 확정일이 휴일이라면 가장 가까운 평일 오전 9시를 확정일로 변경합니다.
	SELECT @confirm_date = confirm_date FROM dbo.FN_GET_ConfirmDate_holiday(@confirm_date)

	IF @sch_gb = '1'
	BEGIN
		-- 초안 dbo.FN_GET_BAESONG_CHOAN
		DECLARE @WorkDay_choan INT
		SET @WorkDay_choan = dbo.FN_GET_BAESONG_CHOAN(@card_seq, @confirm_date)

		SELECT dbo.fn_IsWorkDay(@sch_dt,  @WorkDay_choan + 1) as last_Dt
	END
	ELSE
	BEGIN
		-- 배송 dbo.FN_GET_BAESONG_CARD
		DECLARE @WorkDay_baesong INT		
		SELECT @WorkDay_baesong = WorkDay FROM dbo.FN_GET_BAESONG_CARD(@card_seq, @confirm_date)

		SELECT dbo.fn_IsWorkDay(@sch_dt,  @WorkDay_baesong + 1) as last_Dt
	END
END
GO
