IF OBJECT_ID (N'dbo.SP_EXEC_COUPON_ISSUE_FOR_CONCIERGE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_COUPON_ISSUE_FOR_CONCIERGE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************  
  
2021-05-12 정혜련  

--① 쿠폰명 : [컨시어지전용] 실링스티커 20% 할인쿠폰
--쿠폰번호 : 2997-6660-41CD-98E2
--② 쿠폰명 : [컨시어지전용] 리본 15% 할인쿠폰
--쿠폰번호 : CEBF-A0F3-4623-B635

p_concierge_02

컨시어지 (배송일+1일에 자동 발송)
-- exec SP_EXEC_COUPON_ISSUE_FOR_CONCIERGE
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_COUPON_ISSUE_FOR_CONCIERGE]  
AS  
BEGIN  

    DECLARE @sales_gubun AS VARCHAR(2)  
    DECLARE @member_id AS VARCHAR(50)  
    DECLARE @company_seq AS int  

    DECLARE @Coupon_code1 AS VARCHAR(20)    
    DECLARE @Coupon_code2 AS VARCHAR(20)   
			 
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_order CURSOR FAST_FORWARD  
 FOR  
	
	-- card_Seq = 38243 컨시어지 시즌2 
	select c.company_seq, sales_gubun, member_id 
	from custom_etc_order c, CUSTOM_ETC_ORDER_ITEM ci, s2_userinfo_bhands m
	where c.order_seq = ci.order_seq
	and c.member_id = m.uid
	and order_type ='3'
	AND delivery_date >= CONVERT(CHAR(10), GETDATE() -1 , 23) 
	AND delivery_date < CONVERT(CHAR(10), GETDATE() , 23) 
	and status_seq =12
	and ci.card_Seq = 38243


 OPEN cur_AutoInsert_For_order  
  
 FETCH NEXT FROM cur_AutoInsert_For_order INTO @company_seq, @sales_gubun,  @member_id
  
 WHILE @@FETCH_STATUS = 0  
  
 BEGIN  

		SET @Coupon_code1 = '2997-6660-41CD-98E2'
		EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @company_seq, @sales_gubun,@member_id,@Coupon_code1

		SET @Coupon_code2 = 'CEBF-A0F3-4623-B635'
		EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @company_seq, @sales_gubun,@member_id,@Coupon_code2

       
  FETCH NEXT FROM cur_AutoInsert_For_order INTO  @company_seq, @sales_gubun,  @member_id
 END  
  
 CLOSE cur_AutoInsert_For_order  
 DEALLOCATE cur_AutoInsert_For_order  
END
GO
