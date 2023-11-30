IF OBJECT_ID (N'dbo.SP_EXEC_SMS_SEND_FOR_EVENT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_SMS_SEND_FOR_EVENT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*    
	[더카드용 이벤트 쿠폰지급]
	요청일 : 2018.01.12

	기간> 1월 12일~3월 2일 까지 

	조건> 
	- 더카드 회원 / 샘플 발송 후 14일 이내 
	- 더카드 및 바른컴퍼니 브랜드 (바/비/프)주문 및 결제내역이 없는 고객
	- 예식일 5월 31 이내 고객 

	매주 금요일 쿠폰 발급 후 문자발송  
	-회원 id당 1회만 발송/ 중복발송 금지 .

	쿠폰 발급 : 매주 4시 
	문자 발송 : 매주 4시 30분

	특이사항 >> 
	김지선 : 010-9592-0421 참조해주세요 
*/    
CREATE PROCEDURE [dbo].[SP_EXEC_SMS_SEND_FOR_EVENT]    
    
AS    
BEGIN    
    
	DECLARE @TIME						AS VARCHAR(10)    
	DECLARE @MSG						AS VARCHAR(4000)    
	DECLARE @TITLE						AS VARCHAR(200)    
	DECLARE @CALL_NUMBER				AS VARCHAR(50)    
	DECLARE @CURRENT_DAY				AS VARCHAR(10);		--오늘날짜(2017-12-28형식)
	DECLARE @CURRENT_PRE_HOLIDAYS		AS INT = 0;			--오늘전날의 지정휴일여부
	DECLARE @CURRENT_PRE_SAT_HOLIDAYS	AS INT = 0;			--토요일의 지정휴일여부(오늘이 월요일일때 사용)
	DECLARE @DELIVERY_DT				AS VARCHAR(10);		--배송완료기준 확정일자
	DECLARE @ORDER_DT					AS VARCHAR(10);		--주문건 검색일자
	DECLARE @USE_START_DT				AS VARCHAR(10);		--사용시작일
	DECLARE @USE_END_DT					AS VARCHAR(10);		--사용종료일
	
    
	IF GETDATE() >= '2018-01-12 00:00:00' AND GETDATE() < '2018-03-03 00:00:00' AND DATEPART(DW ,  GETDATE()) = 6
	BEGIN    

		
		SELECT @USE_START_DT = CONVERT(VARCHAR(10) ,datepart(MM , GETDATE())) + '월'+ CONVERT(VARCHAR(10) ,datepart(DD , GETDATE())) + '일'
		SELECT @USE_END_DT = CONVERT(VARCHAR(10) ,datepart(MM , GETDATE()+2)) + '월'+ CONVERT(VARCHAR(10) ,datepart(DD , GETDATE()+2)) + '일'
		
		--커서를 이용하여 해당되는 고객정보를 얻는다.    
		DECLARE cur_AutoInsert_For_babithe CURSOR FAST_FORWARD   
		FOR

			SELECT *
			FROM (
					SELECT    
							CONVERT(VARCHAR(10), GETDATE(), 120) + ' 16:30:00' AS SEND_DATE    
							, VUI.HPHONE    
							, VUI.UID    
							, ( SELECT COUNT(*) 
								FROM CUSTOM_ORDER     
								WHERE MEMBER_ID = VUI.UID 
								AND sales_Gubun IN ('ST','SB','SA','SS','B','C') 
								AND STATUS_SEQ >= 1    
								AND ORDER_TYPE IN (1, 6, 7)  
								--AND ORDER_DATE >= CONVERT(DATETIME , CONVERT(VARCHAR(10), GETDATE() - 14, 120))
								--AND ORDER_DATE < CONVERT(DATETIME , CONVERT(VARCHAR(10), GETDATE() , 120))
								) AS ORDER_CNT  
							, VUI.UNAME  
							, (SELECT COUNT(*) FROM COUPON_ISSUE WHERE UID = CSO.MEMBER_ID AND COUPON_DETAIL_SEQ=57184)  COUPON_ISSUE_CNT
					FROM    CUSTOM_SAMPLE_ORDER CSO   JOIN    VW_USER_INFO VUI ON CSO.MEMBER_ID = VUI.UID AND CSO.SALES_GUBUN = VUI.SITE_DIV       
					WHERE   CSO.SALES_GUBUN = 'ST'
					AND     CSO.DELIVERY_DATE >= CONVERT(DATETIME , CONVERT(VARCHAR(10), GETDATE() - 14, 120))
					AND     CSO.DELIVERY_DATE <  CONVERT(DATETIME , CONVERT(VARCHAR(10), GETDATE() , 120)) 
					AND     VUI.CHK_SMS = 'Y'    
					AND     CSO.SETTLE_PRICE = 0     
					AND		CSO.MEMBER_ID <> 'thesnssample' 
					AND     VUI.WEDDING_DAY <= '2018-05-31'
				) A
			WHERE A.ORDER_CNT = 0
			AND A.COUPON_ISSUE_CNT = 0
			--UNION ALL
			--SELECT CONVERT(VARCHAR(10), GETDATE(), 120) + ' 16:30:00' AS SEND_DATE   ,'010-9592-0421' HPHONE,'s4guest' UID,0 ORDER_CNT,'김지선' UNAME , 0 COUPON_ISSUE_CNT
			--UNION ALL
			--SELECT CONVERT(VARCHAR(10), GETDATE(), 120) + ' 16:30:00' AS SEND_DATE   ,'010-2816-6353' HPHONE,'s4guest' UID,0 ORDER_CNT,'테스트' UNAME

			--SELECT CONVERT(VARCHAR(10), GETDATE(), 120) + ' 16:30:00' AS SEND_DATE   
			--		,'010-9592-0421' HPHONE
			--		,'s4guest' UID
			--		,0 ORDER_CNT
			--		,'테스트' UNAME

			OPEN cur_AutoInsert_For_babithe    
    
					DECLARE @MMS_DATE VARCHAR(100)    
					DECLARE @HAND_PHONE VARCHAR(100)    
					DECLARE @USER_ID VARCHAR(100)    
					DECLARE @USER_NAME VARCHAR(100)   
					DECLARE @ORDER_CNT INT    
					DECLARE @COMPANY_SEQ INT    
					DECLARE @END_DT VARCHAR(10)    
					DECLARE @COUPON_CODE VARCHAR(40) 

					FETCH NEXT FROM cur_AutoInsert_For_babithe INTO @MMS_DATE, @HAND_PHONE, @USER_ID, @ORDER_CNT, @USER_NAME    
    
					WHILE @@FETCH_STATUS = 0 
					BEGIN    

					IF @ORDER_CNT = 0  -- 주문건이 없는 고객만    
						BEGIN
							BEGIN    
								SET @COMPANY_SEQ = 5007     
								SET @TITLE = '[더카드] 쿠폰이 발송되었습니다.';    
								SET @CALL_NUMBER = '1644-7998';         
								SET @MSG = '더카드 샘플키트를 신청해주신 '+ @USER_NAME +'님! 더카드 MD 김지선입니다. '   
										+ CHAR(10) + CHAR(10) + '오늘도 결혼식 준비에 여념이 없으시죠? '   
										+ CHAR(10) + CHAR(10) + '고객님 힘드실까봐 더카드가 조금이나마 힘을 보태드릴게요'  
										+ CHAR(10) + CHAR(10) + '주말동안 사용할 수 있는 10%할인 쿠폰을 드립니다.' + CHAR(10) + CHAR(10)
										+ CHAR(10) + CHAR(10) + '[주말쿠폰 사용방법]'   
										+ CHAR(10) + CHAR(10) + '> 사용기간 : '+ @USE_START_DT +'~'+ @USE_END_DT +''   
										+ CHAR(10) + CHAR(10) + '> 청첩장 13만원 이상 구매시 (중복사용가능)'   
										+ CHAR(10) + CHAR(10) + '> 청첩장 주문 시 할인 쿠폰적용'   
										+ CHAR(10) + CHAR(10) + '♥ 쿠폰확인하기 m.thecard.co.kr'   
							END    
    
							--쿠폰 발송  
							SET @COUPON_CODE = '89EA-F0CF-4CCA-8267'    
							EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'ST', @USER_ID, @COUPON_CODE  
  
							--MMS 발송    
							EXEC SP_EXEC_SMS_OR_MMS_SEND @CALL_NUMBER, @HAND_PHONE, @TITLE, @MSG, 'ST', '주말깜짝쿠폰', '', @MMS_DATE, 0, ''    
						END    
    
						FETCH NEXT FROM cur_AutoInsert_For_babithe INTO @MMS_DATE, @HAND_PHONE, @USER_ID, @ORDER_CNT  , @USER_NAME    
					END    
    
				CLOSE cur_AutoInsert_For_babithe    
			DEALLOCATE cur_AutoInsert_For_babithe
		  
	END        
END    
GO
