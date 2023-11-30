IF OBJECT_ID (N'dbo.S2_orderLstN', N'V') IS NOT NULL DROP View dbo.S2_orderLstN
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [dbo].[S2_orderLstN]
AS
	SELECT
		  A.order_seq
		, A.order_type
		, A.isChoanRisk
		, A.isSpecial
		, A.sales_Gubun
		, A.site_gubun
		, A.pay_Type
		, A.company_seq
		, C.COMPANY_NAME
		, ISNULL(C.ERP_PartCode , '') AS erp_partcode
		, A.up_order_seq
		, A.order_add_flag
		, A.order_add_type
		, A.status_seq
		, A.member_id
		, A.order_hphone
		, A.order_email
		, A.src_compose_admin_id
		, A.src_compose_mod_admin_id
		, A.order_date
		, A.settle_date
		, A.src_ap_date
		, A.src_compose_date
		, A.src_confirm_date
		, A.src_modRequest_date
		, A.src_compose_mod_date
		, A.src_printW_date
		, A.src_print_date
		, A.src_printCopy_date
		, A.src_CloseCopy_date
		, A.src_printer_seq
		, A.src_packing_date
		, A.src_send_date
		, A.order_name
		, A.settle_status
		, A.isinpaper
		, A.ishandmade
		, A.isEnvInsert
		, A.isLiningJaebon
		, ISNULL(A.fticket_price, 0) AS fticket_price
		, ISNULL(A.embo_price, 0) AS embo_price
		, A.isEmbo
		, ISNULL(A.envInsert_price, 0) AS envInsert_price
		, ISNULL(A.mini_price, 0) AS mini_price
		, A.isColorInpaper
		, A.isCompose
		, A.isChoanRisk AS Expr1
		, A.ProcLevel
		, A.couponseq
		, D.card_code
		, D.old_code
		, D.card_code_str
		, D.Master_2Color
		, A.order_count
		, ISNULL(A.order_price, 0) AS order_price
		, ISNULL(A.settle_price , 0) AS settle_price
		, ISNULL(A.unicef_price, 0) AS unicef_price
		, ISNULL(A.last_total_price, 0) AS last_total_price
		, B.groom_name + '.' + B.bride_name + '.' + B.groom_father + '.' + B.groom_mother + '.' + B.bride_father + '.' + B.bride_mother AS etc_name
		, B.wedd_name
		, ISNULL(B.wedd_phone , '') AS wedd_phone
		, A.src_packing_date AS Expr2
		, D.brand_code
		, B.map_trans_method
		, A.isCorel
		, A.isBaesongRisk
		, A.isRibon
		, A.isColorPrint
		, A.trouble_type
		, A.trouble_version
		, A.trouble_type_new
		, A.isVar
		, A.settle_method
		, A.discount_in_advance_cancel_date
		, A.discount_in_advance_reg_date
		, A.discount_in_advance
		, A.cancel_user_type
		, A.cancel_type_comment
		, A.cancel_type
		, B.wedd_place
		, B.wedd_addr
		, A.order_g_seq
		, D.isLaser
		, ISNULL(A.laser_price, 0) AS laser_price
		, ISNULL(A.inflow_route , 'PC') AS Inflow_Route_Order
		, ISNULL(A.inflow_route_settle , 'PC') AS Inflow_Route_Settle
		, A.addition_couponseq
		, D.PrintMethod
		, D.isMasterDigital
		, A.Auto_Choan_Status_Code
        --, CC.DTL_Name AS Auto_Choan_Status_Name
        , case when A.Auto_Choan_Status_Code is not null then (select DTL_Name from  Common_Code where A.Auto_Choan_Status_Code = CMMN_Code ) else '미완료' end AS Auto_Choan_Status_Name
		, ISNULL(A.isEnvCharge , '0') AS isEnvCharge
        , ISNULL(A.isEnvSpecial, '0') AS isEnvSpecial
		, A.sasik_price
		, CASE WHEN (ISNULL(E.ORDER_SEQ,'') <> '' OR A.couponseq IN ('BSMSUPPORT50R','BSMSUPPORT50R2','BSMSUPPORT25R','BSMSUPPORT50RN')) THEN 'Y' ELSE 'N' END crnc_flag 
		, ISNULL(A.isCCG,'N') isCCG
	FROM   custom_order AS A
		INNER JOIN custom_order_WeddInfo AS B
			ON A.weddinfo_id = B.order_seq
		INNER JOIN COMPANY AS C
			ON A.company_seq = C.COMPANY_SEQ
		INNER JOIN S2_CardViewN AS D
			ON A.card_seq = D.card_seq
        --LEFT OUTER JOIN Common_Code AS CC
        --    ON A.Auto_Choan_Status_Code = CC.CMMN_Code
		LEFT JOIN
		(
			SELECT  ORDER_SEQ FROM 
			CUSTOM_ORDER_COUPON A
			INNER JOIN COUPON_ISSUE B ON A.COUPON_ISSUE_SEQ = B.COUPON_ISSUE_SEQ 
			INNER JOIN COUPON_DETAIL C ON B.COUPON_DETAIL_SEQ = C.COUPON_DETAIL_SEQ
			where COUPON_CODE IN 
			(
			'74A9-20DE-4039-A118',
			'1FC2-2AC4-4BC4-999D',
			'2C73-A38A-4CE5-A556',
			'2F6A-8E03-4F23-8901',
			'2FE1-FCF5-4F91-A624',
			'B9C3-2AB7-4F25-8292',
			'FF6E-21A8-4053-B8DD',
			'B312-AB62-4AC9-B288',
			'6A2A-4F36-4ECB-B00F',
			'2F13-6EE7-47F8-8D38',
			'731A-9E73-46B4-9946',
			'9E9E-7C1B-4346-8AFF',
			'77BB-8BF4-4D27-B27E',
			'50E2-8165-4B36-9843',
			'AA63-DB69-4B73-B606',
			'475B-EE45-4DFB-8DC2',
			'4B42-CC8C-43A6-BA25',
			'3EE7-BC89-40C8-BFAF'
			)
			group by ORDER_SEQ
		) AS E ON A.ORDER_SEQ = E.ORDER_SEQ
	WHERE  A.status_seq >= 1 and (A.AUTO_CHOAN_STATUS_CODE <> '138003' OR A.AUTO_CHOAN_STATUS_CODE IS NULL);

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
               Right = 280
            End
            DisplayFlags = 280
            TopColumn = 150
         End
         Begin Table = "B"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 267
               Right = 248
            End
            DisplayFlags = 280
            TopColumn = 38
         End
         Begin Table = "C"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 399
               Right = 253
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "D"
            Begin Extent = 
               Top = 138
               Left = 286
               Bottom = 267
               Right = 447
            End
            DisplayFlags = 280
            TopColumn = 12
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'S2_orderLstN'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'S2_orderLstN'
GO
