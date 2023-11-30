IF OBJECT_ID (N'dbo.SP_EXEC_EVT_MMS_SEND', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_EVT_MMS_SEND
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************

2016-07-01	정혜련
service
	BS: 바른손카드
	BH : 비핸즈
	PP : 프리미어페이퍼
	TC : 더카드
EVT_NUM 
*********************************************************/

CREATE PROCEDURE [dbo].[SP_EXEC_EVT_MMS_SEND]
	@event_seq int
	,@site_gb varchar(2)
	,@uid		varchar(100)

AS

BEGIN


	DECLARE @MMS_DATE VARCHAR(100)
	DECLARE @PHONE_NUM VARCHAR(100)
	DECLARE @SERVICE VARCHAR(4)

	DECLARE @MMS_MSG VARCHAR(MAX)
	DECLARE @MMS_SUBJECT VARCHAR(50)
	DECLARE @MMS_PHONE VARCHAR(50)
	DECLARE @NO_REC_BRAND VARCHAR(50)

	BEGIN
						
			IF @site_gb = 'BS'
				BEGIN
					SET @NO_REC_BRAND	= '바른손카드'
				
					SET @MMS_PHONE		= '1644-0708'
				END

			ELSE IF @site_gb = 'BH'
				BEGIN
					SET @NO_REC_BRAND	= '비핸즈카드'		
					SET @MMS_PHONE		= '1644-9713'
				END


			ELSE IF @site_gb = 'TC'
				BEGIN
					SET @NO_REC_BRAND	= '더카드'
			
					SET @MMS_PHONE		= '1644-7998'
				END
			ELSE
				BEGIN
					SET @NO_REC_BRAND	= '프리미어페이퍼'				
					SET @MMS_PHONE		= '1644-8796'
				END

			
			Select top 1 @PHONE_NUM = hphone From vw_user_info Where uid = @uid


			SET @MMS_SUBJECT = '[ ' + @NO_REC_BRAND + '] 한가위 감사 이벤트 쿠폰 안내'

			SET @MMS_MSG = '[ ' + @NO_REC_BRAND + '] 한가위 감사 이벤트 쿠폰 안내

							한가위 감사선물 증정 이벤트에 응모해주셔서 감사합니다 ^^ 

							바른컴퍼니의 답례품 전문몰 [셀레모]에서 
							사용 가능한 10% 할인쿠폰을 발급해드립니다.


							1. 쿠폰 사용기간 : ~2016년 9월 30일까지 

							2. 셀레모 쿠폰번호 
							▷ 한가위 Gift 10% 할인 
							   쿠폰코드 : BC201608

							3. 쿠폰 사용방법 : 
							   1) 셀레모 회원가입 (www.celemo.co.kr)
							  2) 로그인>마이페이지
							  3) 쿠폰등록(인증)
							  4) 주문 결제시 [쿠폰적용]에서 쿠폰 사용 가능
 
							- 5,000원 이상 구매시 사용 가능
							- 한가위 gift 카테고리 상품에 한해 사용 가능합니다. 
							- 청첩장 할인 쿠폰은 비핸즈 사이트>마이페이지> 쿠폰함에서 확인해주세요.' 


			--MMS 전송
			/*
			INSERT INTO invtmng.MMS_MSG(subject, phone, callback, status, reqdate, msg, TYPE)
			VALUES (  @MMS_SUBJECT
					, @PHONE_NUM
					, @MMS_PHONE
					, '0'
					, getdate()
					, @MMS_MSG
					, '0' )
			*/
					
			----------------------------------------------------------------------------------------------------
			-- Declare Block
			----------------------------------------------------------------------------------------------------
			DECLARE @DEST_INFO     VARCHAR(50)
			      , @SCHEDULE_TYPE INT
			
			
			SET @DEST_INFO = 'AA^' + @PHONE_NUM
			SET @SCHEDULE_TYPE = 0	--즉시전송					
			----------------------------------------------------------------------------------
			-- KT
			----------------------------------------------------------------------------------
			EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, @MMS_SUBJECT, @MMS_MSG, '', @MMS_PHONE, 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''

	
	
	
					
			
	END

END
GO
