IF OBJECT_ID (N'dbo.SP_T_ADMIN_COUPON_RESET', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_ADMIN_COUPON_RESET
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_ADMIN_COUPON_RESET]
/***************************************************************
작성자	:	표수현
작성일	:	2021-05-06
DESCRIPTION	:	결제취소 / 환불완료시 발급받은 쿠폰 초기화
SPECIAL LOGIC	:
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @ORDER_ID INT = NULL
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

 DECLARE @삭제할쿠폰발행ID  INT = 0


 SELECT @삭제할쿠폰발행ID = COUPON_PUBLISH_ID
 FROM TB_ORDER_COUPON_USE 
 WHERE ORDER_ID = @ORDER_ID

 IF @삭제할쿠폰발행ID > 0 BEGIN 
	
	-- TB_COUPON_PUBLISH USE_YN값 N으로 업데이트 
	UPDATE TB_COUPON_PUBLISH
	SET		USE_YN = 'N' , 
			USE_DATETIME = NULL
	WHERE	COUPON_PUBLISH_ID = @삭제할쿠폰발행ID

	--TB_ORDER_COUPON_USE 삭제 
	DELETE 
	FROM TB_ORDER_COUPON_USE 
	WHERE ORDER_ID = @ORDER_ID
	 
 END 
GO
