IF OBJECT_ID (N'dbo.SP_T_USER_ORDER_AUTO_COUPON_PUBLISH', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_USER_ORDER_AUTO_COUPON_PUBLISH
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_USER_ORDER_AUTO_COUPON_PUBLISH]   
/***************************************************************  
작성자 : 표수현  
작성일 : 2020-02-15  
DESCRIPTION : 결제완료한 고객에게 쿠폰 자동 발급 
SPECIAL LOGIC : SP_T_USER_ORDER_AUTO_COUPON_PUBLISH 'M2108190002' 

자동 발급 설정된 쿠폰들의 만료일을 계산해서 TB_COUPON_PUBLISH에 각각 저장 
******************************************************************  
MODIFICATION  
******************************************************************  
수정일           작업자                DESCRIPTION  
==================================================================  
******************************************************************/  
 @ORDER_CODE VARCHAR(25)  
AS    
 
 DECLARE @PAYMENT_STATUS_CODE VARCHAR(10)

 SELECT @PAYMENT_STATUS_CODE = PAYMENT_STATUS_CODE
 FROM TB_ORDER
 WHERE ORDER_CODE = @ORDER_CODE

 --DROP TABLE #TEMP
 SELECT * INTO #TEMP
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
		FROM TB_COUPON A INNER JOIN  TB_COMMON_CODE B ON A.PUBLISH_METHOD_CODE = B.CODE
		WHERE B.CODE_GROUP = 'PUBLISH_METHOD_CODE' AND A.PUBLISH_METHOD_CODE = 'PMC01'
	 ) TEMP

--SELECT COUPON_ID, @USER_ID, 'N', NULL, 만료일, NULL, @USER_ID, GETDATE(), '',@USER_ID, GETDATE(), ''
 --FROM #TEMP

	-- 자동발급설정된 쿠폰이 존재하고, 결제완료 상태일때 
	IF EXISTS (SELECT COUPON_ID FROM #TEMP) AND 
	   @PAYMENT_STATUS_CODE = 'PSC02' BEGIN 
		
		DECLARE  @USER_ID  VARCHAR(50)
		SELECT @USER_ID = USER_ID
		FROM TB_ORDER 
		WHERE ORDER_CODE = @ORDER_CODE

		--BEGIN TRAN 
		
		INSERT TB_COUPON_PUBLISH (COUPON_ID, USER_ID, USE_YN ,USE_DATETIME, EXPIRATION_DATE, RETRIEVE_DATETIME ,REGIST_USER_ID, REGIST_DATETIME, REGIST_IP,
								  UPDATE_USER_ID ,UPDATE_DATETIME, UPDATE_IP)
		SELECT COUPON_ID, @USER_ID, 'N', NULL, 만료일, NULL, @USER_ID, GETDATE(), '', @USER_ID, GETDATE(), ''
		FROM #TEMP


		--SELECT * FROM TB_COUPON_PUBLISH

		--ROLLBACK 


	END 


GO
