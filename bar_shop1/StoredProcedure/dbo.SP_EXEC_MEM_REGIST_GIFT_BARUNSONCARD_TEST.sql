IF OBJECT_ID (N'dbo.SP_EXEC_MEM_REGIST_GIFT_BARUNSONCARD_TEST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_MEM_REGIST_GIFT_BARUNSONCARD_TEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 /*
 
 신규회원 웰컴 쿠폰 : 감사장 할인쿠폰 코드 아래 코드로 변경
(기존 10% → 수정된 15% 쿠폰)
7FFC-E2B6-4BBB-B96B

청첩장 구매고객 감사장 쿠폰 : 지급 쿠폰코드 아래 코드로 변경
C600-1862-412D-AA73

 
 */ 
  
create PROCEDURE [dbo].[SP_EXEC_MEM_REGIST_GIFT_BARUNSONCARD_TEST]  
 @COMPANY_SEQ AS INT  
,   @UID AS VARCHAR(50)  
,   @GIFT_CARD_SEQ AS INT = 0  
AS  
BEGIN  
      
   IF @COMPANY_SEQ = 5001  
   BEGIN 
		EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'SB', @UID, 'A646-CFCB-4CE4-A38B';  
		EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'SB', @UID, '7FFC-E2B6-4BBB-B96B';
   END   
END  
GO
