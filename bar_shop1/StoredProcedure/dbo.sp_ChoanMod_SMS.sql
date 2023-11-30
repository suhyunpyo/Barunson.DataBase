IF OBJECT_ID (N'dbo.sp_ChoanMod_SMS', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ChoanMod_SMS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC sp_ChoanMod_SMS 3076572

SELECT * FROM INVTMNG.MMS_LOG WHERE PHONE = '010-9484-4697'
SELECT * FROM INVTMNG.MMS_LOG WHERE PHONE = '01094844697'

SELECT * FROM INVTMNG.MMS_MSG WHERE PHONE = '010-9484-4697'
SELECT * FROM INVTMNG.MMS_MSG WHERE PHONE = '01094844697'

exec sp_ChoanMod_SMS_HR 3097749

*/
CREATE    PROCEDURE [dbo].[sp_ChoanMod_SMS]
	@ORDER_SEQ INTEGER
AS
BEGIN

	DECLARE @SMS_PHONE [VARCHAR](20)
	DECLARE @ORDER_HPHONE [VARCHAR](100)
	DECLARE @SMS_NEW_MSG [VARCHAR](200)
	DECLARE @SALES_GUBUN [VARCHAR](2)
	DECLARE @TARGET_DT [varchar](10)
	DECLARE	@date	datetime
	  
	SELECT	@SMS_NEW_MSG = CASE WHEN SALES_GUBUN = 'ST' THEN '고객님, 요청하신 초안수정요청이 접수되었으며, 완료 후 안내드리겠습니다.[더카드]'
								  ELSE '[' + B.COMPANY_NAME + ']' + ' 초안수정이접수되었습니다. 초안은 ' + B.TARGET_DATE + ' 재등록될 예정입니다'  
							 END
	    ,	@TARGET_DT = B.TARGET_DT
	    ,	@ORDER_HPHONE = B.ORDER_HPHONE
	    ,	@SMS_PHONE = B.SMS_PHONE
	    ,	@SALES_GUBUN = B.SALES_GUBUN
	FROM ( 
		SELECT 
			REPLACE(RIGHT(CONVERT(VARCHAR(10), DATEADD(DD, 0, target_dt), 120), 5), '-', '월 ') + '일 까지' target_date 
		    ,   TARGET_DT
		    ,	ORDER_HPHONE
		    ,	SMS_PHONE
			, ( CASE WHEN SALES_GUBUN = 'H'  THEN 'B' 
			  WHEN SALES_GUBUN = 'C' THEN 'B'
			  ELSE SALES_GUBUN END ) AS SALES_GUBUN 
			,   COMPANY_NAME
		FROM	(
				SELECT						
					dbo.fn_IsWorkDay(CONVERT(varchar(10), a.new_SRC_MODREQUEST_DATE, 120), dbo.FN_GET_BAESONG_CHOAN(a.card_seq, a.new_SRC_MODREQUEST_DATE) + 1) AS TARGET_DT
					
					,	CASE 
								WHEN A.SALES_GUBUN = 'SB' THEN '바른손카드'
								WHEN A.SALES_GUBUN = 'SA' THEN '비핸즈카드'
								WHEN A.SALES_GUBUN = 'ST' THEN '더카드'
								WHEN A.SALES_GUBUN = 'SS' THEN '프리미어페이퍼'
								WHEN A.SALES_GUBUN = 'G' THEN '아가바른손'
								WHEN A.SALES_GUBUN = 'B' THEN '바른손몰(B)'
								WHEN A.SALES_GUBUN = 'C' THEN '바른손몰(C)'
								WHEN A.SALES_GUBUN = 'H' THEN '바른손몰(H)'
						END AS COMPANY_NAME
						
					,	CASE 
							WHEN A.SALES_GUBUN = 'SB' THEN '1644-0708'	--'바른손카드'
							WHEN A.SALES_GUBUN = 'SA' THEN '1644-9713'	--'비핸즈카드'
							WHEN A.SALES_GUBUN = 'ST' THEN '1644-0708'	--'더카드'
							WHEN A.SALES_GUBUN = 'SS' THEN '1644-8796'	--'프리미어페이퍼'
							WHEN A.SALES_GUBUN = 'G' THEN '1644-0708'	--'아가바른손'
							WHEN A.SALES_GUBUN = 'B' THEN '1644-7413'	--'바른손몰(B)'
							WHEN A.SALES_GUBUN = 'C' THEN '1644-7413'	--'바른손몰(C)'
							WHEN A.SALES_GUBUN = 'H' THEN '1644-7413'	--'바른손몰(H)'
						END AS SMS_PHONE
						
					,	A.ORDER_HPHONE
					,   A.SALES_GUBUN
				FROM	
				(
					SELECT
						-- 주문일이 휴일이라면 가장 가까운 평일 오전 9시로 주문일을 변경합니다.
                	    (SELECT TOP 1 confirm_date FROM dbo.FN_GET_ConfirmDate_holiday(A.SRC_MODREQUEST_DATE)) AS new_SRC_MODREQUEST_DATE
						, A.ORDER_HPHONE
						, A.SALES_GUBUN
						, A.card_seq
					FROM
						CUSTOM_ORDER A
					WHERE	A.ORDER_SEQ = @ORDER_SEQ  
				) A								
			) A
	)b

	SELECT @date = GETDATE()

	IF @date >= '2021-02-10 14:00:00' and @date <= '2021-02-15 08:00:00'
		begin
			SET @TARGET_DT = '2021-02-15'
		end;

	IF @SMS_NEW_MSG <> ''
		IF @SALES_GUBUN = 'SA' or @SALES_GUBUN = 'SB' or @SALES_GUBUN = 'ST' or @SALES_GUBUN = 'SS' or @SALES_GUBUN = 'B'
		  BEGIN
			EXEC SP_EXEC_BIZTALK_SEND @ORDER_HPHONE, 'sp_ChoanMod_SMS', @SALES_GUBUN,@ORDER_SEQ, '초안수정접수완료','',@TARGET_DT
		  END 
		ELSE
		  BEGIN
			EXEC INVTMNG.SP_DACOMSMS @ORDER_HPHONE,@SMS_PHONE,@SMS_NEW_MSG
		  END 
END
GO
