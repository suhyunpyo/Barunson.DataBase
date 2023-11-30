IF OBJECT_ID (N'dbo.PROC_SAVE_MOBILE_GIFT_ORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_SAVE_MOBILE_GIFT_ORDER
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_SAVE_MOBILE_GIFT_ORDER
-- Author        : 박혜림
-- Create date   : 2020-08-19
-- Description   : 모바일 > 답례품 주문정보 저장
-- Update History: 2020-10-28 (박혜림) - 답례품 ERP 연동 테이블 저장 로직 추가
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_SAVE_MOBILE_GIFT_ORDER]
      @Type                 VARCHAR(1)		-- 구분(I:최초저장시, M:수정시)
	, @member_id            VARCHAR(50)		-- 아이디
	, @order_seq            INT				-- 주문번호
	, @order_type           CHAR(2)			-- 카테고리
	, @sales_gubun          VARCHAR(2)		-- 사이트구분_1
	, @company_seq          INT				-- 사이트구분_2
	, @order_name           VARCHAR(50)		-- 주문자 이름
	, @order_email          VARCHAR(100)	-- 주문자 이메일
	, @order_phone          VARCHAR(20)		-- 주문자 전화번호
	, @order_hphone         VARCHAR(20)     -- 주문자 휴대전화
	, @recv_name            VARCHAR(50)		-- 받는사람 이름
	, @recv_phone           VARCHAR(20)		-- 받는사람 전화번호
	, @recv_hphone          VARCHAR(20)		-- 받는사람 휴대폰번호
	, @recv_Address         VARCHAR(255)	-- 받는사람 주소
	, @recv_address_detail  VARCHAR(100)	-- 받는사람 상세주소
	, @recv_zip             VARCHAR(6)		-- 우편번호
	, @recv_msg             VARCHAR(200)	-- 배송메세지
	, @delivery_method      CHAR(1)			-- 배송구분
	, @delivery_price       INT				-- 배송비
	, @option_price         INT				-- 옵션 가격
	, @settle_price         INT				-- 최종결제금액
	, @etc_info_l           INT
	, @etc_info_s           VARCHAR(200)	-- 선택옵션 메세지
	, @pg_paydate           VARCHAR(10)		-- 배송희망일
	, @card_seq             INT				-- 주문상품번호	
	, @order_count          INT				-- 주문수량
	, @card_opt             VARCHAR(500)	-- 선택옵션리스트
	, @Goods_ERP_Code       VARCHAR(200)	-- 주문상품 ERP 코드(,로 구분)
	, @Goods_Unit_Price     VARCHAR(200)	-- 주문상품 단가(,로 구분)
	, @Goods_Cnt            VARCHAR(200)	-- 주문상품수량(,로 구분)
-----------------------------------------------------------------------------------------------------------------------      
    , @ErrNum   INT           OUTPUT
    , @ErrSev   INT           OUTPUT
    , @ErrState INT           OUTPUT
    , @ErrProc  VARCHAR(50)   OUTPUT
    , @ErrLine  INT           OUTPUT
    , @ErrMsg   VARCHAR(2000) OUTPUT

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

-----------------------------------------------------------------------------------------------------------------------
-- Declare Block
-----------------------------------------------------------------------------------------------------------------------
DECLARE @seq     TINYINT
	  , @ERP_Cnt INT 

SET @seq = 1

