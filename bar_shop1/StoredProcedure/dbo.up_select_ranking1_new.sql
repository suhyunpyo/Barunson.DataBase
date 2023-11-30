IF OBJECT_ID (N'dbo.up_select_ranking1_new', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_ranking1_new
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	작성정보   : 김덕중
	관련페이지 : manager > md > product_selector.asp
	내용	   : 랭킹상품 가져오기
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_select_ranking1_new]
	@company_seq AS int,
	@tabgubun AS nvarchar(20),
	@brand AS nvarchar(20),
	@code AS nvarchar(20)
as
begin

	declare @data_arry nvarchar(2000)
	declare @data_arry_title nvarchar(2000)
	select @data_arry=ST_Card_Code_Arry, @data_arry_title=ST_Title from S4_Ranking_Sort where ST_company_seq=@company_seq and ST_tabgubun=@tabgubun and ST_brand=@brand and ST_Code=@code;
	
	select itemvalue, itemvalue2, card_name, card_code, cardbrand, cardset_price, B.card_seq
	 from dbo.fn_SplitIn3Rows(@data_arry,@data_arry_title,',') AS A
	left outer join S2_Card AS B with(nolock) on A.itemvalue = B.Card_Seq
	
	
end


GO
