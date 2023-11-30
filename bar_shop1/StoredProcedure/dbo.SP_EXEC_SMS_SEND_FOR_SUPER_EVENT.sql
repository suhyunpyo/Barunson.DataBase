IF OBJECT_ID (N'dbo.SP_EXEC_SMS_SEND_FOR_SUPER_EVENT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_SMS_SEND_FOR_SUPER_EVENT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_EXEC_SMS_SEND_FOR_SUPER_EVENT]

AS
BEGIN

    DECLARE @TIME AS VARCHAR(10)
	DECLARE @MSG AS VARCHAR(2000)
	DECLARE @TITLE AS VARCHAR(200)
	DECLARE @CALL_NUMBER AS VARCHAR(50)

	--커서를 이용하여 해당되는 고객정보를 얻는다.
	DECLARE cur_AutoInsert CURSOR FAST_FORWARD
	FOR
        SELECT  UPHONE AS HAND_PHONE, IDX 
        FROM    SUPER7DAY_SMS
        WHERE   sendYN = 'N'

	OPEN cur_AutoInsert

	DECLARE @HAND_PHONE VARCHAR(100)
	DECLARE @IDX INT

	FETCH NEXT FROM cur_AutoInsert INTO  @HAND_PHONE, @IDX

	WHILE @@FETCH_STATUS = 0

	BEGIN
		SET @TITLE = '[더카드] 선착순 특가 제품 입고 알림 ★';
		SET @CALL_NUMBER = '1644-7998';
		SET @MSG = '[더카드] 선착순 특가 제품 입고 알림 ★' + char(13) + char(10)
				    + '이번 주 선착순 특가 제품이 업데이트 되었습니다.' + char(13) + char(10)
				    + '지금 바로 더카드 이번 주 선착순 특가 제품을 만나보세요. ' + char(13) + char(10)
				    + '서두르세요~! 망설이면 품절 각!' + char(13) + char(10)
					+  char(13) + char(10)
					+ '감사합니다♡' + char(13) + char(10)
				    + '이번 주 특가 제품 보러가기 ▶ https://bit.ly/2FF2ZtL' + char(13) + char(10)

		--MMS 발송
		EXEC SP_EXEC_SMS_OR_MMS_SEND @CALL_NUMBER, @HAND_PHONE, @TITLE, @MSG, 'ST', '[더카드] 선착순 특가 제품 입고 알림 ★', '', '', 0, ''
        UPDATE SUPER7DAY_SMS SET SENDYN = 'Y' WHERE IDX = @IDX

		FETCH NEXT FROM cur_AutoInsert INTO @HAND_PHONE, @IDX
	END

	CLOSE cur_AutoInsert
	DEALLOCATE cur_AutoInsert
END
GO
