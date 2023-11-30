IF OBJECT_ID (N'dbo.view_Bestseller', N'V') IS NOT NULL DROP View dbo.view_Bestseller
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [dbo].[view_Bestseller]
AS
SELECT top 10 A.sales_gubun,A.gubun,A.card_seq,B.card_code,B.company,B.card_price_customer,B.disrate_type,B.card_kind,B.card_img_ms,A.regdate 
FROM BestRanking A inner join Card B on A.card_seq = B.card_seq


GO
