IF OBJECT_ID (N'dbo.S2_CardViewMerge', N'V') IS NOT NULL DROP View dbo.S2_CardViewMerge
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[S2_CardViewMerge]
AS
	SELECT
		  '0' AS isS2
		, card_seq
		, new_code AS card_code
		, card_code AS old_code
		, new_code AS erp_code
		, card_div
		, card_img_s AS card_image
		, card_price_customer AS card_price
		, card_name
		, company AS brand
		, CASE WHEN new_code = card_code THEN card_code WHEN new_code <> card_code THEN new_code + '(' + card_code + ')' END AS card_code_str
		, ISNULL((SELECT card_code FROM card WHERE card_seq = A.env_seq AND A.env_seq > 0), '') AS env_code
		, ISNULL((SELECT card_code FROM card WHERE card_seq = A.cont_seq AND A.cont_seq > 0), '') AS inpaper_code
		, isHanji
		, 0 AS master_2color
		, 0 AS isLaser
	FROM Card AS A

	UNION ALL

	SELECT
		  '1' AS isS2
		, A.card_Seq
		, new_code AS card_code
		, card_code AS old_code
		, card_erpcode AS erp_code
		, card_div
		, card_image
		, CASE WHEN card_div = 'A01' THEN cardset_price ELSE card_price END AS card_price
		, card_name
        , (SELECT etc1 FROM manage_code WHERE code_type = 'cardbrand' AND code = A.CardBrand) AS brand
		, CASE WHEN new_code = card_code THEN card_code WHEN new_code <> card_code THEN new_code + '(' + card_code + ')' END AS card_code_str
		
		, ISNULL(( SELECT E.Card_Code FROM S2_Card E WHERE E.Card_Seq = C.Env_Seq ), '') AS Env_Code
		, ISNULL(( SELECT I.Card_Code FROM S2_Card I WHERE I.Card_Seq = C.Inpaper_Seq ), '') AS inpaper_code
		--, ISNULL(t_env_code, '') AS env_code
		--, ISNULL(t_inpaper_code, '') AS inpaper_code
		
		, ISNULL(isHanji, '0') AS isHanji
		, B.master_2color
		, ISNULL(B.isLaser, 0) AS isLaser
	FROM   S2_Card AS A
	LEFT JOIN S2_CardOption AS B ON A.card_seq = B.card_Seq
	LEFT JOIN S2_CardDetail AS C ON A.card_seq = C.card_seq

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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'S2_CardViewMerge'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'S2_CardViewMerge'
GO
