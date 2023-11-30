IF OBJECT_ID (N'dbo.SP_REPORT_SALES_LIST_WADMIN', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_REPORT_SALES_LIST_WADMIN
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

	통합어드민 매출리스트 조회 프로시저

    EXEC SP_Report_Sales_List        'List_Excel'      , ' SA , C , SB , ST , SS , B , H , U , D , Q , P , SG , X , XB , G , '  , ''  ,  0 , '2018-04-01'  , '2018-04-30'  ,  0 ,  0 ,  0 ,  -1 ,  0 ,  0 , ''  , 'N'  , 'N'  , '' 
    EXEC SP_Report_Sales_List_WADMIN 'List_Excel'      , ' SA , C , SB , ST , SS , B , H , U , D , Q , P , SG , X , XB , G , '  , ''  ,  0 , '2018-04-01'  , '2018-04-30'  ,  0 ,  0 ,  0 ,  -1 ,  0 ,  0 , ''  , 'N'  , 'N'  , '' 
*/

CREATE PROCEDURE [dbo].[SP_REPORT_SALES_LIST_WADMIN]
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
	/* List_Excel : 리스트 엑셀 출력, 20180516: 비회원 샘플주문내역 추가 */



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
		--,	CO.Order_Phone + '/' + CO.Order_Hphone AS Order_Phone -- jmkim
		,	CO.Order_Phone
		,   CO.Order_Hphone
		,	CO.Order_Email
		,	CO.Order_Type
		,	CO.DisCount_Rate
		,	SCV.Brand
		,	SCV.Card_Seq
		,	SCV.Card_Code
		,	SCV.ERP_Code
		,	SCV.Old_Code
		,	SCV.Card_Price
		,	CO.Order_Count
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
            ISNULL(CO.Laser_Price			, 0) +
            ISNULL(CO.Reduce_Price			, 0) +
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
		,	ISNULL(CO.Laser_Price			, 0) AS Laser_Price
        ,   ISNULL(Env_Option_Price         , 0) AS Env_Option_Price
        ,	ISNULL(CO.Addition_Reduce_Price	, 0) AS Addition_Coupon_Price
		,	ISNULL(CO.Reduce_Price			, 0) AS Coupon_Price
		,	ISNULL(CO.Reduce_Price			, 0) AS Reduce_Price
		,	ISNULL(CO.Last_Total_Price		, 0) AS Last_Total_Price
		,	ISNULL(CO.Settle_Price			, 0) AS Settle_Price
		,	CO.Settle_Method
		,	CO.Order_ETC_Comment
		,	CO.IsVar
		,   CASE 
                WHEN CO.Member_ID IS NULL OR CO.Member_ID = '' THEN '비회원' 
                ELSE CO.Member_ID 
            END AS Member_ID 
		,   ISNULL(CO.Inflow_Route, 'PC') AS Inflow_Route_Order
		,   ISNULL(CO.Inflow_Route_Settle, 'PC') AS Inflow_Route_Settle
        ,   CASE    
                WHEN ISNULL(Coupon_Default.Coupon_Code, '') = '' THEN ISNULL(CO.CouponSeq, '')
                ELSE ISNULL(Coupon_Default.Coupon_Code, '')
            END AS CouponSeq
        ,   CASE    
                WHEN ISNULL(Coupon_Dup.Coupon_Code, '') = '' THEN ISNULL(CO.Addition_CouponSeq, '')
                ELSE ISNULL(Coupon_Dup.Coupon_Code, '')
            END AS Addition_CouponSeq
        ,   ISNULL(Coupon_AD.Coupon_Code, '') AS Coupon_Ad
        ,   ISNULL(Coupon_ADD.Coupon_Code, '') AS Coupon_Add
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

	INTO	#T
	FROM    Custom_Order AS CO
        LEFT OUTER JOIN
        (
            SELECT  
                    SUM(CASE    /* 고급 봉투 또는 추가 봉투 금액 */
                            WHEN ISNULL(Addnum_Price, 0) > ISNULL(Item_Sale_Price, 0) * ISNULL(Item_Count, 0) THEN ISNULL(Addnum_Price, 0) 
                            ELSE ISNULL(Item_Sale_Price, 0) * ISNULL(Item_Count, 0)
                        END ) AS Env_Option_Price
                ,   Order_Seq
            FROM    Custom_Order_Item
            WHERE   Item_Type = 'E'
			  and  REG_DATE between @P_Search_Start_Date  and @P_Search_End_Date + ' 23:59:59' -- jmkim
            GROUP BY Order_Seq
        ) AS COI 
            ON CO.Order_Seq = COI.Order_Seq
	    INNER JOIN  S2_CardView AS SCV 
            ON CO.Card_Seq = SCV.Card_Seq
	    INNER JOIN	Company AS C 
            ON CO.Company_Seq = C.Company_Seq
        LEFT OUTER JOIN
        (
            SELECT  
                    COC.Order_Seq
                ,   MAX(CD.Coupon_Code) AS Coupon_Code
            FROM    Custom_Order_Coupon AS COC
                INNER JOIN    Coupon_Issue AS CI 
                    ON COC.Coupon_Issue_Seq = CI.Coupon_Issue_Seq
                INNER JOIN    Coupon_Detail AS CD 
                    ON CI.Coupon_Detail_Seq = CD.Coupon_Detail_Seq
                INNER JOIN    Coupon_MST AS CM 
                    ON CD.Coupon_MST_Seq = CM.Coupon_MST_Seq
            WHERE   CM.Coupon_Type_Code = '131001'
            GROUP BY 
                    Order_Seq
        ) AS Coupon_Default 
            ON Coupon_Default.Order_Seq = CO.Order_Seq
        LEFT OUTER JOIN
        (
            SELECT  
                    COC.Order_Seq
                ,   MAX(CD.Coupon_Code) AS Coupon_Code
            FROM    Custom_Order_Coupon AS COC
                INNER JOIN    Coupon_Issue AS CI 
                    ON COC.Coupon_Issue_Seq = CI.Coupon_Issue_Seq
                INNER JOIN    Coupon_Detail AS CD 
                    ON CI.Coupon_Detail_Seq = CD.Coupon_Detail_Seq
                INNER JOIN    Coupon_MST AS CM 
                    ON CD.Coupon_MST_Seq = CM.Coupon_MST_Seq
            WHERE   CM.Coupon_Type_Code = '131002'
            GROUP BY 
                    Order_Seq
        ) AS Coupon_Dup 
            ON Coupon_Dup.Order_Seq = CO.Order_Seq
        LEFT OUTER JOIN
        (
            SELECT  
                    COC.Order_Seq
                ,   MAX(CD.Coupon_Code) AS Coupon_Code
            FROM    Custom_Order_Coupon AS COC
                INNER JOIN    Coupon_Issue AS CI 
                    ON COC.Coupon_Issue_Seq = CI.Coupon_Issue_Seq
                INNER JOIN    Coupon_Detail AS CD 
                    ON CI.Coupon_Detail_Seq = CD.Coupon_Detail_Seq
                INNER JOIN    Coupon_MST CM 
                    ON CD.Coupon_MST_Seq = CM.Coupon_MST_Seq
            WHERE   CM.Coupon_Type_Code = '131003'
            GROUP BY 
                    Order_Seq
        ) AS Coupon_AD 
            ON Coupon_AD.Order_Seq = CO.Order_Seq
        LEFT OUTER JOIN
        (
            SELECT  
                    COC.Order_Seq
                ,   MAX(CD.Coupon_Code) AS Coupon_Code
            FROM    Custom_Order_Coupon AS COC
                INNER JOIN    Coupon_Issue AS CI 
                    ON COC.Coupon_Issue_Seq = CI.Coupon_Issue_Seq
                INNER JOIN    Coupon_Detail AS CD 
                    ON CI.Coupon_Detail_Seq = CD.Coupon_Detail_Seq
                INNER JOIN    Coupon_MST AS CM 
                    ON CD.Coupon_MST_Seq = CM.Coupon_MST_Seq
            WHERE   CM.Coupon_Type_Code = '131004'
            GROUP BY 
                    Order_Seq
        ) AS Coupon_Add 
            ON Coupon_Add.Order_Seq = CO.Order_Seq
        LEFT OUTER JOIN Delivery_Info AS DI 
            ON CO.Order_Seq = DI.Order_Seq
	WHERE	1 = 1
        AND     CO.Company_Seq = C.Company_Seq

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
        AND     (
                        (@P_Address_View_YorN = 'Y' AND DI.Delivery_Seq >= 1)
                    OR
                        (@P_Address_View_YorN = 'N' AND DI.Delivery_Seq = 1)
                )
	


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
				    ,	CASE 
						    WHEN SCV.Brand = 1	    THEN '바른손카드'
						    WHEN SCV.Brand = 2	    THEN '위시메이드'
						    WHEN SCV.Brand = 8	    THEN '해피카드'
						    WHEN SCV.Brand = 13     THEN '티아라카드'
						    WHEN SCV.Brand = 16     THEN '프리미어페이퍼'
						    WHEN SCV.Brand = 19     THEN '티로즈'
						    WHEN SCV.Brand = 20     THEN '가랑카드'
						    WHEN SCV.Brand = 21     THEN '예카드'
						    WHEN SCV.Brand = 22     THEN '그레이스문'
						    WHEN SCV.Brand = 23     THEN '투유카드'
						    WHEN SCV.Brand = 24     THEN '더카드'
						    WHEN SCV.Brand = 25     THEN '비핸즈룩'
						    WHEN SCV.Brand = 26     THEN '기타'
						    WHEN SCV.Brand = 27     THEN '프리미어비핸즈'
						    WHEN SCV.Brand = 28     THEN '비핸즈카드'
						    ELSE ''
					    END AS Title
				    ,	COUNT(T.Order_Seq) AS ORD_CNT
				    ,	SUM(COI.Item_Count) AS Card_CNT
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
			FROM	#T AS T
			    LEFT OUTER JOIN [ERPDB.BhandsCard.Com].XERP.dbo.C_ERPItemInfo AS EII 
                    ON T.ERP_Code = EII.ERP_ItemCode

		END

	/* 리스트 엑셀 출력 */
	ELSE IF @P_List_Type = 'List_Excel'
		BEGIN

			/* 샘플주문내역 */ 
			SELECT CSO.Member_ID
				 , t_sub.order_name
				 , t_sub.order_hphone
				 , MIN(CSO.Request_Date) AS Request_Date -- 샘플최초주문일
				 , STUFF ((SELECT '|' + (CASE
											WHEN ISNULL(CSO_SUB.JOIN_Division, 'WEB') = 'Mobile' THEN 'Mobile'
											WHEN ISNULL(CSO_SUB.JOIN_Division, 'WEB') = 'Web' THEN 'PC'
										 ELSE ' ' END )
								FROM Custom_Sample_Order AS CSO_SUB
								WHERE CSO_SUB.Status_Seq = 12
								AND ( cso_sub.member_id = ''
										AND t_sub.order_name = CSO_SUB.member_name
										AND t_sub.order_hphone = cso_sub.member_hphone)
								AND CSO_SUB.Request_Date >= MIN(CSO.Request_Date) FOR XML PATH('') ) , 1, 1, '' ) AS Inflow_Route_Sample
				 , STUFF ((	SELECT '|' + CSO_SUB.Sales_Gubun
							FROM Custom_Sample_Order AS CSO_SUB
							WHERE CSO_SUB.Status_Seq = 12
								AND ( cso_sub.member_id = ''
										AND t_sub.order_name = CSO_SUB.member_name
										AND t_sub.order_hphone = cso_sub.member_hphone)
								AND CSO_SUB.Request_Date >= MIN(CSO.Request_Date) FOR XML PATH('') ) , 1, 1, '' ) AS Sample_Sales_Gubun
				INTO #tmp_sample_order
				FROM #T AS T_SUB INNER JOIN Custom_Sample_Order AS CSO ON ((cso.member_id = ''
								OR cso.member_id is null)
						AND cso.member_name=t_sub.order_name
						AND cso.member_hphone = t_sub.order_hphone)
				WHERE 1 = 1
				AND CSO.Status_Seq = 12
				AND CSO.Request_Date > (T_SUB.Order_Date - 180)
				GROUP BY CSO.Member_ID, t_sub.order_name, t_sub.order_hphone ;
 
			INSERT INTO #tmp_sample_order
			SELECT CSO.Member_ID
					, '' AS order_name
					, '' AS order_hphone
					, MIN(CSO.Request_Date) AS Request_Date -- 샘플최초주문일 , MAX(CSO.Request_Date) AS Request_Date_2 -- 샘플최종주문일
					, STUFF ((SELECT '|' + (CASE
											WHEN ISNULL(CSO_SUB.JOIN_Division, 'WEB') = 'Mobile' THEN 'Mobile'
											WHEN ISNULL(CSO_SUB.JOIN_Division, 'WEB') = 'Web' THEN 'PC'
											ELSE ' ' END )
								FROM Custom_Sample_Order AS CSO_SUB
								WHERE CSO_SUB.Status_Seq = 12
								AND cso_sub.member_id <> ''
								AND cso_sub.member_id = CSO.member_id
								AND CSO_SUB.Request_Date >= MIN(CSO.Request_Date) FOR XML PATH('') ) , 1, 1, '' ) AS Inflow_Route_Sample
					, STUFF ((SELECT '|' + CSO_SUB.Sales_Gubun
								FROM Custom_Sample_Order AS CSO_SUB
								WHERE 1 = 1
								AND CSO_SUB.Status_Seq = 12
								AND (cso_sub.member_id <> ''
										AND cso_sub.member_id = CSO.member_id)
								AND CSO_SUB.Request_Date >= MIN(CSO.Request_Date) FOR XML PATH('') ) , 1, 1, '' ) AS Sample_Sales_Gubun
				FROM #T AS T_SUB INNER JOIN Custom_Sample_Order AS CSO ON (cso.member_id <> ''
						AND cso.member_id = t_sub.Member_ID)
				WHERE 1 = 1
				AND CSO.Status_Seq = 12
				AND (CSO.Member_ID <> ''
						OR cso.member_id is NOT null) --and cso.member_hphone is not null -- jmkim
				AND CSO.Request_Date > (T_SUB.Order_Date - 180)
				GROUP BY CSO.Member_ID ;


			/* List 최종 */
			SELECT DISTINCT t.* 
							,ISNULL(vui.member_age, '')     AS Member_Age 
							,cow.wedd_date 
							,cow.wedd_name 
							,cow.wedd_addr 
							,vui.referer_sales_gubun 
							,CASE 
							   WHEN vui.inflow_route IN ( 'web', 'PC' ) THEN 'PC' 
							   WHEN vui.inflow_route = 'Mobile' THEN 'Mobile' 
							   ELSE '' 
							 END                            AS Inflow_Route_SignUp 
							,CASE 
							   WHEN cso.member_id IS NULL THEN 'N' 
							   ELSE 'Y' 
							 END                            AS Sample_Order_YN 
							,cso.request_date               AS Sample_Request_Date 
							,cso.sample_sales_gubun 
							,cso.inflow_route_sample 
							,CASE 
							   WHEN mi.completedtime IS NOT NULL THEN 'Y' 
							   ELSE 'N' 
							 END                            AS New_Mobile_Invitaion_YN 
							,CASE 
							   WHEN mi.completedtime IS NOT NULL THEN mi.completedtime 
							   ELSE NULL 
							 END                            AS New_Mobile_Invitaion_Date 
							,ISNULL(eii.erp_itemstatus, '') AS ERP_ItemStatus 
			FROM   #t AS t 
				   LEFT OUTER JOIN (SELECT Max (CASE 
												  WHEN ISDATE(birth_date) = 1 THEN Datediff(year, birth_date, Getdate())
												  ELSE '' 
												END)                          AS Member_Age 
										   ,uid 
										   ,ISNULL(referer_sales_gubun, 'SB') AS Referer_Sales_Gubun 
										   ,Max(inflow_route)                 AS inflow_route 
									FROM   vw_user_info 
									WHERE  umail <> '@' 
									GROUP  BY uid 
											  ,referer_sales_gubun) AS vui 
								ON t.member_id = vui.uid 
				   LEFT OUTER JOIN custom_order_weddinfo AS cow 
								ON t.order_seq = cow.order_seq 
                LEFT OUTER JOIN	(
									SELECT Max(member_id)                       AS member_id, 
										   order_name, 
										   order_hphone, 
										   Min(request_date)                    AS request_date, 
										   Substring((SELECT Stuff(inflow_route_sample, 1, 0, '|') 
													  FROM   #tmp_sample_order 
													  WHERE  order_name = cso.order_name 
															 AND order_hphone = cso.order_hphone 
													  FOR xml path('')), 2, 99) AS Inflow_Route_Sample, 
										   Substring((SELECT Stuff(sample_sales_gubun, 1, 0, '|') 
													  FROM   #tmp_sample_order 
													  WHERE  order_name = cso.order_name 
															 AND order_hphone = cso.order_hphone 
													  FOR xml path('')), 2, 99) AS Sample_Sales_Gubun 
									FROM   #tmp_sample_order AS cso 
									GROUP  BY order_name, 
											  order_hphone 
				) AS CSO 
								ON  (CSO.Member_ID <>'' and CSO.Member_ID = T.Member_ID) or
									(CSO.Member_ID = '' and CSO.order_name = T.order_name and CSO.order_hphone = t.order_hphone) -- jmkim 
				   INNER JOIN s2_cardview AS scv 
						   ON t.card_seq = scv.card_seq 
				   LEFT OUTER JOIN (SELECT orderseq 
										   ,Max(sitecode)      AS SiteCode 
										   ,Max(completedtime) AS CompletedTime 
									FROM   mcard_invitation 
									WHERE  deleteyn = 'N' 
											OR ( deleteyn = 'Y' 
												 AND expireyn = 'Y' ) 
									GROUP  BY orderseq) AS mi 
								ON t.order_seq = mi.orderseq 
								   AND t.sales_gubun = mi.sitecode 
				   LEFT OUTER JOIN [ERPDB.BhandsCard.Com].xerp.dbo.c_erpiteminfo AS eii 
								ON t.erp_code = eii.erp_itemcode 
			ORDER  BY t.order_date DESC; 

	END
END
GO
