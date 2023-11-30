IF OBJECT_ID (N'dbo.up_select_today_view', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_today_view
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-11
-- Description:	오늘 본 상품 보여주기
-- TEST : up_select_today_view '118584630', '2014-12-11', 5007
-- =============================================
CREATE PROCEDURE [dbo].[up_select_today_view]
		
	@uid VARCHAR(50), 
	@view_date VARCHAR(10),
	@company_seq INT
			
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
		
	
	-- 오늘 본 상품 가져오기 --
	SELECT  TVI.*	--, '||' AS gubun1 
	       ,C.Card_Code	--*, '||' AS gubun2
	       ,CI.CardImage_FileName	--*
	FROM S5_TodayViewItems TVI
	INNER JOIN S2_CardImage CI ON TVI.card_seq = CI.Card_Seq
	INNER JOIN S2_Card C ON CI.card_seq = C.Card_Seq
	WHERE 1 = 1
	  AND CI.Company_Seq = @company_seq	 
	  AND TVI.uid = @uid
	  AND TVI.view_date = @view_date	  
	  AND CI.CardImage_WSize = '60'
	  AND CI.CardImage_HSize = '60'
	  AND CI.CardImage_Div = 'E'	  
	ORDER BY TVI.seq DESC
			
	
END



-- select * from S5_TodayViewItems

-- select * from S2_Card

-- select * from S2_CardImage
GO
