IF OBJECT_ID (N'dbo.S2_CardViewNew', N'V') IS NOT NULL DROP View dbo.S2_CardViewNew
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[S2_CardViewNew]
AS
	SELECT
		  '0' AS isS2
		, card_seq
		, card_div
		, card_code
		, CASE WHEN new_code = card_code THEN card_code ELSE new_code + '(' + card_code + ')' END AS card_code_str
		, CARD_CODE + '_130.jpg' AS card_image
		, card_price_customer AS card_price
		, card_name
		, (SELECT code_value FROM manage_code WHERE code_type = 'cardbrand' AND etc1 = C.company) AS cardbrand
		, cont_seq AS inpaper_seq
		, env_seq
		, new_code AS erp_code
	FROM Card AS C

	UNION ALL

	SELECT
		  '1' AS isS2
		, A.card_Seq
		, card_div
		, card_code
		, CASE WHEN card_erpcode = card_code THEN card_code ELSE card_code + '(' + card_erpcode + ')' END AS card_code_str
		, card_image
		, CASE WHEN card_div = 'A01' THEN cardset_price ELSE card_price END AS card_price
		, card_name
		, cardbrand
		, ISNULL(inpaper_seq, 0) AS inpaper_seq
		, ISNULL(env_seq, 0) AS env_seq
		, card_erpcode AS erp_code
	FROM   S2_Card AS A
		LEFT OUTER JOIN S2_CardDetail AS B
			ON A.card_seq = B.card_seq;
GO
