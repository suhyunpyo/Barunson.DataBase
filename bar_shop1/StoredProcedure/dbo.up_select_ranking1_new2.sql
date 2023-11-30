IF OBJECT_ID (N'dbo.up_select_ranking1_new2', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_ranking1_new2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	작성정보   : 김덕중
	관련페이지 : s6manager > md > md_select_item.asp
	내용	   : 랭킹상품 가져오기
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_select_ranking1_new2]
	@company_seq AS int,
	@st_seq AS int
as
begin

	declare @data_arry nvarchar(4000)
	declare @data_arry_title nvarchar(4000)
	select @data_arry=ST_Card_Code_Arry, @data_arry_title=ST_Title from S4_Ranking_Sort where ST_company_seq=@company_seq and ST_SEQ=@st_seq;
	
	select itemvalue, itemvalue2, card_name, card_code, cardbrand, cardset_price, B.card_seq, isnull(C.isDisplay+1,0) isDisplay
	 from dbo.fn_SplitIn3Rows(@data_arry,@data_arry_title,',') AS A
	left outer join S2_Card AS B with(nolock) on A.itemvalue = B.Card_Seq
	left outer join S2_CardSalesSite AS C with(nolock) on A.ItemValue = C.card_seq
	where C.Company_Seq=@company_seq
	
	
end


GO
