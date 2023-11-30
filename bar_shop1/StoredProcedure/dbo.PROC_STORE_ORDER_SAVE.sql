IF OBJECT_ID (N'dbo.PROC_STORE_ORDER_SAVE', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_STORE_ORDER_SAVE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_STORE_ORDER_SAVE
-- Author        : 박혜림
-- Create date   : 2021-01-11
-- Description   : 바른손스토어 주문정보 저장
-- Update History:
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_STORE_ORDER_SAVE]
	  @uid                  INT				-- 바른손스토어 주문 고유번호
	, @member_id            VARCHAR(50)		-- 아이디
	, @order_name           VARCHAR(50)		-- 주문자 이름
	, @order_email          VARCHAR(100)	-- 주문자 이메일
	, @order_phone          VARCHAR(20)		-- 주문자 전화번호
	, @order_hphone         VARCHAR(20)		-- 주문자 휴대폰번호
	, @recv_name            VARCHAR(50)		-- 받는사람 이름
	, @recv_phone           VARCHAR(20)		-- 받는사람 전화번호
	, @recv_hphone          VARCHAR(20)		-- 받는사람 휴대폰번호
	, @recv_Address         VARCHAR(255)	-- 받는사람 주소
	, @recv_address_detail  VARCHAR(100)	-- 받는사람 상세주소
	, @recv_zip             VARCHAR(6)		-- 우편번호
	, @recv_msg             VARCHAR(200)	-- 배송메세지
	, @pg_paydate           VARCHAR(10)		-- 희망배송일
	, @status_seq           INT				-- 주문상태(가상계좌:1, 카드/실시간계좌이체:4)
	, @delivery_price       INT				-- 배송비
	, @settle_method        VARCHAR(1)		-- 결제수단(가상계좌:3, 카드결제:2, 실시간계좌이체:1)
	, @settle_price         INT				-- 최종결제금액
	, @pg_tid               VARCHAR(50)		-- PG 전송 주문번호
	, @dacom_tid            VARCHAR(50)		-- TID
	, @pg_resultInfo        VARCHAR(255)	-- 결제정보
	, @pg_resultInfo2       VARCHAR(500)	-- 입금예정자
	, @isAscrow             VARCHAR(1)		-- 에스크로 적용여부
	, @isReceipt            VARCHAR(1)		-- 영수증 발행여부
	, @card_seq             INT				-- 주문상품번호
	, @order_count          INT				-- 총주문수량
	, @card_opt             VARCHAR(500)	-- 선택옵션리스트
	, @Goods_ERP_Code       VARCHAR(200)	-- 주문상품 ERP 코드(,로 구분)
	, @Goods_Unit_Price     VARCHAR(200)	-- 주문상품 단가(,로 구분)
	, @Goods_Cnt            VARCHAR(200)	-- 주문상품 수량(,로 구분)
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
DECLARE @Order_Seq  INT
      , @Order_Type CHAR(2)	--카테고리
	  , @ERP_Cnt    INT

SET @Order_Seq = 0
SET @Order_Type = ''

-----------------------------------------------------------------------------------------------------------------------
-- Execute Block
-----------------------------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY		
		BEGIN TRAN

			----------------------------------------------------------------------------------
			-- 상품 카테고리 조회
			----------------------------------------------------------------------------------
			SELECT @Order_Type = LEFT(card_category, 2)
			  FROM bar_shop1.dbo.S2_CardDetailEtc WITH(NOLOCK)
			 WHERE card_seq = @card_seq

			----------------------------------------------------------------------------------
			-- @order_Seq 생성
			----------------------------------------------------------------------------------
            DECLARE @tbSeq TABLE(Seq INT)
            INSERT @tbSeq EXEC SP_GET_ORDER_SEQ 'E'

            SELECT @Order_Seq =SEQ FROM @tbSeq		

			----------------------------------------------------------------------------------
			-- 주문정보 저장
			----------------------------------------------------------------------------------
			IF @Order_Seq > 0 AND @Order_Type <> ''
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
						, etc_info_l
						, etc_info_s
						, pg_paydate
						, status_seq
						, delivery_method
						, delivery_price
						, settle_method
						, settle_date
						, option_price
						, settle_price
						, pg_shopid			-- 상점아이디
						, pg_tid
						, dacom_tid
						, card_nointyn		-- 무이자여부 (바른손스토어 저장안함)
						, card_installmonth	-- 할부개월수 (바른손스토어 저장안함)
						, pg_resultinfo
						, pg_resultinfo2
						, isAscrow
						, isReceipt
						, pg_caldate
						, pg_recaldate
						, admin_memo
					    , couponseq
						)
				VALUES
					    ( @Order_Seq
						, @Order_Type	
						, 'BS'		-- 바른손스토어	
						, 8028		-- 바른손스토어		
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
						, 0
						, ''
						, @pg_paydate
						, @status_seq
						, '1'
						, @delivery_price
						, @settle_method
						, CASE WHEN @status_seq = 4 THEN GETDATE() ELSE NULL END
						, 0
						, @settle_price
						, 'bhands_new'
						, @pg_tid
						, @dacom_tid
						, ''
						, ''
						, @pg_resultInfo
						, @pg_resultInfo2
						, @isAscrow
						, @isReceipt
						, ''
						, ''
						, ''
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
					    ( @Order_Seq
						, 1
						, @card_seq
						, @order_count
						, '0'	-- 단가		
						, 0		-- 단가		
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
									( @Order_Seq
									, @Goods_ERP_Code
									, @card_seq
									, @Goods_Cnt
									, @Goods_Unit_Price
									, 'Y'
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
			END

			----------------------------------------------------------------------------------
			-- 매칭정보 저장
			----------------------------------------------------------------------------------
			INSERT INTO bar_shop1.dbo.STORE_BARUNSON_ORDER_MATCHING
					    ( [Uid]
						, Order_Seq
						, Reg_Date
						, Last_Matching_Date	
						)
				 VALUES
					    ( @Uid
						, @Order_Seq
						, GETDATE()
						, GETDATE()
					)

			
		COMMIT TRAN
	
	END TRY


	BEGIN CATCH
		IF ( XACT_STATE() ) <> 0
		 BEGIN
		     ROLLBACK TRAN
        END	

		SELECT @ErrNum   = ERROR_NUMBER()
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

EXEC bar_shop1.dbo.PROC_STORE_ORDER_SAVE
	   9213		
	 , 'phrim8611'
	 , '박혜림'
	 , 'hyerim.park@barunn.net'
     , ''
	 , '010-1234-1234'
	 , '박혜림'
	 , ''
	 , '010-1111-2222'
	 , '서울시 마포구 동교로 99'					
	 , '2층'
	 , '04004'
	 , '조심히 배송해주세요~~'
	 , '2021-03-20'
	 , 1
	 , 0
	 , '3'
	 , '150000'
	 , 'A16098670399406513'
	 , 'bhand2021010517173411107'
	 , '우리 46508207218461'
	 , '입금자명'
	 , '0'
	 , '0'
	 , 37919
	 , 22
	 , '우이로 화과자 2구 세트 x 20개/우이로 화과자 6구 세트 x 2개'
	 , 'MJ001,MJ002'
	 , '6900,20900'
	 , '20,2'
	 , @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/
GO
