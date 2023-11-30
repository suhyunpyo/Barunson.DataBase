IF OBJECT_ID (N'dbo.up_select_ranking1_web_final_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_ranking1_web_final_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중(daniel, kim)
-- Create date: 2014-09-29
-- Description:	제품리스트

-- =============================================
CREATE PROCEDURE [dbo].[up_select_ranking1_web_final_list]
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
	
	exec dbo.up_select_ranking1_web_final @company_seq, @brand, @code, @tot output
	
	select @tot;
	
	
	declare @data_arry nvarchar(2000)
	declare @data_arry_title nvarchar(2000)
	select @data_arry=ST_Card_Code_Arry, @data_arry_title=ST_Title from S4_Ranking_Sort where ST_SEQ=@code;
	
	
	select top (@pagesize) ItemSEQ, itemvalue, itemvalue2, card_name, card_code, cardbrand, cardset_price, B.card_seq, B.RegDate, 
	brand_all, convert(integer, discount_rate) AS discount_rate , cardimage_filename,
	IsJumun, IsNew, IsBest, IsExtra, IsSale, IsExtra2, isRecommend, isSSPre, C.Company_Seq, IsSample, ISNULL(H.isFSC, '0') AS isFSC
        ,   CASE WHEN BHANDSCARD_ONLY_CARD.CARD_SEQ IS NOT NULL THEN 'Y' ELSE 'N' END AS BHANDSCARD_ONLY_CARD_YORN
	from dbo.fn_SplitIn5Rows(@data_arry,@data_arry_title,',', @company_seq) AS A
	left outer join S2_Card AS B	with(nolock) on A.itemvalue = B.Card_Seq 
	join s2_cardsalessite AS C with(nolock) on B.Card_Seq= C.card_seq
	join s2_carddiscount AS D with(nolock) on C.CardDiscount_Seq = D.CardDiscount_Seq
	join s2_cardimage AS E	with(nolock) on A.itemvalue=E.Card_Seq 
	join s2_cardoption AS H on B.card_seq=H.card_seq
	join s2_cardkind AS I on C.card_seq = I.Card_Seq
	join s2_cardkindinfo AS j on I.CardKind_Seq = j.CardKind_Seq
	
    LEFT JOIN   ( 
                    SELECT  SMC.CARD_SEQ, MAX(SMCS.COMPANY_SEQ) AS COMPANY_SEQ
                    FROM    S4_MD_Choice SMC JOIN S4_MD_Choice_Str SMCS ON SMC.MD_SEQ = SMCS.MD_SEQ
                    WHERE   SMC.MD_SEQ = 363
                    GROUP BY SMC.CARD_SEQ
                ) BHANDSCARD_ONLY_CARD ON C.CARD_SEQ = BHANDSCARD_ONLY_CARD.CARD_SEQ AND C.COMPANY_SEQ = BHANDSCARD_ONLY_CARD.COMPANY_SEQ
	
	where C.Company_Seq=@company_seq and D.MinCount=@order_num and E.CardImage_WSize='210' and E.CardImage_HSize='210' and E.cardimage_div='E' and
	C.IsDisplay='1' and E.Company_Seq=@company_seq and J.CardKind_Seq=1 and
	(
	CASE @brand
		WHEN 'ALL' THEN	brand_all
		ELSE B.CardBrand
		END
	) = @brand
	
	and A.ItemSEQ not in (select top (@pagesize * (@page - 1)) ItemSEQ from dbo.fn_SplitIn5Rows(@data_arry,@data_arry_title,',', @company_seq) 
	AS C inner join S2_Card AS D with(nolock) on C.itemvalue = D.Card_Seq where 
	(
	CASE @brand
		WHEN 'ALL' THEN	brand_all
		ELSE D.CardBrand
		END
	) = @brand
	
	--정렬기준
	order by 
	(
	CASE @Sequence
     WHEN 'ASC' THEN 
		CASE @orderby 
			WHEN 'REGDATE' THEN RegDate
			WHEN 'PRICE' THEN CardSet_Price 
			WHEN '' THEN ItemSEQ
			END
	 END	)
	 ASC,
	 (
	CASE @Sequence
     WHEN 'DESC' THEN 
		CASE @orderby 
			WHEN 'REGDATE' THEN RegDate
			WHEN 'PRICE' THEN CardSet_Price 
			WHEN '' THEN ItemSEQ
			END
	 END	)
	 DESC
	) 
	
	
	order by 
	(
	CASE @Sequence
     WHEN 'ASC' THEN 
		CASE @orderby 
			WHEN 'REGDATE' THEN RegDate
			WHEN 'PRICE' THEN CardSet_Price 
			WHEN '' THEN ItemSEQ
			END
	 END	)
	 ASC,
	 (
	CASE @Sequence
     WHEN 'DESC' THEN 
		CASE @orderby 
			WHEN 'REGDATE' THEN RegDate
			WHEN 'PRICE' THEN CardSet_Price 
			WHEN '' THEN ItemSEQ
			END
	 END	)
	 DESC
	
			
END
GO
