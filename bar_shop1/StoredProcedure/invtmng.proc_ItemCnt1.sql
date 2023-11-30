IF OBJECT_ID (N'invtmng.proc_ItemCnt1', N'P') IS NOT NULL DROP PROCEDURE invtmng.proc_ItemCnt1
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	EXEC [invtmng].[proc_ItemCnt1] 4028700 
	EXEC [invtmng].[proc_ItemCnt1_] 3066748
*/

CREATE Procedure [invtmng].[proc_ItemCnt1]
@order_seq int
as
begin

	DECLARE @order_type char(1),@last_total_price int,@settle_price int,@card_seq int,@order_count int,@card_count int,@DeliveryCnt tinyint
	DECLARE @isFPrint char(1),@item_type char(1),@item_count int
	DECLARE @rslt tinyint
	DECLARE @pay_type char(1)
	DECLARE @order_add_type char(1) 

	set @rslt = 1

	select	@order_type			=	order_type
		,	@last_total_price	=	last_total_price
		,	@settle_price		=	settle_price
		,	@card_seq			=	card_seq
		,	@order_count		=	order_count 
		,   @pay_type	        =   pay_type
		,   @order_add_type     =   order_add_type
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
		
    
    -- 식권 수량 검증

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

	--print @rslt
	
	-- 주문 수량 VS 배송 수량 검증
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
		AND	    B.isNotPrint<>'1'
		
	) A
	GROUP BY A.id
	
	OPEN delivery_cursor
	
	FETCH NEXT FROM delivery_cursor INTO @id, @cnt
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		IF (SELECT ISNULL(SUM(item_count), 0) FROM DELIVERY_INFO_DETAIL WHERE order_seq = @order_seq AND item_id = @id GROUP BY item_id) <> @cnt
			BEGIN	
				SET @rslt = 0
					-- print 'delivery_info_detail error'
				BREAK
			END

		FETCH NEXT FROM delivery_cursor  INTO @id, @cnt

	END	
	
	CLOSE delivery_cursor
	DEALLOCATE delivery_cursor

	--//주문 수량 VS 배송 수량 검증 
    ----------------------------------------------------------------------------------------------------
	DECLARE item_cursor CURSOR FOR 
	select case print_type when 'S' then 'B' else print_type end as print_type,isFPrint,sum(print_count) as pcount from custom_order_plist where order_seq = @order_seq group by print_type,isFPrint
	
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @item_type,@isFPrint,@item_count
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
	-----------------------------------------------------------------------------------------------
	-- 수량 검증
	IF (select sum(isnull(item_count,0)) from custom_order_item where order_seq = @order_seq and item_type=@item_type) <> @item_count 
	begin	
		set @rslt = 0
		--print 'custom_order_plist/item error'
		break
	end


	-- custom_order 와 custom_order_item 수량체크
	-- 서비스팀(나혜린) 요청 : 이상민 20190510
	IF EXISTS ( 
			SELECT ISNULL(item_count,0) 
			FROM custom_order_item sae
			WHERE order_seq = @order_seq AND card_seq = @card_seq 
				AND ISNULL(item_count, 0) <> ISNULL(@order_count, 0)
	) 
	BEGIN	
		SET @rslt = 0
		--print 'custom_order.order_count/item error'
		BREAK
	END

	----------------------------------------------------------------------------------------------
		

		FETCH NEXT FROM item_cursor  INTO @item_type,@isFPrint,@item_count

	END			-- end of while

	CLOSE item_cursor
	DEALLOCATE item_cursor
    ----------------------------------------------------------------------------------------------------
	
	IF @pay_type < 4 --사고건이 아닌경우만
	BEGIN
		----------------------------------------------------------------------------------------------------
		-- 봉투수량과 스티커 수량이 일치하는지 확인 - #5973 인쇄대기 넘길때 주문상품 수량검증에서 스티커검증 누락 2020.10.28
		----------------------------------------------------------------------------------------------------
	
		DECLARE @sticker_count INT
		DECLARE @env_count INT

		SELECT @env_count = ISNULL(SUM(item_count),0) FROM custom_order_item WHERE order_seq = @order_seq AND item_type = 'E'
		SELECT @sticker_count = ISNULL(SUM(item_count),0) FROM custom_order_item WHERE order_seq = @order_seq AND item_type = 'S'

		--IF @env_count > 0 and @sticker_count > 0 and @env_count <> @sticker_count
		IF @env_count > 0 and @sticker_count > 0 and @env_count > @sticker_count -- CS운영이슈로 스티커를 수동으로 추가해주는 경우가 있기 때문에 스티커수량이 봉투수량보다 작은경우만 오류로 판정. 2020.11.13
		BEGIN
			SET @rslt = 0
			--print 'sticker/env_count error'
		END

		IF @order_add_type = 0 --기능개선 #6071 [빠] 수량0표시, 검증시 오류 통과 요청 : 단품 추가 주문시, 빠른손 수량 0 으로 표시 → 인쇄대기 넘길때 오류 걸리지 않고 통과 시켜 주세요.
		BEGIN

		/**20220419 표수현 추가  START**/
			
			DECLARE @CARD_CODE VARCHAR(50)
			
			SELECT @CARD_CODE = B.CARD_CODE 
			FROM	CUSTOM_ORDER  A INNER JOIN 
					S2_CARDVIEW B ON A.CARD_SEQ = B.CARD_SEQ  
			WHERE	ORDER_SEQ = @ORDER_SEQ
		
		/**20220419 표수현 추가  END**/

			----------------------------------------------------------------------------------------------------
			-- 주문수량과 인쇄판(카드,내지,약도) 각각의 수량이 일치하는지 확인 - #5996 빠른손 수량 검증 로직 개선 2020.10.29
			----------------------------------------------------------------------------------------------------
			DECLARE plist_cursor CURSOR FOR 

			SELECT	PRINT_TYPE,
					ISFPRINT,
					/**20220419 표수현 추가  START
						BH9252/BH9252M 카드는 카드수량보다 약도카드가 50매 추가되게끔 설정되어있는데
						컨펌완료->인쇄대기 넘길때 항상 수량체크 오류로 걸러짐/ 
						이부분은 오류 아니기때문에 걸러지지 않게 수정요청 
					**/
					PCOUNT = CASE WHEN (@CARD_CODE = 'BH9252' OR @CARD_CODE = 'BH9252M') AND PRINT_TYPE = 'P'  
								  THEN SUM(PRINT_COUNT - 50) 
							 ELSE SUM(PRINT_COUNT) 
							 END
					/**20220419 표수현 추가  END**/
					
					--SUM(PRINT_COUNT) AS PCOUNT 
			FROM	CUSTOM_ORDER_PLIST 
			WHERE	PRINT_TYPE IN ('C','P','I') 
					AND ORDER_SEQ = @ORDER_SEQ 
			GROUP BY PRINT_TYPE, ISFPRINT

			--select print_type,isFPrint,sum(print_count) as pcount from custom_order_plist where print_type IN ('C','P','I') AND order_seq = @order_seq group by print_type,isFPrint
	
			OPEN plist_cursor
	
			FETCH NEXT FROM plist_cursor INTO @item_type,@isFPrint,@item_count
		
			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF @order_count <> @item_count
				BEGIN	
					SET @rslt = 0
					--print 'custom_order.order_count/custom_order_plist.print_count error'
					BREAK
				END
	
				FETCH NEXT FROM plist_cursor  INTO @item_type,@isFPrint,@item_count
			END

			CLOSE plist_cursor
			DEALLOCATE plist_cursor
			----------------------------------------------------------------------------------------------------
		END
	END
	
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
		CLOSE plist_cursor
		DEALLOCATE plist_cursor
		select @rslt
		return
		
END


GO
