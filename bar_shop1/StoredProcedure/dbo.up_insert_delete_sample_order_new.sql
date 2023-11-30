IF OBJECT_ID (N'dbo.up_insert_delete_sample_order_new', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_delete_sample_order_new
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2014-04-04
-- Description:	샘플오더 프로세스
--up_insert_delete_sample_order '5007','ljj777','34226','BT','이중정','151770','서울특별시 관악구 봉천동 1712','105동 1102호','02-1234-1234','010-2993-2094','','ljj777@naver.com','1','0','0','0','1000','34226',0,0
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_delete_sample_order_new]
	-- Add the parameters for the stored procedure here
	@company_seq	AS int,
	@uid			AS nvarchar(16),
	@card_seq		AS nvarchar(1000),
	@site_div		AS nvarchar(10),
	@dil_name		AS nvarchar(50),
	@dil_zip		AS nvarchar(6),
	@dil_addr		AS nvarchar(255),
	@dil_addr_detail	AS nvarchar(100),
	@dil_phone		AS nvarchar(50),
	@dil_hphone		AS nvarchar(50),
	@dil_info		AS nvarchar(500),
	@order_email	AS nvarchar(50),
	@buy_chk		AS nvarchar(1),
	@card_price		AS int,
	@delivery_price	AS int,
	@settle_price	AS int,
	@price_set		AS nvarchar(1000),
	@card_seq_set		AS nvarchar(1000),
	@ORDER_G_SEQ		AS int,
	@result_code		int = 0 OUTPUT,
	@result_order_seq		int = 0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	BEGIN TRAN
	declare @max_cnt int
	    
        DECLARE @tbSeq TABLE(Seq INT)
        INSERT @tbSeq EXEC SP_GET_ORDER_SEQ 'S'

        SELECT @max_cnt =SEQ FROM @tbSeq		

    	
    	-- CUSTOM_SAMPLE_ORDER에 담기
		insert into CUSTOM_SAMPLE_ORDER (
		sample_order_seq, sales_gubun, company_seq, member_id, member_email, member_name,
		member_phone, member_hphone, member_Address, member_address_detail, member_zip, memo, 
		request_date, buy_conf, card_price, delivery_price, settle_price, pg_tid, order_g_seq
		) values (
		 @max_cnt, @site_div, @company_seq, @uid, @order_email, @dil_name,
		 @dil_phone, @dil_hphone, @dil_addr, @dil_addr_detail, @dil_zip, @dil_info,
		 GETDATE(), @buy_chk, @card_price, @delivery_price, @settle_price, 'IS'+ convert(varchar(10),@max_cnt), @ORDER_G_SEQ
		)
		IF @@ERROR <> 0 GOTO GO_ERROR

        if @settle_price = 0 --결제비용 0원이면 카드값 0원으로 세팅
        begin
		    -- SAMPLE_Item table에 담기
		    insert into CUSTOM_SAMPLE_ORDER_ITEM (sample_order_seq,card_seq,card_price,ischu)
		    select @max_cnt, ItemValue, 0, '0' from dbo.fn_SplitIn3Rows(@card_seq_set, @price_set, ',')
		    IF @@ERROR <> 0 GOTO GO_ERROR
        end
        else
        begin
		    -- SAMPLE_Item table에 담기
		    insert into CUSTOM_SAMPLE_ORDER_ITEM (sample_order_seq,card_seq,card_price,ischu)
		    select @max_cnt, ItemValue, ItemValue2, '0' from dbo.fn_SplitIn3Rows(@card_seq_set, @price_set, ',')
		    IF @@ERROR <> 0 GOTO GO_ERROR
        end
		/*
		if @settle_price = 0	-- 배송비용이 0원이면(무료샘플 신청일 경우)
			begin
				-- 배송정보 상태 업데이트
				update custom_sample_order set status_seq=4,settle_date=getdate(),settle_method='0' where sample_order_seq=@max_cnt
				IF @@ERROR <> 0 GOTO GO_ERROR

				-- 장바구니에 담긴 샘플을 삭제한다.(체크된 상품만)
				delete from S2_SampleBasket where uid=@uid and company_seq=@company_seq and card_seq in (select card_seq from custom_sample_order_item where sample_order_seq=@max_cnt)
				IF @@ERROR <> 0 GOTO GO_ERROR
			end
		*/
		/*
		-- 배송정보 상태 업데이트
		update custom_sample_order set status_seq=4,settle_date=getdate(),settle_method='0' where sample_order_seq=@max_cnt
		-- 장바구니에 담긴 샘플을 삭제한다.(체크된 상품만)
		delete from S2_SampleBasket where uid=@uid and company_seq=@company_seq and card_seq in (select card_seq from custom_sample_order_item where sample_order_seq=@max_cnt)
		*/	

		set @result_order_seq = @max_cnt
		set @result_code = @@Error		--에러발생 cnt
		
	IF (@@ERROR <> 0) GOTO GO_ERROR
	
	IF ( @@error <> 0 )
		BEGIN
			GO_ERROR:
			ROLLBACK TRAN

		END
	ELSE
		BEGIN
 			COMMIT TRAN
			return @result_code
			return @result_order_seq
		END

END
GO
