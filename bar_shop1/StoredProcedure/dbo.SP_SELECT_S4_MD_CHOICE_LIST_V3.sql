IF OBJECT_ID (N'dbo.SP_SELECT_S4_MD_CHOICE_LIST_V3', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_S4_MD_CHOICE_LIST_V3
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
  
EXEC SP_SELECT_S4_MD_CHOICE_LIST_V3 380, 'Y', 'Y', 300. 5001  
/MD/products.asp로 했을 경우 카드내용포함 프로시저  
  
*/  

CREATE PROCEDURE [dbo].[SP_SELECT_S4_MD_CHOICE_LIST_V3]  
    @MD_SEQ AS INT  
,   @EVENT_OPEN_YORN AS VARCHAR(1) = ''  
,   @VIEW_DIV AS VARCHAR(1) = ''  
, @MIN_COUNT AS INT  
, @COMPANY_SEQ AS INT  
 AS  
BEGIN  
  
    SELECT  ROW_NUMBER() OVER(partition BY A.md_seq ORDER BY A.SORTING_NUM ASC) AS ROW_NUM  
  , *  
  FROM   (SELECT DISTINCT   
       SEQ  
       ,   MD_SEQ  
       ,   SORTING_NUM  
       ,   Z.CARD_SEQ  
       ,   CARD_TEXT  
       ,   ISNULL(MD_TITLE, '') AS MD_TITLE  
       ,   ISNULL(MD_CONTENT, '') AS MD_CONTENT  
       ,   ISNULL(MD_DESC, '') AS MD_DESC  
       ,   replace(ISNULL(IMGFILE_PATH, ''), 'http://', 'https://') AS IMGFILE_PATH  
       ,   CUSTOM_IMG  
       ,   ISNULL(LINK_URL, '') AS LINK_URL  
       ,   LOWER(CASE WHEN UPPER(LINK_TARGET) = '_SELF' THEN '_SELF' ELSE '_BLANK' END) AS LINK_TARGET  
       ,   CLICK_COUNT  
       ,   VIEW_DIV  
       ,   JEHU_VIEW_DIV  
       ,   EVENT_OPEN_YORN  
       ,   Z.ADMIN_ID  
       ,   REG_DATE  
       ,   RECOM_NUM  
       ,   ISNULL(CONVERT(VARCHAR(10), START_DATE, 120), '') AS START_DATE  
       ,   ISNULL(CONVERT(VARCHAR(10), END_DATE, 120), '') AS END_DATE  
       , ISNULL(SNS_SHARE_YORN, 'N') AS SNS_SHARE_YORN  
       , ISNULL(SNS_SHARE_IMAGE_URL, '') AS SNS_SHARE_IMAGE_URL  
       , B.CARD_CODE  
       , B.CARD_NAME  
       , ROUND(( B.CARDSET_PRICE * ( 100 - F.DISCOUNT_RATE) / 100 ), 0) * @MIN_COUNT AS CARDSALES_PRICE  
       , F.DISCOUNT_RATE
	   , F.MINCOUNT
	  FROM    S4_MD_CHOICE Z  
      JOIN S2_CARDSALESSITE A ON A.CARD_SEQ = Z.CARD_SEQ  
      JOIN S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ   
      JOIN S2_CARDDISCOUNT F ON A.CARDDISCOUNT_SEQ = F.CARDDISCOUNT_SEQ  
      WHERE   1 = 1  
      AND     MD_SEQ = @MD_SEQ  
      AND  A.COMPANY_SEQ = @COMPANY_SEQ  
      AND       
        (CASE WHEN @EVENT_OPEN_YORN IN ( 'Y' , 'N' ) THEN EVENT_OPEN_YORN ELSE '' END)  
        =  
        (CASE WHEN @EVENT_OPEN_YORN IN ( 'Y' , 'N' ) THEN @EVENT_OPEN_YORN ELSE '' END)  
  
      AND     (CASE WHEN @VIEW_DIV IN ( 'Y' , 'N' ) THEN VIEW_DIV ELSE '' END)  
        =  
        (CASE WHEN @VIEW_DIV IN ( 'Y' , 'N' ) THEN @VIEW_DIV ELSE '' END)  
  
      --AND     (CASE WHEN @EVENT_OPEN_YORN = ( 'Y' ) THEN CAST(CONVERT(VARCHAR(8), START_DATE, 112) AS NUMERIC) ELSE 0 END)  
      --        <=  
      --        (CASE WHEN @EVENT_OPEN_YORN = ( 'Y' ) THEN CAST(CONVERT(VARCHAR(8), GETDATE(), 112) AS NUMERIC) ELSE 0 END)  
  
      --AND     (CASE WHEN @EVENT_OPEN_YORN = ( 'Y' ) THEN CAST(CONVERT(VARCHAR(8), END_DATE, 112) AS NUMERIC) ELSE 0 END)  
      --        >=  
      --        (CASE WHEN @EVENT_OPEN_YORN = ( 'Y' ) THEN CAST(CONVERT(VARCHAR(8), GETDATE(), 112) AS NUMERIC) ELSE 0 END)  
      AND  F.MINCOUNT = @MIN_COUNT  
      ) A  
      ORDER BY SORTING_NUM ASC  
  
END 
GO
