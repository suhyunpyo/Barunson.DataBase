IF OBJECT_ID (N'dbo.VW_MO_TRAN', N'V') IS NOT NULL DROP View dbo.VW_MO_TRAN
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_MO_TRAN]
AS
SELECT  MO_NUM, MO_ACCEPTTIME, MO_MODIFIED, MO_NUMBER, MO_SENDER, MO_MSG, MO_SN, MO_NET, 
               MO_STATUS, MO_REPLY_DATE, MO_REPLY_MSG, admin_id, act_date, reg_date, LEFT(MO_ACCEPTTIME, 4) 
               + '-' + SUBSTRING(MO_ACCEPTTIME, 5, 2) + '-' + SUBSTRING(MO_ACCEPTTIME, 7, 2) 
               + ' ' + SUBSTRING(MO_ACCEPTTIME, 9, 2) + ':' + SUBSTRING(MO_ACCEPTTIME, 11, 2) 
               + ':' + SUBSTRING(MO_ACCEPTTIME, 13, 2) AS ACCEPT_DATE, DATEDIFF(MINUTE, LEFT(MO_ACCEPTTIME, 4) 
               + '-' + SUBSTRING(MO_ACCEPTTIME, 5, 2) + '-' + SUBSTRING(MO_ACCEPTTIME, 7, 2) 
               + ' ' + SUBSTRING(MO_ACCEPTTIME, 9, 2) + ':' + SUBSTRING(MO_ACCEPTTIME, 11, 2) 
               + ':' + SUBSTRING(MO_ACCEPTTIME, 13, 2), CONVERT(VARCHAR(19), act_date, 120)) AS HANDLE_TIME
FROM     invtmng.MO_TRAN
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
         Begin Table = "MO_TRAN (invtmng)"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 221
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_MO_TRAN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_MO_TRAN'
GO
