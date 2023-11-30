IF OBJECT_ID (N'dbo.SP_EXEC_SMS_SEND_FOR_SAMPLE_BABITHE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_SMS_SEND_FOR_SAMPLE_BABITHE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*    
 SELECT    
  '2016-03-09 10:10:00' AS SEND_DATE    
  , A.HP AS HPHONE    
  , A.UID AS UID    
    
 FROM        
 ( SELECT '010-4531-8283' AS HP, 's4guest' AS uid UNION    
  SELECT '010-5692-2210' AS HP, 'rlawlsdud25' as uid    
 ) A     
    
 2017.12.28 샘플 발송 4일 후로 조정.   

 --2018.01.04수정
	-- 1. 토,일요일은 배치X  : 월~금까지만(영업일기준 4일이면 토=일 토=월이기때문)
	-- 2. 화수목금일때 전날이 공휴일일때 배치X
	-- 3. 월요일일때는 금욜일이 휴무이면 배치X
	-- 4. 2018.01.03기준으로 휴일은 http://cs.barunsoncard.com/callback/cms_manager.asp (시즌2관리자-보고서>콜센타-휴일관리) 관리되는 날짜기준.(단축근무일도 휴일로 간주함. 김희경 과장님)
	-- 5. 발송제외건기준(2018.01.04추가요청) : 샘플주문발송일기준 평일5일전부터 오늘2시 이전까지 청첩장 주문건이 존재하는 고객 
 

 2018-04-04 비핸즈 제외
*/    
CREATE PROCEDURE [dbo].[SP_EXEC_SMS_SEND_FOR_SAMPLE_BABITHE]    
    
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
    
	SET @TIME			= ' 14:00:00';
	SET @CURRENT_DAY	= CONVERT(VARCHAR(10), GETDATE(), 120);
	--SET @CURRENT_DAY	='2018-01-05';

	--오늘 전날이 휴무인지
	SELECT @CURRENT_PRE_HOLIDAYS = COUNT(*) FROM HOLIDAYS WHERE YDATE = CONVERT(VARCHAR(10), CONVERT(DATETIME , @CURRENT_DAY)-1, 112)

	--금요일이 지정휴무인지:월요일에 사용
	SELECT @CURRENT_PRE_SAT_HOLIDAYS = COUNT(*) FROM HOLIDAYS WHERE YDATE = CONVERT(VARCHAR(10), CONVERT(DATETIME , @CURRENT_DAY)-3, 112)
    
	IF GETDATE() < '2099-12-31 00:00:00' AND 
		(DATEPART(DW ,  CONVERT(DATETIME , @CURRENT_DAY)) <> '1' or DATEPART(DW ,  CONVERT(DATETIME , @CURRENT_DAY)) <> '7') AND
		 ( (@CURRENT_PRE_HOLIDAYS = 0	 AND  DATEPART(DW ,  CONVERT(DATETIME , @CURRENT_DAY)) >=3 AND DATEPART(DW ,  CONVERT(DATETIME , @CURRENT_DAY)) <= 6 ) OR (DATEPART(DW ,  CONVERT(DATETIME , @CURRENT_DAY)) = 2  
		 AND @CURRENT_PRE_SAT_HOLIDAYS = 0))
		   
	BEGIN    

		SELECT @DELIVERY_DT = DBO.FN_GET_DATE(@CURRENT_DAY , 4);	--문자발송 해당 배송일자
		SELECT @ORDER_DT	= DBO.FN_GET_DATE(@DELIVERY_DT , 5);	--주문건 검색일자

		IF @DELIVERY_DT IS NOT NULL AND @ORDER_DT IS NOT NULL
		BEGIN

			--print '2-@DELIVERY_DT=' + @DELIVERY_DT + ' , ' + '@ORDER_DT=' + @ORDER_DT;

			--커서를 이용하여 해당되는 고객정보를 얻는다.    
			DECLARE cur_AutoInsert_For_babithe CURSOR FAST_FORWARD    
			FOR    
				SELECT    
						CONVERT(VARCHAR(10), GETDATE(), 120) + @TIME AS SEND_DATE    
						, VUI.HPHONE    
						, VUI.UID    
						, ( SELECT COUNT(*) FROM CUSTOM_ORDER     
							WHERE MEMBER_ID = VUI.UID AND sales_Gubun IN ('ST','SB','SA', 'SS') AND STATUS_SEQ >= 1    
							AND ORDER_TYPE IN (1, 6, 7)  
							AND ORDER_DATE >= CONVERT(DATETIME , @ORDER_DT)
							AND ORDER_DATE < CONVERT(DATETIME , CONVERT(VARCHAR(10), GETDATE(), 120) + ' 14:00:00' )
							) AS ORDER_CNT    
						, CSO.SALES_GUBUN    
						, VUI.UNAME  
				FROM    CUSTOM_SAMPLE_ORDER CSO   JOIN    VW_USER_INFO VUI ON CSO.MEMBER_ID = VUI.UID AND CSO.SALES_GUBUN = VUI.SITE_DIV       
				WHERE   CSO.SALES_GUBUN = 'ST'
				AND     CSO.DELIVERY_DATE >= CONVERT(DATETIME , @DELIVERY_DT)
				AND     CSO.DELIVERY_DATE <  CONVERT(DATETIME , @DELIVERY_DT) + 1 
				AND     VUI.CHK_SMS = 'Y'    
				AND     CSO.SETTLE_PRICE = 0     
				AND		CSO.MEMBER_ID <> 'thesnssample'        
    
				OPEN cur_AutoInsert_For_babithe    
    
					DECLARE @MMS_DATE VARCHAR(100)    
					DECLARE @HAND_PHONE VARCHAR(100)    
					DECLARE @USER_ID VARCHAR(100)    
					DECLARE @USER_NAME VARCHAR(100)    
					DECLARE @SALES_GUBUN VARCHAR(100)    
					DECLARE @ORDER_CNT INT    
					DECLARE @COMPANY_SEQ INT    
					DECLARE @END_DT VARCHAR(10)    
					DECLARE @COUPON_CODE VARCHAR(40)    
     
					SET @END_DT = CONVERT(VARCHAR(10), GETDATE()+14, 120); --어디서 사용함?
   
					FETCH NEXT FROM cur_AutoInsert_For_babithe INTO @MMS_DATE, @HAND_PHONE, @USER_ID, @ORDER_CNT, @SALES_GUBUN, @USER_NAME    
    
					WHILE @@FETCH_STATUS = 0 
					BEGIN    
      
						IF @ORDER_CNT = 0  -- 주문건이 없는 고객만    
						BEGIN    
    
							IF @SALES_GUBUN = 'ST'  --더카드    
								BEGIN    
									SET @COMPANY_SEQ = 5007;    
									SET @TITLE = '[더카드] 샘플신청 고객 혜택안내';    
									SET @CALL_NUMBER = '1644-7998';    
									SET @MSG = '[더카드] 샘플! 마음에 드셨나요? 딱 7일간 사용 가능한 1만원 시크릿 쿠폰발급완료!'  

									--쿠폰 발송  
									SET @COUPON_CODE = 'AAF9-4AD9-484F-A497'    
									EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, @SALES_GUBUN, @USER_ID, @COUPON_CODE

								END    
							ELSE IF @SALES_GUBUN = 'SA'   --비핸즈    
								BEGIN    
									SET @COMPANY_SEQ = 5006    
									SET @TITLE = '[비핸즈카드] 샘플신청 고객 혜택안내';    
									SET @CALL_NUMBER = '1644-9713';         
									SET @MSG = '보내드린 샘플은 잘 받아보셨나요? 샘플후기 남기고 3만원쿠폰 받아가세요~[비핸즈카드]'    
    
								END    
                            /*
                                2018-03-21
                                바른손카드 사용 안함.
                                별도의 SP를 사용 (SP_EXEC_SMS_SEND_FOR_SAMPLE_BARUNSONCARD_SAMPLE_DM)
                            */
							--ELSE    -- 바른손    
							--	BEGIN    
							--		SET @COMPANY_SEQ = 5001     
							--		SET @TITLE = '[바른손카드] 쿠폰이 발송되었습니다.';    
							--		SET @CALL_NUMBER = '1644-0708';         
							--		SET @MSG = @USER_NAME + '님. 고민하며 선택하신' + CHAR(10)+ '청첩장 샘플은 마음에 드시나요? '   
							--				+ CHAR(10) + CHAR(10) + '두분에게 꼬~옥 맞는 청첩장을' + CHAR(10)+ '선택하셨으면 좋겠어요. '   
							--				+ CHAR(10) + CHAR(10) + '주문할 때 더 기분좋아지는' + CHAR(10)+ '#바른손카드 #시크릿쿠폰' + CHAR(10) + '두분께만 시크릿이예요!'  
							--				+ CHAR(10) + CHAR(10) + '※ 쿠폰발송일 포함 ' + CHAR(10)+ ' 10일 이내 사용가능'   
							--				+ CHAR(10) + CHAR(10) + '내 쿠폰 확인하기 ▶' + CHAR(10)+ 'http://m.barunsoncard.com/mypage/coupon/coupon_list.asp'   

							--		--쿠폰 발송  
							--		SET @COUPON_CODE = '7288-61CE-4931-B592'    
							--		EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, @SALES_GUBUN, @USER_ID, @COUPON_CODE
							--	END  
  
							--MMS 발송    
							EXEC SP_EXEC_SMS_OR_MMS_SEND @CALL_NUMBER, @HAND_PHONE, @TITLE, @MSG, @SALES_GUBUN, '샘플후기SMS', '', @MMS_DATE, 0, ''    
    
						END    
    
						FETCH NEXT FROM cur_AutoInsert_For_babithe INTO @MMS_DATE, @HAND_PHONE, @USER_ID, @ORDER_CNT, @SALES_GUBUN  , @USER_NAME    
					END    
    
				CLOSE cur_AutoInsert_For_babithe    
			DEALLOCATE cur_AutoInsert_For_babithe    
		END    
	END        
END 
GO
