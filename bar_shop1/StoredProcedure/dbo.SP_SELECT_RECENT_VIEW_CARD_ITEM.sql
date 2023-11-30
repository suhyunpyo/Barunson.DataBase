IF OBJECT_ID (N'dbo.SP_SELECT_RECENT_VIEW_CARD_ITEM', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_RECENT_VIEW_CARD_ITEM
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_SELECT_RECENT_VIEW_CARD_ITEM]
    @P_COMPANY_SEQ          AS INT
,   @P_UID                  AS VARCHAR(50)
,   @P_GUID                 AS VARCHAR(50)
,   @P_ORDER_NUM            AS INT
,   @P_IMAGE_SIZE_WIDTH     AS INT
,   @P_IMAGE_SIZE_HEIGHT    AS INT
,   @P_CURRENT_PAGE_NUMBER  AS INT
,   @P_PAGE_SIZE            AS INT

AS

BEGIN    
    
    SELECT  *
    FROM    (
                SELECT  ROW_NUMBER()OVER( ORDER BY RVC.REG_DATE DESC ) AS rownum
                    ,   COUNT(*) OVER() AS totalItemCount
                    ,   CEILING(CAST((COUNT(*) OVER()) AS FLOAT) / @P_PAGE_SIZE) AS totalPageSize
                    ,   SCSS.card_seq
                    ,   SCSS.company_seq
                    ,   SC.cardbrand
                    ,   SCSS.isbest
                    ,   SCSS.isnew
                    ,   SCSS.isextra
                    ,   SC.card_code
                    ,   SC.card_name
                    ,   SC.cardset_price
                    ,   SCD.card_content
                    ,   SCDC.carddiscount_seq
                    ,   SCDC.discount_rate
                    ,   SCI.cardimage_filename
                    ,   ROUND((SC.CARDSET_PRICE * (100 - SCDC.DISCOUNT_RATE) / 100), 0) AS cardsale_price
                    ,   SCO.issample

                FROM    (
                            SELECT  RVCI.CARD_SEQ
                                ,   MAX(RVCI.REG_DATE) AS REG_DATE
                            FROM    RECENT_VIEW_CARD_ITEM RVCI 
                            JOIN    RECENT_VIEW_CARD_MST RVCM ON RVCI.RECENT_VIEW_CARD_MST_SEQ = RVCM.RECENT_VIEW_CARD_MST_SEQ
                            WHERE   1 = 1
                            AND     RVCM.COMPANY_SEQ = @P_COMPANY_SEQ
                            AND     CASE WHEN @P_UID = '' THEN '' ELSE RVCM.UID END
                                    =
                                    CASE WHEN @P_UID = '' THEN '' ELSE @P_UID   END

                            AND     CASE WHEN @P_UID <> '' THEN '' ELSE RVCM.GUID END
                                    =
                                    CASE WHEN @P_UID <> '' THEN '' ELSE @P_GUID END
                            GROUP BY RVCI.CARD_SEQ
                        ) RVC 
                JOIN    S2_CARDSALESSITE SCSS   ON RVC.CARD_SEQ             = SCSS.CARD_SEQ  
                JOIN    S2_CARD SC              ON SCSS.CARD_SEQ            = SC.CARD_SEQ 
                JOIN    S2_CARDDETAIL SCD       ON SCSS.CARD_SEQ            = SCD.CARD_SEQ 
                JOIN    S2_CARDDISCOUNT SCDC    ON SCSS.CARDDISCOUNT_SEQ    = SCDC.CARDDISCOUNT_SEQ 
                JOIN    S2_CARDIMAGE SCI        ON SCSS.CARD_SEQ            = SCI.CARD_SEQ 
                JOIN    S2_CARDOPTION SCO       ON SCSS.CARD_SEQ            = SCO.CARD_SEQ 

                WHERE   1 = 1
                AND     SCDC.MINCOUNT       = @P_ORDER_NUM
                AND     SCSS.COMPANY_SEQ    = @P_COMPANY_SEQ
                AND     SCI.COMPANY_SEQ     = @P_COMPANY_SEQ
                AND     SCI.CARDIMAGE_DIV   = 'E'
                AND     SCI.CARDIMAGE_WSIZE = @P_IMAGE_SIZE_WIDTH 
                AND     SCI.CARDIMAGE_HSIZE = @P_IMAGE_SIZE_HEIGHT

            ) A 
        
    WHERE   1 = 1
    AND     A.ROWNUM > (@P_CURRENT_PAGE_NUMBER - 1) * @P_PAGE_SIZE
    AND     A.ROWNUM <= @P_CURRENT_PAGE_NUMBER * @P_PAGE_SIZE

END
GO
