IF OBJECT_ID (N'dbo.sp_choan_induce_biztalk', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_choan_induce_biztalk
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC sp_choan_induce_biztalk   
배치 - 2021.03.22
청첩장 초안확정 유도 프로시저 
*/

CREATE  PROCEDURE [dbo].[sp_choan_induce_biztalk] 
AS  

BEGIN  

    DECLARE @order_name AS VARCHAR(20)
    DECLARE @order_hphone AS VARCHAR(15)
    DECLARE @Sales_gubun AS VARCHAR(2)
    DECLARE @order_Seq AS INT 
    DECLARE @card_name AS VARCHAR(30)
  
    DECLARE @CONTENT AS VARCHAR(800) -- 알림톡내용
    DECLARE @TEMPLATE_CODE AS VARCHAR(30)
    DECLARE @SENDER_KEY AS VARCHAR(40)
    DECLARE @MSG_TYPE AS INT 
    DECLARE @KKO_BTN_TYPE AS char(1)
    DECLARE @KKO_BTN_INFO AS VARCHAR(4000)
    DECLARE @CALLBACK AS VARCHAR(15)
    DECLARE @LMS_SUBJECT AS VARCHAR(200)
    DECLARE @DIV VARCHAR(100) 
    DECLARE @COMPANY_SEQ AS INT
	DECLARE @isSpecial AS VARCHAR(1) 
 
 --커서를 이용하여 해당되는 주문정보를 얻는다.  
 DECLARE cur_Search_For_ORDER CURSOR FAST_FORWARD  
 FOR  

	
	-- src_compose_date 초안등록일
	-- src_compose_mod_date 재초안등록일

	SELECT  order_Seq
		,( CASE WHEN sales_gubun IN ('B', 'H', 'C') THEN 'B' 
		ELSE sales_gubun END ) sales_gubun
		, order_name
		, order_hphone
		, s.card_name
		, c.company_seq
		, (CASE WHEN c.isSpecial = '1' THEN '초특급초안확정유도' ELSE '초안확정유도' END) DIV 
	FROM custom_order c , s2_card s 
	WHERE c.card_Seq = s.card_Seq  
	AND c.status_seq in (7,8)
	AND c.settle_status in (0,1)
	AND ( c.src_compose_date > CONVERT(CHAR(10), GETDATE()-4,  23)   and  c.src_compose_date < CONVERT(CHAR(10), GETDATE()-3, 23) )
	AND c.member_id <> 's4guest'
	AND sales_gubun <> 'SD'
	
 OPEN cur_Search_For_ORDER  
  	   
 FETCH NEXT FROM cur_Search_For_ORDER INTO @order_Seq, @sales_gubun, @order_name, @order_hphone, @card_name, @company_seq, @DIV
  
 WHILE @@FETCH_STATUS = 0  
  
 BEGIN  

	SELECT  @CONTENT = CONTENT
	,   @TEMPLATE_CODE = TEMPLATE_CODE
	,   @SENDER_KEY = SENDER_KEY 
	,   @MSG_TYPE = MSG_TYPE 
	,   @kko_btn_type = kko_btn_type 
	,   @KKO_BTN_INFO = KKO_BTN_INFO 
	,   @CALLBACK = callback
	,   @LMS_SUBJECT = lms_subject
	FROM    WEDD_BIZTALK
	WHERE   SALES_GUBUN = @sales_gubun
	AND     DIV = @DIV
	AND     USE_YORN ='Y'

        IF CHARINDEX('#{name}',@CONTENT) > 0
        BEGIN
            SET @CONTENT = Replace(@CONTENT , '#{name}' , @order_name);  
        END        

        IF CHARINDEX('#{0000000}',@CONTENT) > 0
        BEGIN
            SET @CONTENT = Replace(@CONTENT , '#{0000000}' , @order_Seq);  
        END        

        IF CHARINDEX('#{상품명}',@CONTENT) > 0
        BEGIN
			SET @CONTENT = Replace(@CONTENT , '#{상품명}' , @card_name);  
        END   

	-- 발송하자
	IF @CONTENT <> ''
	
		BEGIN
			INSERT INTO ata_mmt_tran (
				                        date_client_req
			                        ,   subject
			                        ,   content
			                        ,   callback
			                        ,   msg_status
			                        ,   recipient_num
			                        ,   msg_type
			                        ,   sender_key
			                        ,   template_code
			                        ,   kko_btn_type
			                        ,   kko_btn_info
			                        ,   etc_text_1	-- sales_gubun
			                        ,   etc_text_2	-- 호출프로시저
			                        ,   etc_num_1	-- company_Seq 
			                        ) VALUES (
				                        GETDATE() 
				                    ,   @LMS_SUBJECT 
				                    ,   @CONTENT
				                    ,   @CALLBACK 
				                    ,   '1' 
				                    ,   @order_hphone 
				                    ,   @msg_type
				                    ,   @sender_key
				                    ,   @template_code
				                    ,   @kko_btn_type 
				                    ,   @kko_btn_info
				                    ,   @Sales_gubun
				                    ,   'sp_choan_induce_biztalk'
				                    ,   @company_seq	
			                        )
		END

  FETCH NEXT FROM cur_Search_For_ORDER INTO  @order_Seq, @sales_gubun, @order_name, @order_hphone, @card_name, @company_seq,@DIV
 END  
  
 CLOSE cur_Search_For_ORDER  
 DEALLOCATE cur_Search_For_ORDER  
END 
GO
