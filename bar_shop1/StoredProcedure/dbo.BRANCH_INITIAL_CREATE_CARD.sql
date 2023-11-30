IF OBJECT_ID (N'dbo.BRANCH_INITIAL_CREATE_CARD', N'P') IS NOT NULL DROP PROCEDURE dbo.BRANCH_INITIAL_CREATE_CARD
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
	작성정보   : [2005-09-26] 	
	내용	  : 대리점사이트 추가로 인한 초기작업 
		    - 카드제품(Default) - 최초한번! 
		    - 기준은 200번 한나카드로 잡고있음!
	수정정보   : 
*/
CREATE   PROCEDURE [dbo].[BRANCH_INITIAL_CREATE_CARD]
	@company_seq	INT
AS

DECLARE @card_seq INT
DECLARE @card_group  smallint
DECLARE @card_max INT

DECLARE Cur_Product_Master CURSOR 
FOR
    SELECT	card_seq, card_group
    FROM	dbo.card
    where card_group = 200
OPEN Cur_Product_Master

FETCH NEXT FROM Cur_Product_Master INTO @card_seq, @card_group

WHILE @@FETCH_STATUS = 0
BEGIN    
    select @card_max = max(card_seq) from card
    set @card_max = @card_max + 1
    set @card_group = @company_seq

    insert card
    SELECT @card_max, @card_group, [CARD_CATE], [CARD_CATEGORY_SEQ], [CARD_KIND], [CARD_CODE], [ERP_CODE], [CARD_PRICE_CUSTOMER], [DISPLAY_YES_OR_NO], [B2B_YES_OR_NO], [RECOMEND_YES_OR_NO], [CARD_IMG_S], [CARD_IMG_XS], [CARD_IMG_MS], [CARD_IMG_M1], [CARD_IMG_M2], [CARD_IMG_M3], [CARD_IMG_M4], [CARD_IMG_M5], [CARD_IMG_M6], [CARD_IMG_B1], [CARD_IMG_B2], [CARD_IMG_B4], [CARD_IMG_B5], [CARD_IMG_B6], [CARD_IMG_B7], [CARD_IMG_B8], [CARD_IMG_B9], [CARD_IMG_B10], [CARD_PAPER], [CARD_SIZE], [CARD_OSI], [COMPANY], [PRODUCE_YEAR], [set_seq], [SALES_RANKING], [CARD_DESCRIPTION], [REGIST_DATE], [LAST_UPDATE], [CARD_IMG_B3], [CARD_ENVELOPE], [CARD_PRICE], [CARD_SRC_PRICE], [CARD_BRANCH_PRICE], [CARD_ONLINE_BRANCH_PRICE], [CARD_B2B_PRICE], [CARD_DISCOUNT_RATE], [CARD_IMG_D], [DISRATE_TYPE], [BEST_YES_OR_NO], [BEST_STR], [ONLINE_YES_OR_NO], [NEW_YES_OR_NO], [ISHAVE], [ISHAVE_NUM], [ISInPaper], [IsHandMade], [IsGold], [IsRibon], [IsFlower], [IsHeart], [IsWonang], [IsYu], [IsHanji], [IsSample], [IsOffDisplay], [IsOffBest], [IsOffDDisplay], [Env_code], [cont_code], [acc_code], [env_code_o], [cont_code_o], [acc_seq], [env_seq], [cont_seq], [cont_seq_b2b], [env_seq_b2b], [Is100], [Is1001], [Is1002], [Is1003], [Is1004], [Is1005], [Is1006], [Is1007], [Is1008], [Is1009], [Is200], [Is400], [Is300], [ADMIN_ID], [CARD_MARKET_PRICE]
    FROM [dbo].[card]
    where card_seq = @card_seq

    FETCH NEXT FROM Cur_Product_Master INTO @card_seq, @card_group
END

CLOSE Cur_Product_Master
DEALLOCATE Cur_Product_Master
GO
