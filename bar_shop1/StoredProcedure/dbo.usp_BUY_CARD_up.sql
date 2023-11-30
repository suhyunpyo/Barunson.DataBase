IF OBJECT_ID (N'dbo.usp_BUY_CARD_up', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_BUY_CARD_up
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*********************************************************
	신용카드로 결제후 결제가 정상적으로 이루어졌으면 
	buy_CARD  /  buy_CARD_CONTENT  / buy_SETTLE_INFO  
	---------     -------------------      ----------------
	테이블로 인서트 
**********************************************************/
			
CREATE PROC [dbo].[usp_BUY_CARD_up] 
(
	@b_c_seq		[int],	--카드구매번호
	--ewed_buy_CARD
	@buy_card_MAXDATE	[datetime], 
	
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
	@buy_PLACE	[varchar](100) ,
	@buy_MENT	[text] ,	
	@buy_MENT2	[text] 
)
AS 
SET XACT_ABORT ON
SET NOCOUNT ON
Begin Tran
	--------------------------
	--------------------------
	UPDATE ewed_BUY_CARD set  buy_card_MAXDATE=@buy_card_MAXDATE 
	WHERE buy_card_SEQ=@b_c_seq 
	
	--------------------------
	--------------------------
	UPDATE ewed_BUY_CARD_CONTENT set  buy_GROOM=@buy_GROOM, buy_BRIDE=@buy_BRIDE, 
	buy_YEAR=@buy_YEAR, buy_MONTH=@buy_MONTH, 
	buy_DAY=@buy_DAY, buy_WEEK=@buy_WEEK, buy_AMPM=@buy_AMPM, buy_HOUR=@buy_HOUR, 
	buy_MINUTE=@buy_MINUTE, buy_LUNAR=@buy_LUNAR, buy_PLACE=@buy_PLACE, buy_MENT=@buy_MENT,
	buy_MENT2=@buy_MENT2 
	WHERE buy_card_SEQ=@b_c_seq 
	
Commit Tran
GO
