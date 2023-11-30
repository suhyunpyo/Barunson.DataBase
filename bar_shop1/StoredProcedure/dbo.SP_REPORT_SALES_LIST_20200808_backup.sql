IF OBJECT_ID (N'dbo.SP_REPORT_SALES_LIST_20200808_backup', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_REPORT_SALES_LIST_20200808_backup
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
 EXEC SP_REPORT_SALES_LIST    'AGGREGATE'  , ' SA ,  SB , ST , SS , B ,C , H , U , D , Q , P , SG , X , XB , G , SD , '  , ''  ,  1 , '2020-07-01'  , '2020-07-03'  ,  0 ,  0 ,  0 ,  -1 ,  0 ,  0 , ''  , 'N'  , 'N'  , '' 
 EXEC SP_REPORT_SALES_LIST    'LIST_EXCEL'  , ' SA ,  SB , ST , SS , B ,C , H , U , D , Q , P , SG , X , XB , G , SD , '  , ''  ,  1 , '2020-07-01'  , '2020-07-03'  ,  0 ,  0 ,  0 ,  -1 ,  0 ,  0 , ''  , 'N'  , 'N'  , '' 



    EXEC SP_Report_Sales_List 'Aggregate'       , 'SB', '', 0, '2018-01-01', '2018-03-31', 2, 0, 0, -1, 0, 0, '', 'N', 'N', ''

	EXEC SP_Report_Sales_List 'List_Excel'      , 'SB', '', 0, '2018-01-01', '2018-03-31', 2, 0, 0, -1, 0, 0, '', 'N', 'N', ''
	
	EXEC SP_Report_Sales_List 'List_Excel'      , ' SA, C , SB , ST , SS , B , H , U , D , Q , P , SG , X , XB , G '  , ''  ,  0 , '2017-10-01'  , '2017-10-19'  ,  0 ,  0 ,  0 ,  -1 ,  0 ,  0 , ''  , 'N'  , 'N'  , '' 

    EXEC SP_Report_Sales_List 'Aggregate_Excel' , ' SA, C , SB , ST , SS , B , H , U , D , Q , P , SG , X , XB , G '  , ''  ,  0 , '2017-10-01'  , '2017-10-19'  ,  0 ,  0 ,  0 ,  -1 ,  0 ,  0 , ''  , 'N'  , 'N'  , '' 
    
    EXEC SP_Report_Sales_List 'List_Excel'      , ' SA , C , SB , ST , SS , B , H , U , D , Q , P , SG , X , XB , G , '  , ''  ,  0 , '2018-03-05'  , '2018-03-05'  ,  4 ,  0 ,  0 ,  -1 ,  0 ,  0 , 'bh2104'  , 'N'  , 'N'  , '' 
*/
CREATE PROCEDURE [dbo].[SP_REPORT_SALES_LIST_20200808_backup]
	@P_List_Type			AS VARCHAR(50)
,	@P_Sales_Gubun_List		AS VARCHAR(100)
,	@P_ERP_Part_Code		AS VARCHAR(50)
,	@P_Search_Date_Type		AS INT
,	@P_Search_Start_Date	AS VARCHAR(10)
,	@P_Search_End_Date		AS VARCHAR(10)
,	@P_Order_Trouble_Type	AS INT
,	@P_Order_Type			AS INT
,	@P_Brand				AS INT
,	@P_Printer				AS INT
,	@P_MIN_Price			AS INT
,	@P_MAX_Price			AS INT
,	@P_Card_Code			AS VARCHAR(100)
,	@P_Jaebon_YorN			AS VARCHAR(1)
,	@P_Address_View_YorN	AS VARCHAR(1)
,	@P_Inflow_Route_Type	AS VARCHAR(50)

AS

BEGIN

	SET NOCOUNT ON;

	/* @P_List_Type [Aggregate, Aggregate_Excel, List, List_Excel] */
	/* Aggregate : 집계 요약 출력 */
	/* Aggregate_Excel : 집계 요약 엑셀 출력 */
	/* List : 리스트 출력 */
	/* List_Excel : 리스트 엑셀 출력 */


/*
--쿠폰정보
SELECT DISTINCT CM.Coupon_Type_Code 
	, COC.Order_Seq
    , CD.Coupon_Code AS Coupon_Code
	, COC.COUPON_AMT AS COUPON_AMT
	, CM.COUPON_NAME AS COUPON_NAME	
INTO #Custom_Order_Coupon
FROM Custom_Order_Coupon AS COC
INNER JOIN    Coupon_Issue AS CI ON COC.Coupon_Issue_Seq = CI.Coupon_Issue_Seq
INNER JOIN    Coupon_Detail AS CD ON CI.Coupon_Detail_Seq = CD.Coupon_Detail_Seq
INNER JOIN    Coupon_MST AS CM ON CD.Coupon_MST_Seq = CM.Coupon_MST_Seq

*/



    /* 기초 데이터 수집 */
	SELECT	
			CO.Company_Seq
		,	C.ERP_PartCode
		,	C.Company_Name
		,	CO.Sales_Gubun
		,	CO.Up_Order_Seq
		,	CO.Order_Seq
		,	CO.Order_Date
		,	CO.Order_Add_Type
		,	CO.Src_Compose_Date
		,	CO.Src_Compose_Mod_Date
		,	CO.Settle_Date
		,	CO.Src_Print_Date
		,	CO.Src_Send_Date
		,	CO.Settle_Cancel_Date
		,	CO.Src_Printer_Seq
		,	CO.Status_Seq
		,	CO.Order_Name
		,	CO.Order_Phone + '/' + CO.Order_Hphone AS Order_Phone
		,	CO.Order_Email
		,	CO.Order_Type
		,	CO.DisCount_Rate
		,	SCV.Brand
		,	SCV.Card_Seq
		,	SCV.Card_Code
		,	SCV.ERP_Code
		,	SCV.Old_Code
		,	SCV.Card_Price
		,   CO.unit_price
		--,	CO.Order_Count /* 주문수 이상으로 수정 2018-10-08 */
		,   ISNULL(COI2.item_count, 0) AS Order_Count
		,	CO.IsInpaper
		,	CO.IsHandmade
		,	CO.IsRibon
		,	CO.IsEnvInsert
		,	CO.IsEmbo
        ,   ROUND((ISNULL(SCV.Card_Price, 0) * ((100 - ISNULL(CO.Discount_Rate, 0)) / 100)) + 0.4, 0) AS Calc_Card_Price
        ,   ROUND((ISNULL(SCV.Card_Price, 0) * ((100 - ISNULL(CO.Discount_Rate, 0)) / 100)) + 0.4, 0) * ISNULL(CO.Order_Count, 0) AS Calc_Total_Card_Price
        
		,   ISNULL(Env_Option_Price         , 0) +
            ISNULL(CO.Jebon_Price			, 0) +
            ISNULL(CO.Option_Price			, 0) +
            ISNULL(CO.Mini_Price			, 0) +
            ISNULL(CO.FTicket_Price			, 0) +
            ISNULL(CO.Sticker_Price			, 0) +
            ISNULL(CO.Label_Price			, 0) +
            ISNULL(CO.Embo_Price			, 0) +
            ISNULL(CO.Print_Price			, 0) +
            ISNULL(CO.Cont_Price			, 0) +
            ISNULL(CO.EnvInsert_Price		, 0) +
            ISNULL(CO.ETC_Price				, 0) +
            ISNULL(CO.Delivery_Price		, 0) +
            ISNULL(CO.Env_Price				, 0) +
            ISNULL(CO.GuestBook_Price		, 0) +
            ISNULL(CO.Sasik_Price			, 0) +
            ISNULL(CO.Coop_Sale_Price		, 0) +
            ISNULL(CO.MoneyEnv_Price		, 0) +
			ISNULL(CO.EnvSpecial_Price		, 0) +
			ISNULL(CO.MemoryBook_Price		, 0) +
			ISNULL(CO.flower_price			, 0) +
			ISNULL(CO.sealing_sticker_price , 0) +
			ISNULL(CO.perfume_price			, 0) +
			ISNULL(CO.ribbon_price			, 0) +
			ISNULL(CO.paperCover_price		, 0) +
            ISNULL(CO.Laser_Price			, 0) AS Calc_Total_Option_Price
        
		,   (ROUND((ISNULL(SCV.Card_Price, 0) * ((100 - ISNULL(CO.Discount_Rate, 0)) / 100)) + 0.4, 0) * ISNULL(CO.Order_Count, 0)) +
            ISNULL(Env_Option_Price         , 0) +
            ISNULL(CO.Jebon_Price			, 0) +
            ISNULL(CO.Option_Price			, 0) +
            ISNULL(CO.Mini_Price			, 0) +
            ISNULL(CO.FTicket_Price			, 0) +
            ISNULL(CO.Sticker_Price			, 0) +
            ISNULL(CO.Label_Price			, 0) +
            ISNULL(CO.Embo_Price			, 0) +
            ISNULL(CO.Print_Price			, 0) +
            ISNULL(CO.Cont_Price			, 0) +
            ISNULL(CO.EnvInsert_Price		, 0) +
            ISNULL(CO.ETC_Price				, 0) +
            ISNULL(CO.Delivery_Price		, 0) +
            ISNULL(CO.Env_Price				, 0) +
            ISNULL(CO.GuestBook_Price		, 0) +
            ISNULL(CO.Sasik_Price			, 0) +
            ISNULL(CO.Coop_Sale_Price		, 0) +
            ISNULL(CO.MoneyEnv_Price		, 0) +
			ISNULL(CO.EnvSpecial_Price		, 0) +
            ISNULL(CO.Laser_Price			, 0) +
            ISNULL(CO.Reduce_Price			, 0) +
			ISNULL(CO.MemoryBook_Price		, 0) +
			ISNULL(CO.flower_price			, 0) +
			ISNULL(CO.sealing_sticker_price , 0) +
			ISNULL(CO.perfume_price			, 0) +
			ISNULL(CO.ribbon_price			, 0) +
			ISNULL(CO.paperCover_price		, 0) +
            ISNULL(CO.Addition_Reduce_Price	, 0) AS Calc_Settle_Price

		,	ISNULL(CO.Jebon_Price			, 0) AS Jebon_Price
		,	ISNULL(CO.Option_Price			, 0) AS Option_Price
		,	ISNULL(CO.Mini_Price			, 0) AS Mini_Price
		,	ISNULL(CO.FTicket_Price			, 0) AS FTicket_Price
		,	ISNULL(CO.Sticker_Price			, 0) AS Sticker_Price
		,	ISNULL(CO.Label_Price			, 0) AS Label_Price
		,	ISNULL(CO.Embo_Price			, 0) AS Embo_Price
		,	ISNULL(CO.Print_Price			, 0) AS Print_Price
		,	ISNULL(CO.Cont_Price			, 0) AS Cont_Price
		,	ISNULL(CO.EnvInsert_Price		, 0) AS EnvInsert_Price
		,	ISNULL(CO.ETC_Price				, 0) AS ETC_Price
		,	ISNULL(CO.Delivery_Price		, 0) AS Delivery_Price
		,	ISNULL(CO.Env_Price				, 0) AS Env_Price
		,	ISNULL(CO.GuestBook_Price		, 0) AS GuestBook_Price
		,	ISNULL(CO.Sasik_Price			, 0) AS Sasik_Price
		,	ISNULL(CO.Coop_Sale_Price		, 0) AS Coop_Sale_Price
		,	ISNULL(CO.MoneyEnv_Price		, 0) AS MoneyEnv_Price
		,	ISNULL(CO.EnvSpecial_Price		, 0) AS EnvSpecial_Price
		,	ISNULL(CO.Laser_Price			, 0) AS Laser_Price
        ,   ISNULL(Env_Option_Price         , 0) AS Env_Option_Price
		,	CASE WHEN ISNULL(Coupon_Default.COUPON_AMT, 0)+ISNULL(Coupon_Dup.COUPON_AMT, 0)+ISNULL(Coupon_AD.COUPON_AMT, 0)+ISNULL(Coupon_Add.COUPON_AMT, 0) = 0 THEN ISNULL(CO.Reduce_Price, 0) ELSE ISNULL(Coupon_Default.COUPON_AMT, 0)*-1 END AS Coupon_Price
		,	CASE WHEN ISNULL(Coupon_Default.COUPON_AMT, 0)+ISNULL(Coupon_Dup.COUPON_AMT, 0)+ISNULL(Coupon_AD.COUPON_AMT, 0)+ISNULL(Coupon_Add.COUPON_AMT, 0) = 0 THEN ISNULL(CO.Addition_Reduce_Price, 0) ELSE ISNULL(Coupon_Dup.COUPON_AMT, 0)*-1 END AS Addition_Coupon_Price
		,	CASE WHEN ISNULL(Coupon_Default.COUPON_AMT, 0)+ISNULL(Coupon_Dup.COUPON_AMT, 0)+ISNULL(Coupon_AD.COUPON_AMT, 0)+ISNULL(Coupon_Add.COUPON_AMT, 0) = 0 THEN 0 ELSE ISNULL(Coupon_AD.COUPON_AMT, 0)*-1 END AS AD_Coupon_Price
		,	CASE WHEN ISNULL(Coupon_Default.COUPON_AMT, 0)+ISNULL(Coupon_Dup.COUPON_AMT, 0)+ISNULL(Coupon_AD.COUPON_AMT, 0)+ISNULL(Coupon_Add.COUPON_AMT, 0) = 0 THEN 0 ELSE ISNULL(Coupon_Add.COUPON_AMT, 0)*-1 END AS ADD_Addition_Coupon_Price

		,	ISNULL(CO.Last_Total_Price		, 0) AS Last_Total_Price
		,	ISNULL(CO.Settle_Price			, 0) AS Settle_Price
		
		,	ISNULL(CO.MemoryBook_Price		, 0) AS MemoryBook_Price
		,	ISNULL(CO.flower_price			, 0) AS flower_price
		,	ISNULL(CO.sealing_sticker_price , 0) AS sealing_sticker_price
		,	ISNULL(CO.perfume_price			, 0) AS perfume_price
		,	ISNULL(CO.ribbon_price			, 0) AS ribbon_price
		,	ISNULL(CO.paperCover_price		, 0) AS paperCover_price	

	
		,	CO.Settle_Method
		--,	ISNULL(CO.CouponSeq             ,'') AS CouponSeq
		--,	ISNULL(CO.Addition_CouponSeq    ,'') AS Addition_CouponSeq
		,	CO.Order_ETC_Comment
		,	CO.IsVar
		,   CASE 
                WHEN CO.Member_ID IS NULL OR CO.Member_ID = '' THEN '비회원' 
                ELSE CO.Member_ID 
            END AS Member_ID 
		,   ISNULL(CO.Inflow_Route, 'PC') AS Inflow_Route_Order
		,   ISNULL(CO.Inflow_Route_Settle, 'PC') AS Inflow_Route_Settle
        
		,   dbo.FN_ORDER_COUPON_LIST(CO.ORDER_SEQ,'131001') AS CouponSeq

		,   dbo.FN_ORDER_COUPON_LIST(CO.ORDER_SEQ,'131002') AS Addition_CouponSeq

		,   dbo.FN_ORDER_COUPON_LIST(CO.ORDER_SEQ,'131003') AS Coupon_Ad

		,   dbo.FN_ORDER_COUPON_LIST(CO.ORDER_SEQ,'131004') AS Coupon_Add

		,	CASE 
                WHEN @P_Address_View_YorN = 'Y' THEN ISNULL(DI.ZIP, '') 
                ELSE '' 
            END AS ZIPCode
        ,   CASE 
                WHEN @P_Address_View_YorN = 'Y' THEN ISNULL(DI.Addr, '') 
                ELSE '' 
            END AS Addr
        ,   CASE 
                WHEN @P_Address_View_YorN = 'Y' THEN ISNULL(DI.Addr_Detail, '') 
                ELSE '' 
            END AS Addr_Detail
		, LEFT(OT.PrintMethod, 1) AS PrintMethod
		, OT.isLaser
		, convert(varchar(10), UI.reg_date, 120) as reg_date /* 20200714 김성동 본부장님 긴급 추가 요청 */
	INTO	#T
	FROM    Custom_Order AS CO
		INNER JOIN  S2_CardView AS SCV ON CO.Card_Seq = SCV.Card_Seq
	    INNER JOIN	Company AS C ON CO.Company_Seq = C.Company_Seq
		LEFT OUTER JOIN S2_UserInfo_BHands AS UI ON UI.uid = CO.member_id /* 20200714 김성동 본부장님 긴급 추가 요청 */
        
		LEFT JOIN Custom_Order_Item AS COI2 ON CO.Order_Seq = COI2.Order_Seq AND COI2.item_count > 0 AND COI2.item_type = 'C'
		LEFT OUTER JOIN
        (
            SELECT  
                    SUM
                    (
                        CASE    /* 고급 봉투 또는 추가 봉투 금액 */
                            WHEN ISNULL(Addnum_Price, 0) > ISNULL(Item_Sale_Price, 0) * ISNULL(Item_Count, 0) THEN ISNULL(Addnum_Price, 0) 
                            ELSE ISNULL(Item_Sale_Price, 0) * ISNULL(Item_Count, 0)
                        END
                    ) AS Env_Option_Price
                ,   Order_Seq
            FROM    Custom_Order_Item
            WHERE   Item_Type = 'E'
            GROUP BY 
                    Order_Seq
        ) AS COI 
            ON CO.Order_Seq = COI.Order_Seq
       
		LEFT JOIN VW_COUPONTYPE_ORDER_AMT AS Coupon_Default ON Coupon_Default.Coupon_Type_Code = '131001' AND  Coupon_Default.Order_Seq = CO.Order_Seq
		LEFT JOIN VW_COUPONTYPE_ORDER_AMT AS Coupon_Dup ON Coupon_Dup.Coupon_Type_Code = '131002' AND  Coupon_Dup.Order_Seq = CO.Order_Seq
		LEFT JOIN VW_COUPONTYPE_ORDER_AMT AS Coupon_AD ON Coupon_AD.Coupon_Type_Code = '131003' AND  Coupon_AD.Order_Seq = CO.Order_Seq
		LEFT JOIN VW_COUPONTYPE_ORDER_AMT AS Coupon_Add ON Coupon_Add.Coupon_Type_Code = '131004' AND  Coupon_Add.Order_Seq = CO.Order_Seq
		    
		/* 주소 출력 여부 */
		LEFT JOIN Delivery_Info AS DI ON CO.Order_Seq = DI.Order_Seq			
				AND (
						(@P_Address_View_YorN = 'Y' AND DI.Delivery_Seq >= 1) OR (@P_Address_View_YorN = 'N' AND DI.Delivery_Seq = 1)
					)
		LEFT JOIN S2_CardOption OT ON CO.card_seq = OT.Card_Seq
	WHERE	1 = 1
        AND  CO.Company_Seq = C.Company_Seq

	    /* 사이트 */
	    AND		CO.Sales_Gubun IN ( SELECT VALUE FROM FN_SPLIT(REPLACE(@P_Sales_Gubun_List, ' ', ''), ',') )

	    /* 부서코드 */
	    AND		(C.ERP_PartCode = @P_ERP_Part_Code OR @P_ERP_Part_Code = '')

	    /* 날짜 검색 */
	    /* 0 : 주문일, 1 : 배송일, 2 : 결제일, 3 : 인쇄일 */
	    AND		(
				    (
						    @P_Search_Date_Type = 0 
					    AND CO.Status_Seq IN (1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
					    AND CO.Order_Date >= @P_Search_Start_Date + ' 00:00:00' 
					    AND CO.Order_Date < DATEADD(DAY, 1, @P_Search_End_Date)
				    )
				    OR
				    (		
						    @P_Search_Date_Type = 1
					    AND CO.Status_Seq = 15
					    AND CO.SRC_Send_Date >= @P_Search_Start_Date + ' 00:00:00' 
					    AND CO.SRC_Send_Date < DATEADD(DAY, 1, @P_Search_End_Date)
				    )
				    OR
				    (		
						    @P_Search_Date_Type = 2 
					    AND CO.Status_Seq >= 9
					    AND CO.Settle_Date >= @P_Search_Start_Date + ' 00:00:00' 
					    AND CO.Settle_Date < DATEADD(DAY, 1, @P_Search_End_Date)
				    )
				    OR
				    (		
						    @P_Search_Date_Type = 3
					    AND CO.Status_Seq >= 11
					    AND CO.SRC_Print_Date >= @P_Search_Start_Date + ' 00:00:00' 
					    AND CO.SRC_Print_Date < DATEADD(DAY, 1, @P_Search_End_Date)
				    )
			    )

	    /* 주문 종류 [전체, 정상주문(추가주문 포함), 원주문, 사고건, 추가주문] */
	    /* 0 : 전체, 1 : 정상주문(추가주문 포함), 2 : 원주문, 3 : 사고건, 4 : 추가주문 */
	    AND		(
				    (@P_Order_Trouble_Type = 0)
				    OR	(@P_Order_Trouble_Type = 1 AND CO.Pay_Type <> '4')
				    OR	(@P_Order_Trouble_Type = 2 AND CO.Pay_Type <> '4' AND CO.Up_Order_Seq IS NULL)
				    OR	(@P_Order_Trouble_Type = 3 AND CO.Pay_Type = '4')
				    OR	(@P_Order_Trouble_Type = 4 AND CO.Pay_Type <> '4' AND CO.Up_Order_Seq IS NOT NULL)
			    )

	    /* 주문 타입 [전체, 청첩장, 감사장, 시즌] */
	    /* 0 : 전체, 1 : 청첩장(초대장), 2 : 감사장, 3 : 시즌 */
	    AND		(
					    (@P_Order_Type = 0)
				    OR	(@P_Order_Type = 1 AND CO.Order_Type NOT IN ('2', '4'))
				    OR	(@P_Order_Type = 2 AND CO.Order_Type  = '2')
				    OR	(@P_Order_Type = 3 AND CO.Order_Type  = '4')
			    )
    
	    /* 브랜드 */
	    AND		(SCV.Brand = @P_Brand OR @P_Brand = 0)

	    /* 가격 */
	    AND		(@P_MIN_Price = 0 OR (@P_MIN_Price <> 0 AND SCV.Card_Price >= @P_MIN_Price AND SCV.Card_Price < @P_MAX_Price))

	    /* 인쇄소 */
	    /* 0 : 내부, 1 : 경림, 2 : 용진, 3 : 기타인쇄, 4 : 직매장, 5 : 대리점, 6 : 학술 */
	    AND		(CO.SRC_Printer_Seq = @P_Printer OR @P_Printer = -1)

	    /* 카드코드 */
	    AND		(@P_Card_Code = '' OR SCV.Card_Code LIKE '%' + @P_Card_Code + '%')

	    /* 제본 여부 */
	    AND		(
					    @P_Jaebon_YorN = 'N' 
				    OR	(@P_Jaebon_YorN = 'Y' AND (CO.IsInpaper = '1' OR CO.IsHandmade = '1' OR CO.IsRibon = '1' OR CO.IsEnvInsert = '1'))
			    )

	    /* 유입 경로 */
	    /* 날짜 타입이 주문일, 결제일 일때만 적용  */
	    AND		(
					    (@P_Inflow_Route_Type = '' OR @P_Search_Date_Type IN (1, 3))
				    OR	(@P_Search_Date_Type = 0 AND ISNULL(CO.Inflow_Route, 'PC') = @P_Inflow_Route_Type)
				    OR	(@P_Search_Date_Type = 2 AND ISNULL(CO.Inflow_Route, 'PC') = @P_Inflow_Route_Type)
			    )

        /* 주소 출력 여부 */
		/*
        AND     (
                        (@P_Address_View_YorN = 'Y' AND DI.Delivery_Seq >= 1)
                    OR
                        (@P_Address_View_YorN = 'N' AND DI.Delivery_Seq = 1)
                )
	*/







    /* 집계 요약 데이터 생성 */
	IF @P_List_Type = 'Aggregate'
		BEGIN

			/* 집계 요약 [주문건수, 주문금액, 결제금액, 카드수량] */	
			SELECT	
                        ISNULL(COUNT(Order_Seq), 0) AS Order_CNT
				    ,	ISNULL(SUM(CASE WHEN Order_Count > 0 THEN 1 ELSE 0 END), 0) AS Order_Card_Only_CNT
				    ,	ISNULL(SUM(CAST(ISNULL(Last_Total_Price, 0) AS BIGINT)), 0) AS Total_Price
				    ,	ISNULL(SUM(CAST(ISNULL(Settle_Price ,0) AS BIGINT)), 0) AS Settle_Price 
			FROM	#T AS T


			/* 브랜드별 주문 및 카드 수량 */
            SELECT
                    A.*
            FROM
            (
			    SELECT	
                        1 AS Sort
                    ,   (SELECT code_value FROM manage_code WHERE code_type = 'cardbrand' AND etc1 = SCV.Brand) AS Title
				    ,	COUNT(T.Order_Seq) AS ORD_CNT
				    ,	SUM(COI.Item_Count) AS Card_CNT
					--,   SUM(T.Order_Count) AS Card_CNT
				    ,	'C' AS Item_Type
			    FROM	#T AS T
			        INNER JOIN  Custom_Order_Item AS COI 
                        ON T.Order_Seq = COI.Order_Seq
			        INNER JOIN	S2_CardView AS SCV 
                        ON COI.Card_Seq = SCV.Card_Seq
			    WHERE	1 = 1
			        AND		COI.Item_Type = 'C'
			        AND		COI.Item_Count > 0
			    GROUP BY 
                        SCV.Brand 
				
			    UNION ALL 

			    SELECT
                        2 AS Sort
				    ,	CASE 
						    WHEN COI.Item_Type = 'E'	THEN '봉투'
						    WHEN COI.Item_Type = 'I'	THEN '내지'
						    WHEN COI.Item_Type = 'F'	THEN '식권'
						    WHEN COI.Item_Type = 'M'	THEN '미니청첩장'
						    WHEN COI.Item_Type = 'L'	THEN '스크랩북'
						    ELSE ''
					    END AS Title
				    ,	COUNT(T.Order_Seq) AS ORD_CNT
					--,   SUM(T.Order_Count) AS Card_CNT
				    ,	SUM(COI.Item_Count) AS Card_CNT
				    ,	COI.Item_Type
			    FROM	#T AS T
			        INNER JOIN	Custom_Order_Item AS COI 
                        ON T.Order_Seq = COI.Order_Seq
			        INNER JOIN	S2_CardView AS SCV 
                        ON COI.Card_Seq = SCV.Card_Seq
			    WHERE	1 = 1
			        AND		COI.Item_Type IN ('E', 'I', 'F', 'M' ,'L') 
			        AND	    COI.Item_Count > 0
			    GROUP BY 
                        COI.Item_Type 
            ) AS A 
			ORDER BY 
                    A.Sort ASC
                ,   A.Card_CNT DESC

			
            /* 브랜드별 카드별 주문 및 카드 수량 */
			SELECT
                	SCV.Brand
				,	SCV.Card_Code
				,	Count(T.Order_Seq) AS ORD_CNT
				,	SUM(COI.Item_Count) AS Card_CNT
			FROM	#T AS T
			    INNER JOIN	Custom_Order_Item AS COI 
                    ON T.Order_Seq = COI.Order_Seq
			    INNER JOIN	S2_CardView AS SCV 
                    ON COI.Card_Seq = SCV.Card_Seq
			WHERE	1 = 1
			    AND		COI.Item_Type = 'C'
			    AND		COI.Item_Count > 0
			GROUP BY 
                    SCV.Card_Code
                ,   SCV.Brand 
			ORDER BY
                    Card_CNT DESC

		END

	
    /* 집계 요약 엑셀 출력 */
	ELSE IF @P_List_Type = 'Aggregate_Excel'
		BEGIN
			
			SELECT	
                    *
			FROM	#T AS T

		END

	
    /* 리스트 출력 */
	ELSE IF @P_List_Type = 'List'
		BEGIN
			
			SELECT	
                    *
				,	ISNULL(EII.ERP_ItemStatus, '') AS ERP_ItemStatus
				, (SELECT IP FROM S4_LoginIpInfo WHERE seq = (SELECT MIN(seq) FROM S4_LoginIpInfo WHERE uid = T.Member_ID AND IP is not null)) AS IP
			FROM	#T AS T
			    LEFT OUTER JOIN [ERPDB.BhandsCard.Com].XERP.dbo.C_ERPItemInfo AS EII 
                    ON T.ERP_Code = EII.ERP_ItemCode

		END

	/* 리스트 엑셀 출력 */
	ELSE IF @P_List_Type = 'List_Excel'
		BEGIN

		
			--디얼디어 카드 표준가격이 0일경우 바른디자인ERP에서 소비자가격 업데이트. 강은지요청 20200422
			UPDATE #T
			SET card_price = ISNULL(P.C_sobi, 0)
			FROM #T A
			JOIN [ERPDB.BhandsCard.Com].BHC.dbo.ItemSiteMaster AS P ON P.SiteCode = 'BHC2' AND A.ERP_Code = P.ItemCode
			WHERE ISNULL(A.card_price, 0) = 0 AND A.sales_Gubun = 'SD'


				SELECT  CSO.Member_ID,   MAX(CSO.Request_Date) AS Request_Date
					,	STUFF
					(
						(
							SELECT	
									'|' + 
									CASE 
										WHEN ISNULL(CSO_SUB.JOIN_Division, 'WEB') = 'Mobile' THEN 'Mobile' 
										WHEN ISNULL(CSO_SUB.JOIN_Division, 'WEB') = 'Web' THEN 'PC' 
										ELSE ' ' 
									END 
							FROM	Custom_Sample_Order AS CSO_SUB
							WHERE	1 = 1
								AND		CSO_SUB.Status_Seq = 12
								AND		CSO_SUB.Member_ID IS NOT NULL
								AND		CSO_SUB.Member_ID <> ''
								AND		CSO_SUB.Member_ID = CSO.Member_ID
								AND		CSO_SUB.Request_Date >= MIN(CSO.Request_Date)
							FOR XML PATH('')
						) , 1, 1, ''
					) AS Inflow_Route_Sample
				,	STUFF
					(
						(
							SELECT	
									'|' + 
									CSO_SUB.Sales_Gubun 
							FROM	Custom_Sample_Order AS CSO_SUB
							WHERE	1 = 1
								AND		CSO_SUB.Status_Seq = 12
								AND		CSO_SUB.Member_ID IS NOT NULL
								AND		CSO_SUB.Member_ID <> ''
								AND		CSO_SUB.Member_ID = CSO.Member_ID
								AND		CSO_SUB.Request_Date >= MIN(CSO.Request_Date)
							FOR XML PATH('')
						) , 1, 1, ''
					) AS Sample_Sales_Gubun
			INTO #Custom_Sample_Order
			FROM	Custom_Sample_Order AS CSO
			JOIN	#T AS T_SUB ON CSO.Member_ID = T_SUB.Member_ID
			WHERE	1 = 1
				AND		CSO.Status_Seq = 12
				AND		ISNULL(LTRIM(RTRIM(CSO.Member_ID)), '') <> ''						
				AND		CSO.Request_Date >= DATEADD(YEAR, -1, T_SUB.Order_Date)
			GROUP BY CSO.Member_ID



			
			SELECT	DISTINCT
					T.*
				,	ISNULL(VUI.Member_Age, '') AS Member_Age
				,	COW.Wedd_Date
				,	COW.Wedd_Name
				
				, CASE 
						WHEN LTRIM(ISNULL(COW.Wedd_Addr, '')) <> '' THEN LTRIM(RTRIM(COW.Wedd_Addr)) 
						ELSE LTRIM(RTRIM(ISNULL(COW.wedd_road_Addr, ''))) 
					END  AS Wedd_Addr  --, COW.Wedd_Addr
				,	VUI.Referer_Sales_Gubun
                ,   CASE
                        WHEN VUI.Inflow_Route IN ('web', 'PC') THEN 'PC' 
                        WHEN VUI.Inflow_Route = 'Mobile' THEN 'Mobile'
                        ELSE ''
                    END AS Inflow_Route_SignUp
				
				, CASE WHEN ISNULL(CSO.Member_ID, 'N') = 'N' THEN 'N' ELSE 'Y' END AS Sample_Order_YN
				, CASE WHEN ISNULL(SB.Member_ID, 'N') = 'N' THEN 'N' ELSE 'Y' END AS SampleBook_Order_YN				
			
				,	CSO.Request_Date AS Sample_Request_Date
				,	CSO.Sample_Sales_Gubun
				,	CSO.Inflow_Route_Sample
                ,   SB.Inflow_Route_SampleBook
				,	CASE 
                        WHEN MI.CompletedTime IS NOT NULL THEN 'Y' 
                        ELSE 'N' 
                    END AS New_Mobile_Invitaion_YN
				,	CASE 
                        WHEN MI.CompletedTime IS NOT NULL THEN MI.CompletedTime 
                        ELSE NULL 
                    END AS New_Mobile_Invitaion_Date
                ,   (CASE WHEN MS.UID IS NOT NULL AND MA.UID IS NULL THEN 'O' ELSE 'X' END) AS Sign_Marketing_Agree
                ,   (CASE WHEN MS.UID IS NOT NULL AND MA.UID IS NOT NULL THEN 'O' ELSE 'X' END) AS Order_Marketing_Agree
				,	ISNULL(EII.ERP_ItemStatus, '') AS ERP_ItemStatus
					-- sql 수정
				,   STUFF(( SELECT '|' + SCKI.CardKind FROM S2_CardKindInfo SCKI WHERE SCKI.CardKind_Seq IN ( SELECT ISNULL(SCKIND.CardKind_Seq,0) FROM S2_CardKind SCKIND WHERE SCKIND.Card_Seq = SCV.Card_Seq) FOR XML PATH('')),1,1,'')  AS Card_Kind
				,   (SELECT IP FROM S4_LoginIpInfo WHERE seq = (SELECT MIN(seq) FROM S4_LoginIpInfo WHERE uid = T.Member_ID AND IP is not null)) AS IP
				, ISNULL(T.ZIPCode, '') AS ZIPCode
				, ISNULL(T.addr, '') AS addr
				, ISNULL(T.Addr_Detail, '') AS Addr_Detail
				, CASE WHEN T.PrintMethod <> '0' THEN 'Y' ELSE 'X' END AS PrintMethod
				, CASE WHEN  T.isLaser <> '0' THEN 'Y' ELSE 'X' END AS isLaser
				--, '' AS Card_Kind
			FROM	#T AS T
		        LEFT OUTER JOIN
			    ( 
					SELECT
                            MAX
                            (
                                CASE 
                                    WHEN ISDATE(Birth_Date) = 1 THEN DATEDIFF(YEAR, Birth_Date, GETDATE()) 
                                    ELSE '' 
                                END
                            ) AS Member_Age
						,	UID
						,	ISNULL(Referer_Sales_Gubun, 'SB') AS Referer_Sales_Gubun
                        ,   MAX(inflow_route) AS inflow_route
                    FROM	vw_User_Info
                    WHERE	Umail <> '@'
                    GROUP BY 
                            UID
                        ,   Referer_Sales_Gubun
                ) AS VUI 
                    ON T.Member_ID = VUI.UID
                LEFT OUTER JOIN Custom_Order_WeddInfo AS COW ON T.Order_Seq = COW.Order_Seq
                LEFT OUTER JOIN	#Custom_Sample_Order AS CSO ON CSO.Member_ID = T.Member_ID

                INNER JOIN	S2_CardView AS SCV ON T.Card_Seq = SCV.Card_Seq
                
				LEFT OUTER JOIN
			    (
					SELECT	
                            OrderSeq
						,	MAX(SiteCode) AS SiteCode
						,	MAX(CompletedTime) AS CompletedTime
					FROM	MCard_Invitation
					WHERE	DeleteYN = 'N'  OR  (DeleteYN = 'Y' AND ExpireYN = 'Y')
					GROUP BY OrderSeq
				) AS MI 
                    ON T.Order_Seq = MI.OrderSeq 
                    AND T.Sales_Gubun = MI.SiteCode
                LEFT OUTER JOIN ( SELECT uid FROM S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT GROUP BY uid ) AS MS ON T.Member_ID = MS.UID
                LEFT OUTER JOIN ( SELECT uid FROM EVENT_MARKETING_AGREEMENT GROUP BY uid ) AS MA ON T.Member_ID = MA.UID
			    LEFT OUTER JOIN [ERPDB.BhandsCard.Com].XERP.dbo.C_ERPItemInfo AS EII ON T.ERP_Code = EII.ERP_ItemCode
                LEFT OUTER JOIN
                (
                    SELECT member_id
                        , CASE WHEN pg_shopid in ( 'bhands_c', 'pbhands') THEN 'PC' WHEN pg_shopid IN ('bhands_cm', 'pbhands_m') THEN 'Mobile' ELSE '' END AS Inflow_Route_SampleBook
                    FROM custom_etc_order
                    WHERE order_type = 'U' AND status_seq > 0
                    GROUP BY member_id, pg_shopid
                ) AS SB
                    ON T.Member_ID = SB.member_id
			ORDER BY 
                    T.Order_Date DESC
		END

END
GO
