IF OBJECT_ID (N'dbo.view_UsrInfo', N'V') IS NOT NULL DROP View dbo.view_UsrInfo
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_UsrInfo]
AS
SELECT  '비핸즈카드' AS site_name, 's2_userinfo_bhands' AS tbl_name, uid, uname, pwd, jumin, umail, phone1 + phone2 + phone3 AS phone, 
               hand_phone1 + hand_phone2 + hand_phone3 AS hand_phone, reg_date, company_seq
FROM     s2_userinfo_bhands
UNION ALL
SELECT  '더카드' AS site_name, 's2_userinfo_thecard' AS tbl_name, uid, uname, pwd, jumin, umail, phone1 + phone2 + phone3 AS phone, 
               hand_phone1 + hand_phone2 + hand_phone3 AS hand_phone, reg_date, company_seq
FROM     s2_userinfo_thecard
UNION ALL
SELECT  '바른손/프리미어' AS site_name, 's2_userinfo' AS tbl_name, uid, uname, pwd, jumin, umail, phone1 + phone2 + phone3 AS phone, 
               hand_phone1 + hand_phone2 + hand_phone3 AS hand_phone, reg_date, company_seq
FROM     s2_userinfo
/* 2023-11-21 사용안함
UNION ALL
SELECT  '티아라카드' AS site_name, 'tiara_member' AS tbl_name, uid, name AS uname, pw AS pwd, jumin, mail AS umail, phone1 + phone2 + phone3 AS phone, 
               hand_phone1 + hand_phone2 + hand_phone3 AS hand_phone, rdate AS reg_date, -1 AS company_seq
FROM     tiara_member
*/
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_UsrInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_UsrInfo'
GO
