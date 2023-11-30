IF OBJECT_ID (N'invtmng.sp_SmsPrint', N'P') IS NOT NULL DROP PROCEDURE invtmng.sp_SmsPrint
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO


/* 전달 주문번호 arr는 1000개까지만 가능하다. */

CREATE    PROCEDURE [invtmng].[sp_SmsPrint] 
	@order_seq integer
AS 
begin
	declare @order_hphone varchar(50)
	declare @sms_phone varchar(20)
	declare @sms_msg varchar(200)
	declare @date datetime
	declare @datetime datetime
	DECLARE @SALES_GUBUN VARCHAR(2)
	
	declare @up_order_seq int
	declare @isSpecial char(1)
	declare @pay_type char(1)
	declare @P_DIV varchar(64)

	select
		@up_order_seq = ISNULL(A.up_order_seq, 0),
		@isSpecial = A.isSpecial,
		@pay_type = A.pay_type,
		@order_hphone = order_hphone,
		@sms_phone = sms_phone,
		@sms_msg = sms_msg,
		@SALES_GUBUN = A.SALES_GUBUN
	from
		custom_order A
		inner join wedd_mail B on A.sales_gubun = B.sales_gubun
		and B.div = '초대장인쇄'
	where
		A.order_seq = @order_seq
	
	-- 알림톡 템플릿 선택 (배송일 표기, 배송일 미표기)
	IF @up_order_seq > 0 AND @pay_type <> '4' AND @isSpecial <> '1' AND @isSpecial <> '2' -- 사/특 아닌 경우
	BEGIN
		-- 수/기 건. 배송일 미표기 템플릿으로 전송합니다.
		SET @P_DIV = '초대장인쇄-배송예정일미표기'
	END
	ELSE
	BEGIN
		SET @P_DIV = '초대장인쇄'
	END

	-- 제휴 프페 H -> B 
	IF @SALES_GUBUN = 'H' OR  @SALES_GUBUN = 'C' 
	BEGIN
		SET @SALES_GUBUN = 'B'	
	END

	SELECT @date = GETDATE()
	SELECT @datetime = CONVERT(VARCHAR(20), GETDATE(), 108)
	
	--IF @date <= '2010-01-21 18:00:00' OR @date >= '2020-01-28 00:00:00'
	IF @date >= '2020-10-05 08:00:00'
	BEGIN
		IF @datetime >= '07:00:00' AND @datetime <= '19:05:00'
		BEGIN
			if @sms_msg <> null
			BEGIN

				DECLARE @P_REMARKS AS VARCHAR(64)
				SET @P_REMARKS = '초대장인쇄 - SP_SMSPRINT'
				IF ( @SALES_GUBUN = 'SA' or @SALES_GUBUN = 'SB' or @SALES_GUBUN = 'ST' OR @SALES_GUBUN = 'SS' OR @SALES_GUBUN = 'B')
					BEGIN
					EXEC SP_EXEC_BIZTALK_SEND @order_hphone, 'sp_SmsPrint', @SALES_GUBUN, @order_seq, @P_DIV, '',''
					END 
				ELSE 
					BEGIN
					EXEC SP_EXEC_SMS_OR_MMS_SEND @SMS_PHONE, @ORDER_HPHONE, '', @SMS_MSG, @SALES_GUBUN, '단계별 DM', @P_REMARKS, '', 0, ''
					END 				

			END

		END
	END
		
end
GO
