IF OBJECT_ID (N'dbo.orderLst', N'V') IS NOT NULL DROP View dbo.orderLst
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[orderLst]
AS
SELECT   A.order_seq, A.order_type, A.isChoanRisk, A.sales_Gubun, A.site_gubun, 
                A.pay_Type, A.company_seq, C.COMPANY_NAME, A.up_order_seq, 
                A.order_add_flag, A.order_add_type, A.status_seq, A.member_id, A.order_hphone, 
                A.order_email, A.src_compose_admin_id, A.order_date, A.src_compose_date, 
                A.src_confirm_date, A.src_modRequest_date, A.src_printW_date, 
                A.src_print_date, A.src_send_date, A.order_name, A.settle_status, A.isinpaper, 
                A.ishandmade, A.fticket_price, A.mini_price, A.isCompose, 
                A.isChoanRisk AS Expr1, A.ProcLevel, A.couponseq, D.CARD_CODE, 
                A.order_count, A.order_price, ISNULL(A.settle_price, 0) AS settle_price, 
                A.last_total_price, 
                B.groom_name + '.' + B.bride_name + '.' + B.groom_father + '.' + B.groom_mother +
                 '.' + B.bride_father + '.' + B.bride_mother AS etc_name, B.wedd_name, 
                A.src_packing_date, D.COMPANY
FROM      dbo.custom_order A INNER JOIN
                dbo.custom_order_WeddInfo B ON A.order_seq = B.order_seq INNER JOIN
                dbo.COMPANY C ON A.company_seq = C.COMPANY_SEQ INNER JOIN
                dbo.CARD D ON A.card_seq = D.CARD_SEQ
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
         Configuration = "(H (1[50] 2[25] 3) )"
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
         Configuration = "(H (1 [56] 4 [18] 2))"
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
         Begin Table = "A"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 109
               Right = 283
            End
            DisplayFlags = 280
            TopColumn = 19
         End
         Begin Table = "B"
            Begin Extent = 
               Top = 6
               Left = 321
               Bottom = 109
               Right = 508
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "C"
            Begin Extent = 
               Top = 6
               Left = 546
               Bottom = 109
               Right = 741
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "D"
            Begin Extent = 
               Top = 114
               Left = 38
               Bottom = 217
               Right = 300
            End
            DisplayFlags = 280
            TopColumn = 31
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 240
      Begin ColumnWidths = 43
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
 ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'orderLst'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'        Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'orderLst'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'orderLst'
GO
