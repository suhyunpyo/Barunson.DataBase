IF OBJECT_ID (N'dbo.VW_IMP_CART_PRINT_ITEM_MST', N'V') IS NOT NULL DROP View dbo.VW_IMP_CART_PRINT_ITEM_MST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_IMP_CART_PRINT_ITEM_MST]
AS
SELECT     VOM.ORDER_SEQ, VOM.ORDER_CODE, VOM.REQUEST_STATUS_TYPE_CODE, VOM.ORDER_STATUS_TYPE_CODE, VCM.CART_CODE, 
                      VCM.REQUEST_SHIPPING_DATE, CIPM.PDF_PATH, CIPM.JPG_PATH, CIPM.QUANTITY, CIPM.EXPORT_QUANTITY, PM.PROD_SEQ, PM.PROD_CODE, 
                      PM.PROD_TITLE, PM.PROD_TYPE_CODE
FROM         dbo.VW_ORDER_MST AS VOM LEFT OUTER JOIN
                      dbo.VW_CART_MST AS VCM ON VOM.ORDER_SEQ = VCM.ORDER_SEQ LEFT OUTER JOIN
                      dbo.CART_ITEM_MST AS CIM ON VCM.CART_SEQ = CIM.CART_SEQ LEFT OUTER JOIN
                      dbo.CART_ITEM_PRINT_MST AS CIPM ON CIPM.CART_ITEM_SEQ = CIM.CART_ITEM_SEQ LEFT OUTER JOIN
                      dbo.PROD_MST AS PM ON PM.PROD_SEQ = CIM.PROD_SEQ
WHERE     (VOM.CART_ITEM_PRINT_COUNT > 0) AND (CIPM.PDF_PATH IS NOT NULL) AND (CIPM.PDF_PATH <> '') AND (VOM.REQUEST_STATUS_TYPE_CODE = '712002')

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
         Begin Table = "VOM"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 281
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "VCM"
            Begin Extent = 
               Top = 6
               Left = 319
               Bottom = 125
               Right = 542
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CIM"
            Begin Extent = 
               Top = 6
               Left = 580
               Bottom = 125
               Right = 765
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CIPM"
            Begin Extent = 
               Top = 6
               Left = 803
               Bottom = 125
               Right = 1011
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PM"
            Begin Extent = 
               Top = 6
               Left = 1049
               Bottom = 125
               Right = 1306
            End
            DisplayFlags = 280
            TopColumn = 0
         End
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_IMP_CART_PRINT_ITEM_MST'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_IMP_CART_PRINT_ITEM_MST'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_IMP_CART_PRINT_ITEM_MST'
GO
