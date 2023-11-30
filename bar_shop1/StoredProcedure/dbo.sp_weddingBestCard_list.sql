IF OBJECT_ID (N'dbo.sp_weddingBestCard_list', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_weddingBestCard_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : sp_weddingBestCard_list
-- Author        : 임승인
-- Create date   : 2022-11-11
-- Description   : [바] 웨딩홀별 베스트 청첩장
-- Update History: 
-- Comment       : [sp_WeddingBestCard_list] 11220,5001,'','',200
****************************************************************************************************************/

	ALTER PROCEDURE [dbo].[sp_weddingBestCard_list] 
		@wedd_idx   int,
		@company_seq int,
		@uid varchar(20),
		@guid varchar(200),
		@MIN_COUNT	int
	AS


	DECLARE @DATE DATETIME
	DECLARE @MD_SEQ INT
	
	SET @DATE = CONVERT(VARCHAR(10),DATEADD(M,-3,getdate()),120) 
	SET @MD_SEQ = 997

	SELECT TOP 9 card_seq, card_code, card_name, cardset_price, discount_rate,isBasket , MIN(MODE) MODE, MAX(COUNT) COUNT FROM(
		SELECT * FROM (
			SELECT TOP 9 a.card_seq, z.card_code, z.card_name, z.cardset_price, f.discount_rate, COUNT,
			ISNULL((SELECT COUNT(1) FROM S2_SampleBasket WHERE UID = @uid and GUID = @guid and company_seq = @company_seq and card_seq = a.card_Seq),0) isBasket , 1 AS MODE
			FROM (		
					SELECT card_seq ,COUNT(*) COUNT,MAX(C.ORDER_DATE) ORDER_DATE
					FROM custom_order c, custom_order_WeddInfo cw 
					WHERE c.order_Seq = cw.order_Seq and cw.wedd_idx = 10669
					AND c.src_send_date >= CONVERT(VARCHAR(10),DATEADD(D,-3,getdate()),120) 
					GROUP BY card_Seq 			
				) a INNER JOIN s2_Card z ON a.card_seq=z.Card_Seq 
			INNER JOIN s2_cardsalessite s ON z.Card_Seq=S.card_seq AND s.company_seq=@company_seq
			INNER join s2_carddiscount f ON S.carddiscount_seq = f.carddiscount_seq and f.mincount = @MIN_COUNT  
			WHERE isdisplay = '1'
			ORDER BY COUNT DESC, ORDER_DATE DESC
		) X
	
		UNION ALL

		SELECT TOP 9 a.card_seq, z.card_code, z.card_name, z.cardset_price, f.discount_rate, 0 AS COUNT,
		ISNULL((SELECT COUNT(1) FROM S2_SampleBasket WHERE UID = @uid and GUID = @guid and company_seq = @company_seq and card_seq = a.card_Seq),0) isBasket  , 2 AS MODE
		FROM S4_MD_Choice a INNER JOIN s2_Card z ON a.card_seq=z.Card_Seq and a.MD_SEQ = @MD_SEQ
		INNER JOIN s2_cardsalessite s ON z.Card_Seq=S.card_seq AND s.company_seq=@company_seq
		INNER join s2_carddiscount f ON S.carddiscount_seq = f.carddiscount_seq and f.mincount = @MIN_COUNT  
		WHERE isdisplay = '1'
	) X 
	GROUP BY card_seq, card_code, card_name, cardset_price, discount_rate,isBasket 
	ORDER BY MODE, COUNT DESC
GO
