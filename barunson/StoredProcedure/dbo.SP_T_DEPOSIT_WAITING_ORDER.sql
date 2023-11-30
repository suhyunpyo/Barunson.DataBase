IF OBJECT_ID (N'dbo.SP_T_DEPOSIT_WAITING_ORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_DEPOSIT_WAITING_ORDER
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_DEPOSIT_WAITING_ORDER]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	ADMIN - 메뉴 저장
SPECIAL LOGIC	: 무통장 결제 대기 상태에서 3일 이상 경과한 주문건을 일괄 입금대기 취소 처리 
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--DROP TABLE #무통장결재대기주문건

-- 입금대기 취소로 변경

-- REFUND 테이블에 삽입 

 SELECT * INTO #무통장결재대기주문건
 FROM 
	(
	 SELECT ORDER_ID = A.ORDER_ID,
			DEPOSIT_DEADLINE_DATETIME = A.DEPOSIT_DEADLINE_DATETIME
	 FROM	TB_ORDER A INNER JOIN 
			TB_COMMON_CODE  B ON A.PAYMENT_STATUS_CODE = B.CODE
	 WHERE	B.CODE_GROUP = 'PAYMENT_STATUS_CODE' 
			--AND A.ORDER_ID = 11305
			AND A.PAYMENT_STATUS_CODE = 'PSC04' -- 입금대기
			AND DATEDIFF(MI,GETDATE(),DEPOSIT_DEADLINE_DATETIME)  < 0
			
			--ORDER BY DEPOSIT_DEADLINE_DATETIME ASC
	) TB


	
 DECLARE @기한이지난_무통장결재대기건수 INT

 SELECT @기한이지난_무통장결재대기건수 = COUNT(1)
 FROM #무통장결재대기주문건
 
 IF @기한이지난_무통장결재대기건수 > 0 BEGIN 
 
	 -- 1. 입금대기 취소 상태로 일괄 변경
	 UPDATE TB_ORDER  
	 SET PAYMENT_STATUS_CODE = 'PSC05', --입금대기취소 
		 CANCEL_DATETIME = GETDATE()
	 WHERE ORDER_ID IN (SELECT ORDER_ID FROM #무통장결재대기주문건)

	 -- 2. REFUND 테이블에 입금대기취소 / 입금대기취소완료로 업데이트 
	 INSERT TB_REFUND_INFO(	ORDER_ID, REFUND_TYPE_CODE, REFUND_PRICE, BANK_TYPE_CODE, ACCOUNTNUMBER,
							REFUND_STATUS_CODE, DEPOSITOR_NAME, REFUND_CONTENT, REGIST_DATETIME,
							REFUND_DATETIME, REGIST_USER_ID, REGIST_IP, UPDATE_USER_ID, UPDATE_DATETIME, UPDATE_IP)
	 SELECT ORDER_ID, 'RTC05', 0, '','','RSC05','','',GETDATE(),GETDATE(),NULL,NULL,NULL,NULL,NULL
	 FROM #무통장결재대기주문건

	INSERT TB_ORDER_COPY
	SELECT * FROM TB_ORDER WHERE ORDER_ID IN (SELECT ORDER_ID FROM #무통장결재대기주문건)


 END 

 SELECT * INTO #삭제할쿠폰발행ID
 FROM 
	(
	 SELECT COUPON_PUBLISH_ID  
	 FROM TB_ORDER_COUPON_USE   
	 WHERE ORDER_ID IN (SELECT ORDER_ID FROM #무통장결재대기주문건)
	) TB2

 
 DECLARE @삭제할쿠폰발행ID개수 INT

 SELECT @삭제할쿠폰발행ID개수 = COUNT(1)
 FROM #삭제할쿠폰발행ID

 
 IF @삭제할쿠폰발행ID개수 > 0 BEGIN 
 
	-- TB_COUPON_PUBLISH USE_YN값 N으로 업데이트   
	 UPDATE TB_COUPON_PUBLISH  
	 SET TB_COUPON_PUBLISH.USE_YN = 'N' ,   
		 TB_COUPON_PUBLISH.USE_DATETIME = NULL  
	 WHERE TB_COUPON_PUBLISH.COUPON_PUBLISH_ID IN (SELECT COUPON_PUBLISH_ID FROM  #삭제할쿠폰발행ID)
 
 
	 --TB_ORDER_COUPON_USE 삭제  
	 DELETE   
	 FROM TB_ORDER_COUPON_USE   
	 WHERE ORDER_ID IN (SELECT ORDER_ID FROM #무통장결재대기주문건)

 END
GO
