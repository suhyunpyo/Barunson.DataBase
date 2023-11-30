IF OBJECT_ID (N'dbo.up_select_ranking1_web_test', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_ranking1_web_test
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[up_select_ranking1_web_test]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,
	@tabgubun AS nvarchar(20),
	@brand AS nvarchar(20),
	@ordernum AS int,
	@image_wsize AS nvarchar(10),
	@image_hsize AS nvarchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	
	declare @st int
	
	select @st=ST_SEQ from S4_Ranking_Sort with(nolock)  where ST_company_seq=@company_seq and ST_tabgubun=@tabgubun and ST_brand=@brand;
	
	select 1

    -- Insert statements for procedure here
	select RK_Card_Code, RK_Title as card_name, card_seq, company_seq, isbest, isnew, isextra
, isextra2, isjumun,cardbrand, card_code, card_name as card_name_ori, regdate,
	 cardset_price, card_content, carddiscount_seq, cardimage_filename,
	 issample, isdigitalcolor, discount_rate, cardsale_price, card_text_premier, isFSC, custom_card_yn
	,  CASE WHEN cardset_price <= 699 THEN 'P1'
				WHEN cardset_price >= 700 AND cardset_price < 800 THEN 'P2'
				WHEN cardset_price >= 800 AND cardset_price < 900 THEN 'P3'
				WHEN cardset_price >= 900 THEN 'P4' END AS subgubun
				--WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price > 600 AND (100-D.DisCount_Rate)/100 * B.CardSet_Price < 1200 THEN 'P4'

	 from S4_Ranking_Sort_Table AS A
	 
	 left outer join (select distinct 
	 B.Card_Seq, C.company_seq,
	 isbest, isnew, isextra, isextra2, isjumun,
	 cardbrand, card_code, card_name, regdate,
	 cardset_price, card_content, c.carddiscount_seq, cardimage_filename,
	 issample, isdigitalcolor, discount_rate, mincount, 
	 round((B.cardset_price*(100-j.discount_rate)/100),0) as cardsale_price,
	 F.card_text_premier, ISNULL(h.isFSC, '0') AS isFSC,c.isdisplay
	 ,isnull((select count(1) from s2_cardkind where card_Seq = B.card_Seq and cardkind_Seq = 14),0) custom_card_yn
	  from
	 S2_Card AS B with(nolock) 
	 join s2_cardsalessite AS C with(nolock)  on B.Card_Seq= c.card_seq
	 join s2_cardimage AS G with(nolock)  on B.Card_Seq = g.Card_Seq
	 join s2_carddetail AS F with(nolock)  on B.Card_Seq =  F.Card_Seq
	 join s2_cardoption AS h with(nolock)  on B.Card_Seq =  h.Card_Seq
	 join s2_carddiscount j with(nolock)  on C.carddiscount_seq=j.carddiscount_seq
	 where cardimage_wsize=@image_wsize and cardimage_hsize=@image_hsize
	 and cardimage_div='E' and g.Company_Seq=@company_seq
	 and c.Company_Seq=@company_seq
	 and j.mincount=@ordernum
	 ) AS D on A.RK_Card_Code = D.Card_Seq
	 where A.RK_ST_SEQ=@st
	 and isdisplay = '1'
END
GO
