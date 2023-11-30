IF OBJECT_ID (N'dbo.view_DeliveryLst', N'V') IS NOT NULL DROP View dbo.view_DeliveryLst
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_DeliveryLst]
AS

SELECT  'W' AS OTYPE, A.ORDER_SEQ, A.SALES_GUBUN, A.COMPANY_SEQ, D .COMPANY_NAME, 
		A.SRC_SEND_DATE AS DELIVERY_DATE, B.NAME AS RECV_NAME, B.ADDR + ' ' + ISNULL(B.ADDR_DETAIL, '') 
		AS RECV_ADDRESS, C.DELIVERY_COM, C.DELIVERY_CODE_NUM AS DELIVERY_CODE, 
		--D.ERP_PARTCODE, 
		ERP_PARTCODE = CASE WHEN D.ERP_PARTCODE IS NULL AND D.SALES_GUBUN = 'P'
								THEN 'P' 
							WHEN  D.ERP_PARTCODE IS NULL AND D.SALES_GUBUN = 'Q'
								THEN 'Q' 
						ELSE D.ERP_PARTCODE
						END,
		A.SRC_PACKING_DATE AS PACKING_DATE
FROM	CUSTOM_ORDER A INNER JOIN
		DELIVERY_INFO B ON A.ORDER_SEQ = B.ORDER_SEQ, DELIVERY_INFO_DELCODE C, COMPANY D
WHERE	B.ID = C.DELIVERY_ID AND A.COMPANY_SEQ = D .COMPANY_SEQ AND C.DELIVERY_COM IN ('HJ', 'CJ') AND 
        B.DELIVERY_METHOD = 1
UNION ALL

SELECT  'S' AS OTYPE, SAMPLE_ORDER_SEQ AS ORDER_SEQ, A.SALES_GUBUN, A.COMPANY_SEQ, B.COMPANY_NAME, 
               DELIVERY_DATE, MEMBER_NAME AS RECV_NAME, MEMBER_ADDRESS + ' ' + MEMBER_ADDRESS_DETAIL AS RECV_ADDRESS, 
               DELIVERY_COM, DELIVERY_CODE_NUM AS DELIVERY_CODE, 
			   --B.ERP_PARTCODE, 
			     ERP_PARTCODE = CASE WHEN B.ERP_PARTCODE IS NULL AND B.SALES_GUBUN = 'P'
									THEN 'P' 
								WHEN  B.ERP_PARTCODE IS NULL AND B.SALES_GUBUN = 'Q'
									THEN 'Q' 
								ELSE B.ERP_PARTCODE
								END,
			   PREPARE_DATE AS PACKING_DATE
FROM     CUSTOM_SAMPLE_ORDER A INNER JOIN
               COMPANY B ON A.COMPANY_SEQ = B.COMPANY_SEQ
WHERE  DELIVERY_COM IN ( 'HJ' , 'CJ' )

UNION ALL

SELECT  'E' AS OTYPE, ORDER_SEQ, A.SALES_GUBUN, A.COMPANY_SEQ, B.COMPANY_NAME, DELIVERY_DATE, RECV_NAME, 
               ISNULL(RECV_ADDRESS, '') + ' ' + ISNULL(RECV_ADDRESS_DETAIL, '') AS RECV_ADDRESS, DELIVERY_COM, DELIVERY_CODE, 
			   --B.ERP_PARTCODE, 
			    ERP_PARTCODE = CASE WHEN B.ERP_PARTCODE IS NULL AND B.SALES_GUBUN = 'P'
									THEN 'P' 
								WHEN  B.ERP_PARTCODE IS NULL AND B.SALES_GUBUN = 'Q'
									THEN 'Q' 
								ELSE B.ERP_PARTCODE
								END,

               PREPARE_DATE AS PACKING_DATE
FROM     CUSTOM_ETC_ORDER A INNER JOIN
               COMPANY B ON A.COMPANY_SEQ = B.COMPANY_SEQ
WHERE  DELIVERY_COM IN ( 'HJ' , 'CJ' )



--SELECT  'W' AS OTYPE, A.ORDER_SEQ, A.SALES_GUBUN, A.COMPANY_SEQ, D .COMPANY_NAME, 
--               A.SRC_SEND_DATE AS DELIVERY_DATE, B.NAME AS RECV_NAME, B.ADDR + ' ' + ISNULL(B.ADDR_DETAIL, '') 
--               AS RECV_ADDRESS, C.DELIVERY_COM, C.DELIVERY_CODE_NUM AS DELIVERY_CODE, D .ERP_PARTCODE, 
--               A.SRC_PACKING_DATE AS PACKING_DATE
--FROM     CUSTOM_ORDER A INNER JOIN
--               DELIVERY_INFO B ON A.ORDER_SEQ = B.ORDER_SEQ, DELIVERY_INFO_DELCODE C, COMPANY D
--WHERE  B.ID = C.DELIVERY_ID AND A.COMPANY_SEQ = D .COMPANY_SEQ AND C.DELIVERY_COM IN ( 'HJ' , 'CJ' ) AND 
--               B.DELIVERY_METHOD = 1
--UNION ALL

--SELECT  'S' AS OTYPE, SAMPLE_ORDER_SEQ AS ORDER_SEQ, A.SALES_GUBUN, A.COMPANY_SEQ, B.COMPANY_NAME, 
--               DELIVERY_DATE, MEMBER_NAME AS RECV_NAME, MEMBER_ADDRESS + ' ' + MEMBER_ADDRESS_DETAIL AS RECV_ADDRESS, 
--               DELIVERY_COM, DELIVERY_CODE_NUM AS DELIVERY_CODE, B.ERP_PARTCODE, PREPARE_DATE AS PACKING_DATE
--FROM     CUSTOM_SAMPLE_ORDER A INNER JOIN
--               COMPANY B ON A.COMPANY_SEQ = B.COMPANY_SEQ
--WHERE  DELIVERY_COM IN ( 'HJ' , 'CJ' )

--UNION ALL

--SELECT  'E' AS OTYPE, ORDER_SEQ, A.SALES_GUBUN, A.COMPANY_SEQ, B.COMPANY_NAME, DELIVERY_DATE, RECV_NAME, 
--               ISNULL(RECV_ADDRESS, '') + ' ' + ISNULL(RECV_ADDRESS_DETAIL, '') AS RECV_ADDRESS, DELIVERY_COM, DELIVERY_CODE, B.ERP_PARTCODE, 
--               PREPARE_DATE AS PACKING_DATE
--FROM     CUSTOM_ETC_ORDER A INNER JOIN
--               COMPANY B ON A.COMPANY_SEQ = B.COMPANY_SEQ
--WHERE  DELIVERY_COM IN ( 'HJ' , 'CJ' )

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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_DeliveryLst'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'view_DeliveryLst'
GO
