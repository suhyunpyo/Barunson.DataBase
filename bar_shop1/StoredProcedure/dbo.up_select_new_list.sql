IF OBJECT_ID (N'dbo.up_select_new_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_new_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중(daniel, kim)
-- Create date: 2014-03-25
-- Description:	비핸즈 신상품 리스트 출력 product_list_new_res.asp

-- =============================================
CREATE PROCEDURE [dbo].[up_select_new_list]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,		-- 회사고유코드
	@tabgubun AS nvarchar(20),	-- 탭구분(추천, 신상품, etc)
	@brand AS nvarchar(20),		-- 고유브랜드(없을경우 all값 넘겨받으면 됨)
	@code	AS nvarchar(20)		-- 고유코드(신상품:NEW 스타일별:STYLE)

AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE	@T_CNT	INT
	DECLARE	@SQL	nvarchar(1000)
		
	declare @data_arry nvarchar(2000)
	declare @data_arry_title nvarchar(2000)
	select @data_arry=ST_Card_Code_Arry, @data_arry_title=ST_Title from S4_Ranking_Sort where ST_company_seq=@company_seq  and ST_Code=@code;
	
		begin
			select top 30 card_name, card_code, cardbrand, cardset_price, B.card_seq, B.RegDate, 
			brand_all, convert(integer, discount_rate) AS discount_rate , cardimage_filename,
			IsJumun, IsNew, IsBest, IsExtra, IsSale, IsExtra2, isRecommend, isSSPre, C.Company_Seq, IsSample, ISNULL(H.isFSC, '0') AS isFSC, Ranking_m
            ,   CASE WHEN BHANDSCARD_ONLY_CARD.CARD_SEQ IS NOT NULL THEN 'Y' ELSE 'N' END AS BHANDSCARD_ONLY_CARD_YORN
			 from dbo.fn_SplitIn4Rows(@data_arry,@data_arry_title,',') AS A
			left outer join S2_Card AS B	with(nolock) on A.itemvalue = B.Card_Seq 
			join s2_cardsalessite AS C with(nolock) on B.Card_Seq= C.card_seq
			join s2_carddiscount AS D with(nolock) on C.CardDiscount_Seq = D.CardDiscount_Seq
			join s2_cardimage AS E	with(nolock) on A.itemvalue=E.Card_Seq 
			join s2_cardoption AS H on B.card_seq=H.card_seq
			join s2_cardkind AS I on C.card_seq = I.Card_Seq
			join s2_cardkindinfo AS j on I.CardKind_Seq = j.CardKind_Seq
	        
            -- 비핸즈카드 전용 디지털카드를 위한 쿼리
            LEFT JOIN   (
                            SELECT  SMC.CARD_SEQ, MAX(SMCS.COMPANY_SEQ) AS COMPANY_SEQ
                            FROM    S4_MD_Choice SMC JOIN S4_MD_Choice_Str SMCS ON SMC.MD_SEQ = SMCS.MD_SEQ 
                            WHERE   SMC.MD_SEQ = 363 
                            GROUP BY SMC.CARD_SEQ
                        ) BHANDSCARD_ONLY_CARD ON B.CARD_SEQ = BHANDSCARD_ONLY_CARD.CARD_SEQ AND C.COMPANY_SEQ = BHANDSCARD_ONLY_CARD.COMPANY_SEQ
	
			where C.Company_Seq=@company_seq and D.MinCount= 300 and E.CardImage_WSize='210' and E.CardImage_HSize='210' and E.cardimage_div='E' and
			C.IsDisplay='1' and E.Company_Seq=@company_seq and J.CardKind_Seq=1 and
			C.IsJehyu=0 and
			(
			CASE @brand
				WHEN 'ALL' THEN	brand_all
				ELSE B.CardBrand
				END
			) = @brand
		
		end		
END
GO
