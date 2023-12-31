USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_SELECT_S4_MD_CHOICE_ONECLICK]    Script Date: 2023-07-26 오후 5:08:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
   
  
ALTER PROCEDURE [dbo].[SP_SELECT_S4_MD_CHOICE_ONECLICK]      
    @COMPANY_SEQ AS INT      
,   @MD_SEQ AS INT    
,   @ST_CODE AS INT  
 AS    
 
BEGIN      
      		SELECT	SC.CARD_SEQ		AS card_seq
			,	SC.CARD_CODE	AS card_code
			,	SC.CARD_NAME	AS card_name
			,	SC.CardSet_Price	AS Card_price
			,	'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/b1.jpg' AS Image_Url
			,	C.ROW_NUM		AS Sorting_Num
			,	SM.md_title		AS md_title
			,	''	AS DisTotPrice
			,	''	AS DisCount_Rate
			,	'http://file.barunsoncard.com/common_img/'	+ SC.Card_Image AS Image_Url2

		FROM	DBO.ufn_SplitTableForRowNum
				(
					(
						SELECT	TOP 1 ST_CARD_CODE_ARRY 
						FROM	S4_RANKING_SORT
						WHERE	1 = 1
						AND		ST_COMPANY_SEQ = @COMPANY_SEQ 		
						AND		ST_MD_SEQ = @MD_SEQ
						AND		ST_Code = @ST_CODE						
					)
					, ','
				) C
		JOIN S2_CARD SC ON C.VALUE = SC.CARD_SEQ		
		JOIN S4_MD_Choice SM ON MD_SEQ = @MD_SEQ AND SEQ = @ST_CODE		
      
END 