-----------------------------------------------------------------------------------------------------------------------
-- Execute Block
-----------------------------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY		
		BEGIN TRAN

			IF @Type = 'I'	-- 저장인 경우
			BEGIN

				----------------------------------------------------------------------------------
				-- @order_Seq 생성
				----------------------------------------------------------------------------------				
                DECLARE @tbSeq TABLE(Seq INT)
                INSERT @tbSeq EXEC SP_GET_ORDER_SEQ 'E'

                SELECT @order_seq =SEQ FROM @tbSeq

				----------------------------------------------------------------------------------
				-- 주문정보 저장
				----------------------------------------------------------------------------------
				IF @order_name <> ''
				BEGIN
					INSERT INTO bar_shop1.dbo.CUSTOM_ETC_ORDER
					     ( order_seq		
						 , order_type		
						 , sales_gubun		
						 , company_seq		
						 , member_id	
						 , order_name		
						 , order_email		
						 , order_phone	
						 , order_hphone	
						 , recv_name
						 , recv_phone
						 , recv_hphone
						 , recv_Address
						 , recv_address_detail
						 , recv_zip
						 , recv_msg
						 , delivery_method
						 , delivery_price
						 , option_price
						 , settle_price
						 , etc_info_l
						 , etc_info_s
						 , pg_paydate
						 , pg_caldate
						 , pg_recaldate
						 , admin_memo
						 , pg_tid
					     , couponseq
						 )
					VALUES
					     ( @order_seq
						 , @order_type		
						 , @sales_gubun		
						 , @company_seq		
						 , @member_id	
						 , @order_name		
						 , @order_email		
						 , @order_phone	
						 , @order_hphone	
						 , @recv_name
						 , @recv_phone
						 , @recv_hphone
						 , @recv_Address
						 , @recv_address_detail
						 , @recv_zip
						 , @recv_msg
						 , @delivery_method
						 , @delivery_price
						 , @option_price
						 , @settle_price
						 , @etc_info_l
						 , @etc_info_s
						 , @pg_paydate
						 , ''
						 , ''
						 , ''
						 , 'ET' + CONVERT(VARCHAR(50), @order_seq)
						 , ''
						)

					INSERT INTO bar_shop1.dbo.CUSTOM_ETC_ORDER_ITEM
					     ( order_seq
						 , seq
						 , card_seq		
						 , order_count		
						 , card_price		
						 , card_sale_price	
						 , card_opt
						 )
					VALUES
					     ( @order_seq
						 , @seq
						 , @card_seq
						 , @order_count
						 , '0'	-- 단가		
						 , 0	-- 단가		
						 , @card_opt
						)

					----------------------------------------------------------------------------------
					-- 답례품 ERP 연동 테이블 저장
					----------------------------------------------------------------------------------
					SELECT @ERP_Cnt = COUNT(*)
						FROM bar_shop1.dbo.SplitTableStr(@Goods_ERP_Code,',') AS ERP_Count

					IF @ERP_Cnt > 0
					BEGIN

						SELECT IndexNo
						     , Value AS Item_ERP_Code
						  INTO #TempGoods_ERP_Code
						  FROM bar_shop1.dbo.SplitTableStr(@Goods_ERP_Code, ',')
				  
						SELECT IndexNo
						     , Value AS Item_Unit_Price
						  INTO #TempGoods_Unit_Price
						  FROM bar_shop1.dbo.SplitTableStr(@Goods_Unit_Price, ',')

						SELECT IndexNo
						     , Value AS Item_Cnt
						  INTO #TempGoods_Cnt
						  FROM bar_shop1.dbo.SplitTableStr(@Goods_Cnt, ',')	
				  				  
				  				
						DECLARE CURSOR_Gift_Order CURSOR FOR
					
						 SELECT T1.Item_ERP_Code
						      , T2.Item_Unit_Price
							  , T3.Item_Cnt 
						   FROM #TempGoods_ERP_Code        AS T1
						  INNER JOIN #TempGoods_Unit_Price AS T2 ON (T1.IndexNo = T2.IndexNo)
						  INNER JOIN #TempGoods_Cnt        AS T3 ON (T2.IndexNo = T3.IndexNo)
				         					 									 
						OPEN CURSOR_Gift_Order
				
						FETCH NEXT FROM CURSOR_Gift_Order INTO @Goods_ERP_Code, @Goods_Unit_Price, @Goods_Cnt
				
						WHILE @@fetch_status = 0
						BEGIN
							IF @Goods_Cnt <> 0  
							BEGIN
								INSERT INTO bar_shop1.dbo.CUSTOM_ETC_ORDER_GIFT_ITEM
									    ( Order_Seq		 
										, card_erp_code
										, card_seq
										, order_count
										, card_sale_price
										, Use_Yn
										, Reg_Date)
								VALUES
									    ( @order_seq
										, @Goods_ERP_Code
										, @card_seq
										, @Goods_Cnt
										, @Goods_Unit_Price
										, 'N'
										, GETDATE()
									)
							END
								  
							FETCH NEXT FROM CURSOR_Gift_Order INTO @Goods_ERP_Code, @Goods_Unit_Price, @Goods_Cnt
							
						END
				
						CLOSE CURSOR_Gift_Order
						
						DEALLOCATE CURSOR_Gift_Order

						Drop Table #TempGoods_ERP_Code
						Drop Table #TempGoods_Unit_Price
						Drop Table #TempGoods_Cnt
					END

					----------------------------------------------------------------------------------
					-- 주문번호 Return
					----------------------------------------------------------------------------------
					SELECT @order_seq

				END
			END
			ELSE IF @Type = 'M'	-- 수정인 경우
			BEGIN
				UPDATE bar_shop1.dbo.CUSTOM_ETC_ORDER
				   SET order_name          = @order_name
				     , order_email         = @order_email
					 , order_phone         = @order_phone
					 , order_hphone        = @order_hphone
				     , recv_name           = @recv_name
				     , recv_phone          = @recv_phone
					 , recv_hphone         = @recv_hphone
					 , recv_Address        = @recv_Address
					 , recv_Address_detail = @recv_Address_detail
					 , recv_zip            = @recv_zip
					 , recv_msg            = @recv_msg
					 , delivery_method     = @delivery_method
					 , delivery_price      = @delivery_price
					 , option_price        = @option_price
					 , settle_price        = @settle_price
					 , etc_info_l          = @etc_info_l
					 , etc_info_s          = @etc_info_s
					 , pg_paydate          = @pg_paydate
				 WHERE order_seq = @order_seq 

				----------------------------------------------------------------------------------
				-- 주문번호 Return
				----------------------------------------------------------------------------------
				SELECT @order_seq

			END		
			
		COMMIT TRAN
	
	END TRY


	BEGIN CATCH
		IF ( XACT_STATE() ) <> 0
		 BEGIN
		     ROLLBACK TRAN
        END	

		SELECT  @ErrNum   = ERROR_NUMBER()
			  , @ErrSev   = ERROR_SEVERITY()
			  , @ErrState = ERROR_STATE()
			  , @ErrProc  = ERROR_PROCEDURE()
			  , @ErrLine  = ERROR_LINE()
			  , @ErrMsg   = ERROR_MESSAGE();

	END CATCH

END

-- Execute Sample
/*

DECLARE	@ErrNum   INT          
	  , @ErrSev   INT          
	  , @ErrState INT          
	  , @ErrProc  VARCHAR(50)  
	  , @ErrLine  INT          
	  , @ErrMsg   VARCHAR(2000)

EXEC bar_shop1.dbo.PROC_SAVE_MOBILE_GIFT_ORDER
	   'I'				
	 , 's4guest'						
     , ''					
	 , 'AA'					
	 , 'SB'	
	 , '5001'
	 , '주문자'
	 , 'hyerim.park@barunn.net'
	 , '02-123-1234'
	 , '010-1234-1234'
	 , '테스트'					
	 , '02-123-1234'						
	 , '010-1234-1234'						
	 , '서울시 동교로 99'						
	 , '바른컴퍼니 2층'						
	 , '03414'						
	 , ''						
	 , '1'				
     , 0				
     , 0						
     , 276000
     , 0
	 , ''
	 , '2020-08-21'
	 , 37919
	 , 40
	 , '3. 마스터블렌드 32입 x 8개/2. 메모리인제주 20입 x 4개'
	 , 'OR003, OR002'
	 , '39400, 26000'
	 , '8, 4'
	 , @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/
GO
