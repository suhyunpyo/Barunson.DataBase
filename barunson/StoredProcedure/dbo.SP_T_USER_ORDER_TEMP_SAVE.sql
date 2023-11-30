IF OBJECT_ID (N'dbo.SP_T_USER_ORDER_TEMP_SAVE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_USER_ORDER_TEMP_SAVE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_USER_ORDER_TEMP_SAVE]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	주문 임시 저장(쿠폰 부분결제 관련) - 모바일에서만 호출 
SP_T_USER_ORDER_TEMP_SAVE 'S', 'M2108260014'
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @GUBUN		CHAR(1) = 'I',			-- D -> 임시저장 삭제 / S -> 주문 이력 조회 / I - 임시저장
 @ORDER_CODE	VARCHAR(25) = NULL,		
 @COUPON_PUBLISH_ID INT = NULL,
 @COUPON_PRICE	INT = NULL
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 IF @GUBUN = 'D' BEGIN -- 모바일에서 결재완료및 쿠폰정보까지 저장한 뒤에 임시 테이블에 저장했던 데이터 삭제 
	
	DELETE FROM TB_TEMP_ORDER
	WHERE ORDER_CODE = @ORDER_CODE

 END ELSE IF @GUBUN = 'S' BEGIN  --모바일에서 결제완료후에 쿠폰으로 주문 임시 저장 이력을 조회 
		
	DECLARE @ORDER_ID INT 
	DECLARE @임시저장여부 INT = 0
 
	SELECT @임시저장여부 = COUNT(*) 
	FROM TB_TEMP_ORDER
	WHERE ORDER_CODE = @ORDER_CODE 

	IF @임시저장여부 > 0 BEGIN 
		
		SELECT @ORDER_ID = ORDER_ID
		FROM TB_ORDER 
		WHERE ORDER_CODE = @ORDER_CODE

		SELECT ORDER_ID  = @ORDER_ID, COUPON_PUBLISH_ID ,COUPON_PRICE
		FROM TB_TEMP_ORDER
		WHERE ORDER_CODE = @ORDER_CODE 

	END ELSE BEGIN 
		
		SELECT 'F'

	END 
	

 END ELSE IF @GUBUN = 'I' BEGIN  -- 모바일에서 결재창을 띄우는 순간에 쿠폰관련 정보를 임시 테이블에 저장
	
	DELETE FROM TB_TEMP_ORDER
	WHERE ORDER_CODE = @ORDER_CODE

		INSERT TB_TEMP_ORDER(ORDER_CODE, COUPON_PUBLISH_ID, COUPON_PRICE)
		VALUES (@ORDER_CODE, @COUPON_PUBLISH_ID, @COUPON_PRICE)
 END 





 --SELECT * FROM TB_TEMP_ORDER
GO
