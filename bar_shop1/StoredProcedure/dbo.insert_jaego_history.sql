IF OBJECT_ID (N'dbo.insert_jaego_history', N'P') IS NOT NULL DROP PROCEDURE dbo.insert_jaego_history
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[insert_jaego_history]
 @p_card_code varchar(20),
 @p_chnum int,
 @p_comment varchar(100),
 @p_admin_id varchar(20)
as
begin
	if Exists(select jaego from CARD_JAEGO where card_code = @p_card_code)
	BEGIN
		-- 최종재고갯수 업데이트
		update CARD_JAEGO set 
			jaego = jaego + @p_chnum
			,reg_date=GETDATE()
			where card_code = @p_card_code
	END
	ELSE 
		insert into CARD_JAEGO(card_code,jaego) values(@p_card_code,@p_chnum)
		
	-- 재고 히스토리 추가
	insert into card_jaego_history(
		card_code,
		chnum,
		chcomment,
		order_seq,			
		now_jaego,
		admin_id) values
		(			
		@p_card_code,
		@p_chnum,
		@p_comment,
		0,
		(select jaego from CARD_JAEGO where card_code = @p_card_code),
		@p_admin_id
		)

end


GO
