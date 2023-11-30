IF OBJECT_ID (N'dbo.SP_SELECT_BARUNSONCARD_GROUPOPTION', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_BARUNSONCARD_GROUPOPTION
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec sp_S2GroupOption 1,0  
CREATE PROCEDURE [dbo].[SP_SELECT_BARUNSONCARD_GROUPOPTION]  
      @CARDITEMGROUP_SEQ INT
    , @CARDITEM_SEQ INT  
WITH EXEC AS CALLER  
AS  
    IF @CARDITEM_SEQ = 0   
        BEGIN  
            SELECT   
            CardSeq = A.CARD_SEQ,    
            CardCode = A.CARD_CODE,  
            CardName = A.CARD_NAME,  
            DiffPrice = A.CARD_PRICE,  
            CardPrice = A.CARD_PRICE,  
            SetPrice = A.CARDSET_PRICE,  
            (SELECT CARD_TEXT_PREMIER FROM S2_CARDDETAIL WHERE CARD_SEQ = A.CARD_SEQ) CatdTextPremier,  
            CARD_IMAGE  
            FROM S2_CARD A JOIN S2_CARDITEMGROUP B ON A.CARD_SEQ = B.CARD_SEQ  
            WHERE 1 = 1
            AND B.CARDITEMGROUP_SEQ <> 0  
            ORDER BY A.CARD_PRICE  
        END    
    ELSE  
        BEGIN  
            DECLARE @CARD_PRICE INT  
            SET @CARD_PRICE = 0  
     
            SELECT @CARD_PRICE = CARD_PRICE FROM S2_CARD WHERE CARD_SEQ = @CARDITEM_SEQ  
     
            SELECT   
            CardSeq = A.CARD_SEQ,    
            CardCode = A.CARD_CODE,  
            CardName = A.CARD_NAME,  
            DiffPrice = A.CARD_PRICE - @CARD_PRICE,
            CardPrice = A.CARD_PRICE,  
            SetPrice = A.CARDSET_PRICE,  
            (SELECT CARD_TEXT_PREMIER FROM S2_CARDDETAIL WHERE CARD_SEQ = A.CARD_SEQ) CatdTextPremier,  
            CARD_IMAGE  
            FROM S2_CARD A JOIN S2_CARDITEMGROUP B ON A.CARD_SEQ = B.CARD_SEQ  
            WHERE 1 = 1
            AND B.CARDITEMGROUP_SEQ <> 0  
            ORDER BY A.CARD_PRICE - @CARD_PRICE   
        END
GO
