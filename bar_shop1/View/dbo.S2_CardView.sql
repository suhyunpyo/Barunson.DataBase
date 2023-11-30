IF OBJECT_ID (N'dbo.S2_CardView', N'V') IS NOT NULL DROP View dbo.S2_CardView
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[S2_CardView]
AS
	SELECT
		  '0' AS isS2
		, card_seq
		, new_code AS card_code
		, card_code AS old_code
		, card_div
		, CASE card_cate WHEN 'SN' THEN card_Code + '_s.jpg' ELSE CARD_CODE + '_130.jpg' END AS card_image
		, card_price_customer AS card_price
		, card_name
	    , CASE WHEN new_code = card_code THEN card_code WHEN new_code <> card_code THEN new_code + '(' + card_code + ')' END AS card_code_str
		, company AS brand
		, card_group AS company_seq
		, cont_seq AS inpaper_seq
		, env_seq
		, new_code AS erp_code
		, '' AS embo_print
		, '' AS outsourcing_print
		, '' AS brand_code
		, '' AS brand_name
        , '' AS isMasterPrintColor
	FROM     Card

	UNION ALL

	SELECT
		  '1' AS isS2
		, A.card_Seq
		, new_code AS card_code
		, card_code AS old_code
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
				        WHEN CardBrand = 'A' THEN 13
				        WHEN CardBrand = 'Z' THEN 26
				        WHEN CardBrand = 'Y' THEN 21
				        WHEN CardBrand = 'T' THEN 19
				        WHEN CardBrand = 'G' THEN 20
				        WHEN CardBrand = 'U' THEN 23
				        WHEN CardBrand = 'M' THEN 22
				        WHEN CardBrand = 'C' THEN 24
				        WHEN CardBrand = 'E' THEN 25
				        WHEN CardBrand = 'N' THEN 28
				        ELSE 0
				  END  
*/
        , (SELECT etc1 FROM manage_code WHERE code_type = 'cardbrand' AND code = A.CardBrand) AS brand
		, CASE
		        WHEN Cardbrand = 'B' THEN 5001
		        WHEN Cardbrand = 'W' THEN 5002
		        WHEN CardBrand = 'S' THEN 5003
		        WHEN CardBrand = 'H' THEN 5004
		        WHEN CardBrand = 'P' THEN 5005
		        WHEN CardBrand = 'X' THEN 7717
		        WHEN CardBrand = 'Z' THEN 1
		        ELSE 5006
	      END AS company_seq
		, ISNULL(inpaper_seq, 0) AS inpaper_seq
		, ISNULL(env_seq, 0) AS env_seq
		, card_erpcode AS erp_code
		, ISNULL(C.embo_print, '') AS embo_print
		, ISNULL(C.outsourcing_print, '') AS outsourcing_print
		, A.cardBrand AS brand_code
		, (SELECT code_value FROM manage_code WHERE code_type = 'cardbrand' AND code = A.CardBrand) AS brand_name
        , ISNULL(C.isMasterPrintColor, '') AS isMasterPrintColor
	FROM S2_Card AS A
		LEFT OUTER JOIN S2_CardDetail AS B
			ON A.card_seq = B.card_seq
		LEFT OUTER JOIN S2_CardOption AS C
			ON A.card_seq = C.card_Seq;

GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'S2_CardView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'S2_CardView'
GO
