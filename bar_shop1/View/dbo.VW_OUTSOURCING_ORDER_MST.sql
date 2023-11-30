IF OBJECT_ID (N'dbo.VW_OUTSOURCING_ORDER_MST', N'V') IS NOT NULL DROP View dbo.VW_OUTSOURCING_ORDER_MST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_OUTSOURCING_ORDER_MST]  
AS  
SELECT  OOM.OUTSOURCING_ORDER_SEQ, OOM.ORDER_STATUS_CODE, OOM.ORDER_SEQ, OOM.CARD_CODE, OOM.ORDER_NAME, OOM.ORDER_QTY, OOM.PAPER_TYPE_NAME,   
               OOM.PAPER_SIZE, OOM.PAGES_PER_SHEET_VALUE, OOM.PRINT_LOSS_VALUE, OOM.BOTH_SIDE_YORN, OOM.OSI_YORN, OOM.CUTOUT_YORN, OOM.GLOSSY_YORN,   
               OOM.PRESS_YORN, OOM.FOIL_TYPE_NAME, OOM.LASER_CUT_YORN, OOM.REQUESTOR_NAME, OOM.COMPANY_TYPE_CODE, OOM.DELIVERY_TYPE_CODE, OOM.PRINT_FILE_URL,   
               OOM.IMAGE_FILE_URL, OOM.RECEIPT_DATE, OOM.REG_DATE, CC_0.DTL_NAME AS ORDER_STATUS_CODE_NAME, CC_7.DTL_NAME AS COMPANY_TYPE_NAME,   
               CC_8.DTL_NAME AS DELIVERY_TYPE_NAME, CC_1.DTL_NAME AS SITE_TYPE_NAME, OOM.SITE_TYPE_CODE, OOM.ORDER_TYPE_CODE, OOM.ERP_PART_TYPE_CODE,   
               CC_9.DTL_NAME AS ERP_PART_TYPE_NAME, CC_9.RMRK_CLMN AS ERP_PART_SUB_TYPE_CODE, OOM.ORDER_SUB_TYPE_CODE,   
               CC_10.DTL_NAME AS ORDER_SUB_TYPE_NAME, OOM.MEMO AS MEMO, OOM.EXPECT_DATE AS EXPECT_DATE, OOM.EDGE_YORN AS EDGE_YORN, OOM.EDGE_COLOR AS EDGE_COLOR,  
      OOM.PRINT_CHASU AS PRINT_CHASU, OOM.DEV_FLAG, OOM.MEMO_EX AS MEMO_EX
FROM     dbo.OUTSOURCING_ORDER_MST AS OOM INNER JOIN  
               dbo.COMMON_CODE AS CC_0 ON OOM.ORDER_STATUS_CODE = CC_0.CMMN_CODE INNER JOIN  
               dbo.COMMON_CODE AS CC_1 ON OOM.SITE_TYPE_CODE = CC_1.CMMN_CODE INNER JOIN  
               dbo.COMMON_CODE AS CC_7 ON OOM.COMPANY_TYPE_CODE = CC_7.CMMN_CODE INNER JOIN  
               dbo.COMMON_CODE AS CC_8 ON OOM.DELIVERY_TYPE_CODE = CC_8.CMMN_CODE INNER JOIN  
               dbo.COMMON_CODE AS CC_9 ON OOM.ERP_PART_TYPE_CODE = CC_9.CMMN_CODE INNER JOIN  
               dbo.COMMON_CODE AS CC_10 ON OOM.ORDER_SUB_TYPE_CODE = CC_10.CMMN_CODE  





			    

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
         Begin Table = "OOM"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 279
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "CC_0"
            Begin Extent = 
               Top = 6
               Left = 317
               Bottom = 135
               Right = 490
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CC_1"
            Begin Extent = 
               Top = 6
               Left = 528
               Bottom = 135
               Right = 701
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CC_7"
            Begin Extent = 
               Top = 6
               Left = 739
               Bottom = 135
               Right = 912
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CC_8"
            Begin Extent = 
               Top = 6
               Left = 950
               Bottom = 135
               Right = 1123
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CC_9"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 267
               Right = 211
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CC_10"
            Begin Extent = 
               Top = 138
               Left = 249
               Bottom = 268
               Right = 422
            End
            DisplayFlags = 280
            TopColumn = ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_OUTSOURCING_ORDER_MST'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'0
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_OUTSOURCING_ORDER_MST'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_OUTSOURCING_ORDER_MST'
GO
