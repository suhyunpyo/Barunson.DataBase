IF OBJECT_ID (N'dbo.insert_season_jaego', N'P') IS NOT NULL DROP PROCEDURE dbo.insert_season_jaego
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[insert_season_jaego]
 @p_order_seq int,
 @p_order_type char(1),
 @p_isJumun char(1)
as
begin
	declare @wp_card_code varchar(10)		--주문카드
	declare @wp_chnum int				--재고변동수량
	declare @wp_param int
	declare @wp_str varchar(20)
	
	if @p_isJumun = '1'
	BEGIN
		set @wp_param = -1
		set @wp_str = '주문결제'
	END
	else
	BEGIN
		set @wp_param = 1
		set @wp_str = '주문취소'
	END
	
	
	if @p_order_type = 'P'
	BEGIN
		
		-- 주문카드와 주문수량 가져오기
		select @wp_card_code = CD.card_code
				,@wp_chnum = OI.item_count*@wp_param
			from custom_order_item OI inner join CARD CD on OI.card_seq = CD.CARD_SEQ and OI.item_type = 'C'
			where OI.order_seq = @p_order_seq
		
		-- 최종재고갯수 업데이트
		update CARD_JAEGO set 
			jaego = jaego + @wp_chnum
			,reg_date=GETDATE()
			where card_code = @wp_card_code
		
		-- 재고 히스토리 추가
		insert into card_jaego_history(
			card_code,
			chnum,
			chcomment,
			order_seq,
			now_jaego) values
			(			
			@wp_card_code,
			@wp_chnum,
			@wp_str,
			@p_order_seq,
			(select jaego from CARD_JAEGO where card_code = @wp_card_code)
			)
	END
	ELSE
	BEGIN
		DECLARE @imax int
		DECLARE @i int
		
		DECLARE  @ORDER_ITEM  TABLE( 
                         ROWID INT IDENTITY ( 1 , 1 ), 
                         card_code varchar(20),
                         order_num int
                         ) 
                         
		INSERT @ORDER_ITEM(card_code,order_num)
		SELECT CD.card_code,OI.order_count
		FROM CUSTOM_ETC_ORDER_ITEM OI inner join CARD CD on OI.card_seq = CD.card_seq
		WHERE OI.order_seq = @p_order_seq	
		
		SET @imax = @@ROWCOUNT 
		SET @i = 1 
		
		WHILE (@i <= @imax) 
		BEGIN 
			SELECT 
			   @wp_card_code = card_code,
			   @wp_chnum = order_num * @wp_param
			FROM   @ORDER_ITEM 
			WHERE  ROWID = @i 		

			-- 최종재고갯수 업데이트
			update CARD_JAEGO set 
			jaego = jaego + @wp_chnum
			,reg_date=GETDATE()
			where card_code = @wp_card_code			
			
			-- 재고 히스토리 추가
			insert card_jaego_history(
			card_code,
			chnum,
			chcomment,
			order_seq,
			now_jaego) values
			(			
			@wp_card_code,
			@wp_chnum,
			@wp_str,
			@p_order_seq,
			(select jaego from CARD_JAEGO where card_code = @wp_card_code)
			)
			SET @i = @i + 1
		END
	END
end


GO
