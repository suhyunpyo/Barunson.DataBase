IF OBJECT_ID (N'dbo.SP_CONCIERGE_BIZTALK_PROC', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_CONCIERGE_BIZTALK_PROC
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************
CUSTOM_ETC_ORDER ORDER_TYPE ='3' 컨시어지서비스

2020-11-24	정혜련
프페 컨시어지 서비스 완료시 호출 프로시저

EXEC [SP_CONCIERGE_BIZTALK_PROC] 3201692

*********************************************************/

CREATE PROCEDURE [dbo].[SP_CONCIERGE_BIZTALK_PROC]
	@ORDER_SEQ   INT
AS

BEGIN

    DECLARE @Mem_name AS VARCHAR(20)
    DECLARE @Mem_Hphone AS VARCHAR(15)
    DECLARE @Sales_gubun AS VARCHAR(2)
    
    DECLARE @CONTENT AS VARCHAR(800) -- 알림톡내용
    DECLARE @TEMPLATE_CODE AS VARCHAR(30)
    DECLARE @SENDER_KEY AS VARCHAR(40)
    DECLARE @MSG_TYPE AS INT 
    DECLARE @KKO_BTN_TYPE AS char(1)
    DECLARE @KKO_BTN_INFO AS VARCHAR(4000)
    DECLARE @CALLBACK AS VARCHAR(15)
    DECLARE @LMS_SUBJECT AS VARCHAR(200)
    DECLARE @company_seq as INT 

	  BEGIN
						
			-------------------------------------------------------
			-- 컨시어지 주문정보 확인
			-------------------------------------------------------
			SELECT  @Mem_name       =   ORDER_NAME		
			,   @Mem_Hphone         =   RECV_HPHONE	
			,   @Sales_gubun        =   Sales_gubun
			,   @company_seq        =   company_Seq
			FROM    ( 
				    SELECT  ORDER_NAME
				    ,   (  SELECT TOP 1 CARD_NAME 
					    FROM CUSTOM_ETC_ORDER_ITEM SI , S2_CARD C 
					    WHERE SI.CARD_SEQ = C.CARD_SEQ AND ORDER_SEQ = S.ORDER_SEQ  ) ITEM_NAME
				    ,   RECV_HPHONE
						,   ( case 
					    when company_seq = 5001 then 'SB'
							    WHEN company_seq = 5003 then 'SS'
							    WHEN company_seq = 5006 then 'SA'
							    WHEN company_seq = 5007 then 'ST'
							ELSE 'B' 
					  END ) Sales_gubun
					    ,   DELIVERY_CODE
					    ,   company_seq 
				    FROM    CUSTOM_ETC_ORDER S
				    WHERE   ORDER_SEQ = @ORDER_SEQ AND ORDER_TYPE ='3'
				) A 	

				-------------------------------------------------------
				-- 비즈톡 관련 내용 테이블 WEDD_BIZTAIK
				-------------------------------------------------------
				SELECT  
					@CONTENT = CONTENT
				    ,   @TEMPLATE_CODE = TEMPLATE_CODE
				    ,   @SENDER_KEY = SENDER_KEY 
				    ,   @MSG_TYPE = MSG_TYPE 
				    ,   @kko_btn_type = kko_btn_type 
				    ,   @KKO_BTN_INFO = KKO_BTN_INFO 
				    ,   @CALLBACK = callback
				    ,   @LMS_SUBJECT = lms_subject
				FROM    WEDD_BIZTALK
				WHERE   SALES_GUBUN = @Sales_gubun
				AND     DIV = '컨시어지서비스구매완료'
				AND     USE_YORN ='Y'

				-- 고객명
				IF CHARINDEX('#{name}',@CONTENT) > 0
				BEGIN
				    SET @CONTENT = Replace(@CONTENT , '#{name}' , @Mem_name);  
				END     


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
								    ,   @Mem_Hphone 
								    ,   @msg_type
								    ,   @sender_key
								    ,   @template_code
								    ,   @kko_btn_type 
								    ,   @kko_btn_info
								    ,   @Sales_gubun
								    ,   'sp_concierge_biztalk_proc'
								    ,   @company_seq	
								)
				END
	  END

END
GO
