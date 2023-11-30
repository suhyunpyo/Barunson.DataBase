IF OBJECT_ID (N'dbo.up_select_event_bestsample', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_event_bestsample
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		유우종
-- Create date: 2016-06-28
-- Description:	샘플투표시스템 최다득표 Best list
-- =============================================
CREATE PROCEDURE [dbo].[up_select_event_bestsample] 
	@company_seq	int,				-- 회사고유코드		
	@pagesize		int					-- 노출 갯수
		
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON;		
		
	SELECT TOP (8)				
			T.LIKE_CARD_SEQ
			, SC.CARD_CODE
			, SC.Card_Name			
			, T.LIKE_CNT
	FROM ( SELECT LIKE_CARD_SEQ, COUNT(*) AS LIKE_CNT FROM SAMPLE_LIKE_CHECK
			GROUP BY LIKE_CARD_SEQ
		) T JOIN S2_CARD SC ON T.LIKE_CARD_SEQ = SC.Card_Seq
		INNER JOIN S2_CardSalesSite AS C ON SC.Card_Seq = C.card_seq	
		INNER JOIN S2_CardOption AS H ON SC.card_seq = H.card_seq
		INNER JOIN S2_CardKind AS I ON SC.card_seq = I.Card_Seq
	WHERE C.Company_Seq = @company_seq
	  AND C.IsDisplay = 1  	  
	  AND I.CardKind_Seq = 1
	ORDER BY T.LIKE_CNT DESC

END
GO
