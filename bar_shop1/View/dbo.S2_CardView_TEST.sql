IF OBJECT_ID (N'dbo.S2_CardView_TEST', N'V') IS NOT NULL DROP View dbo.S2_CardView_TEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[S2_CardView_TEST]
AS
SELECT  '0' AS isS2, card_seq, new_code AS card_code, card_code AS old_code, card_div, 
               CASE card_cate WHEN 'SN' THEN card_Code + '_s.jpg' ELSE CARD_CODE + '_130.jpg' END AS card_image, 
               card_price_customer AS card_price, card_name, 
               card_code_str = CASE WHEN new_code = card_code THEN card_code WHEN new_code <> card_code THEN new_code
                + '(' + card_code + ')' END, company AS brand, card_group AS company_seq, cont_seq AS inpaper_seq, 
               env_seq, new_code AS erp_code, '' AS embo_print, '' AS outsourcing_print
FROM     Card
UNION ALL
SELECT  '1' AS isS2, A.card_Seq, new_code AS card_code, card_code AS old_code, card_div, card_image, 
               card_price = CASE WHEN card_div = 'A01' THEN cardset_price ELSE card_price END, card_name, 
               card_code_str = CASE WHEN new_code = card_code THEN card_code WHEN new_code <> card_code THEN new_code
                + '(' + card_code + ')' END, 
               brand = CASE WHEN Cardbrand = 'B' THEN 1 WHEN Cardbrand = 'W' THEN 2 WHEN CardBrand = 'S' THEN 16 WHEN
                CardBrand = 'H' THEN 8 WHEN CardBrand = 'A' THEN 13 WHEN CardBrand = 'Z' THEN 1 WHEN CardBrand = 'Y' THEN
                21 WHEN CardBrand = 'T' THEN 19 WHEN CardBrand = 'G' THEN 20 WHEN CardBrand = 'U' THEN 22 WHEN CardBrand
                = 'M' THEN 22 WHEN CardBrand = 'C' THEN 23 WHEN CardBrand = 'E' THEN 24 WHEN CardBrand = 'N' THEN 25 ELSE 0 END, 
               company_seq = CASE WHEN Cardbrand = 'B' THEN 5001 WHEN Cardbrand = 'W' THEN 5002 WHEN CardBrand = 'S'
                THEN 5003 WHEN CardBrand = 'H' THEN 5004 WHEN CardBrand = 'P' THEN 5005 WHEN CardBrand = 'Z' THEN 1
                ELSE 5006 END, ISNULL(inpaper_seq, 0) AS inpaper_seq, ISNULL(env_seq, 0) AS env_seq, 
               card_erpcode AS erp_code, ISNULL(C.embo_print, '') AS embo_print, ISNULL(C.outsourcing_print, '') 
               AS outsourcing_print
FROM     S2_Card A LEFT OUTER JOIN
               S2_CardDetail B ON A.card_seq = B.card_seq LEFT OUTER JOIN
               S2_CardOption C ON A.card_seq = C.card_Seq

GO
