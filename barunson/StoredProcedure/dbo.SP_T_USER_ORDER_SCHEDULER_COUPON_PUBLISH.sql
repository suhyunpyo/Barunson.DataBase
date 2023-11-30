IF OBJECT_ID (N'dbo.SP_T_USER_ORDER_SCHEDULER_COUPON_PUBLISH', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_USER_ORDER_SCHEDULER_COUPON_PUBLISH
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_USER_ORDER_SCHEDULER_COUPON_PUBLISH]   
/***************************************************************  
작성자 : 표수현  
작성일 : 2020-02-15  
DESCRIPTION : 스케쥴러 실행(바비더프몰 결제완료 / 초안컨펌완료 주문건에 한해서 쿠폰 발급
SPECIAL LOGIC : SP_T_USER_ORDER_AUTO_COUPON_PUBLISH 'M2108190002' 
자동 발급 설정된 쿠폰들의 만료일을 계산해서 TB_COUPON_PUBLISH에 각각 저장 

declare @time datetime

	select @time =  event_year + '-' +  event_month + '-' + event_day + '  ' + 
		(
		CONVERT(NVARCHAR(10), case event_ampm when '오후' then  CONVERT(INT,event_hour + 12)
						 else event_hour end)
		)-- + '00:00' --+ 
		-- + ':00:00'
		+ 

	(case event_minute when  '' then  ':00:'
	else ':' + event_hour + ':' end
	)
	+ '00'

	
	from custom_order_WeddInfo  where order_seq  = 4036549 



	select @time

	if @time > getdate() begin select 'fdf' end 

******************************************************************  
MODIFICATION  
******************************************************************  
수정일           작업자                DESCRIPTION  
==================================================================  
******************************************************************/  
AS    

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
	
	--drop table #Wedding_List

	--return

 CREATE TABLE #WEDDING_LIST
 (
	ORDER_SEQ INT,
	WEDDING_DAY VARCHAR(20),
	MEMBER_ID VARCHAR(100)
 )

 -- 쿠폰 발송할 회원ID리스트 
 INSERT	#WEDDING_LIST
 SELECT 
	MIN(TB.ORDER_SEQ) ORDER_SEQ , 
	MAX(TB.WEDDING_DAY) WEDDING_DAY, 
	TB.MEMBER_ID
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
													) 

		FROM	BAR_SHOP1.DBO.CUSTOM_ORDER A with(nolock) INNER JOIN 
				BAR_SHOP1.DBO.CUSTOM_ORDER_WEDDINFO B with(nolock) ON A.ORDER_SEQ = B.ORDER_SEQ
		WHERE	A.STATUS_SEQ >= 9 AND --초안컨펌완료
				A.SETTLE_STATUS = 2 AND --결제완료
				A.SALES_GUBUN <> 'SD' AND -- 디디제외
				A.PAY_TYPE <> '4' AND --  사고건 제외
				A.ORDER_TYPE IN ('1','6','7') AND  -- 청첩장주문건
				A.SRC_CONFIRM_DATE <= CONVERT(VARCHAR(10), GETDATE() + 1, 120) AND -- 초안컨펌완료일이 현재보다 큰거 
				A.SRC_CONFIRM_DATE >= '2021-09-27 13:55:00' and -- 오픈시간 이후
				A.MEMBER_ID <> '' AND 
				A.MEMBER_ID IS NOT NULL
	) TB
	LEFT JOIN (SELECT MEMBER_ID FROM TB_SCHEDULER_COUPON_PUBLISHED with(nolock) union SELECT MEMBER_ID FROM BARUNSON.DBO.TB_CASEB_COUPON_PUBLISHED with(nolock) ) AS B
		ON TB.member_id = B.Member_ID
 WHERE	TB.WEDDING_DAY >= CONVERT(VARCHAR(10), GETDATE(), 120) AND
		ISDATE(TB.WEDDING_DAY) = 1 AND  
		B.MEMBER_ID IS NULL
 GROUP BY TB.MEMBER_ID
				
 -- 발송할 회원이 존재
 IF EXISTS (SELECT COUNT(1) FROM #WEDDING_LIST) BEGIN 
		
		--1. 발송할 쿠폰 정보 (조건은 추후 수정해야됨)
		
		SELECT * INTO #COUPON
		FROM (
				SELECT	A.COUPON_ID ,
						만료일 = CASE A.PERIOD_METHOD_CODE 
									WHEN 'PMC01' THEN CONVERT(VARCHAR(10), A.PUBLISH_END_DATE , 120) -- 날짜 지정 
									WHEN 'PMC02' THEN 
									(
										-- 발행일로부터
										SELECT CONVERT(VARCHAR(10), DATEADD(DD, CONVERT(INT,CODE_NAME), GETDATE()) , 120) 
										FROM TB_COMMON_CODE with(nolock)
										WHERE CODE_GROUP = 'PUBLISH_PERIOD_CODE' AND
												CODE = A.PUBLISH_PERIOD_CODE 

									)
								--ELSE '무제한' 
								END 
							--A.PERIOD_METHOD_CODE,
							--A.PUBLISH_PERIOD_CODE
					FROM TB_COUPON A with(nolock) INNER JOIN 
						 TB_COMMON_CODE B with(nolock) ON A.PUBLISH_METHOD_CODE = B.CODE  INNER JOIN 
						 TB_COMMON_CODE C with(nolock) ON A.PUBLISH_TARGET_CODE = C.CODE
					WHERE B.CODE_GROUP = 'PUBLISH_METHOD_CODE' AND 
						  A.PUBLISH_METHOD_CODE = 'PMC01' AND -- 자동발행
						  C.CODE_GROUP = 'PUBLISH_TARGET_CODE'  AND 
						  A.PUBLISH_TARGET_CODE = 'PTC01' -- 청첩장 결제완료 + 고객 컨펌 완료 
			) TB 

		-- 2. 자동발급설정된 쿠폰이 존재
		IF EXISTS (SELECT COUNT(1) FROM #COUPON) BEGIN 
				
					
			-- TB_SCHEDULER_COUPON_PUBLISHED에 ID저장 

			INSERT TB_SCHEDULER_COUPON_PUBLISHED (ORDER_ID, MEMBER_ID, REG_DATE)
			SELECT ORDER_SEQ, MEMBER_ID, GETDATE() FROM #WEDDING_LIST

			--BEGIN TRAN 
			-- 쿠폰 발급
			INSERT TB_COUPON_PUBLISH (COUPON_ID, USER_ID, USE_YN ,USE_DATETIME, EXPIRATION_DATE, 
			--INSERT TB_COUPON_PUBLISH_TEST (COUPON_ID, USER_ID, USE_YN ,USE_DATETIME, EXPIRATION_DATE, 
										RETRIEVE_DATETIME ,REGIST_USER_ID, REGIST_DATETIME, REGIST_IP,
										UPDATE_USER_ID ,UPDATE_DATETIME, UPDATE_IP)
			SELECT A.COUPON_ID, B.MEMBER_ID, 'N', NULL, A.만료일, 
					NULL, B.MEMBER_ID, GETDATE(), '', B.MEMBER_ID, GETDATE(), ''
			FROM  #COUPON A CROSS JOIN 
					#WEDDING_LIST B

			--ROLLBACK 

		END 
 END 

 
 --IF EXISTS (
	--		SELECT 1
	--		FROM	BAR_SHOP1.DBO.CUSTOM_ORDER A  INNER JOIN 
	--				BAR_SHOP1.DBO.CUSTOM_ORDER_WEDDINFO B ON A.ORDER_SEQ = B.ORDER_SEQ
	--		WHERE	A.ORDER_SEQ =  @ORDER_ID AND 
	--				A.STATUS_SEQ > 9 AND --초안컨펌완료
	--				A.SETTLE_STATUS = 2 AND --결제완료
	--				-- 예식일이 현재날짜보다 큰거
	--				B.EVENT_YEAR + '-' +  B.EVENT_MONTH + '-' + B.EVENT_DAY >= CONVERT(VARCHAR(10), GETDATE(), 120)

	--				--CONVERT(CHAR(19),
	--				--					B.EVENT_YEAR + '-' +  B.EVENT_MONTH + '-' + B.EVENT_DAY + '  ' + 
	--				--					(
	--				--						CONVERT(NVARCHAR(10),  CASE B.EVENT_AMPM WHEN '오후' THEN  
	--				--													CONVERT(INT,EVENT_HOUR + 12)
	--				--												ELSE EVENT_HOUR END
	--				--								)
	--				--					) 
	--				--					+ 
	--				--					(
	--				--						CASE EVENT_MINUTE WHEN  '' THEN  ':00:'
	--				--						ELSE ':' + EVENT_HOUR + ':' END
	--				--					)
	--				--					+ '00' ,
	--				--    120) >= GETDATE()

	--		)  
	--		--AND NOT EXISTS(
					
	--		--		SELECT 1 
	--		--		FROM BARUNSON.DBO.TB_SCHEDULER_COUPON_PUBLISHED
	--		--		WHERE ORDER_ID = @ORDER_ID

	--		--				)
	--				BEGIN 
				
	--					 --DROP TABLE #TEMP
	--					 SELECT * INTO #TEMP
	--					 FROM (
	--							SELECT	A.COUPON_ID ,
	--									만료일 = CASE A.PERIOD_METHOD_CODE 
	--												WHEN 'PMC01' THEN CONVERT(VARCHAR(10), A.PUBLISH_END_DATE , 120) -- 날짜 지정 
	--												WHEN 'PMC02' THEN 
	--												(
	--													-- 발행일로부터
	--													SELECT CONVERT(VARCHAR(10), DATEADD(DD, CONVERT(INT,CODE_NAME), GETDATE()) , 120) 
	--													FROM TB_COMMON_CODE 
	--													WHERE CODE_GROUP = 'PUBLISH_PERIOD_CODE' AND
	--														  CODE = A.PUBLISH_PERIOD_CODE 

	--												)
	--											--ELSE '무제한' 
	--											END 
	--									--A.PERIOD_METHOD_CODE,
	--									--A.PUBLISH_PERIOD_CODE
	--							FROM TB_COUPON A INNER JOIN  TB_COMMON_CODE B ON A.PUBLISH_METHOD_CODE = B.CODE
	--							WHERE B.CODE_GROUP = 'PUBLISH_METHOD_CODE' AND A.PUBLISH_METHOD_CODE = 'PMC01'
	--						 ) TEMP

	--					--SELECT COUPON_ID, @USER_ID, 'N', NULL, 만료일, NULL, @USER_ID, GETDATE(), '',@USER_ID, GETDATE(), ''
	--					 --FROM #TEMP

	--					-- 자동발급설정된 쿠폰이 존재하고, 결제완료 상태일때 
	--					IF EXISTS (SELECT COUPON_ID FROM #TEMP) BEGIN 
		
	--						DECLARE  @USER_ID  VARCHAR(50)
	--						SELECT @USER_ID = MEMBER_ID
	--						FROM BAR_SHOP1.DBO.CUSTOM_ORDER --INNER JOIN VW_USER B ON A.MEMBER_ID = B.USER_ID
	--						WHERE ORDER_SEQ =  @ORDER_ID

	--						--BEGIN TRAN 
		
	--						INSERT TB_COUPON_PUBLISH (COUPON_ID, USER_ID, USE_YN ,USE_DATETIME, EXPIRATION_DATE, RETRIEVE_DATETIME ,REGIST_USER_ID, REGIST_DATETIME, REGIST_IP,
	--													UPDATE_USER_ID ,UPDATE_DATETIME, UPDATE_IP)
	--						SELECT COUPON_ID, @USER_ID, 'N', NULL, 만료일, NULL, @USER_ID, GETDATE(), '', @USER_ID, GETDATE(), ''
	--						FROM #TEMP


	--						--SELECT * FROM TB_COUPON_PUBLISH

	--						--ROLLBACK 


	--					END 



	--				END 

GO
