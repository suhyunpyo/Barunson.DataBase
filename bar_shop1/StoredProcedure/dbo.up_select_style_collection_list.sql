IF OBJECT_ID (N'dbo.up_select_style_collection_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_style_collection_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김현기
-- Create date: 2016-01-11
-- exec [up_select_style_collection_list] 5006, 'ALL', 1, 100, '29', '', 'ASC', 400, 0 
-- =============================================
CREATE PROCEDURE [dbo].[up_select_style_collection_list]
	-- Add the parameters for the stored procedure here
	@company_seq	int,
	@brand AS nvarchar(20),		-- 고유브랜드(없을경우 all값 넘겨받으면 됨)
	@page	int,				-- 페이지넘버
	@pagesize int,				-- 페이지사이즈(페이지당 노출갯수)
	@code	nvarchar(20),		-- 시퀀스
	@orderby nvarchar(20),		-- 정렬컬럼
	@Sequence	nvarchar(20),	-- 정렬조건(ASC, DESC)
	@order_num	int,				-- 주문수량
	@tot				int output	-- 총갯수
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE	@T_CNT	INT
	DECLARE	@SQL	nvarchar(1000)

	select @tot = count(*)
	from ( SELECT  SMC.CARD_SEQ, MAX(SMCS.COMPANY_SEQ) AS COMPANY_SEQ
                    FROM    S4_MD_Choice SMC JOIN S4_MD_Choice_Str SMCS ON SMC.MD_SEQ = SMCS.MD_SEQ
                    WHERE   SMC.MD_SEQ = @code
                    GROUP BY SMC.CARD_SEQ) AS A
	left outer join S2_Card AS B	with(nolock) on A.CARD_SEQ = B.Card_Seq 
	join s2_cardsalessite AS C with(nolock) on B.Card_Seq= C.card_seq
	join s2_carddiscount AS D with(nolock) on C.CardDiscount_Seq = D.CardDiscount_Seq
	join s2_cardimage AS E	with(nolock) on A.CARD_SEQ=E.Card_Seq 
	join s2_cardoption AS H on B.card_seq=H.card_seq
	join s2_cardkind AS I on C.card_seq = I.Card_Seq
	join s2_cardkindinfo AS j on I.CardKind_Seq = j.CardKind_Seq
	
    LEFT JOIN   ( 
                     SELECT  SMC.CARD_SEQ, MAX(SMCS.COMPANY_SEQ)AS COMPANY_SEQ ,smc.SORTING_NUM as SORTING_NUM
                    FROM    S4_MD_Choice SMC JOIN S4_MD_Choice_Str SMCS ON SMC.MD_SEQ = SMCS.MD_SEQ
                    WHERE   SMC.MD_SEQ = @code
                    GROUP BY SMC.CARD_SEQ, smc.SORTING_NUM
                ) BHANDSCARD_ONLY_CARD ON C.CARD_SEQ = BHANDSCARD_ONLY_CARD.CARD_SEQ AND C.COMPANY_SEQ = BHANDSCARD_ONLY_CARD.COMPANY_SEQ
	
	where C.Company_Seq=@company_seq and D.MinCount=@order_num and E.CardImage_WSize='210' and E.CardImage_HSize='210' and E.cardimage_div='E' and
	C.IsDisplay='1' and E.Company_Seq=@company_seq and J.CardKind_Seq=1

	select @tot;
		
	select top (@pagesize) BHANDSCARD_ONLY_CARD.SORTING_NUM as ItemSEQ, BHANDSCARD_ONLY_CARD.CARD_SEQ as itemvalue, card_name AS itemvalue2, card_name, card_code, cardbrand, cardset_price, B.card_seq, B.RegDate, 
	'all' as brandall, convert(integer, discount_rate) AS discount_rate , cardimage_filename,
	IsJumun, IsNew, IsBest, IsExtra, IsSale, IsExtra2, isRecommend, isSSPre, C.Company_Seq, IsSample, ISNULL(H.isFSC, '0') AS isFSC
        ,   CASE WHEN BHANDSCARD_ONLY_CARD.CARD_SEQ IS NOT NULL THEN 'Y' ELSE 'N' END AS BHANDSCARD_ONLY_CARD_YORN
	from ( SELECT  SMC.CARD_SEQ, MAX(SMCS.COMPANY_SEQ) AS COMPANY_SEQ
                    FROM    S4_MD_Choice SMC JOIN S4_MD_Choice_Str SMCS ON SMC.MD_SEQ = SMCS.MD_SEQ
                    WHERE   SMC.MD_SEQ = @code
                    GROUP BY SMC.CARD_SEQ) AS A
	left outer join S2_Card AS B	with(nolock) on A.CARD_SEQ = B.Card_Seq 
	join s2_cardsalessite AS C with(nolock) on B.Card_Seq= C.card_seq
	join s2_carddiscount AS D with(nolock) on C.CardDiscount_Seq = D.CardDiscount_Seq
	join s2_cardimage AS E	with(nolock) on A.CARD_SEQ=E.Card_Seq 
	join s2_cardoption AS H on B.card_seq=H.card_seq
	join s2_cardkind AS I on C.card_seq = I.Card_Seq
	join s2_cardkindinfo AS j on I.CardKind_Seq = j.CardKind_Seq
	
    LEFT JOIN   ( 
                     SELECT  SMC.CARD_SEQ, MAX(SMCS.COMPANY_SEQ)AS COMPANY_SEQ ,smc.SORTING_NUM as SORTING_NUM
                    FROM    S4_MD_Choice SMC JOIN S4_MD_Choice_Str SMCS ON SMC.MD_SEQ = SMCS.MD_SEQ
                    WHERE   SMC.MD_SEQ = @code
                    GROUP BY SMC.CARD_SEQ, smc.SORTING_NUM
                ) BHANDSCARD_ONLY_CARD ON C.CARD_SEQ = BHANDSCARD_ONLY_CARD.CARD_SEQ AND C.COMPANY_SEQ = BHANDSCARD_ONLY_CARD.COMPANY_SEQ
	
	where C.Company_Seq=@company_seq and D.MinCount=@order_num and E.CardImage_WSize='210' and E.CardImage_HSize='210' and E.cardimage_div='E' and
	C.IsDisplay='1' and E.Company_Seq=@company_seq and J.CardKind_Seq=1
	--정렬기준
	order by BHANDSCARD_ONLY_CARD.SORTING_NUM ASC


END
GO
