IF OBJECT_ID (N'invtmng.proc_ItemCnt_test', N'P') IS NOT NULL DROP PROCEDURE invtmng.proc_ItemCnt_test
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*

    EXEC [invtmng].[proc_ItemCnt1] 2646877 

	EXEC [invtmng].[proc_ItemCnt1] 2297333

	EXEC [invtmng].[proc_ItemCnt1] 2905999


*/

CREATE            Procedure  [invtmng].[proc_ItemCnt_test]
@order_seq int
--,@rslt tinyint output
as
begin

	DECLARE @order_type char(1),@last_total_price int,@settle_price int,@card_seq int,@order_count int,@card_count int,@DeliveryCnt tinyint
	DECLARE @isFPrint char(1),@item_type char(1),@item_count int
	DECLARE @rslt tinyint
	set @rslt = 1

	select	@order_type			=	order_type
		,	@last_total_price	=	last_total_price
		,	@settle_price		=	settle_price
		,	@card_seq			=	card_seq
		,	@order_count		=	order_count 
	from	custom_order 
	where	order_seq = @order_seq
	
	
             ----------------------------------------------------------------------------------------------------
	if @last_total_price <> @settle_price
		goto err_act1

	--if (@order_type = '5' or @order_type = '8')  -- 미니주문인 경우
		--select @card_count = isnull(sum(item_count),0) from custom_order_item where order_seq = @order_seq and item_type='M'	
	--else
		--select @card_count = isnull(sum(item_count),0) from custom_order_item where order_seq = @order_seq and item_type='C'
	

	--if @card_count <> @order_count 		-- 주문테이블의 카드수량과 제품 수량이 틀린경우
		--goto err_act1

    ----------------------------------------------------------------------------------------------------
		
    
    /* 식권 수량 검증 */
    SET @rslt = ISNULL
                        (
                            (
                                SELECT  TOP 1 0
                                FROM    (    
                                            SELECT  SUM(COI.ITEM_COUNT) AS ORDER_CNT
                                                ,   SUM(ISNULL(DID.ITEM_COUNT, 0)) AS DELIVERY_CNT
                                            FROM    CUSTOM_ORDER_ITEM COI
                                            JOIN    CUSTOM_ORDER CO ON COI.ORDER_SEQ = CO.ORDER_SEQ
                                            LEFT JOIN
                                                    --DELIVERY_INFO_DETAIL DID ON COI.ORDER_SEQ = DID.ORDER_SEQ AND COI.ID = DID.ITEM_ID
											(
													SELECT
														  order_seq
														, item_id
														, SUM(item_count) AS item_count
													FROM DELIVERY_INFO_DETAIL 
													WHERE order_seq = @ORDER_SEQ
													GROUP BY
														  order_seq
														, item_id
											) AS DID ON COI.ORDER_SEQ = DID.ORDER_SEQ AND COI.ID = DID.ITEM_ID
                                            WHERE   1 = 1
                                            AND     COI.ORDER_SEQ = @ORDER_SEQ
                                            AND     COI.ITEM_TYPE = 'F'
                                            AND     CO.COMPANY_SEQ <> 5007
                                            GROUP BY COI.ID	
                                        ) A
                                WHERE   1 = 1
                                AND     A.ORDER_CNT <> A.DELIVERY_CNT
                            ), 1
                        )	

	
	select @rslt

	/* 주문 수량 VS 배송 수량 검증 */
	
	DECLARE @id int, @cnt int
	DECLARE delivery_cursor CURSOR FOR 
	
	SELECT A.id, SUM(A.cnt) AS cnt
	FROM	(

		SELECT	CASE WHEN B.id is not null THEN B.id ELSE A.id END AS id
			,	CASE WHEN B.id is not null THEN B.print_count ELSE A.item_count END AS cnt
		FROM	custom_order_item A 
		LEFT JOIN custom_order_plist B ON A.order_seq = B.order_seq AND A.card_seq = B.card_seq AND B.isFPrint <> 1
		WHERE	A.order_seq = @order_seq
		AND		A.item_count <> 0 
		AND		A.item_type <> 'S'
		
	) A
	GROUP BY A.id
	
	OPEN delivery_cursor
	
	FETCH NEXT FROM delivery_cursor INTO @id, @cnt
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		IF (SELECT ISNULL(SUM(item_count), 0) FROM DELIVERY_INFO_DETAIL WHERE order_seq = @order_seq AND item_id = @id GROUP BY item_id) <> @cnt
			BEGIN	
				SET @rslt = 0
				select 'A'
				BREAK
			END

		FETCH NEXT FROM delivery_cursor  INTO @id, @cnt

	END	
	
	CLOSE delivery_cursor
	DEALLOCATE delivery_cursor
	
	/* //주문 수량 VS 배송 수량 검증 */





    ----------------------------------------------------------------------------------------------------
	DECLARE item_cursor CURSOR FOR 
	select print_type,isFPrint,sum(print_count) as pcount from custom_order_plist where order_seq = @order_seq group by print_type,isFPrint
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @item_type,@isFPrint,@item_count
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-----------------------------------------------------------------------------------------------
		-- 수량 검증
		IF (select sum(isnull(item_count,0)) from custom_order_item where order_seq = @order_seq and item_type=@item_type) <> @item_count 
		begin	
			set @rslt = 0
			select 'B'
			break
		end


		-- custom_order 와 custom_order_item 수량체크
		-- 서비스팀(나혜린) 요청 : 이상민 20190510
		IF EXISTS ( 
				SELECT ISNULL(item_count,0) 
				FROM custom_order_item 
				WHERE order_seq = @order_seq AND card_seq = @card_seq 
					AND ISNULL(item_count, 0) <> ISNULL(@order_count, 0)
		) 
		BEGIN	
			SET @rslt = 0
			select 'C'
			BREAK
		END

		----------------------------------------------------------------------------------------------
		

		FETCH NEXT FROM item_cursor  INTO @item_type,@isFPrint,@item_count

	END			-- end of while

	CLOSE item_cursor
	DEALLOCATE item_cursor
             ----------------------------------------------------------------------------------------------------
	
	select @rslt	
	return

	err_act1:
		set @rslt = 0
		select @rslt	
		return
	err_act:
		set @rslt = 0
		CLOSE item_cursor
		DEALLOCATE item_cursor
		select @rslt	
		return
		
END











GO
