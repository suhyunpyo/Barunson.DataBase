IF OBJECT_ID (N'dbo.VW_ORDER_MST', N'V') IS NOT NULL DROP View dbo.VW_ORDER_MST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_ORDER_MST]
AS
SELECT     OM.ORDER_SEQ, OM.ORDER_CODE, OM.ORDER_DATE, UM.USER_SEQ, UM.USER_ID, AUM.ADMIN_USER_SEQ, AUM.ADMIN_USER_ID, AUM.ADMIN_USER_NAME, 
                      OM.FIRST_NAME, OM.LAST_NAME, OM.EMAIL, OM.TEL_1, OM.TEL_2, OM.TEL_3, OM.TEL_4, OM.SHIPPING_ADDR_1, OM.SHIPPING_ADDR_2, OM.SHIPPING_CITY, 
                      OM.SHIPPING_STATE, OM.SHIPPING_ZIPCODE, OM.SHIPPING_COUNTRY, OM.MEMO, OM.UPDATE_DATE, OM.CLAIM_EXIST_YORN, OM.CLAIM_CONTENT, 
                      OM.SPECIAL_INSTRUCTION, OM.REQUEST_CANCLE_DATE, OM.REQUEST_CANCLE_CONTENT,
                          (SELECT     ISNULL(SUM(CAL_PRICE), 0) AS Expr1
                            FROM          dbo.VW_CART_MST AS CM
                            WHERE      (USER_SEQ = OM.USER_SEQ) AND (CART_STATE_CODE = '118002') AND (ORDER_SEQ = OM.ORDER_SEQ)) +
                          (SELECT     ISNULL(SUM(PRICE), 0) AS Expr1
                            FROM          dbo.ADDITIONAL_PRICE_MST
                            WHERE      (FOREIGN_SEQ = OM.ORDER_SEQ) AND (ADD_PRICE_TYPE_CODE = '120003' OR
                                                   ADD_PRICE_TYPE_CODE = '120004')) AS TOTAL_PRICE, OM.ORDER_STATUS_TYPE_CODE, OM.SHIPPING_TRACKING_NUMBER, 
                      OM.SHIPPING_TYPE_CODE, OM.ORDER_TYPE_CODE, OM.ERP_INSERT_YORN, OM.REQUEST_CANCLE_TITLE, OM.PAYMENT_TYPE_CODE, 
                      OM.PAYMENT_STATUS_CODE, OM.DESCRIPTION
FROM         dbo.ORDER_MST AS OM LEFT OUTER JOIN
                      dbo.USER_MST AS UM ON OM.USER_SEQ = UM.USER_SEQ LEFT OUTER JOIN
                      dbo.ADMIN_USER_MST AS AUM ON AUM.ADMIN_USER_SEQ = OM.ADMIN_USER_SEQ

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
         Begin Table = "UM"
            Begin Extent = 
               Top = 6
               Left = 266
               Bottom = 125
               Right = 508
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AUM"
            Begin Extent = 
               Top = 6
               Left = 546
               Bottom = 125
               Right = 734
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "OM"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 281
               Right = 227
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
         Column = 1590
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_ORDER_MST'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_ORDER_MST'
GO
