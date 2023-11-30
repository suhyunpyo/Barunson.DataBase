IF OBJECT_ID (N'dbo.SP_EXEC_SMS_SEND_FOR_ORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_SMS_SEND_FOR_ORDER
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************

2016-06-13	황새롬
바른손/비핸즈 공통-구매고객에 LMS 자동 발송 
바른손카드 청첩장 구매 고객/ SMS 수신거부 고객은 제외
발송 처리 후 +3일 뒤 오후 2시
비핸즈카드 제외 2018.04.04 ( 알림톡 예정)
*********************************************************/
CREATE PROCEDURE [dbo].[SP_EXEC_SMS_SEND_FOR_ORDER]
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
    SET @TIME = ' 14:00:00'


	IF GETDATE() < '2099-12-31 00:00:00'
	BEGIN



	--커서를 이용하여 해당되는 고객정보를 얻는다.
	DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD
	FOR
		SELECT
				CONVERT(VARCHAR(10), DATEADD(DD, 3, CO.SRC_SEND_DATE), 120) + @TIME AS SEND_DATE 
			, VUI.HPHONE
			, VUI.UID
			, CO.SALES_GUBUN
			, VUI.UNAME 
		FROM    CUSTOM_ORDER CO
		JOIN    VW_USER_INFO VUI ON CO.MEMBER_ID = VUI.UID AND CO.SALES_GUBUN = VUI.SITE_DIV   
		WHERE   1 = 1
		AND		CO.SALES_GUBUN IN ('SB','ST')
		AND     CO.SRC_SEND_DATE >= CONVERT(VARCHAR(10), GETDATE()-6, 120) + ' 00:00:00'
		AND     CO.SRC_SEND_DATE < CONVERT(VARCHAR(10), GETDATE()-5, 120) + ' 00:00:00'
		AND     VUI.CHK_SMS = 'Y'
		AND     CO.UP_ORDER_SEQ IS NULL
		AND     CO.ORDER_TYPE IN ('1','6','7')
		AND		CO.ORDER_SEQ <> 2725711

		--AND		CO.MEMBER_ID = 's5guest'

	OPEN cur_AutoInsert_For_Order

	DECLARE @MMS_DATE VARCHAR(100)
	DECLARE @HAND_PHONE VARCHAR(100)
	DECLARE @USER_ID VARCHAR(100)
	DECLARE @SALES_GUBUN VARCHAR(4)
	DECLARE @MMS_MSG VARCHAR(MAX)
	DECLARE @MMS_SUBJECT VARCHAR(50)
	DECLARE @MMS_PHONE VARCHAR(50)
	DECLARE @UNAME VARCHAR(30)

	FETCH NEXT FROM cur_AutoInsert_For_Order INTO @MMS_DATE, @HAND_PHONE, @USER_ID, @SALES_GUBUN, @UNAME

	WHILE @@FETCH_STATUS = 0

	BEGIN
			IF @SALES_GUBUN = 'SB' 
			--바른손 LMS 발송
				BEGIN
					SET @MMS_SUBJECT = '[바른손] 이용후기 EVENT';					
					SET @MMS_MSG = '청첩장은 잘 받아보셨나요? 후기 남기고 푸짐한 선물 받으세요~ [바른손카드]';
					SET @MMS_PHONE = '1644-0708';
				END
			ELSE IF @SALES_GUBUN = 'ST' 
			--더카드 LMS 발송
				BEGIN
					SET @MMS_SUBJECT = '[더카드] 이용후기 EVENT';
					SET @MMS_MSG = '청첩장은 잘 받아보셨나요? 후기 남기고 레꼴뜨전기포트 받아가세요~[더카드]';
					SET @MMS_PHONE = '1644-7998';
				END

			--ELSE IF @SALES_GUBUN = 'SA' 
			----비핸즈 LMS 발송
			--	BEGIN
			--		SET @MMS_SUBJECT = '[비핸즈] 이용후기 EVENT';
			--		SET @MMS_MSG = '청첩장은 잘 받아보셨나요? 후기 남기고 식전영상쿠폰 받아가세요~[비핸즈카드]';
			--		SET @MMS_PHONE = '1644-9713';
			--	END

			
		/* 2020-11-23 KT 문자 서비스 작업 변경 */
		SET @UNAME = '^' + @HAND_PHONE
		EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @MMS_MSG, '', @MMS_PHONE, 1,  @HAND_PHONE, 0, '', 0, @SALES_GUBUN, '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT


		--EXEC SP_EXEC_SMS_OR_MMS_SEND @MMS_PHONE, @HAND_PHONE, @MMS_SUBJECT, @MMS_MSG, @SALES_GUBUN, '이용후기SMS', '', @MMS_DATE, 0, ''


		FETCH NEXT FROM cur_AutoInsert_For_Order INTO @MMS_DATE, @HAND_PHONE, @USER_ID, @SALES_GUBUN, @UNAME
	END

	CLOSE cur_AutoInsert_For_Order
	DEALLOCATE cur_AutoInsert_For_Order

	END

END
GO
