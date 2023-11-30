IF OBJECT_ID (N'dbo.SP_EXEC_SMS_SEND_FOR_SEMPIO_EVENT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_SMS_SEND_FOR_SEMPIO_EVENT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_EXEC_SMS_SEND_FOR_SEMPIO_EVENT]

AS
BEGIN

    DECLARE @TIME AS VARCHAR(10)
	DECLARE @MSG AS VARCHAR(2000)
	DECLARE @TITLE AS VARCHAR(200)
	DECLARE @CALL_NUMBER AS VARCHAR(50)

	--커서를 이용하여 해당되는 고객정보를 얻는다.
	DECLARE cur_AutoInsert CURSOR FAST_FORWARD
	FOR
		SELECT  CONVERT(VARCHAR(10), GETDATE(), 120) + ' 16:00:00' AS SEND_DATE
				, VUI.HPHONE
				, VUI.UID
				, (SELECT COUNT(*) 
					FROM CUSTOM_ORDER_ITEM 
					WHERE ORDER_SEQ = CO.ORDER_SEQ
					AND CARD_SEQ = 35990) AS GIFT_CNT
		FROM CUSTOM_ORDER CO
		JOIN    VW_USER_INFO VUI ON CO.MEMBER_ID = VUI.UID AND CO.SALES_GUBUN = VUI.SITE_DIV   
		WHERE SALES_GUBUN = 'SB'
		AND STATUS_SEQ = 15
		AND ORDER_TYPE IN (1, 6, 7)
		AND SRC_SEND_DATE >= CONVERT(VARCHAR(10), GETDATE()-3, 120) + ' 00:00:00'
		AND SRC_SEND_DATE < CONVERT(VARCHAR(10), GETDATE()-2, 120) + ' 00:00:00'
		AND VUI.CHK_SMS = 'Y'

	OPEN cur_AutoInsert

	DECLARE @MMS_DATE VARCHAR(100)
	DECLARE @HAND_PHONE VARCHAR(100)
	DECLARE @USER_ID VARCHAR(100)
	DECLARE @GIFT_CNT INT

	FETCH NEXT FROM cur_AutoInsert INTO @MMS_DATE, @HAND_PHONE, @USER_ID, @GIFT_CNT

	WHILE @@FETCH_STATUS = 0

	BEGIN
		
		IF @GIFT_CNT > 0  -- 샘표 사은품을 가지고 있는 고객만
		BEGIN

				SET @TITLE = '[바른손카드] 청첩장과 국시세트 선물 잘 받아 보셨나요?';
				SET @CALL_NUMBER = '1644-0708';
				SET @MSG = '★ 샘표X바른손카드 행복한 결혼 선물 이벤트 ★' + char(13) + char(10)
				         + '받으신 청첩장과 샘표 국시세트의 SNS후기를 남겨주세요.' + char(13) + char(10)
				         + '사진 1장만 등록 해도 신혼주방에 꼭 필요한' + char(13) + char(10)
				         + '제품들만 모은샘표 ‘첫 살림 꾸러미 세트’를 드립니다~!' + char(13) + char(10)
						 +  char(13) + char(10)
						 + '▶ 자세히 보기' + char(13) + char(10)
				         + '▶ http://m.barunsoncard.com/mobile/event/event_2017sempio.asp' + char(13) + char(10)
				         +  char(13) + char(10)
				         + '[수신거부]고객센터 1644-0708';

				--MMS 발송
				EXEC SP_EXEC_SMS_OR_MMS_SEND @CALL_NUMBER, @HAND_PHONE, @TITLE, @MSG, 'SB', '[바른손카드]행복한결혼생활', '', '', 0, ''
		END

		FETCH NEXT FROM cur_AutoInsert INTO @MMS_DATE, @HAND_PHONE, @USER_ID, @GIFT_CNT
	END

	CLOSE cur_AutoInsert
	DEALLOCATE cur_AutoInsert
END
GO
