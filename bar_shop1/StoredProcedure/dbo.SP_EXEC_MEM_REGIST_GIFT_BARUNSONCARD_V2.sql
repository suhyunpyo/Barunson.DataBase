IF OBJECT_ID (N'dbo.SP_EXEC_MEM_REGIST_GIFT_BARUNSONCARD_V2', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_MEM_REGIST_GIFT_BARUNSONCARD_V2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 /*     
   20200311  
   제 3자 마케팅 동의해야 쿠폰 발급 조건변경  
     
  
[SP_EXEC_MEM_REGIST_GIFT_BARUNSONCARD_V2] 5001, 'testskatmdal100', 0  
  
  
  
select * from COUPON_MST  
where COUPON_MST_SEQ in ( 501, 534, 520)  
  
select * from COUPON_DETAIL  
where COUPON_MST_SEQ in ( 501, 534)  
  
--삼성 라운지   
select * from COUPON_DETAIL  
where COUPON_MST_SEQ in ( 520)  
  
 EXEC dbo.[SP_INSERT_SAMSUNG_LOUNGE_COUPON] 'testskatmdal100', '5001'    
  
 */     
      
CREATE  PROCEDURE [dbo].[SP_EXEC_MEM_REGIST_GIFT_BARUNSONCARD_V2]      
 @COMPANY_SEQ AS INT      
,   @UID AS VARCHAR(50)      
,   @GIFT_CARD_SEQ AS INT = 0      
AS      
BEGIN      
  
 --//제3자 마케팅 동의 여부?  
 declare @mkt_chk_flg char(10) = 'N'  
  
 select top 1 @mkt_chk_flg = mkt_chk_flag  
   from S2_UserInfo   
 where uid = @UID            


	--// 바른손일 때만 주기로 조건 추가
   IF @mkt_chk_flg  = 'Y'   and @COMPANY_SEQ = 5001
    BEGIN     
		EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'SB', @UID, 'A646-CFCB-4CE4-A38B';    --// 신규회원 웰컴 쿠폰 - 청첩장 10% 할인  
		EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, 'SB', @UID, '7FFC-E2B6-4BBB-B96B'; --// 신규회원 웰컴 쿠폰 - 감사장 15% 할인 쿠폰  
    END       
END   
GO
