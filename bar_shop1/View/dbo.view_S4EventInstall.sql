IF OBJECT_ID (N'dbo.view_S4EventInstall', N'V') IS NOT NULL DROP View dbo.view_S4EventInstall
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_S4EventInstall]
AS
SELECT     A.seq, A.company_seq, '비핸즈카드' AS company_name, A.uid, B.uname, CONVERT(varchar(10), A.reg_date, 21) AS reg_date, 
                      B.hand_phone1 + '-' + B.hand_phone2 + '-' + B.hand_phone3 AS hphone, B.address + ' ' + B.addr_detail AS addr, favorite_install, desktop_install, favorite_cnt, 
                      desktop_cnt, A.isSelection, A.isUsed, B.login_count
FROM         S4_Event_install A INNER JOIN
                      S2_userinfo_bhands B ON A.uid = B.uid
WHERE     A.company_Seq = 5006
UNION ALL
SELECT     A.seq, A.company_seq, '더카드' AS company_name, A.uid, B.uname, CONVERT(varchar(10), A.reg_date, 21) AS reg_date, 
                      B.hand_phone1 + '-' + B.hand_phone2 + '-' + B.hand_phone3 AS hphone, B.address + ' ' + B.addr_detail AS addr, favorite_install, desktop_install, favorite_cnt, 
                      desktop_cnt, A.isSelection, A.isUsed, B.login_count
FROM         S4_Event_install A INNER JOIN
                      S2_userinfo_thecard B ON A.uid = B.uid
WHERE     A.company_Seq = 5007
UNION ALL
SELECT     A.seq, A.company_seq, '바른손카드' AS company_name, A.uid, B.uname, CONVERT(varchar(10), A.reg_date, 21) AS reg_date, 
                      B.hand_phone1 + '-' + B.hand_phone2 + '-' + B.hand_phone3 AS hphone, B.address + ' ' + B.addr_detail AS addr, favorite_install, desktop_install, favorite_cnt, 
                      desktop_cnt, A.isSelection, A.isUsed, B.login_count
FROM         S4_Event_install A INNER JOIN
                      S2_userinfo B ON A.uid = B.uid
WHERE     A.company_Seq = 5001 and b.site_div = 'SB'
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
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_S4EventInstall'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_S4EventInstall'
GO
