IF OBJECT_ID (N'dbo.VW_USER_INFO_ASTERISK', N'V') IS NOT NULL DROP View dbo.VW_USER_INFO_ASTERISK
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_USER_INFO_ASTERISK]
AS
SELECT  uid, pwd, uname, umail, jumin, birth, birth_div, zip1, zip2, address, addr_detail, phone1, phone2, phone3, 
               hand_phone1, hand_phone2, hand_phone3, chk_mail_input, chk_sms, chk_mailservice, site_div, isJehu, 
               company_seq, login_date, login_date_lastest, login_count, is_appSample, reg_date, var1, site_div_lastest, 
               RequestNumber, AuthType, DupInfo, ConnInfo, Gender, BirthDate, NationalInfo, wedd_year, wedd_month, 
               wedd_day, Name, isMCardAble, ugubun, chk_DM, wedd_hour, wedd_minute, wedd_pgubun, mod_date, 
               chk_smembership, addr_flag, smembership_reg_date, smembership_leave_date, chk_smembership_leave, 
               chk_smembership_per, chk_smembership_coop, inflow_route, smembership_inflow_route, 
               smembership_chk_flag, mkt_chk_flag, zip1_R, zip2_R, address_R, addr_detail_R, chk_DormancyAccount, 
               INTEGRATION_MEMBER_YORN, USE_YORN
FROM     (SELECT  uid, pwd, uname, umail, jumin, birth, birth_div, zip1, zip2, address, addr_detail, phone1, phone2, 
                               phone3, hand_phone1, hand_phone2, hand_phone3, chk_mail_input, chk_sms, chk_mailservice, 
                               site_div, isJehu, company_seq, login_date, login_date_lastest, login_count, is_appSample, reg_date, 
                               var1, site_div_lastest, RequestNumber, AuthType, DupInfo, ConnInfo, Gender, BirthDate, NationalInfo, 
                               wedd_year, wedd_month, wedd_day, Name, isMCardAble, ugubun, chk_DM, wedd_hour, wedd_minute, 
                               wedd_pgubun, mod_date, chk_smembership, addr_flag, smembership_reg_date, 
                               smembership_leave_date, chk_smembership_leave, chk_smembership_per, chk_smembership_coop, 
                               inflow_route, smembership_inflow_route, smembership_chk_flag, mkt_chk_flag, zip1_R, zip2_R, 
                               address_R, addr_detail_R, chk_DormancyAccount, INTEGRATION_MEMBER_YORN, USE_YORN
                FROM     dbo.S2_UserInfo
                UNION ALL
                SELECT  uid, pwd, uname, umail, jumin, birth, birth_div, zip1, zip2, address, addr_detail, phone1, phone2, 
                               phone3, hand_phone1, hand_phone2, hand_phone3, chk_mail_input, chk_sms, chk_mailservice, 
                               site_div, isJehu, company_seq, login_date, login_date_lastest, login_count, is_appSample, reg_date, 
                               var1, site_div_lastest, RequestNumber, AuthType, DupInfo, ConnInfo, Gender, BirthDate, NationalInfo, 
                               wedd_year, wedd_month, wedd_day, Name, isMCardAble, ugubun, chk_DM, wedd_hour, wedd_minute, 
                               wedd_pgubun, mod_date, chk_smembership, addr_flag, smembership_reg_date, 
                               smembership_leave_date, chk_smembership_leave, chk_smembership_per, chk_smembership_coop, 
                               inflow_route, smembership_inflow_route, smembership_chk_flag, mkt_chk_flag, zip1_R, zip2_R, 
                               address_R, addr_detail_R, chk_DormancyAccount, INTEGRATION_MEMBER_YORN, USE_YORN
                FROM     dbo.S2_UserInfo_BHands
                UNION ALL
                SELECT  uid, pwd, uname, umail, jumin, birth, birth_div, zip1, zip2, address, addr_detail, phone1, phone2, 
                               phone3, hand_phone1, hand_phone2, hand_phone3, chk_mail_input, chk_sms, chk_mailservice, 
                               site_div, isJehu, company_seq, login_date, login_date_lastest, login_count, is_appSample, reg_date, 
                               var1, site_div_lastest, RequestNumber, AuthType, DupInfo, ConnInfo, Gender, BirthDate, NationalInfo, 
                               wedd_year, wedd_month, wedd_day, Name, isMCardAble, ugubun, chk_DM, wedd_hour, wedd_minute, 
                               wedd_pgubun, mod_date, chk_smembership, addr_flag, smembership_reg_date, 
                               smembership_leave_date, chk_smembership_leave, chk_smembership_per, chk_smembership_coop, 
                               inflow_route, smembership_inflow_route, smembership_chk_flag, mkt_chk_flag, zip1_R, zip2_R, 
                               address_R, addr_detail_R, chk_DormancyAccount, INTEGRATION_MEMBER_YORN, USE_YORN
                FROM     dbo.S2_UserInfo_TheCard) AS A
WHERE  (DupInfo = 'MC0GCCqGSIb3DQIJAyEAgQMn9E0TJmup1Yu5+Ws1cmQPM5Io02lOWvzoC0hwn0o=')
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
         Begin Table = "A"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 291
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_USER_INFO_ASTERISK'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_USER_INFO_ASTERISK'
GO
