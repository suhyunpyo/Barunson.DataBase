IF OBJECT_ID (N'dbo.up_select_ranking1_bhands', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_ranking1_bhands
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	작성정보   : 정혜련 (2018.07.10)
	관련페이지 : 비핸즈메인
	내용	   : 베스트(MNMO) / 샘플(MNSL) 상품 가져오기
	
*/
CREATE Procedure [dbo].[up_select_ranking1_bhands]
	@company_seq AS int,
	@tabgubun AS nvarchar(20),
	@brand AS nvarchar(20),
	@userid AS nvarchar(50)
	
as
begin

	declare @data_arry nvarchar(2000)
	declare @data_arry_title nvarchar(2000)
	select @data_arry=ST_Card_Code_Arry, @data_arry_title=ST_Title from S4_Ranking_Sort where ST_company_seq=@company_seq and ST_tabgubun=@tabgubun and ST_brand=@brand;
	
	select d.card_Seq , card_code , card_name , Discount_Rate 
	 , replace( convert( VARCHAR, convert(money , (Round(d.cardset_price * ((100 - d.Discount_Rate) / 100) , 0)) * 300), 1 ), '.00', '' )  card_sale_price
	 , replace( convert( VARCHAR, convert(money , d.cardset_price *  300),1), '.00', '' )  cardset_total_price 
	 ,ISNULL(seq,0) sampleInd 
	from 
	( 
	select B.card_seq, card_code, card_name, cardset_price
	 ,(SELECT Discount_Rate FROM S2_CARDDISCOUNT WHERE CARDDISCOUNT_SEQ = c.CARDDISCOUNT_SEQ AND MinCount = 300) Discount_Rate
	 ,z.seq
	 from dbo.fn_SplitIn3Rows(@data_arry,@data_arry_title,',') AS A
	left outer join S2_Card AS B with(nolock) on A.itemvalue = B.Card_Seq
	left outer join S2_SampleBasket z on z.card_Seq = b.card_seq and z.company_seq = @company_seq and z.uid= @userid
	JOIN S2_CARDSALESSITE C on A.itemvalue = c.Card_Seq
	where (c.ISDISPLAY = 1 OR c.ISJUMUN = 1)
	and c.company_seq = @company_seq 
	) d
	
end


GO
