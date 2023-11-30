IF OBJECT_ID (N'dbo.VW_DELIVERY_MST', N'V') IS NOT NULL DROP View dbo.VW_DELIVERY_MST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_DELIVERY_MST]
AS
SELECT  SAMPLE_ORDER_SEQ AS ORDER_SEQ, A.SALES_GUBUN, A.COMPANY_SEQ, B.COMPANY_NAME, 
               '' AS ORDER_TYPE, 'CUSTOM_SAMPLE_ORDER' AS ORDER_TABLE_NAME, A.ISHJ, A.STATUS_SEQ, 
               ISNULL(B.ERP_PARTCODE, '') AS ERP_PARTCODE, A.DELIVERY_CODE_NUM AS DELIVERY_CODE, 
               A.MEMBER_ZIP AS RECV_ZIP, A.MEMBER_ADDRESS AS RECV_ADDR, 
               A.MEMBER_ADDRESS_DETAIL AS RECV_ADDR_DETAIL, A.MEMBER_NAME AS RECV_NAME, 
               A.MEMBER_PHONE AS RECV_PHONE, A.MEMBER_HPHONE AS RECV_HPHONE, '' AS RECV_MSG, 
               A.DELIVERY_DATE AS SEND_DATE, ISNULL(A.MEMO, '') AS DELIVERY_MSG, 1 AS DELIVERY_SEQ
FROM     CUSTOM_SAMPLE_ORDER A JOIN
               COMPANY B ON A.COMPANY_SEQ = B.COMPANY_SEQ
WHERE  1 = 1 AND A.STATUS_SEQ = 12 
UNION ALL
SELECT  A.ORDER_SEQ AS ORDER_SEQ, A.SALES_GUBUN, A.COMPANY_SEQ, B.COMPANY_NAME, A.ORDER_TYPE, 
               'CUSTOM_ETC_ORDER' AS ORDER_TABLE_NAME, A.ISHJ, A.STATUS_SEQ, ISNULL(B.ERP_PARTCODE, '') 
               AS ERP_PARTCODE, A.DELIVERY_CODE, A.RECV_ZIP, A.RECV_ADDRESS AS RECV_ADDR, 
               A.RECV_ADDRESS_DETAIL AS RECV_ADDR_DETAIL, A.RECV_NAME, A.RECV_PHONE, A.RECV_HPHONE, 
               A.RECV_MSG, A.DELIVERY_DATE AS SEND_DATE, ISNULL(A.RECV_MSG, '') AS DELIVERY_MSG, 
               1 AS DELIVERY_SEQ
FROM     CUSTOM_ETC_ORDER A INNER JOIN
               COMPANY B ON A.COMPANY_SEQ = B.COMPANY_SEQ
WHERE  1 = 1 AND A.STATUS_SEQ = 12 
UNION ALL
SELECT  A.ORDER_SEQ AS ORDER_SEQ, A.SALES_GUBUN, A.COMPANY_SEQ, D .COMPANY_NAME, '' AS ORDER_TYPE, 
               'CUSTOM_ORDER' AS ORDER_TABLE_NAME, C.ISHJ, A.STATUS_SEQ, ISNULL(D .ERP_PARTCODE, '') 
               AS ERP_PARTCODE, C.DELIVERY_CODE_NUM AS DELIVERY_CODE, B.ZIP AS RECV_ZIP, 
               B.ADDR AS RECV_ADDR, B.ADDR_DETAIL AS RECV_ADDR_DETAIL, 
			   
			   	CASE WHEN ISNULL(B.NAME,'') = ''
					THEN A.order_name
					ELSE B.NAME
				END RECV_NAME,

			   --B.NAME AS RECV_NAME, 
               
			   B.PHONE AS RECV_PHONE, B.HPHONE AS RECV_HPHONE, '' AS RECV_MSG, 
               A.SRC_SEND_DATE AS SEND_DATE, ISNULL(B.DELIVERY_MEMO, '') AS DELIVERY_MSG, 
               DELIVERY_SEQ AS DELIVERY_SEQ
FROM     CUSTOM_ORDER A JOIN
               DELIVERY_INFO B ON A.ORDER_SEQ = B.ORDER_SEQ JOIN
               DELIVERY_INFO_DELCODE C ON B.ID = C.DELIVERY_ID JOIN
               COMPANY D ON A.COMPANY_SEQ = D .COMPANY_SEQ
WHERE  1 = 1 AND B.DELIVERY_METHOD = '1' AND A.STATUS_SEQ = 15 


--SELECT  A.ORDER_SEQ AS ORDER_SEQ, A.SALES_GUBUN, A.COMPANY_SEQ, D .COMPANY_NAME, '' AS ORDER_TYPE, 
--               'CUSTOM_ORDER' AS ORDER_TABLE_NAME, C.ISHJ, A.STATUS_SEQ, ISNULL(D .ERP_PARTCODE, '') 
--               AS ERP_PARTCODE, C.DELIVERY_CODE_NUM AS DELIVERY_CODE, B.ZIP AS RECV_ZIP, 
--               B.ADDR AS RECV_ADDR, B.ADDR_DETAIL AS RECV_ADDR_DETAIL, B.NAME AS RECV_NAME, 
--               B.PHONE AS RECV_PHONE, B.HPHONE AS RECV_HPHONE, '' AS RECV_MSG, 
--               A.SRC_SEND_DATE AS SEND_DATE, ISNULL(B.DELIVERY_MEMO, '') AS DELIVERY_MSG, 
--               DELIVERY_SEQ AS DELIVERY_SEQ
--FROM     CUSTOM_ORDER A JOIN
--               DELIVERY_INFO B ON A.ORDER_SEQ = B.ORDER_SEQ JOIN
--               DELIVERY_INFO_DELCODE C ON B.ID = C.DELIVERY_ID JOIN
--               COMPANY D ON A.COMPANY_SEQ = D .COMPANY_SEQ
--WHERE  1 = 1 AND B.DELIVERY_METHOD = '1' AND A.STATUS_SEQ = 15 

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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_DELIVERY_MST'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_DELIVERY_MST'
GO
