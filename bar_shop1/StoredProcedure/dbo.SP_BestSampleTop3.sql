IF OBJECT_ID (N'dbo.SP_BestSampleTop3', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_BestSampleTop3
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		임승인
-- Create date: 2023-03-07
-- Description:	베스트샘플 3종
-- 수정일 : 2023-06-23 #12043 요청으로 상품 고정
-- =============================================
--[SP_BestSampleTop3] 5001,'610','477'

CREATE PROCEDURE [dbo].[SP_BestSampleTop3]
	@Company_Seq INT,
	@cardimage_wsize VARCHAR(4),
	@cardimage_hsize VARCHAR(4)
AS
SET NOCOUNT ON
BEGIN
	SELECT 
	 b.Card_Code,b.Card_Seq, b.Card_Name, d.CardImage_FileName 
	FROM S2_CARD b 
	INNER JOIN s2_cardimage d on b.Card_Seq=d.Card_Seq 
	WHERE cardimage_wsize=610 
		AND cardimage_hsize=477 
		AND cardimage_div = 'B' 
		and Company_Seq=5001 
		AND CardImage_FileName = 'B1.jpg'	
		AND b.card_seq IN (37717, 38961, 36451)
	ORDER BY CASE b.card_seq WHEN 37717 THEN 1 WHEN 38961 THEN 2 WHEN 36451 THEN 3 END 
	

/*
	SELECT 
		 TOP 3 b.Card_Code,b.Card_Seq, b.Card_Name, d.CardImage_FileName 
	FROM (
		SELECT TOP 10 CARD_SEQ,COUNT(*) COUNT
		FROM CUSTOM_SAMPLE_ORDER_ITEM 
		WHERE DATEADD(D,-30,GETDATE())<REG_DATE 
		GROUP BY CARD_SEQ 
		ORDER BY COUNT(*) DESC
	) a INNER JOIN  S2_CARD b ON a.Card_Seq = B.Card_Seq 
	INNER JOIN S2_CardSalesSite c ON b.Card_Seq=c.Card_Seq 
	INNER JOIN s2_cardimage d on b.Card_Seq=d.Card_Seq AND d.Company_Seq=@Company_Seq
	WHERE IsDisplay=1 
		AND c.Company_Seq=@Company_Seq 		
		AND cardimage_wsize=@cardimage_wsize 
		AND cardimage_hsize=@cardimage_hsize 
		AND cardimage_div = 'B' 
		AND CardImage_FileName = 'B1.jpg'		
	ORDER BY a.COUNT DESC
*/
SET NOCOUNT OFF	
END





GO
