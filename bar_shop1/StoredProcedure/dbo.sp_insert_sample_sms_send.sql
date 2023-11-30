IF OBJECT_ID (N'dbo.sp_insert_sample_sms_send', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_insert_sample_sms_send
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		김현기
-- Create date: 2016-07-04
-- Description:	샘플추천 로직
-- exec sp_insert_sample_sms_send 'hg12345', 'ST', 1161712, '0'
-- =============================================
CREATE PROCEDURE [dbo].[sp_insert_sample_sms_send]
		
	@uid			NVARCHAR(20),
	@sales_gubun	VARCHAR(10),
	@order_seq		INT,
	@result_code	INT = 0 OUTPUT

AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;	
	
	DECLARE @ResultCount INT
	DECLARE @CouponCnt INT
	DECLARE @hphone VARCHAR(20)
	DECLARE @sample_url VARCHAR(200)
	set @sample_url = 'http://m.thecard.co.kr/mobile/event/2016bestsample_vote.asp?order_seq='


	BEGIN

		SELECT	@hphone = hand_phone1+'-'+hand_phone2+'-'+hand_phone3
		FROM	S2_UserInfo_TheCard
		WHERE	1 = 1
		  AND	UID = @uid

		IF @hphone <> '' 
			BEGIN
				INSERT INTO invtmng.MMS_MSG(subject, phone, callback, status, reqdate, msg, TYPE) 								
				VALUES ( '[더카드]샘플 투표하기 이벤트'
						, @hphone
						, '1644-7998'
						, '0'
						,  CONVERT(VARCHAR(10), GETDATE(), 120)
						, '▶샘플 투표하기 URL
						  ' + @sample_url + convert(varchar(10),@order_seq) + char(10)
						  + ' 투표하기 이벤트 참여하고,' + char(10)
						  + ' 만원 할인 쿠폰 받아가세요! '
						, '0' )

				set @result_code = 1
			End
		ELSE
			BEGIN
				SET @result_code = 0
			END
	END


	RETURN @result_code
	
END
GO
