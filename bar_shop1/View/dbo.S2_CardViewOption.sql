IF OBJECT_ID (N'dbo.S2_CardViewOption', N'V') IS NOT NULL DROP View dbo.S2_CardViewOption
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[S2_CardViewOption]
AS
	SELECT
		  '0' AS isS2
		, card_seq
		, new_code AS card_code
		, card_code AS old_code
		, card_div
		, card_img_s AS card_image
		, card_price_customer AS card_price
		, card_name
		, CASE WHEN new_code = card_code THEN card_code WHEN new_code <> card_code THEN new_code + '(' + card_code + ')' END AS card_code_str
		, company AS brand
		, card_group AS company_seq
		, isInitial
		, isHanji
		, '' AS PrintMethod
		, 'C' AS Embo_Print
		, 'C' AS Outsourcing_Print
		, new_code AS erp_code
	FROM     Card

	UNION ALL

	SELECT
		  '1' AS isS2
		, A.card_Seq
		, card_code
		, old_code
		, card_div
		, card_image
		, CASE WHEN card_div = 'A01' THEN cardset_price ELSE card_price END AS card_price
		, card_name
		, CASE WHEN new_code = card_code THEN card_code WHEN new_code <> card_code THEN new_code + '(' + card_code + ')' END AS card_code_str
/*
		, brand = CASE
				    WHEN Cardbrand = 'B' THEN 1
				    WHEN Cardbrand = 'W' THEN 2
				    WHEN CardBrand = 'S' THEN 16
				    WHEN CardBrand = 'H' THEN 8
				    WHEN CardBrand = 'P' THEN 17
				    WHEN CardBrand = 'Z' THEN 1
				END
*/
        , (SELECT etc1 FROM manage_code WHERE code_type = 'cardbrand' AND code = A.CardBrand) AS brand
		, CASE
                WHEN Cardbrand = 'B' THEN 5001
                WHEN Cardbrand = 'W' THEN 5002
                WHEN CardBrand = 'S' THEN 5003
                WHEN CardBrand = 'H' THEN 5004
                WHEN CardBrand = 'P' THEN 5005
                WHEN CardBrand = 'Z' THEN 1
          END AS company_seq
		, isOutsideInitial AS isInitial
		, isHanji
		, ISNULL(printmethod, '') AS PrintMethod
		, ISNULL(embo_print, '') AS Embo_Print
		, ISNULL(outsourcing_print, '') AS Outsourcing_Print
		, card_erpcode AS erp_code
	FROM   S2_Card AS A
		LEFT OUTER JOIN S2_CardOption AS B
			ON A.card_seq = B.card_seq;
GO
