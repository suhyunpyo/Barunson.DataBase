IF OBJECT_ID (N'dbo.S2_OrderViewMerge_For_ChasuGroupSet', N'V') IS NOT NULL DROP View dbo.S2_OrderViewMerge_For_ChasuGroupSet
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[S2_OrderViewMerge_For_ChasuGroupSet]
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
              END AS Card_Code
			
			, ISNULL(( SELECT E.Card_Code FROM S2_Card E WHERE E.Card_Seq = F.Env_Seq ), '') AS Env_Code
			, ISNULL(( SELECT I.Card_Code FROM S2_Card I WHERE I.Card_Seq = F.Inpaper_Seq ), '') AS inpaper_code

            --, ISNULL(B.t_env_code , '') AS Env_Code
            --, ISNULL(B.t_inpaper_code , '') AS inPaper_code
            
			, ISNULL((SELECT TOP 1 isLaser FROM S2_CardOption WHERE card_seq = B.card_seq), 0) AS isLaserCut
            , D.GroupCode + '-' + CONVERT(VARCHAR, D.GroupCodeSeq) AS GroupCodeSet
            , D.GroupName
            , D.GroupType
    FROM custom_order AS A
    INNER JOIN S2_Card AS B ON A.card_seq = B.card_seq
    INNER JOIN PrintChasuGroupDetail AS C ON B.Card_Code = C.CardCode
    INNER JOIN PrintChasuGroup AS D ON C.GroupCode = D.GroupCode AND C.GroupCodeSeq = D.GroupCodeSeq
    LEFT JOIN S2_CardDetail AS F ON B.card_seq = F.card_seq

	WHERE A.status_seq = 10
        AND A.src_closecopy_date IS NOT NULL;
GO
