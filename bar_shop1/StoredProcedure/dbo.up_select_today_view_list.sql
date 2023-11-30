IF OBJECT_ID (N'dbo.up_select_today_view_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_today_view_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-14
-- Description:	MyPage 최근 본 상품
-- TEST : up_select_today_view_list 'palaoh', '2014-12-14', 5007
-- =============================================
CREATE PROCEDURE [dbo].[up_select_today_view_list]	

	@uid VARCHAR(16),
	@view_date VARCHAR(10),
	@company_seq INT 

AS
BEGIN
	
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;

	--DECLARE @uid VARCHAR(16)='palaoh'
	--DECLARE @view_date VARCHAR(10)='2014-12-14'
	--DECLARE @company_seq INT=5007
		
	SELECT  TVI.seq
		   ,TVI.uid
		   ,TVI.card_seq
		   ,SC.Card_Code
		   ,SC.Card_Name
		   ,SC.CardSet_Price		   
		   ,SCK.cardkind_seq
		   ,D.Discount_Rate
	FROM S5_TodayViewItems TVI
	INNER JOIN S2_Card SC ON TVI.card_seq = SC.Card_Seq
	INNER JOIN (
					SELECT card_seq, MIN(CardKind_Seq) AS cardkind_seq
					FROM S2_CardKind
					GROUP BY card_seq
				) SCK ON TVI.card_seq = SCK.Card_Seq
	INNER JOIN S2_CardSalesSite C ON TVI.Card_Seq = C.Card_Seq
	INNER JOIN S2_CardDiscount D ON C.CardDiscount_Seq = D.CardDiscount_Seq
	WHERE 1 = 1
	  AND TVI.uid = @uid
	  AND TVI.view_date = @view_date
	  AND D.MinCount <= 400 
	  AND D.MaxCount >= 400
	  AND C.Company_Seq = @Company_Seq
	ORDER BY TVI.seq DESC
	
	
	
				  
END



/*
SELECT  D.CardDiscount_Seq
       ,D.MinCount
       ,D.MaxCount
       ,D.Discount_Rate 
FROM S2_Card A 
INNER JOIN S2_CardDetail B ON A.Card_Seq = B.Card_Seq
INNER JOIN S2_CardSalesSite C ON A.Card_Seq = C.Card_Seq
INNER JOIN S2_CardDiscount D ON C.CardDiscount_Seq = D.CardDiscount_Seq
WHERE D.MinCount <= 400 
AND D.MaxCount >= 400
AND C.Company_Seq = @Company_Seq 
AND A.Card_Seq = @Card_Seq	
--ORDER BY D.minCount
*/


/*
select * from S5_TodayViewItems
where uid = 'palaoh'
and view_date = '2014-12-14'
order by seq desc
*/
GO
