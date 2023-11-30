IF OBJECT_ID (N'dbo.usp_BUY_CARD', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_BUY_CARD
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*********************************************************
	신용카드로 결제후 결제가 정상적으로 이루어졌으면 
	buy_CARD  /  buy_CARD_CONTENT  / buy_SETTLE_INFO  
	---------     -------------------      ----------------
	테이블로 인서트 
**********************************************************/
			
CREATE PROC [dbo].[usp_BUY_CARD]
(
	--ewed_buy_CARD
	@buy_card_UID		[varchar](16),
	@buy_STATUS		[tinyint] ,
	@CARD_SEQ		[int] ,
	@buy_card_DATE		[datetime] ,
	@buy_card_MAXDATE	[datetime] ,
	@buy_card_price 	[int] ,
	--ewed_BUY_CARD_CONTENT
	@buy_GROOM	[varchar](50) ,
	@buy_BRIDE	[varchar](50) ,
	@buy_YEAR	[char](4) ,	
	@buy_MONTH	[char](2) ,	
	@buy_DAY	[char](2) ,	
	@buy_WEEK	[char](1) ,	
	@buy_AMPM	[char](1) ,	
	@buy_HOUR	[char](2) ,	
	@buy_MINUTE	[char](2) ,	
	@buy_LUNAR	[varchar](50) ,
	@buy_PLACE	[varchar](50) ,
	@buy_MENT	[text] ,	
	@buy_MENT2	[text] ,	
	--ewed_BUY_SETTLE_INFO	
	@TID		[varchar](50) ,
	@ResultCode	[char](2) ,	
	@ResultMsg	[varchar](100) ,	
	@PayMethod	[varchar](20) ,
	@AuthCode	[varchar](20) ,
	@CardQuota	[char](2) ,	
	@CardCode	[char](2) ,	
	@PGAuthDate	[varchar](8) ,	
	@PGAuthTime	[varchar](6)
	
)
AS 
SET XACT_ABORT ON
SET NOCOUNT ON
Begin Tran
	DECLARE @b_c_seq  int	--구매카드번호
	SET  select @b_c_seq= max(buy_card_SEQ) + 1  FROM ewed_BUY_CARD 
	IF @b_c_seq is null
		SET @b_c_seq = 1
	--------------------------
	--------------------------
	INSERT INTO ewed_BUY_CARD 
	( buy_card_SEQ, buy_card_UID,  buy_STATUS,     CARD_SEQ,    buy_card_DATE,   buy_card_MAXDATE,    buy_card_price) 
	VALUES 
	( @b_c_seq,     @buy_card_UID, @buy_STATUS, @CARD_SEQ, @buy_card_DATE, @buy_card_MAXDATE, @buy_card_price)
	--------------------------
	--------------------------
	INSERT INTO ewed_BUY_CARD_CONTENT 
	(Buy_card_SEQ, Buy_GROOM, Buy_BRIDE, Buy_YEAR, Buy_MONTH, Buy_DAY, Buy_WEEK, Buy_AMPM, 
	 Buy_HOUR, Buy_MINUTE, Buy_LUNAR, Buy_PLACE, Buy_MENT, Buy_MENT2) 
	VALUES 
	( @b_c_seq,  @Buy_GROOM, @Buy_BRIDE, @Buy_YEAR, @Buy_MONTH, @Buy_DAY, @Buy_WEEK, @Buy_AMPM, 
	 @Buy_HOUR, @Buy_MINUTE, @Buy_LUNAR, @Buy_PLACE, @Buy_MENT, @Buy_MENT2) 
	--------------------------
	--------------------------
	INSERT INTO ewed_BUY_SETTLE_INFO
	(Buy_card_SEQ, TID, ResultCode, ResultMsg, PayMethod, AuthCode, CardQuota, 
	CardCode, PGAuthDate, PGAuthTime ) 
	VALUES 
	( @b_c_seq,  @TID, @ResultCode, @ResultMsg, @PayMethod, @AuthCode, @CardQuota, 
	@CardCode, @PGAuthDate, @PGAuthTime) 		
	
Commit Tran
GO
