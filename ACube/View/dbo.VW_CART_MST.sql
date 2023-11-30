IF OBJECT_ID (N'dbo.VW_CART_MST', N'V') IS NOT NULL DROP View dbo.VW_CART_MST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_CART_MST]
AS
SELECT     ORDER_SEQ, CART_SEQ, CART_CODE, CART_TYPE_CODE, PROD_SEQ, QUANTITY, REG_DATE, REQUEST_SHIPPING_DATE, UPDATE_DATE, PRICE_UNIT, 
                      CART_ITEM_PRINT_COUNT, QUANTITY * PRICE_UNIT + ADDITION_PROCESSING_PRICE AS PRICE, ADDITION_PROCESSING_PRICE
FROM         (SELECT     ORDER_SEQ, CART_SEQ, CART_CODE, CART_TYPE_CODE, PROD_SEQ, QUANTITY, REG_DATE, REQUEST_SHIPPING_DATE, 
                                              ADDITION_PROCESSING_PRICE, UPDATE_DATE, 
                                              (CASE OUT_CM.CART_ITEM_PRINT_COUNT WHEN 0 THEN OUT_CM.PRICE_UNIT ELSE (OUT_CM.PRICE_UNIT + 0.44) END) AS PRICE_UNIT, 
                                              CART_ITEM_PRINT_COUNT
                       FROM          (SELECT     ORDER_SEQ, CART_SEQ, CART_CODE, CART_TYPE_CODE, PROD_SEQ, QUANTITY, REG_DATE, REQUEST_SHIPPING_DATE, UPDATE_DATE, 
                                                                      (CASE CM.CART_TYPE_CODE WHEN '201003' THEN
                                                                          (SELECT     TOP 1 PM.PART_CASE_PRICE_UNIT
                                                                            FROM          PROD_MST PM
                                                                            WHERE      PM.PROD_SEQ = CM.PROD_SEQ) ELSE
                                                                          (SELECT     SUM(PM.PRICE_UNIT)
                                                                            FROM          CART_ITEM_MST CIM LEFT JOIN
                                                                                                   PROD_MST PM ON PM.PROD_SEQ = CIM.PROD_SEQ
                                                                            WHERE      CIM.CART_SEQ = CM.CART_SEQ) END) AS PRICE_UNIT,
                                                                          (SELECT     COUNT(*) AS Expr1
                                                                            FROM          dbo.CART_ITEM_PRINT_MST AS CIPM LEFT OUTER JOIN
                                                                                                   dbo.CART_ITEM_MST AS CIM ON CIPM.CART_ITEM_SEQ = CIM.CART_ITEM_SEQ
                                                                            WHERE      (CIM.CART_SEQ = CM.CART_SEQ)) AS CART_ITEM_PRINT_COUNT, (CASE CM.CART_TYPE_CODE WHEN '201001' THEN
                                                                          (SELECT     PGM.ADDITIONAL_PROCESSING_PRICE
                                                                            FROM          PROD_SET_GROUP_MST PGM
                                                                            WHERE      PGM.PROD_SET_GROUP_SEQ = CM.PROD_SEQ) WHEN '201003' THEN
                                                                          (SELECT     PM.ADDITIONAL_PROCESSING_PRICE
                                                                            FROM          PROD_MST PM
                                                                            WHERE      PM.PROD_SEQ = CM.PROD_SEQ) ELSE (0) END) AS ADDITION_PROCESSING_PRICE
                                               FROM          dbo.CART_MST AS CM) AS OUT_CM) AS RESULT

GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[26] 4[35] 2[20] 3) )"
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
         Top = -576
         Left = 0
      End
      Begin Tables = 
         Begin Table = "RESULT"
            Begin Extent = 
               Top = 582
               Left = 38
               Bottom = 701
               Right = 283
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
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_CART_MST'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_CART_MST'
GO
