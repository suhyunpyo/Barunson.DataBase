IF OBJECT_ID (N'dbo.S2_OrderViewMerge_New_Admin', N'V') IS NOT NULL DROP View dbo.S2_OrderViewMerge_New_Admin
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[S2_OrderViewMerge_New_Admin]
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
    WHERE A.status_Seq >= 10 AND A.status_seq < 15
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
            , ISNULL(B.t_env_code , '') AS env_code
            , ISNULL(B.t_inpaper_code , '') AS inpaper_code
            , ISNULL((SELECT TOP 1 isLaser FROM S2_CardOption WHERE card_seq = B.card_seq), 0) AS isLaserCut
            , '' AS GroupCodeSet
            , '' AS GroupName
            , '' AS GroupType
    FROM custom_order AS A
        INNER JOIN S2_Card AS B
            ON A.card_seq = B.card_seq
    WHERE A.status_Seq >= 10 AND A.status_seq < 15
        AND A.src_closecopy_date IS NOT NULL;
GO
