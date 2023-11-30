IF OBJECT_ID (N'dbo.SELECT_S2_CARD_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SELECT_S2_CARD_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
    
    EXEC SELECT_S2_CARD_LIST 5001, 130, 130, 'E', 1, 300, 57, 16, 1, 'sortingnum desc'

*/

CREATE PROCEDURE [dbo].[SELECT_S2_CARD_LIST]
    @P_COMPANY_SEQ          AS INT
,   @P_IMAGE_SIZE_WIDTH     AS VARCHAR(10)
,   @P_IMAGE_SIZE_HEIGHT    AS VARCHAR(10)
,   @P_IMAGE_TYPE           AS VARCHAR(10)
,   @P_DISPLAY_TYPE         AS VARCHAR(1)
,   @P_COUNT                AS INT
,   @P_MD_SEQ               AS INT
,   @P_PAGE_SIZE            AS INT
,   @P_PAGE_NUMBER          AS INT
,   @P_ORDER_BY             AS VARCHAR(500)
AS
BEGIN
    
    SET NOCOUNT ON;

    SELECT  DISTINCT
            SCSS.CARD_SEQ                   AS CardSeq
        ,   SC.CARD_CODE                    AS CardCode
        ,   SC.CARD_NAME                    AS CardName
        ,   SCI.CARDIMAGE_FILENAME          AS ImageFileName
        ,   ISNULL(SCSS.RANKING_W, 999)     AS RankingWeek
        ,   CONVERT(INT, ROUND((SC.CARDSET_PRICE * (100 - SCDIS.DISCOUNT_RATE) / 100), 0)) * @P_COUNT AS SalePrice
    INTO    #CARD
    FROM    S2_CARDSALESSITE    AS SCSS	
    JOIN	S2_CARD             AS SC       ON  SCSS.CARD_SEQ = SC.CARD_SEQ
    JOIN	S2_CARDDETAIL       AS SCD		ON	SCSS.CARD_SEQ = SCD.CARD_SEQ
    JOIN	S2_CARDIMAGE        AS SCI		ON	SCSS.CARD_SEQ = SCI.CARD_SEQ
    JOIN	S2_CARDDISCOUNT     AS SCDIS    ON	SCSS.CARDDISCOUNT_SEQ = SCDIS.CARDDISCOUNT_SEQ
    WHERE   1 = 1
    AND     SCI.CARDIMAGE_WSIZE = @P_IMAGE_SIZE_WIDTH
    AND		SCI.CARDIMAGE_HSIZE = @P_IMAGE_SIZE_HEIGHT
    AND		SCI.CARDIMAGE_DIV = @P_IMAGE_TYPE
    AND		SCSS.ISDISPLAY = 1
    AND		SCI.COMPANY_SEQ = @P_COMPANY_SEQ
    AND		SCSS.COMPANY_SEQ = @P_COMPANY_SEQ
    AND		SCDIS.MINCOUNT = @P_COUNT
    AND     (@P_DISPLAY_TYPE = '' OR SCSS.ISDISPLAY = @P_DISPLAY_TYPE)

    IF @P_MD_SEQ > 0 
        BEGIN
            
            ;WITH CTE AS
            (
                SELECT  #C.*
                    ,   SMC.MD_SEQ      AS MdSeq
                    ,   SMC.SEQ         AS Seq
                    ,   SMC.SORTING_NUM AS SortingNum
                FROM    #CARD           AS #C
                JOIN    S4_MD_CHOICE    AS SMC  ON #C.CardSeq = SMC.CARD_SEQ
                WHERE   1 = 1
                AND     SMC.MD_SEQ = @P_MD_SEQ
            )
            SELECT  *
            FROM    CTE
            WHERE   1 = 1
            ORDER   BY 
                    CASE WHEN CHARINDEX('SORTINGNUM ASC' , @P_ORDER_BY) > 0 THEN SortingNum ELSE 1 END ASC
                ,   CASE WHEN CHARINDEX('SORTINGNUM DESC', @P_ORDER_BY) > 0 THEN SortingNum ELSE 1 END DESC
            OFFSET ((@P_PAGE_NUMBER - 1) * @P_PAGE_SIZE) ROWS
            FETCH NEXT @P_PAGE_SIZE ROWS ONLY;

        END
    ELSE 
        BEGIN
            
            -- 임시
            -- 사용하는 용도에 맞게 변경 하세요
            SELECT  *
            FROM    #CARD

        END

END


														
GO
