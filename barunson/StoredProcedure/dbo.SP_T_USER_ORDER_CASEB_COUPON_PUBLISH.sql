IF OBJECT_ID (N'dbo.SP_T_USER_ORDER_CASEB_COUPON_PUBLISH', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_USER_ORDER_CASEB_COUPON_PUBLISH
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_USER_ORDER_CASEB_COUPON_PUBLISH]   
/***************************************************************  
작성자 : 표수현  
작성일 : 2021-09-17  
DESCRIPTION : 기존 바비더프몰 회원한테 쿠폰 쏘기 
			1. 종이청첩 컨펌 / 결제 완료 이후 진행중인 모든 건들 해당
			2. 모바일 청첩장 미제작
			3. 예식일이 21.9.27일 이후인것들만 해당
			4. 자동발행으로 설정된 쿠폰중에서 할인율 30%짜리 쿠폰만 해당 
******************************************************************  
MODIFICATION  
******************************************************************  
수정일           작업자                DESCRIPTION  
==================================================================  
******************************************************************/  
AS    

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
	
 CREATE TABLE #WEDDING_LIST
 (
	ORDER_SEQ INT,
	WEDDING_DAY VARCHAR(20),
	MEMBER_ID VARCHAR(100)
 )

 -- 쿠폰 발송할 회원ID리스트 
 INSERT	#WEDDING_LIST
 SELECT MIN(ORDER_SEQ), 
		MAX(WEDDING_DAY), 
		MEMBER_ID
 FROM (
		SELECT A.ORDER_SEQ, A.MEMBER_ID , 
			   WEDDING_DAY = B.EVENT_YEAR + '-' +  (
														CASE WHEN LEN(B.EVENT_MONTH) = 1 AND  
																DATALENGTH(B.EVENT_MONTH) = 1 THEN  '0' + B.EVENT_MONTH
														ELSE B.EVENT_MONTH
														END 
													) + '-' + 
													(
														CASE WHEN LEN(B.EVENT_DAY) = 1 AND  
																DATALENGTH(B.EVENT_DAY) = 1 THEN  '0' + B.EVENT_DAY
														ELSE B.EVENT_DAY
														END 
													), 
				MCARD_INVITATION_CNT = (SELECT COUNT(1) FROM BAR_SHOP1.DBO.MCARD_INVITATION WHERE AUTHCODE = A.MEMBER_ID)
		FROM	BAR_SHOP1.DBO.CUSTOM_ORDER A INNER JOIN 
				BAR_SHOP1.DBO.CUSTOM_ORDER_WEDDINFO B ON A.ORDER_SEQ = B.ORDER_SEQ
		WHERE	A.STATUS_SEQ >= 9 AND	-- 초안컨펌완료 이후
				A.SETTLE_STATUS = 2 AND -- 결제완료 이후 
				A.SALES_GUBUN <> 'SD' AND -- 디디제외
				A.MEMBER_ID <> '' AND 
				A.MEMBER_ID IS NOT NULL AND
				A.PAY_TYPE <> '4' AND --  사고건 제외
				A.ORDER_TYPE IN ('1','6','7')  -- 청첩장주문건
		) TB
 WHERE	CONVERT(VARCHAR(10), TB.WEDDING_DAY, 120)  >= '2021-09-27' AND -- 예식일이 21년 9월 27일 이후
		ISDATE(TB.WEDDING_DAY) = 1 AND  
		TB.MCARD_INVITATION_CNT = 0 AND -- 모바일 청첩장 미제작
		TB.MEMBER_ID NOT IN (SELECT MEMBER_ID FROM BARUNSON.DBO.TB_CASEB_COUPON_PUBLISHED) -- ID로 중복발송 체크
 GROUP BY MEMBER_ID


 
				
 -- 발송할 회원이 존재
 IF EXISTS (SELECT COUNT(1) FROM #WEDDING_LIST) BEGIN 
		
		--1. 발송할 쿠폰 정보(헐인율 30%인 자동발행 쿠폰만)
		SELECT * INTO #COUPON
		FROM (
				SELECT	A.COUPON_ID ,
						만료일 = CASE A.PERIOD_METHOD_CODE 
									WHEN 'PMC01' THEN CONVERT(VARCHAR(10), A.PUBLISH_END_DATE , 120) -- 날짜 지정 
									WHEN 'PMC02' THEN 
									(
										-- 발행일로부터
										SELECT CONVERT(VARCHAR(10), DATEADD(DD, CONVERT(INT,CODE_NAME), GETDATE()) , 120) 
										FROM TB_COMMON_CODE 
										WHERE CODE_GROUP = 'PUBLISH_PERIOD_CODE' AND
												CODE = A.PUBLISH_PERIOD_CODE 

									)
								--ELSE '무제한' 
								END 
							--A.PERIOD_METHOD_CODE,
							--A.PUBLISH_PERIOD_CODE
					FROM BARUNSON.DBO.TB_COUPON A INNER JOIN 
						 BARUNSON.DBO.TB_COMMON_CODE B ON A.PUBLISH_METHOD_CODE = B.CODE  INNER JOIN 
						 BARUNSON.DBO.TB_COMMON_CODE C ON A.PUBLISH_TARGET_CODE = C.CODE  INNER JOIN 
						 BARUNSON.DBO.TB_COMMON_CODE D ON A.DISCOUNT_METHOD_CODE = D.CODE 
					WHERE B.CODE_GROUP = 'PUBLISH_METHOD_CODE' AND 
						  A.PUBLISH_METHOD_CODE = 'PMC01' AND -- 자동발행
						  C.CODE_GROUP = 'PUBLISH_TARGET_CODE'  AND 
						  A.PUBLISH_TARGET_CODE = 'PTC01' AND  -- 청첩장 결제완료 + 고객 컨펌 완료 
						  D.CODE_GROUP = 'DISCOUNT_METHOD_CODE' AND
						  A.DISCOUNT_METHOD_CODE = 'DMC03'  -- 전액할인
						 
			) TB 

		-- 2. 자동발행으로 설정된 쿠폰중에서 할인율 30%짜리 쿠폰이 존재하면

		IF EXISTS (SELECT COUNT(1) FROM #COUPON) BEGIN 
					
			-- TB_CASEA_COUPON_PUBLISHED에 ID저장 (임시 저장용)

			INSERT BARUNSON.DBO.TB_CASEB_COUPON_PUBLISHED (ORDER_ID, MEMBER_ID, REG_DATE)
			SELECT ORDER_SEQ, MEMBER_ID, GETDATE() FROM #WEDDING_LIST

			--BEGIN TRAN 
			-- 쿠폰 발급
			INSERT BARUNSON.DBO.TB_COUPON_PUBLISH (COUPON_ID, USER_ID, USE_YN ,USE_DATETIME, EXPIRATION_DATE, 
									  RETRIEVE_DATETIME ,REGIST_USER_ID, REGIST_DATETIME, REGIST_IP,
									  UPDATE_USER_ID ,UPDATE_DATETIME, UPDATE_IP)
			SELECT A.COUPON_ID, B.MEMBER_ID, 'N', NULL, A.만료일, 
					NULL, B.MEMBER_ID, GETDATE(), '', B.MEMBER_ID, GETDATE(), ''
			FROM  #COUPON A CROSS JOIN  -- 아 크로스조인 쓰기 싫은데 떠오러는 방법이 없네..
				  #WEDDING_LIST B

			--ROLLBACK 

		END 
 END 


GO
