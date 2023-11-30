IF OBJECT_ID (N'dbo.VW_USER_INFO', N'V') IS NOT NULL DROP View dbo.VW_USER_INFO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[VW_USER_INFO]
WITH SCHEMABINDING
AS
	SELECT
		  uid
		, pwd
		, uname
		, umail
		, birth AS BIRTH_DATE
		, birth_div AS BIRTH_DATE_TYPE
		, DupInfo
		, ConnInfo
		, AuthType
		, BirthDate AS ORIGINAL_BIRTH_DATE
		, Gender
		, NationalInfo AS NATIONAL_INFO
		, CASE
			 WHEN WEDD_YEAR <> '' AND WEDD_MONTH <> ''AND WEDD_DAY <> '' THEN WEDD_YEAR
			 ELSE ''
		  END AS WEDD_YEAR
		, CASE
			 WHEN WEDD_YEAR <> '' AND WEDD_MONTH <> '' AND WEDD_DAY <> '' THEN WEDD_MONTH
			 ELSE ''
		  END AS WEDD_MONTH
		, CASE
			 WHEN WEDD_YEAR <> '' AND WEDD_MONTH <> '' AND WEDD_DAY <> '' THEN WEDD_DAY
			 ELSE ''
		  END AS WEDD_DAY
		, CASE
			 WHEN WEDD_YEAR <> '' AND WEDD_MONTH <> '' AND WEDD_DAY <> '' THEN WEDD_YEAR + '-' + WEDD_MONTH + '-' + WEDD_DAY
			 ELSE ''
		  END AS WEDDING_DAY
		, wedd_pgubun AS WEDDING_HALL
		, site_div
		, CASE
			 WHEN SITE_DIV = 'SB' THEN '바른손카드'
			 WHEN SITE_DIV = 'SS' THEN '프리미어페이퍼'
			 WHEN SITE_DIV = 'H' THEN '바른손몰(H)'
			 WHEN SITE_DIV = 'SA' THEN '비핸즈카드'
			 WHEN SITE_DIV = 'B' THEN '바른손몰(B)'
			 WHEN SITE_DIV = 'C' THEN '비핸즈카드 제휴'
			 WHEN SITE_DIV = 'ST' THEN '더카드'
			 ELSE '기타'
		  END AS SITE_DIV_NAME
		, chk_sms
		, chk_mailservice
		, CASE
			 WHEN REPLACE(HPHONE, '-', '') = '' THEN ''
			 ELSE HPHONE
		  END AS HPHONE
		, CASE
			 WHEN REPLACE(PHONE, '-', '') = '' THEN ''
			 ELSE PHONE
		  END AS PHONE
		, CASE
			 WHEN REPLACE(ZIPCODE, '-', '') = '' THEN ''
			 WHEN LEN(REPLACE(ZIPCODE, '-', '')) = 5 THEN REPLACE(ZIPCODE, '-', '')
			 ELSE ZIPCODE
		  END AS ZIPCODE
		, isJehu
		, zip1
		, zip2
		, address
		, addr_detail
		, mkt_chk_flag
		, chk_smembership AS CHOICE_AGREEMENT_FOR_SAMSUNG_MEMBERSHIP
		, chk_smembership_per AS CHOICE_AGREEMENT_FOR_SAMSUNG_CHOICE_PERSONAL_DATA
		, chk_smembership_coop AS CHOICE_AGREEMENT_FOR_SAMSUNG_THIRDPARTY
		, smembership_reg_date
		, INTEGRATION_MEMBER_YORN
		, INTERGRATION_DATE
		, INTERGRATION_BEFORE_ID
		, REFERER_SALES_GUBUN
		, SELECT_SALES_GUBUN
		, SELECT_USER_ID
		, USE_YORN
		, reg_date
		, company_seq
		, CHK_MYOMEE
		, MYOMEE_REG_DATE
		, isMCardAble
        , inflow_route
		, chk_iloommembership
		, iloommembership_reg_date
		, chk_lgmembership
		, lgmembership_reg_date
		, chk_cuckoosmembership
		, cuckoosship_reg_Date
		, chk_casamiamembership
		, casamiaship_reg_Date
		, chk_ktmembership
		, ktmembership_reg_Date
		, chk_hyundaimembership
		, hyundaimembership_reg_Date
		, wedd_name
		, smembership_period
	FROM
    (
	   SELECT
			uid
		   , pwd
		   , uname
		   , umail
		   , birth
		   , birth_div
		   , DupInfo
		   , ConnInfo
		   , ISNULL(wedd_year, '') AS WEDD_YEAR
		   , RIGHT('0' + ISNULL(wedd_month, ''), 2) AS WEDD_MONTH
		   , RIGHT('0' + ISNULL(wedd_day, ''), 2) AS WEDD_DAY
		   , wedd_pgubun
		   , site_div
		   , chk_sms
		   , chk_mailservice
		   , hand_phone1 + '-' + hand_phone2 + '-' + hand_phone3 AS HPHONE
		   , phone1 + '-' + phone2 + '-' + phone3 AS PHONE
		   , zip1 + '-' + zip2 AS ZIPCODE
		   , isJehu
		   , zip1
		   , zip2
		   , address
		   , addr_detail
		   , mkt_chk_flag
		   , INTEGRATION_MEMBER_YORN
		   , USE_YORN
		   , reg_date
		   , AuthType
		   , chk_smembership
		   , chk_smembership_per
		   , chk_smembership_coop
		   , smembership_reg_date
		   , INTERGRATION_DATE
		   , INTERGRATION_BEFORE_ID
		   , REFERER_SALES_GUBUN
		   , SELECT_SALES_GUBUN
		   , SELECT_USER_ID
		   , BirthDate
		   , Gender
		   , NationalInfo
		   , CASE
			    WHEN site_div = 'SB' THEN '5001'
			    WHEN site_div = 'SS' THEN '5003'
			    ELSE company_seq
			END AS company_seq
		   , CHK_MYOMEE
		   , MYOMEE_REG_DATE
		   , isMCardAble
           , inflow_route
		   , chk_iloommembership
		   , iloommembership_reg_date
		, chk_lgmembership
		, lgmembership_reg_date
		, chk_cuckoosmembership
		, cuckoosship_reg_Date
		, chk_casamiamembership
		, casamiaship_reg_Date
		, chk_ktmembership
		, ktmembership_reg_Date
		, chk_hyundaimembership
		, hyundaimembership_reg_Date
		, wedd_name
		, smembership_period
	   FROM dbo.S2_UserInfo
	   WHERE site_div IN ('SB', 'SS', 'H', 'BM')
    
	   UNION ALL
    
	   SELECT
			uid
		   , pwd
		   , uname
		   , umail
		   , birth
		   , birth_div
		   , DupInfo
		   , ConnInfo
		   , ISNULL(wedd_year, '') AS WEDD_YEAR
		   , RIGHT('0' + ISNULL(wedd_month, ''), 2) AS WEDD_MONTH
		   , RIGHT('0' + ISNULL(wedd_day, ''), 2) AS WEDD_DAY
		   , wedd_pgubun
		   , site_div
		   , chk_sms
		   , chk_mailservice
		   , hand_phone1 + '-' + hand_phone2 + '-' + hand_phone3 AS HPHONE
		   , phone1 + '-' + phone2 + '-' + phone3 AS PHONE
		   , zip1 + '-' + zip2 AS ZIPCODE
		   , isJehu
		   , zip1
		   , zip2
		   , address
		   , addr_detail
		   , mkt_chk_flag
		   , INTEGRATION_MEMBER_YORN
		   , USE_YORN
		   , reg_date
		   , AuthType
		   , chk_smembership
		   , chk_smembership_per
		   , chk_smembership_coop
		   , smembership_reg_date
		   , INTERGRATION_DATE
		   , INTERGRATION_BEFORE_ID
		   , REFERER_SALES_GUBUN
		   , SELECT_SALES_GUBUN
		   , SELECT_USER_ID
		   , BirthDate
		   , Gender
		   , NationalInfo
		   , CASE
			    WHEN site_div = 'SA' THEN '5006'
			    ELSE company_seq
			END AS company_seq
		   , CHK_MYOMEE
		   , MYOMEE_REG_DATE
		   , isMCardAble
           , inflow_route
		   , chk_iloommembership
		   , iloommembership_reg_date
		, chk_lgmembership
		, lgmembership_reg_date
		, chk_cuckoosmembership
		, cuckoosship_reg_Date
		, chk_casamiamembership
		, casamiaship_reg_Date
		, chk_ktmembership
		, ktmembership_reg_Date
		, chk_hyundaimembership
		, hyundaimembership_reg_Date
		, wedd_name
		, smembership_period
	   FROM dbo.S2_UserInfo_BHands
	   WHERE site_div IN ('SA', 'B', 'C')

	   UNION ALL

	   SELECT
			uid
		   , pwd
		   , uname
		   , umail
		   , birth
		   , birth_div
		   , DupInfo
		   , ConnInfo
		   , ISNULL(wedd_year, '') AS WEDD_YEAR
		   , RIGHT('0' + ISNULL(wedd_month, ''), 2) AS WEDD_MONTH
		   , RIGHT('0' + ISNULL(wedd_day, ''), 2) AS WEDD_DAY
		   , wedd_pgubun
		   , site_div
		   , chk_sms
		   , chk_mailservice
		   , hand_phone1 + '-' + hand_phone2 + '-' + hand_phone3 AS HPHONE
		   , phone1 + '-' + phone2 + '-' + phone3 AS PHONE
		   , zip1 + '-' + zip2 AS ZIPCODE
		   , isJehu
		   , zip1
		   , zip2
		   , address
		   , addr_detail
		   , mkt_chk_flag
		   , INTEGRATION_MEMBER_YORN
		   , USE_YORN
		   , reg_date
		   , AuthType
		   , chk_smembership
		   , chk_smembership_per
		   , chk_smembership_coop
		   , smembership_reg_date
		   , INTERGRATION_DATE
		   , INTERGRATION_BEFORE_ID
		   , REFERER_SALES_GUBUN
		   , SELECT_SALES_GUBUN
		   , SELECT_USER_ID
		   , BirthDate
		   , Gender
		   , NationalInfo
		   , CASE
			    WHEN site_div = 'ST' THEN '5007'
			    ELSE company_seq
			END AS company_seq
		   , CHK_MYOMEE
		   , MYOMEE_REG_DATE
		   , isMCardAble
           , inflow_route
		   , chk_iloommembership
		   , iloommembership_reg_date
		, chk_lgmembership
		, lgmembership_reg_date
		, chk_cuckoosmembership
		, cuckoosship_reg_Date
		, chk_casamiamembership
		, casamiaship_reg_Date
		, chk_ktmembership
		, ktmembership_reg_Date
		, chk_hyundaimembership
		, hyundaimembership_reg_Date
		, wedd_name
		, smembership_period
	   FROM dbo.S2_UserInfo_TheCard
	   WHERE site_div IN ('ST')
    ) AS A;


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
               Bottom = 136
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_USER_INFO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_USER_INFO'
GO
