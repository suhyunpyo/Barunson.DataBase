IF OBJECT_ID (N'dbo.sp_theCard_eWed', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_theCard_eWed
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************************
*          시스템명	: 더카드 - 이청첩장 
*          명칭		: 이청첩장 주문 후 청첩장 주문 완료시 처리
*                       (이청첩장 유료 -> 무료)
*          인수		:
*          Output    : 
*
******************************************************************
*          작성일자              작성자                내용
******************************************************************
*        2005/08/24            진나영             
******************************************************************/
CREATE PROCEDURE [dbo].[sp_theCard_eWed]
    @order_id int,
	@order_seq int,
    @admin_id varchar(50)
as
begin
    DECLARE @order_result CHAR(1)
    DECLARE @tmp_order_seq INT
    SELECT  @order_result = ORDER_RESULT, @tmp_order_seq = ORDER_SEQ 
    FROM THE_EWED_ORDER
    WHERE ORDER_ID = @order_id

    IF @tmp_order_seq is null
        begin
            -- order_result : 4 -> 2
            IF @order_result = '4' 
                begin
                    update the_ewed_order
                    set order_seq = @order_seq, settle_status = 0, status_seq = 1, pg_resultinfo = '무료', settle_price = 0, settle_date = getdate(), order_result = 2, admin_id = @admin_id
                    where order_id = @order_id
                end           

            -- order_result : 3 -> 1
            IF @order_result = '3' 
                begin
                    update the_ewed_order
                    set order_seq = @order_seq, settle_status = 2, status_seq = 2, pg_resultinfo = '무료', settle_price = 0, settle_date = getdate(), order_result = 1, admin_id = @admin_id
                    where order_id = @order_id  
                end
        end	

end
GO
