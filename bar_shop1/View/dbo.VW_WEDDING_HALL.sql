IF OBJECT_ID (N'dbo.VW_WEDDING_HALL', N'V') IS NOT NULL DROP View dbo.VW_WEDDING_HALL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_WEDDING_HALL]
AS
SELECT
   WH.wedd_idx AS wid,
   WH.wedd_idx,
   WH.Wdiv,
   WH.location,
   WH.Wcnt,
   WH.Wname,
   WH.Waddress,
   WH.WRoadNameAddress,
   WH.Wphone,
   WH.corelFolder,
   WH.flag,
   WH.iscorel,
   WH.reg_date,
   WH.isAutoupdate,
   WH.isIllur,
   WH.isIllur_update,
   WH.AREA,
   WH.POI,
   WH.admin_id,
   WH.mod_date,
   WH.map_admin_id,
   WH.ranking,
   WH.waddress_detail,
   WH.wedd_keyword,
   WH.update_id,
   WH.isAutoWeddInfo,
   WH.isUpdate,
   WH.poi_id,
   WH.poi_x,
   WH.poi_y,
   WH.poi_matching,
   WH.JOB_ID,
   ISNULL(WH_BALCK.CNT, 0) + ISNULL(WH_COLOR.CNT, 0) AS IMGID,
   ISNULL(WH_BALCK.CNT, 0) AS BLACK_CNT,
   ISNULL(WH_COLOR.CNT, 0) AS COLOR_CNT
FROM
   dbo.WeddingHall AS WH
   LEFT OUTER JOIN (
      SELECT
         Wedd_IDX,
         MAX(isColor) AS ISCOLOR,
         COUNT(*) AS CNT
      FROM
         dbo.WeddingHall_Image
      WHERE
         (isCorel = '1')
         AND (isColor = '1')
      GROUP BY
         Wedd_IDX
   ) AS WH_COLOR ON WH.wedd_idx = WH_COLOR.Wedd_IDX
   LEFT OUTER JOIN (
      SELECT
         Wedd_IDX,
         MAX(isColor) AS ISBLACK,
         COUNT(*) AS CNT
      FROM
         dbo.WeddingHall_Image AS WeddingHall_Image_1
      WHERE
         (isCorel = '1')
         AND (isColor = '0')
      GROUP BY
         Wedd_IDX
   ) AS WH_BALCK ON WH.wedd_idx = WH_BALCK.Wedd_IDX
WHERE
   WH.isUse = '1'
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
         Begin Table = "WH"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 239
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "WH_COLOR"
            Begin Extent = 
               Top = 6
               Left = 277
               Bottom = 118
               Right = 423
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "WH_BALCK"
            Begin Extent = 
               Top = 6
               Left = 461
               Bottom = 118
               Right = 607
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_WEDDING_HALL'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'VW_WEDDING_HALL'
GO
