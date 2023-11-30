IF OBJECT_ID (N'dbo.SP_SELECT_CARD_INFO_FOR_MOBILE_MAIN_COLLECTION_BHANDS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CARD_INFO_FOR_MOBILE_MAIN_COLLECTION_BHANDS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC [SP_SELECT_CARD_INFO_FOR_MOBILE_MAIN_COLLECTION] 'BH5143|BH5138|BH5134|BH5148|BH5153|BH5135|BH5141|BH5136|BH5146'

*/

CREATE PROC [dbo].[SP_SELECT_CARD_INFO_FOR_MOBILE_MAIN_COLLECTION_BHANDS]  
    @P_CARD_CODES AS VARCHAR(4000)

AS  

BEGIN
    
    SET NOCOUNT ON;

    DECLARE @T_CARD_CODE TABLE
    (
            SORTING_NUM INT IDENTITY(1,1) NOT NULL
	    ,   CARD_CODE VARCHAR(20) NOT NULL
    )

    INSERT INTO @T_CARD_CODE (CARD_CODE)
    SELECT * FROM dbo.[ufn_SplitTable](@P_CARD_CODES, '|')
	


    SELECT  SC.CARD_SEQ                                                                                    
        ,   SC.CARD_CODE                                                                                   
        ,   SC.CARD_NAME                                                                                   
        ,   SC.CARD_CODE + '/' + SCI.CARDIMAGE_FILENAME AS CARDIMAGE_FILENAME                              
        ,   SC.CARDSET_PRICE                                                                               
        ,   CONVERT(INT, ROUND(SC.CARDSET_PRICE * ((100 - SCD.DISCOUNT_RATE) / 100), 0)) AS CARDSALES_PRICE
        ,   SCD.DISCOUNT_RATE                                                                                     
    FROM    S2_CARD SC                                                                                      
    JOIN    @T_CARD_CODE TCC ON SC.CARD_CODE = TCC.CARD_CODE                                                 
    JOIN    S2_CARDSALESSITE SCSS ON SC.CARD_SEQ = SCSS.CARD_SEQ                                            
    JOIN    S2_CARDDISCOUNT SCD ON SCSS.CARDDISCOUNT_SEQ = SCD.CARDDISCOUNT_SEQ                             
    JOIN    (
                SELECT  CARD_SEQ, MAX(CARDIMAGE_FILENAME) AS CARDIMAGE_FILENAME
                FROM    S2_CARDIMAGE
                WHERE   1 = 1
                AND     CARDIMAGE_HSIZE = '303'
                AND     CARDIMAGE_WSIZE = '303'
                AND     COMPANY_SEQ = 5006
                GROUP BY CARD_SEQ
            ) SCI ON SC.CARD_SEQ = SCI.CARD_SEQ 
    WHERE   1 = 1                                                                                           
    AND     SCSS.COMPANY_SEQ = 5006
    AND     SCD.MINCOUNT = 300     
    AND     SCSS.ISDISPLAY = 1
    ORDER BY TCC.SORTING_NUM ASC                                                                       



END

GO
