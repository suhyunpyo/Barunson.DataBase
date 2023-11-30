IF OBJECT_ID (N'dbo.up_select_ranking1_web_new_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_ranking1_web_new_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중(daniel, kim)
-- Create date: 2014-03-25
-- Description:	비핸즈 신상품 리스트 출력 product_list_new_res.asp



/*
    18.02.20
    위의 이 개똥같은 놈이 만든 쿼리 변경함
    기존 페이지의 호환성을 유지하기 위해
        (
            SELECT를 두개 반환해야함
                SELECT TOT
                SELECT LIST
        )
    TEMP TABLE을 사용함
    모바일 사이트에서도 사용하고 있는데, 자바스크립트에서는 소문자로 사용하고 있기 때문에,
    반드시 소문자로 반환해야함

    exec up_select_ranking1_web_new_list 5001, 'PHOTO_CARD_EVENT', 'ALL', 1, 30, 'PHOTO_CARD_EVENT', 'RECOM', 'ASC', 300, 0, 0
*/



-- =============================================
CREATE PROCEDURE [dbo].[up_select_ranking1_web_new_list]
	@COMPANY_SEQ        AS INT		        -- 회사고유코드
,   @TABGUBUN           AS NVARCHAR(20)	    -- 탭구분(추천, 신상품, ETC)
,   @BRAND              AS NVARCHAR(20) 	-- 고유브랜드(없을경우 ALL값 넘겨받으면 됨)
,   @PAGE	            INT 				-- 페이지넘버
,   @PAGESIZE           INT 				-- 페이지사이즈(페이지당 노출갯수)
,   @CODE	            NVARCHAR(20)		-- 고유코드(신상품:NEW 스타일별:STYLE)
,   @ORDERBY            NVARCHAR(20)		-- 정렬컬럼
,   @SEQUENCE	        NVARCHAR(20)	    -- 정렬조건(ASC, DESC)
,   @ORDER_NUM	        INT 				-- 주문수량
,   @JEHYU	            INT
,   @TOT				INT OUTPUT	        -- 총갯수

AS
BEGIN

	SET NOCOUNT ON;

	SELECT  ranking.itemseq
        ,   ranking.itemvalue
        ,   ranking.itemvalue2
        ,   sc.card_name
        ,   sc.card_code
        ,   sc.cardbrand
        ,   sc.cardset_price
        ,   sc.card_seq
        ,   sc.regdate
        ,   ranking.brand_all
        ,   CONVERT(INTEGER, SCD.DISCOUNT_RATE) AS discount_rate
        ,   cardimage_filename
        ,   scss.isjumun
        ,   scss.isnew
        ,   scss.isbest
        ,   scss.isextra
        ,   scss.issale
        ,   scss.isextra2
        ,   scss.isrecommend
        ,   scss.issspre
        ,   scss.company_seq
        ,   sco.issample
        ,   ISNULL(SCO.ISFSC, '0') AS isfsc
        ,   scss.ranking_m
        ,   ISNULL(SCSS.ISBGCOLOR, '0') AS isbgcolor
		,   CASE WHEN SCK_CUSTOM.CARDKIND_SEQ IS NULL THEN 0 ELSE 1 END custom_card_yn
        ,   CASE WHEN BHANDSCARD_ONLY_CARD.CARD_SEQ IS NOT NULL THEN 'Y' ELSE 'N' END AS bhandscard_only_card_yorn
        ,   ISNULL(POST.POST_CNT, 0) AS post_cnt
        ,   ISNULL(POST.SCORE, 0) AS score 
        ,   ISNULL(CARD_LIKE.LIKE_CNT, 0) AS LIKE_CNT
		,   CASE WHEN SCD_STICKER.STICKER_GROUPSEQ IS NULL THEN 0 ELSE SCD_STICKER.STICKER_GROUPSEQ END AS sticker_groupseq
        ,   ROW_NUMBER () 
            OVER 
            (
                ORDER BY
                    CASE 
                            WHEN @SEQUENCE = 'ASC' AND @ORDERBY = 'REGDATE'     THEN REGDATE
                            WHEN @SEQUENCE = 'ASC' AND @ORDERBY = 'BEST'        THEN RANKING_M
                            WHEN @SEQUENCE = 'ASC' AND @ORDERBY = 'PRICE'       THEN CARDSET_PRICE
                            WHEN @SEQUENCE = 'ASC' AND @ORDERBY = 'RECOM'       THEN ITEMSEQ
                            WHEN @SEQUENCE = 'ASC' AND @ORDERBY = 'NEW_EVENT'   THEN ITEMSEQ
                            ELSE 1
                    END ASC
                ,   CASE 
                            WHEN @SEQUENCE = 'DESC' AND @ORDERBY = 'REGDATE'    THEN REGDATE
                            WHEN @SEQUENCE = 'DESC' AND @ORDERBY = 'BEST'       THEN RANKING_M
                            WHEN @SEQUENCE = 'DESC' AND @ORDERBY = 'PRICE'      THEN CARDSET_PRICE
                            WHEN @SEQUENCE = 'DESC' AND @ORDERBY = 'RECOM'      THEN ITEMSEQ
                            WHEN @SEQUENCE = 'DESC' AND @ORDERBY = 'NEW_EVENT'  THEN ITEMSEQ
                            ELSE 1
                    END DESC
            ) AS row_num

    INTO    #CARD_LIST
	FROM    DBO.FN_SPLITIN4ROWS
            (
                    (SELECT ST_CARD_CODE_ARRY   FROM S4_RANKING_SORT WHERE ST_COMPANY_SEQ=@COMPANY_SEQ  AND ST_CODE=@CODE)
                ,   (SELECT ST_TITLE            FROM S4_RANKING_SORT WHERE ST_COMPANY_SEQ=@COMPANY_SEQ  AND ST_CODE=@CODE)
                ,   ','
            ) AS RANKING

    JOIN    S2_CARD             AS SC   ON RANKING.ITEMVALUE        = SC.CARD_SEQ 
	JOIN    S2_CARDSALESSITE    AS SCSS ON SC.CARD_SEQ              = SCSS.CARD_SEQ
	JOIN    S2_CARDDISCOUNT     AS SCD  ON SCSS.CARDDISCOUNT_SEQ    = SCD.CARDDISCOUNT_SEQ
	JOIN    S2_CARDIMAGE        AS SCI	ON RANKING.ITEMVALUE        = SCI.CARD_SEQ 
	JOIN    S2_CARDOPTION       AS SCO  ON SC.CARD_SEQ              = SCO.CARD_SEQ
	JOIN    S2_CARDKIND         AS SCK  ON SCSS.CARD_SEQ            = SCK.CARD_SEQ
	JOIN    S2_CARDKINDINFO     AS SCKI ON SCK.CARDKIND_SEQ         = SCKI.CARDKIND_SEQ
                
    LEFT
    JOIN    (
                SELECT  CARD_SEQ
                    ,   CARDKIND_SEQ
                FROM    S2_CARDKIND
                WHERE   CARDKIND_SEQ = 14
                GROUP BY CARD_SEQ, CARDKIND_SEQ
            ) AS SCK_CUSTOM 
        ON  SCK_CUSTOM.CARD_SEQ = SC.CARD_SEQ

    LEFT
    JOIN    (
                SELECT  CARD_SEQ
                    ,   STICKER_GROUPSEQ
                FROM    S2_CARDDETAIL
            ) AS SCD_STICKER
        ON  SCD_STICKER.CARD_SEQ = SC.CARD_SEQ

    LEFT 
    JOIN   (
                -- 비핸즈카드 전용 디지털카드를 위한 쿼리
                SELECT  SMC.CARD_SEQ
                    ,   MAX(SMCS.COMPANY_SEQ) AS COMPANY_SEQ
                FROM    S4_MD_CHOICE SMC 
                JOIN    S4_MD_CHOICE_STR SMCS ON SMC.MD_SEQ = SMCS.MD_SEQ 
                WHERE   SMC.MD_SEQ = 363 
                GROUP BY SMC.CARD_SEQ
            ) AS BHANDSCARD_ONLY_CARD 
        ON  SC.CARD_SEQ = BHANDSCARD_ONLY_CARD.CARD_SEQ 
        AND SCSS.COMPANY_SEQ = BHANDSCARD_ONLY_CARD.COMPANY_SEQ

	LEFT 
    JOIN    (
                SELECT  CARD_SEQ
                    ,   COUNT(*)        AS POST_CNT
                    ,   AVG(SCORE) * 20 AS SCORE 
                FROM    S2_USERCOMMENT 
                WHERE   COMPANY_SEQ = @COMPANY_SEQ 
                GROUP BY CARD_SEQ
            ) AS POST 
        ON  SCSS.CARD_SEQ = POST.CARD_SEQ
	
	LEFT 
    JOIN    (
                SELECT  CARD_SEQ
                    ,   COUNT(*)        AS LIKE_CNT
                FROM    S2_CARD_LIKE 
                WHERE   COMPANY_SEQ = @COMPANY_SEQ 
                GROUP BY CARD_SEQ
            ) AS CARD_LIKE 
        ON  SCSS.CARD_SEQ = CARD_LIKE.CARD_SEQ

	WHERE   1 = 1
    AND     SCSS.COMPANY_SEQ        = @COMPANY_SEQ 
    AND     SCD.MINCOUNT            = @ORDER_NUM 
    AND     SCI.CARDIMAGE_WSIZE     = '210' 
    AND     SCI.CARDIMAGE_HSIZE     = '210' 
    AND     SCI.CARDIMAGE_DIV       = 'E' 
    AND     SCSS.ISDISPLAY          = '1' 
    AND     SCI.COMPANY_SEQ         = @COMPANY_SEQ 
    AND     SCKI.CARDKIND_SEQ       = 1 
    AND     CASE 
                    WHEN @COMPANY_SEQ = 5001 AND @CODE = 'NEW' 
                    THEN SCSS.ISNEW 
                    ELSE '1' 
            END = '1'
    AND     CASE 
                    WHEN @jehyu <> '1' 
                    THEN SCSS.ISJEHYU 
                    ELSE '0' 
            END <> '1'
    AND     CASE 
                    WHEN @BRAND = 'ALL' 
                    THEN BRAND_ALL 
                    ELSE SC.CARDBRAND 
            END = @BRAND

    AND     (
                CASE 
                        WHEN @COMPANY_SEQ = 5001 AND @CODE = 'NEW' AND (@TABGUBUN = 'NEW_EVENT' OR @ORDERBY = 'NEW_EVENT')
                        THEN SCSS.CARD_SEQ
                        ELSE 1
                END 
                NOT IN 
                (SELECT CARD_SEQ FROM S2_CARD WHERE CARD_CODE IN ('BH8216' , 'BH8230' , 'BH8712', 'BH8760', 'BH8761', 'BH8762', 'BH8763', 'BH8764', 'BH8765', 'BH8767', 'BH8766'))
            )

    --AND     (
    --            CASE 
    --                    WHEN @COMPANY_SEQ = 5001 AND @CODE = 'PHOTO_CARD_EVENT'
    --                    THEN SCSS.CARD_SEQ
    --                    ELSE 1
    --            END 
    --            NOT IN 
    --            (SELECT CARD_SEQ FROM S2_CARD WHERE CARD_CODE IN ('BH8723', 'BH8716', 'BH8714', 'BH8713', 'BH8712', 'BH7815', 'BH7814', 'BH7813', 'BH7812', 'BH7808', 'BH7807', 'BH7806', 'BH7805', 'BH7802', 'BH7804', 'BH7797', 'BH7725', 'BH7740', 'BH7739', 'BH7716', 'BH7726'))
    --        )
    --AND     (
    --            CASE 
    --                    WHEN @COMPANY_SEQ = 5001 AND @CODE = 'PHOTO_CARD_EVENT'
    --                    THEN SCKI.CARDKIND_SEQ
    --                    ELSE 14
    --            END 
    --            = 14
    --        )

    SET @TOT = (SELECT COUNT(*) FROM #CARD_LIST)

    SELECT  @tot

    SELECT  *
    FROM    #CARD_LIST
    WHERE   1 = 1
    AND     ROW_NUM > (@PAGE - 1) * @PAGESIZE  
    AND     ROW_NUM <= @PAGE * @PAGESIZE 

    DROP TABLE #CARD_LIST;

END

select * from ( select distinct z.seq, z.md_seq, z.sorting_num, a.company_seq, a.card_seq, a.isbest, a.isnew, a.issale, a.isextra, b.card_code, b.cardbrand, b.card_name, b.cardset_price, c.card_content, c.minimum_count, f.carddiscount_seq, f.discount_rate, g.cardimage_filename, h.isdigitalcolor, h.digitalcolor, h.istechnic, b.regdate, a.ranking_w, a.ranking_m, a.SampRankNo,	round((b.cardset_price*(100-f.discount_rate)/100),0) as cardsale_price, round((b.cardset_price*(100-ff.discount_rate)/100),0) as cardsale_price_orderby, ff.discount_rate as discount_rate2, h.issample From s4_MD_choice z join s2_cardsalessite a on z.card_seq = a.card_seq join s2_card b on a.card_seq=b.card_seq join s2_carddetail c on a.card_seq=c.card_seq join s2_cardkind d on a.card_seq=d.card_seq join s2_cardkindinfo e on d.cardkind_seq=e.cardkind_seq join s2_carddiscount f on a.carddiscount_seq = f.carddiscount_seq join s2_carddiscount ff on a.carddiscount_seq = ff.carddiscount_seq join s2_cardimage g on a.card_seq=g.card_seq join s2_cardoption h on a.card_seq=h.card_seq Where a.company_seq = 5001 and a.isdisplay = '1' and f.mincount = 400 and ff.mincount = 400 and g.cardimage_wsize = '210' and g.cardimage_hsize='210' and g.cardimage_div = 'E' and g.company_seq = 5001	and z.md_seq in ( 612 ) ) a order by a.sorting_num asc 
GO
