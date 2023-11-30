USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_SAMPLE_BIZTALK_PROC]    Script Date: 2023-06-01 오후 5:40:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************
-- div : 샘플주문완료/샘플발송완료
2018-03-15	정혜련

EXEC SP_SAMPLE_BIZTALK_PROC 1812251,'샘플주문완료'
EXEC SP_SAMPLE_BIZTALK_PROC 1812251,'샘플발송완료'
EXEC SP_SAMPLE_BIZTALK_PROC_TEST 1867725,'샘플무통장결제' 

이지웰, SKQ베네피아 제외 

*********************************************************/

ALTER PROCEDURE [dbo].[SP_SAMPLE_BIZTALK_PROC]
	@SAMPLE_ORDER_SEQ   integer,
	@DIV                VARCHAR(100) 
AS

BEGIN

    DECLARE @Mem_name AS VARCHAR(20)
    DECLARE @Mem_Hphone AS VARCHAR(15)
    DECLARE @Sales_gubun AS VARCHAR(2)
    DECLARE @Item_name AS VARCHAR(30)
    DECLARE @Item_Count AS INT
    DECLARE @Item_title AS VARCHAR(50) -- 샘플주문내용
    
    DECLARE @CONTENT AS VARCHAR(800) -- 알림톡내용
    DECLARE @TEMPLATE_CODE AS VARCHAR(30)
    DECLARE @SENDER_KEY AS VARCHAR(40)
    DECLARE @MSG_TYPE AS INT 
    DECLARE @KKO_BTN_TYPE AS char(1)
    DECLARE @KKO_BTN_INFO AS VARCHAR(4000)
    DECLARE @CALLBACK AS VARCHAR(15)
    DECLARE @LMS_SUBJECT AS VARCHAR(200)
	DECLARE @DELIVERY_CODE_NUM AS VARCHAR(15)
	DECLARE @today_dt as varchar(10)
    DECLARE @company_seq as INT 

    --임시조치 mjbyon : 일정기간 지난 거래건은 발송하지 않도록 조치 20230628
	DECLARE @ReqDate  DATETIME = GETDATE()
	DECLARE @ChkDate  DATETIME = DATEADD(day, -3 ,GETDATE()) 
	--//임시조치

	DECLARE @SendYN AS char(1)

	-------------------------------------------------------
	-- 샘플 주문정보 확인
	-------------------------------------------------------
	SELECT  @Mem_name           =   MEMBER_NAME	
        ,   @item_name          =   item_name	
        ,   @Item_Count         =   Item_Count	
        ,   @Mem_Hphone         =   MEMBER_HPHONE	
        ,   @Sales_gubun        =   Sales_gubun
        ,   @company_seq        =   company_Seq
        ,   @Item_title         =   (item_name+' 포함 '+ cast(Item_Count as nvarchar(2))+'종')	
        ,   @DELIVERY_CODE_NUM  = DELIVERY_CODE_NUM
        ,   @today_dt           =   convert(varchar(10),getdate(),23)
        ,   @ReqDate            = REQUEST_DATE
	FROM    ( 
	            SELECT  MEMBER_NAME
                    ,   (  SELECT TOP  1 CARD_NAME 
                            FROM CUSTOM_SAMPLE_ORDER_ITEM SI , S2_CARD C 
                            WHERE SI.CARD_SEQ = C.CARD_SEQ AND SAMPLE_ORDER_SEQ = S.SAMPLE_ORDER_SEQ 
                            ORDER BY REG_DATE ASC ) item_name
                    ,   (   SELECT COUNT(*) 
                            FROM CUSTOM_SAMPLE_ORDER_ITEM 
                            WHERE SAMPLE_ORDER_SEQ = S.SAMPLE_ORDER_SEQ and ischu <> '9' ) Item_Count
                    ,   MEMBER_HPHONE
			        ,   ( case 
                            when company_seq = 5001 then 'SB'
				            WHEN company_seq = 5003 then 'SS'
				            WHEN company_seq = 5006 then 'SA'
				            WHEN company_seq = 5007 then 'ST'
							WHEN company_seq = 7717 then 'SD'
							ELSE 'B' 
                          END ) Sales_gubun
		            ,   DELIVERY_CODE_NUM
		            ,   company_seq 
                    ,   REQUEST_DATE
	            FROM    CUSTOM_SAMPLE_ORDER S
	            WHERE   SAMPLE_ORDER_SEQ = @SAMPLE_ORDER_SEQ
	        ) A 	
	

         --임시조치 mjbyon : 일정기간 지난 거래건은 발송하지 않도록 조치 20230628
    	IF @ReqDate < @ChkDate AND @DIV IN('샘플주문완료','샘플무통장결제') BEGIN
            RETURN 
        END
        --//임시조치
		
		-- 무통장 입금...
        DECLARE     @bank_name          [varchar](200)  
        DECLARE     @bank_account       [varchar](100)  
        DECLARE     @settle_price       integer   

        -- 결제정보
        SELECT       
                     @bank_name = bank_name, 
                     @bank_account = bank_account, 
                     @settle_price = isnull(settle_price,0)
        FROM     (
                    SELECT 
                            (CASE WHEN c.settle_method = '1' or c.settle_method = '0' or c.settle_method = '9' THEN pg_resultinfo ELSE LEFT(C.pg_resultinfo, CASE WHEN CHARINDEX(' ', C.pg_resultinfo) = 0 THEN 0 ELSE CHARINDEX(' ', C.pg_resultinfo) - 1 END) END ) bank_name
                        ,   RIGHT(C.pg_resultinfo, (case when LEN(C.pg_resultinfo) - CHARINDEX(' ', C.pg_resultinfo) > 0 then LEN(C.pg_resultinfo) - CHARINDEX(' ', C.pg_resultinfo) else 0 end)) bank_account
                        ,   isnull(settle_price,0) settle_price
                    FROM    custom_sample_order c 
                    WHERE   sample_order_seq = @SAMPLE_ORDER_SEQ
					and company_seq not in (5780, 5787)
                 ) a 




	
	SET @SendYN = 'Y'	

	IF @SendYN = 'Y'
	BEGIN

		-------------------------------------------------------
		-- 비즈톡 관련 내용 테이블 WEDD_BIZTAIK
		-------------------------------------------------------
		SELECT  @CONTENT = CONTENT
            ,   @TEMPLATE_CODE = TEMPLATE_CODE
            ,   @SENDER_KEY = SENDER_KEY 
            ,   @MSG_TYPE = MSG_TYPE 
            ,   @kko_btn_type = kko_btn_type 
            ,   @KKO_BTN_INFO = KKO_BTN_INFO 
		    ,   @CALLBACK = callback, @LMS_SUBJECT = lms_subject
		FROM    WEDD_BIZTALK
		WHERE   SALES_GUBUN = @Sales_gubun
		AND     DIV = @DIV
		AND     USE_YORN ='Y'

        IF CHARINDEX('#{name}',@CONTENT) > 0
        BEGIN
            SET @CONTENT = Replace(@CONTENT , '#{name}' , @Mem_name);  
        END        

        IF CHARINDEX('#{0000000}',@CONTENT) > 0
        BEGIN
			SET @CONTENT = Replace(@CONTENT , '#{0000000}' , @SAMPLE_ORDER_SEQ);  
        END        

        IF CHARINDEX('#{상품명}',@CONTENT) > 0
        BEGIN
			SET @CONTENT = Replace(@CONTENT , '#{상품명}' , @Item_title);  
        END        

        IF CHARINDEX('#{0000-00-00}',@CONTENT) > 0
        BEGIN
            SET @CONTENT = Replace(@CONTENT , '#{0000-00-00}' , @today_dt);
        END        

        IF CHARINDEX('#{000000000000}',@CONTENT) > 0
        BEGIN
            SET @CONTENT = Replace(@CONTENT , '#{000000000000}' , @DELIVERY_CODE_NUM);
        END        

		/*IF @DIV = '샘플발송완료'
			BEGIN
				SET @CONTENT = Replace(@CONTENT , '#{0000-00-00}' , @today_dt);
				SET @CONTENT = Replace(@CONTENT , '#{000000000000}' , @DELIVERY_CODE_NUM);
			END*/

        IF @bank_name <> '' AND CHARINDEX('#{입금은행명}',@content) > 0
        BEGIN
            SET @content = Replace(@content, '#{입금은행명}', @bank_name)
        END

        IF @bank_account <> '' AND CHARINDEX('#{가상계좌번호}',@content) > 0
        BEGIN
			SET @content = Replace(@content, '#{가상계좌번호}', @bank_account)
        END

        IF @settle_price >= 0  AND CHARINDEX('#{입금금액}',@content) > 0
        BEGIN
            SET @content = Replace(@content, '#{입금금액}', @settle_price)
		END

		IF @CONTENT <> ''
	
		BEGIN
			--2023-05-31 이재호 샘플발송완료 추가(관리자 연동으로 수정)
			DECLARE @START_DATE DATETIME
			DECLARE @END_DATE DATETIME
			DECLARE @USE_YN CHAR(1)
			DECLARE @NOW_DATE DATETIME = GETDATE();

			SELECT TOP 1 @START_DATE = START_DATE,
					@END_DATE = END_DATE,
					@USE_YN = USE_YN
			FROM ADMIN_LIMIT_SETTING
			WHERE TYPE = 'P';

			-- select @START_DATE startDate, @END_DATE endDate, @USE_YN useYn, @NOW_DATE nowDate;

			IF @USE_YN = 'N' OR (@USE_YN = 'Y' AND (@NOW_DATE <= @START_DATE OR @NOW_DATE >= @END_DATE))
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
										,   'sp_sample_biztalk_proc'
										,   @company_seq	
										)
			END 
		END
	END
END
Go