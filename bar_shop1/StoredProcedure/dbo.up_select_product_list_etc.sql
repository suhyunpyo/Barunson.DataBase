IF OBJECT_ID (N'dbo.up_select_product_list_etc', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_product_list_etc
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
/*
	작성정보   : 강현주
	관련페이지 : product > product_list_option.asp
	내용	   : 부가상품리스트 가져오기
	
	수정정보   : 
*/
-- =============================================
CREATE Procedure [dbo].[up_select_product_list_etc]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,		-- 회사고유코드
	@card_div char(3),		    -- 부가상품종류
	@page	int,				-- 페이지넘버
	@pagesize int,				-- 페이지사이즈(페이지당 노출갯수)
	@orderby nvarchar(20),		-- 정렬컬럼
	@Sequence	nvarchar(20)	-- 정렬조건(ASC, DESC)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @card_div_list varchar(100)
	set @card_div_list = CASE @card_div WHEN 'C06' THEN 'C01,C02,C06,C09,C10,C11' ELSE @card_div + ',' END
	
    -- Insert statements for procedure here
	-- total count
	SELECT COUNT(A.Card_Seq) AS TOT 
	FROM 
		S2_Card AS A WITH(NOLOCK) 
		INNER JOIN S2_CardSalesSite AS B WITH(NOLOCK) ON A.Card_Seq=B.Card_Seq  
	WHERE 
		A.card_div IN (SELECT value FROM FN_SPLIT(@card_div_list, ',')) 
		--A.card_div=@card_div
		AND A.card_seq not in ('33958', '34420', '34431', '34432', '34836', '34880') -- 사용안하는 제품은 노출금지..daniel,kim
		AND A.Card_Group='I' 
		AND B.isJumun='1' 
		AND B.Company_Seq=@company_seq;
		
	-- goods list
	SELECT * 
	FROM
	(
		SELECT  ROW_NUMBER() OVER (ORDER BY (
												CASE @Sequence WHEN 'ASC' THEN 
																				CASE @orderby WHEN 'REGDATE' THEN A.RegDate
																							  WHEN 'PRICE' THEN A.CardSet_Price 
																				END
												END	
											 ) ASC,
											 (
												CASE @Sequence WHEN 'DESC' THEN 
																				CASE @orderby WHEN 'REGDATE' THEN A.RegDate
																							  WHEN 'PRICE' THEN A.CardSet_Price
																				END
												END	
											 ) DESC ) AS RowNum, 				
			A.card_seq, A.card_code, A.card_name, A.cardset_price, A.card_price, A.cardFactory_Price, A.card_image,
			CASE WHEN C.acc1_seq > 0 THEN (SELECT card_code FROM S2_Card WHERE Card_Seq=C.acc1_seq) ELSE '' END AS acc1_code, 
			CASE WHEN C.acc2_seq > 0 THEN (SELECT card_code FROM S2_Card WHERE Card_Seq=C.acc2_seq) ELSE '' END AS acc2_code
		FROM 
			S2_Card AS A 
			inner join s2_cardsalessite AS B WITH(NOLOCK) ON A.Card_Seq= B.card_seq
			left join S2_CardDetail as C WITH(NOLOCK) ON A.Card_Seq= C.card_seq
		WHERE 
			A.card_div IN (SELECT value FROM FN_SPLIT(@card_div_list, ','))  
			--A.card_div=@card_div 
			AND A.card_seq not in ('33958', '34420', '34431', '34432', '34836', '34880') -- 사용안하는 제품은 노출금지..daniel,kim
			AND A.Card_Group='I' 
			AND B.isJumun='1' 
			AND B.Company_Seq=@company_seq
	) AS RESULT
	WHERE RowNum BETWEEN ( ( (@page - 1) * @pagesize ) + 1 ) AND ( @page * @pagesize )	
END
GO
