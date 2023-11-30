IF OBJECT_ID (N'dbo.SP_EXEC_SAMPLEBOOK_SMS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_SAMPLEBOOK_SMS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************************************************************************
작성자		: 정혜련
작성일		: 2018-07-18
DESCRIPTION	: 바른손 샘플북 회수고객에 LMS 자동 발송  (발송 시점 : 샘플북 반납 기한 D-5)
SPECIAL LOGIC	: 
URL			: 
EXEC		: 
*********************************************************************************************************************
MODIFICATION
*********************************************************************************************************************
수정일		작업자	요청자				DESCRIPTION
=====================================================================================================================
*********************************************************************************************************************/ 
CREATE PROCEDURE [dbo].[SP_EXEC_SAMPLEBOOK_SMS]
AS
	BEGIN

		/****** 20201123 표수현 추가 START ****/
		DECLARE	@ErrNum   INT          
			, @ErrSev   INT          
			, @ErrState INT          
			, @ErrProc  VARCHAR(50)  
			, @ErrLine  INT          
			, @ErrMsg   VARCHAR(2000)
		/****** 20201123 표수현 추가 END ****/

		DECLARE @TIME AS VARCHAR(10)
		SET @TIME = ' 09:05:00'

		--커서를 이용하여 해당되는 고객정보를 얻는다.
		DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD
		FOR
	
			SELECT
				CONVERT(VARCHAR(10), getdate(), 120) + @TIME AS SEND_DATE 
				, VUI.HPHONE
				, VUI.UID
				, CO.SALES_GUBUN
			FROM    CUSTOM_ETC_ORDER CO
			JOIN    VW_USER_INFO VUI ON CO.MEMBER_ID = VUI.UID AND CO.SALES_GUBUN = VUI.SITE_DIV   
			WHERE   1 = 1
			AND	CO.SALES_GUBUN in ('SB','SS')
			AND	CO.ORDER_TYPE= 'U'
			AND     CO.RETURN_LIMIT_DATE >= CONVERT(VARCHAR(10), GETDATE()+5, 120) + ' 00:00:00'
			AND     CO.RETURN_LIMIT_DATE < CONVERT(VARCHAR(10), GETDATE()+6, 120) + ' 00:00:00'
			AND     VUI.CHK_SMS = 'Y'
			AND     CO.STATUS_SEQ = 12


		OPEN cur_AutoInsert_For_Order

		DECLARE @MMS_DATE VARCHAR(100)
		DECLARE @HAND_PHONE VARCHAR(100)
		DECLARE @USER_ID VARCHAR(100)
		DECLARE @SALES_GUBUN VARCHAR(4)
		DECLARE @MMS_MSG VARCHAR(MAX)
		DECLARE @MMS_SUBJECT VARCHAR(50)
		DECLARE @MMS_PHONE VARCHAR(50)

		FETCH NEXT FROM cur_AutoInsert_For_Order INTO @MMS_DATE, @HAND_PHONE, @USER_ID, @SALES_GUBUN

		WHILE @@FETCH_STATUS = 0

		BEGIN
				--바른손 LMS 발송
				IF @SALES_GUBUN = 'SB'
					BEGIN
					SET @MMS_SUBJECT = '[바른손카드] 샘플북 반납 기한 안내';					
					SET @MMS_MSG = '샘플북 반납 접수 기한이 5일 남았습니다. 
					기한 내에 마이페이지에서 ''샘플북 반납 접수''를 진행하고,
					샘플북 이용 고객에게 제공되는 20,000원 쿠폰을 놓치지 마세요!

					바로가기 ▶ http://m.barunsoncard.com/mypage/mypage.asp';
					SET @MMS_PHONE = '1644-0708';
				END

				--바른손 LMS 발송
				IF @SALES_GUBUN = 'SS'
					BEGIN
					SET @MMS_SUBJECT = '[프리미어] 샘플북 반납 기한 안내';					
					SET @MMS_MSG = '샘플북 반납 접수 기한이 5일 남았습니다. 
					기한 내에 마이페이지에서 ''샘플북 반납 접수''를 진행하고,
					샘플북 이용 고객에게 제공되는 페이백쿠폰 + 추가할인쿠폰을 놓치지 마세요!

					바로가기 ▶ http://m.barunsoncard.com/mypage/mypage.asp';
					SET @MMS_PHONE = '1644-8796';
				END


				 /* 20201123 KT 문자 서비스 작업 변경 */
				 SET @HAND_PHONE = '^' + @HAND_PHONE
				EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @MMS_SUBJECT, '', @MMS_PHONE, 1, @HAND_PHONE, 0, '', 0, @SALES_GUBUN, '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

				--EXEC SP_EXEC_SMS_OR_MMS_SEND @MMS_PHONE, @HAND_PHONE, @MMS_SUBJECT, @MMS_MSG, @SALES_GUBUN, '샘플북 반납 기한 안내', '', @MMS_DATE, 0, ''


			FETCH NEXT FROM cur_AutoInsert_For_Order INTO @MMS_DATE, @HAND_PHONE, @USER_ID, @SALES_GUBUN
		END

		CLOSE cur_AutoInsert_For_Order
		DEALLOCATE cur_AutoInsert_For_Order



END

GO
