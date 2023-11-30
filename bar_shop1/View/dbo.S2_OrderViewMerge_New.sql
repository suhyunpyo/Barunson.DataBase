IF OBJECT_ID (N'dbo.S2_OrderViewMerge_New', N'V') IS NOT NULL DROP View dbo.S2_OrderViewMerge_New
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[S2_OrderViewMerge_New]
AS
    SELECT
              A.sales_gubun
            , A.order_seq
            , A.procLevel
            , A.src_confirm_date
            , A.order_type
            , A.order_name
            , A.pay_type
            , A.printW_status
            , A.order_count
            , A.isColorPrint
            , A.isColorInpaper
            , A.isEmbo
            , A.isCorel
            , A.card_seq
            , B.card_div
            , A.unicef_price
            , A.print_type
            , CASE
                    WHEN B.new_code = B.card_code THEN card_code
                    WHEN B.new_code <> B.card_code THEN new_code
              END AS card_code
            , ISNULL(B.env_code , '') AS env_code
            , ISNULL(B.cont_code , '') AS inpaper_code
            , ISNULL((SELECT TOP 1 isLaser FROM S2_CardOption WHERE card_seq = B.card_seq), 0) AS isLaserCut
            , '' AS GroupCodeSet
            , '' AS GroupName
            , '' AS GroupType
    FROM custom_order AS A
        INNER JOIN card AS B
            ON A.card_seq = B.card_seq
    WHERE A.status_Seq = 10 
        AND A.src_closecopy_date IS NOT NULL
    
    UNION ALL
    
    SELECT
              A.sales_gubun
            , A.order_seq
            , A.procLevel
            , A.src_confirm_date
            , A.order_type
            , A.order_name
            , A.pay_type
            , A.printW_status
            , A.order_count
            , A.isColorPrint
            , A.isColorInpaper
            , A.isEmbo
            , A.isCorel
            , A.card_seq
            , B.card_div
            , A.unicef_price
            , A.print_type
            , CASE
                    WHEN B.new_code = B.card_code THEN card_code
                    WHEN B.new_code <> B.card_code THEN new_code
              END AS card_code

			, ISNULL(( SELECT E.Card_Code FROM S2_Card E WHERE E.Card_Seq = C.Env_Seq ), '') AS Env_Code
			, ISNULL(( SELECT I.Card_Code FROM S2_Card I WHERE I.Card_Seq = C.Inpaper_Seq ), '') AS inpaper_code

			--, ISNULL(B.t_env_code , '') AS env_code
            --, ISNULL(B.t_inpaper_code , '') AS inpaper_code


            , ISNULL((SELECT TOP 1 isLaser FROM S2_CardOption WHERE card_seq = B.card_seq), 0) AS isLaserCut
            , '' AS GroupCodeSet
            , '' AS GroupName
            , '' AS GroupType
    FROM custom_order AS A
    INNER JOIN S2_Card AS B ON A.card_seq = B.card_seq
    LEFT JOIN S2_CardDetail AS C ON B.card_seq = C.card_seq

	WHERE A.status_Seq = 10
        AND A.src_closecopy_date IS NOT NULL;
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'S2_OrderViewMerge_New'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'S2_OrderViewMerge_New'
GO
