IF OBJECT_ID (N'dbo.sp_SmsPacking', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_SmsPacking
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_SmsPacking] 
	@order_seq integer
AS 
BEGIN
	declare @order_hphone varchar(50)
	declare @sms_phone varchar(20)
	declare @sms_msg varchar(200)
	declare @SALES_GUBUN VARCHAR(2)
	declare @P_REMARKS AS VARCHAR(64)
	declare @datetime datetime	

	select @order_hphone = order_hphone
		,@sms_phone = sms_phone
		,@sms_msg = sms_msg
		,@SALES_GUBUN = A.SALES_GUBUN 
	from custom_order A inner join wedd_mail B
	on A.sales_gubun = B.sales_gubun 
	and B.div='초대장포장' 
    where A.order_seq = @order_seq AND USE_YORN = 'Y'
	
	-- 제휴 프페 H -> B 
	IF @SALES_GUBUN = 'H' OR @SALES_GUBUN = 'C'
	BEGIN
		SET @SALES_GUBUN = 'B'	
	END


	/* 주문하신청첩장포장완료 내용의 문자 발송 예약 시각 계산 */
	/*
	로직
	1. 18시 05분 이후 라면 다음날 9시로 변경
	2. 0시 ~ 9시까지는 당일 9시로 변경
	3. 1, 2번 적용 후 휴일이라면(주말 포함) 가장 가까운 평일 9시로 변경
	*/    
    DECLARE @RESERVE_DATE   DATETIME
    DECLARE @date datetime
    SET @date = GETDATE();

	SELECT
		-- 3. 1, 2번 적용 후 휴일이라면(주말 포함) 가장 가까운 평일 9시로 변경
		@RESERVE_DATE = (SELECT TOP 1 confirm_date FROM dbo.FN_GET_ConfirmDate_holiday(A.TARGET_DATE))
	FROM
	(
		-- 1. 18시 05분 이후 라면 다음날 9시로 변경
		-- 2. 0시 ~ 9시까지는 당일 9시로 변경
		SELECT
			CASE 
				WHEN CONVERT(VARCHAR(20), @date, 108) >= '18:05:00' THEN 
					CONVERT(VARCHAR(10), DATEADD(DD, 1, @date), 120) + ' 09:00:00'
				WHEN RIGHT(CONVERT(VARCHAR(13), @date, 120), 2) <= '08' THEN 
					CONVERT(VARCHAR(10), @date, 120) + ' 09:00:00'
				ELSE @date 
			END AS TARGET_DATE
	) A

	SET @datetime = CONVERT(varchar(23), getdate(), 120)

--	IF @datetime >= '2020-10-05 08:00:00'
--	begin
		 
--		IF @sms_msg <> ''
--			BEGIN
				-- 바/비 카카오 알림톡
--			  IF ( @SALES_GUBUN = 'SA' or @SALES_GUBUN = 'SB' OR @SALES_GUBUN = 'SS' OR @SALES_GUBUN = 'ST')  		
--				BEGIN
--					SET @P_REMARKS = 'SP_SMSPACKING'
--					--EXEC SP_EXEC_BIZTALK_SEND @ORDER_HPHONE, @P_REMARKS, @SALES_GUBUN, @order_seq, '초대장포장', @RESERVE_DATE,''--// 2019-06-14 nsm  : 공휴일 주말 체크해서 예약발송일 넘기기
--				END	
--			  else
--				BEGIN
--					DECLARE @P_RESERVE_DATE VARCHAR(19)
--					SET @P_RESERVE_DATE = FORMAT(CONVERT(DATETIME,@RESERVE_DATE),'yyyyMMddHHmmss')
--					SET @P_REMARKS = '포장완료 - SP_SMSPACKING'
--					--EXEC SP_EXEC_SMS_OR_MMS_SEND @SMS_PHONE, @ORDER_HPHONE, '', @SMS_MSG, @SALES_GUBUN, '단계별 DM', @P_REMARKS, @P_RESERVE_DATE, 0, ''--// 2019-06-14 nsm  : 공휴일 주말 체크해서 예약발송일 넘기기
--				END			
--			END
--	end
END
GO
