IF OBJECT_ID (N'dbo.SP_SETTLE_PRICE_SMS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SETTLE_PRICE_SMS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================================================
-- Create date: 2019.08.12 정혜련
-- Description:	쿠폰적용오류 문자 발송

-- =============================================================================================================================
CREATE PROCEDURE [dbo].[SP_SETTLE_PRICE_SMS] 
AS
BEGIN

	DECLARE @OrderSeqCnt INT -- 

	DECLARE @SMS_NUM AS VARCHAR(200);		--SMS전송 번호

	DECLARE @TMP_SMS_NUM AS VARCHAR(200);	--실제저장변수
	DECLARE @STR_SMS_NUM AS VARCHAR(200);	--반복문사용변수
	DECLARE @splitStr AS VARCHAR(1);		--문자열구분자(|)
		
	
	SET @SMS_NUM			= '010-9484-4697|'; -- 정혜련
	SET @splitStr			= '|';
	SET @STR_SMS_NUM		= @SMS_NUM;

	SET NOCOUNT ON;

		select  @OrderSeqCnt = COUNT(*) from custom_order where order_date >= '2019-05-01'
		and last_total_price <> settle_price and status_Seq < 15 and status_Seq not in (3,5) 
		and order_seq not in (2830406,2823659,2845847) and settle_status = 2 and sales_gubun <> 'SD' and pay_type <> '4'

		----★문자전송 --------------------------------------------------------------------------------------------------------------------------

		if (@OrderSeqCnt > 0 )
			BEGIN

				WHILE CharIndex(@splitStr, @STR_SMS_NUM, 0) > 0
					BEGIN

						SET @TMP_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,1,CHARINDEX(@splitStr,@STR_SMS_NUM)-1)
						SET @STR_SMS_NUM	=  SUBSTRING(@STR_SMS_NUM,CHARINDEX(@splitStr,@STR_SMS_NUM)+LEN(@splitStr),LEN(@STR_SMS_NUM))


						INSERT INTO invtmng.SC_TRAN (	TR_SENDSTAT
													,   TR_RSLTSTAT
													,   TR_SENDDATE
													,   TR_PHONE
													,   TR_CALLBACK
													,   TR_MSG
													)
									VALUES('0' , '00' , CONVERT(VARCHAR(16), DATEADD(mi, 1, GETDATE()), 120) , @TMP_SMS_NUM , '16440708' , '[확인요망]쿠폰적용 오류.')
					END

			END

	SET NOCOUNT OFF;

END
GO
