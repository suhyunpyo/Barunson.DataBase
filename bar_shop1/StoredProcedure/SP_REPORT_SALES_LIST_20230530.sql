USE [bar_shop1]
GO

/****** Object:  StoredProcedure [dbo].[SP_REPORT_SALES_LIST_20230530]    Script Date: 2023-05-30 오전 11:11:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/*  
 EXEC SP_REPORT_SALES_LIST_20230530    'AGGREGATE'  , ' SB , '  , ''  ,  0 , '2021-04-01'  , '2021-04-22'  ,  0 ,  0 ,  0 ,  -1 ,  0 ,  0 , ''  , 'N'  , 'N'  , '' 
  EXEC SP_REPORT_SALES_LIST_20230530    'LIST'  , ' SB , '  , ''  ,  0 , '2021-04-01'  , '2021-04-22'  ,  0 ,  0 ,  0 ,  -1 ,  0 ,  0 , ''  , 'N'  , 'N'  , '' 
*/  
CREATE PROCEDURE [dbo].[SP_REPORT_SALES_LIST_20230530]  
 @P_List_Type   AS VARCHAR(50)  
, @P_Sales_Gubun_List  AS VARCHAR(100)  
, @P_ERP_Part_Code  AS VARCHAR(50)  
, @P_Search_Date_Type  AS INT  
, @P_Search_Start_Date AS VARCHAR(10)  
, @P_Search_End_Date  AS VARCHAR(10)  
, @P_Order_Trouble_Type AS INT  
, @P_Order_Type   AS INT  
, @P_Brand    AS INT  
, @P_Printer    AS INT  
, @P_MIN_Price   AS INT  
, @P_MAX_Price   AS INT  
, @P_Card_Code   AS VARCHAR(100)  
, @P_Jaebon_YorN   AS VARCHAR(1)  
, @P_Address_View_YorN AS VARCHAR(1)  
, @P_Inflow_Route_Type AS VARCHAR(50)  
  
AS  
  
BEGIN  
  
SET NOCOUNT ON;  

-- 임시테이블 생성  
CREATE TABLE #custom_order_year (
	[order_seq] [int] NOT NULL,
	[up_order_seq] [int] NULL,
	[order_type] [varchar](2) NULL,
	[sales_Gubun] [varchar](2) NULL,
	[pay_Type] [char](1) NULL,	
	[company_seq] [int] NULL,
	[status_seq] [int] NOT NULL,	
	[order_date] [smalldatetime] NULL,
	[src_compose_date] [smalldatetime] NULL,
	[src_compose_mod_date] [smalldatetime] NULL,	
	[src_print_date] [smalldatetime] NULL,	
	[src_send_date] [smalldatetime] NULL,	
	[src_printer_seq] [smallint] NULL,
	[member_id] [varchar](50) NULL,
	[order_name] [varchar](50) NULL,
	[order_email] [varchar](50) NULL,
	[order_phone] [varchar](20) NULL,
	[order_hphone] [varchar](20) NULL,
	[order_etc_comment] [varchar](1000) NULL,	
	[card_seq] [int] NULL,
	[order_count] [int] NULL,	
	[order_add_type] [char](1) NULL,	
	[isinpaper] [char](1) NULL,
	[ishandmade] [char](1) NULL,
	[isRibon] [char](1) NULL,
	[isEmbo] [char](1) NULL,	
	[isEnvInsert] [char](1) NULL,	
	[isSpecial] [char](1) NULL,
	[couponseq] [varchar](50) NULL,	
	[discount_rate] [float] NULL,	
	[delivery_price] [int] NULL,
	[jebon_price] [int] NULL,
	[sticker_price] [int] NULL,
	[mini_price] [int] NULL,
	[embo_price] [int] NULL,
	[etc_price] [int] NULL,
	[env_price] [int] NULL,
	[guestbook_price] [int] NULL,
	[cont_price] [int] NULL,
	[option_price] [int] NULL,
	[reduce_price] [int] NULL,
	[fticket_price] [int] NULL,
	[print_price] [int] NULL,
	[sasik_price] [int] NULL,
	[label_price] [int] NULL,
	[envInsert_price] [int] NULL,
	[coop_sale_price] [int] NULL,
	[last_total_price] [int] NULL,
	[settle_date] [smalldatetime] NULL,
	[settle_cancel_date] [smalldatetime] NULL,
	[settle_method] [char](1) NULL,
	[settle_price] [int] NULL,	
	[isVar] [char](1) NULL,	
	[inflow_route] [varchar](10) NULL,	
	[moneyenv_price] [int] NULL,
	[isEnvCharge] [char](1) NULL,	
	[laser_price] [int] NULL,	
	[inflow_route_settle] [varchar](10) NULL,
	[addition_reduce_price] [int] NULL,
	[addition_couponseq] [varchar](50) NULL,	
	[MemoryBook_Price] [int] NULL,
	[EnvSpecial_Price] [int] NULL,
	[unit_price] [int] NULL,
	[flower_price] [int] NULL,
	[sealing_sticker_price] [int] NULL,	
	[perfume_price] [int] NULL,	
	[ribbon_price] [int] NULL,
	[paperCover_price] [int] NULL,	
	[Mask_Price] [int] NULL,	
	[isCCG] [char](1) NULL,	
	[Pocket_price] [int] NOT NULL,
	[EnvPremium_price] [int] NULL,
	[MaskingTape_price] [int] NULL
)

INSERT INTO #custom_order_year (order_seq, Up_Order_Seq, order_type, sales_Gubun, pay_Type, company_seq, status_seq, order_date, src_compose_date, src_compose_mod_date, src_print_date, src_send_date, src_printer_seq, member_id, order_name, order_email, order_phone, order_hphone, order_etc_comment, card_seq, order_count, order_add_type, isinpaper, ishandmade, isRibon, isEmbo, isEnvInsert, isSpecial, couponseq, discount_rate, delivery_price, jebon_price, sticker_price, mini_price, embo_price, etc_price, env_price, guestbook_price, cont_price, option_price, reduce_price, fticket_price, print_price, sasik_price, label_price, envInsert_price, coop_sale_price, last_total_price, settle_date, settle_cancel_date, settle_method, settle_price, isVar, inflow_route, moneyenv_price, isEnvCharge, laser_price, inflow_route_settle, addition_reduce_price, addition_couponseq, MemoryBook_Price, EnvSpecial_Price, unit_price, flower_price, sealing_sticker_price, perfume_price, ribbon_price, paperCover_price, Mask_Price, isCCG, Pocket_price, EnvPremium_price, MaskingTape_price)
select order_seq, Up_Order_Seq, order_type, sales_Gubun, pay_Type, company_seq, status_seq, order_date, src_compose_date, src_compose_mod_date, src_print_date, src_send_date, src_printer_seq, member_id, order_name, order_email, order_phone, order_hphone, order_etc_comment, card_seq, order_count, order_add_type, isinpaper, ishandmade, isRibon, isEmbo, isEnvInsert, isSpecial, couponseq, discount_rate, delivery_price, jebon_price, sticker_price, mini_price, embo_price, etc_price, env_price, guestbook_price, cont_price, option_price, reduce_price, fticket_price, print_price, sasik_price, label_price, envInsert_price, coop_sale_price, last_total_price, settle_date, settle_cancel_date, settle_method, settle_price, isVar, inflow_route, moneyenv_price, isEnvCharge, laser_price, inflow_route_settle, addition_reduce_price, addition_couponseq, MemoryBook_Price, EnvSpecial_Price, unit_price, flower_price, sealing_sticker_price, perfume_price, ribbon_price, paperCover_price, Mask_Price, isCCG, Pocket_price, EnvPremium_price, MaskingTape_price from custom_order AS CO with(nolock) 
where 1=1
	-- and order_date > '2019-01-01'
     AND  (  
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

CREATE CLUSTERED INDEX IDX_TEMP_custom_order_year1 ON #custom_order_year (order_seq)
CREATE NONCLUSTERED INDEX IDX_TEMP_custom_order_year2 ON #custom_order_year ([up_order_seq],[status_seq],[order_type],[pay_Type],[src_send_date])
CREATE NONCLUSTERED INDEX IDX_TEMP_custom_order_year3 ON #custom_order_year ([up_order_seq],[status_seq],[member_id],[order_type],[pay_Type],[src_send_date])

 /* @P_List_Type [Aggregate, Aggregate_Excel, List, List_Excel] */  
 /* Aggregate : 집계 요약 출력 */  
 /* Aggregate_Excel : 집계 요약 엑셀 출력 */  
 /* List : 리스트 출력 */  
 /* List_Excel : 리스트 엑셀 출력 */  
  
  
--쿠폰정보  
/*  
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

SELECT CM.Coupon_Type_Code   
 , COC.Order_Seq  
    , MAX(CD.Coupon_Code) AS Coupon_Code  
 , SUM(COC.COUPON_AMT) AS COUPON_AMT  
 , MAX(CM.COUPON_NAME) AS COUPON_NAME   
INTO #Custom_Order_Coupon  
FROM 
Custom_Order_Coupon AS COC WITH(NOLOCK) 
INNER JOIN #custom_order_year AS CO WITH(NOLOCK) ON COC.ORDER_SEQ = CO.order_seq
INNER JOIN    Coupon_Issue AS CI WITH(NOLOCK)  ON COC.Coupon_Issue_Seq = CI.Coupon_Issue_Seq  
INNER JOIN    Coupon_Detail AS CD WITH(NOLOCK)  ON CI.Coupon_Detail_Seq = CD.Coupon_Detail_Seq  
INNER JOIN    Coupon_MST AS CM  WITH(NOLOCK) ON CD.Coupon_MST_Seq = CM.Coupon_MST_Seq  
GROUP BY CM.Coupon_Type_Code,COC.ORDER_SEQ  

/*
SELECT CM.Coupon_Type_Code   
 , COC.Order_Seq  
    , MAX(CD.Coupon_Code) AS Coupon_Code  
 , SUM(COC.COUPON_AMT) AS COUPON_AMT  
 , MAX(CM.COUPON_NAME) AS COUPON_NAME   
INTO #Custom_Order_Coupon  
FROM Custom_Order_Coupon AS COC WITH(NOLOCK) 
inner join custom_order as co with(nolock) on COC.Order_Seq = co.order_seq
INNER JOIN    Coupon_Issue AS CI WITH(NOLOCK)  ON COC.Coupon_Issue_Seq = CI.Coupon_Issue_Seq  
INNER JOIN    Coupon_Detail AS CD WITH(NOLOCK)  ON CI.Coupon_Detail_Seq = CD.Coupon_Detail_Seq  
INNER JOIN  Coupon_MST AS CM  WITH(NOLOCK) ON CD.Coupon_MST_Seq = CM.Coupon_MST_Seq  
where  1=1

     AND  (  
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
GROUP BY CM.Coupon_Type_Code,COC.ORDER_SEQ  
*/
  
    /* 기초 데이터 수집 */  
 SELECT   
   CO.Company_Seq  
  , C.ERP_PartCode  
  , C.Company_Name  
  , CO.Sales_Gubun  
  , CO.Up_Order_Seq  
  , CO.Order_Seq  
  , CO.Order_Date  
  , CO.Order_Add_Type  
  , CO.Src_Compose_Date  
  , CO.Src_Compose_Mod_Date  
  , CO.Settle_Date  
  , CO.Src_Print_Date  
  , CO.Src_Send_Date  
  , CO.Settle_Cancel_Date  
  , CO.Src_Printer_Seq  
  , CO.Status_Seq  
  , CO.Order_Name  
  , CO.Order_Phone + '/' + CO.Order_Hphone AS Order_Phone  
  , CO.Order_Hphone  
  , CO.Order_Email  
  , CO.Order_Type  
  , CO.DisCount_Rate  
  , SCV.Brand  
  , SCV.Card_Seq  
  , SCV.Card_Code  
  , SCV.ERP_Code  
  , SCV.Old_Code  
  , SCV.Card_Price  
  ,   CO.unit_price  
  --, CO.Order_Count /* 주문수 이상으로 수정 2018-10-08 */  
  ,   ISNULL(COI2.item_count, 0) AS Order_Count  
  , CO.IsInpaper  
  , CO.IsHandmade  
  , CO.IsRibon  
  , CO.IsEnvInsert  
  , CO.IsEmbo  
       ,   ROUND((ISNULL(CO.unit_price, 0) * ((100 - ISNULL(CO.Discount_Rate, 0)) / 100)) + 0.4, 0) AS Calc_Card_Price  
        ,   ROUND((ISNULL(CO.unit_price, 0) * ((100 - ISNULL(CO.Discount_Rate, 0)) / 100)) + 0.4, 0) * ISNULL(CO.Order_Count, 0) AS Calc_Total_Card_Price  
          
  ,   ISNULL(Env_Option_Price         , 0) +  
            ISNULL(CO.Jebon_Price   , 0) +  
            ISNULL(CO.Option_Price   , 0) +  
            ISNULL(CO.Mini_Price   , 0) +  
            ISNULL(CO.FTicket_Price   , 0) +  
            ISNULL(CO.POCKET_Price   , 0) +  
            ISNULL(CO.Sticker_Price   , 0) +  
            ISNULL(CO.Label_Price   , 0) +  
            ISNULL(CO.Embo_Price   , 0) +  
            ISNULL(CO.Print_Price   , 0) +  
  ISNULL(CO.Cont_Price   , 0) +  
            ISNULL(CO.EnvInsert_Price  , 0) +  
            ISNULL(CO.ETC_Price    , 0) +  
            ISNULL(CO.Delivery_Price  , 0) +  
            ISNULL(CO.Env_Price    , 0) +  
            ISNULL(CO.GuestBook_Price  , 0) +  
            ISNULL(CO.Sasik_Price   , 0) +  
            ISNULL(CO.Coop_Sale_Price  , 0) +  
            ISNULL(CO.MoneyEnv_Price  , 0) +  
   ISNULL(CO.EnvSpecial_Price  , 0) +  
   ISNULL(CO.EnvPremium_Price  , 0) +  
   ISNULL(CO.MemoryBook_Price  , 0) +  
   ISNULL(CO.flower_price   , 0) +  
   ISNULL(CO.sealing_sticker_price , 0) +  
   ISNULL(CO.perfume_price   , 0) +  
   ISNULL(CO.ribbon_price   , 0) +  
   ISNULL(CO.paperCover_price  , 0) +  
   ISNULL(CO.Mask_Price  , 0) + 
   ISNULL(CO.MaskingTape_price  , 0) + 
            ISNULL(CO.Laser_Price   , 0) AS Calc_Total_Option_Price  
          
  ,   (ROUND((ISNULL(SCV.Card_Price, 0) * ((100 - ISNULL(CO.Discount_Rate, 0)) / 100)) + 0.4, 0) * ISNULL(CO.Order_Count, 0)) +  
            ISNULL(Env_Option_Price         , 0) +  
            ISNULL(CO.Jebon_Price   , 0) +  
            ISNULL(CO.Option_Price   , 0) +  
            ISNULL(CO.Mini_Price   , 0) +  
            ISNULL(CO.FTicket_Price   , 0) + 
			ISNULL(CO.POCKET_Price   , 0) + 
            ISNULL(CO.Sticker_Price   , 0) +  
            ISNULL(CO.Label_Price   , 0) +  
            ISNULL(CO.Embo_Price   , 0) +  
            ISNULL(CO.Print_Price   , 0) +  
            ISNULL(CO.Cont_Price   , 0) +  
            ISNULL(CO.EnvInsert_Price  , 0) +  
            ISNULL(CO.ETC_Price    , 0) +  
            ISNULL(CO.Delivery_Price  , 0) +  
            ISNULL(CO.Env_Price    , 0) +  
            ISNULL(CO.GuestBook_Price  , 0) +  
            ISNULL(CO.Sasik_Price   , 0) +  
            ISNULL(CO.Coop_Sale_Price  , 0) +  
            ISNULL(CO.MoneyEnv_Price  , 0) +  
   ISNULL(CO.EnvSpecial_Price  , 0) +  
   ISNULL(CO.EnvPremium_Price  , 0) +  
           ISNULL(CO.Laser_Price   , 0) +  
            ISNULL(CO.Reduce_Price   , 0) +  
   ISNULL(CO.MemoryBook_Price  , 0) +  
   ISNULL(CO.flower_price   , 0) +  
   ISNULL(CO.sealing_sticker_price , 0) +  
   ISNULL(CO.perfume_price   , 0) +  
   ISNULL(CO.ribbon_price   , 0) +  
   ISNULL(CO.paperCover_price  , 0) +  
            ISNULL(CO.Addition_Reduce_Price , 0) AS Calc_Settle_Price  
  
  , ISNULL(CO.Jebon_Price   , 0) AS Jebon_Price  
  , ISNULL(CO.Option_Price   , 0) AS Option_Price  
  , ISNULL(CO.Mini_Price   , 0) AS Mini_Price  
  , ISNULL(CO.FTicket_Price   , 0) AS FTicket_Price  
  ,	ISNULL(CO.POCKET_Price   , 0) AS Pocket_Price
  , ISNULL(CO.Sticker_Price   , 0) AS Sticker_Price  
  , ISNULL(CO.Label_Price   , 0) AS Label_Price  
  , ISNULL(CO.Embo_Price   , 0) AS Embo_Price  
  , ISNULL(CO.Print_Price   , 0) AS Print_Price  
  , ISNULL(CO.Cont_Price   , 0) AS Cont_Price  
  , ISNULL(CO.EnvInsert_Price  , 0) AS EnvInsert_Price  
  , CASE WHEN ISNULL(isSpecial,0) = 1 THEN 0 ELSE ISNULL(CO.ETC_Price,0) END AS ETC_Price  -- 초특급제작 서비스비용은 기타금액에서 제외 
  --기능개선 #6164 [빠른손] 초특급제작 _ 서비스비용  칼럼값 별도 생성 요청
  , CASE WHEN ISNULL(isSpecial,0) = 1 THEN ISNULL(CO.ETC_Price,0) ELSE 0 END AS SP_Price  -- 초특급제작 서비스비용
  , ISNULL(CO.Delivery_Price  , 0) AS Delivery_Price  
  , ISNULL(CO.Env_Price    , 0) AS Env_Price  
  , ISNULL(CO.GuestBook_Price  , 0) AS GuestBook_Price  
  , ISNULL(CO.Sasik_Price   , 0) AS Sasik_Price  
  , ISNULL(CO.Coop_Sale_Price  , 0) AS Coop_Sale_Price  
  , ISNULL(CO.MoneyEnv_Price  , 0) AS MoneyEnv_Price  
  , ISNULL(CO.EnvSpecial_Price  , 0) AS EnvSpecial_Price  
  , ISNULL(CO.EnvPremium_Price  , 0) AS EnvPremium_Price  
  , ISNULL(CO.Laser_Price   , 0) AS Laser_Price  
        ,   ISNULL(Env_Option_Price         , 0) AS Env_Option_Price  
  , COI.Card_Code  AS SP_ENV_CODE
  , CASE WHEN ISNULL(Coupon_Default.COUPON_AMT, 0)+ISNULL(Coupon_Dup.COUPON_AMT, 0)+ISNULL(Coupon_AD.COUPON_AMT, 0)+ISNULL(Coupon_Add.COUPON_AMT, 0) = 0 THEN ISNULL(CO.Reduce_Price, 0) ELSE ISNULL(Coupon_Default.COUPON_AMT, 0)*-1 END AS Coupon_Price  
  , CASE WHEN ISNULL(Coupon_Default.COUPON_AMT, 0)+ISNULL(Coupon_Dup.COUPON_AMT, 0)+ISNULL(Coupon_AD.COUPON_AMT, 0)+ISNULL(Coupon_Add.COUPON_AMT, 0) = 0 THEN ISNULL(CO.Addition_Reduce_Price, 0) ELSE ISNULL(Coupon_Dup.COUPON_AMT, 0)*-1 END AS Addition_Coupon_Price  
  , CASE WHEN ISNULL(Coupon_Default.COUPON_AMT, 0)+ISNULL(Coupon_Dup.COUPON_AMT, 0)+ISNULL(Coupon_AD.COUPON_AMT, 0)+ISNULL(Coupon_Add.COUPON_AMT, 0) = 0 THEN 0 ELSE ISNULL(Coupon_AD.COUPON_AMT, 0)*-1 END AS AD_Coupon_Price  
  , CASE WHEN ISNULL(Coupon_Default.COUPON_AMT, 0)+ISNULL(Coupon_Dup.COUPON_AMT, 0)+ISNULL(Coupon_AD.COUPON_AMT, 0)+ISNULL(Coupon_Add.COUPON_AMT, 0) = 0 THEN 0 ELSE ISNULL(Coupon_Add.COUPON_AMT, 0)*-1 END AS ADD_Addition_Coupon_Price  
  
  , ISNULL(CO.Last_Total_Price  , 0) AS Last_Total_Price  
  , ISNULL(CO.Settle_Price   , 0) AS Settle_Price  
    
  , ISNULL(CO.MemoryBook_Price  , 0) AS MemoryBook_Price  
  , ISNULL(CO.flower_price   , 0) AS flower_price  
  , ISNULL(CO.sealing_sticker_price , 0) AS sealing_sticker_price  
  , ISNULL(CO.perfume_price   , 0) AS perfume_price  
  , ISNULL(CO.ribbon_price   , 0) AS ribbon_price  
  , ISNULL(CO.paperCover_price  , 0) AS paperCover_price   
  , ISNULL(CO.mask_price  , 0) AS mask_price   
  , ISNULL(CO.MaskingTape_price,0) as MaskingTape_price
  
   
  , CO.Settle_Method  
  , ISNULL(CO.CouponSeq             ,'') AS CouponSeq_CRN  
  --, ISNULL(CO.Addition_CouponSeq    ,'') AS Addition_CouponSeq  
  , CO.Order_ETC_Comment  
  , CO.IsVar 
  , ISNULL(CO.isCCG, 'N') isCCG
  ,   CASE   
                WHEN CO.Member_ID IS NULL OR CO.Member_ID = '' THEN '비회원'   
                ELSE CO.Member_ID   
            END AS Member_ID   
  ,   ISNULL(CO.Inflow_Route, 'PC') AS Inflow_Route_Order  
  ,   ISNULL(CO.Inflow_Route_Settle, 'PC') AS Inflow_Route_Settle  
          
  , '' AS CouponSeq  
  
  , '' AS Addition_CouponSeq  
  
  , '' AS Coupon_Ad  
  
  , '' AS Coupon_Add  
  
  , CASE   
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

  , ISNULL(LTRIM(RTRIM(Coupon_Default.COUPON_NAME)), '') AS Coupon_Default_COUPON_NAME
  , Coupon_Default.Coupon_Code AS Coupon_Default_Coupon_Code
  , CO.CouponSeq AS CO_CouponSeq

  , ISNULL(LTRIM(Coupon_Dup.COUPON_NAME), '') AS Coupon_Dup_COUPON_NAME
  , Coupon_Dup.Coupon_Code AS Coupon_Dup_Coupon_Code
  , CO.addition_couponseq AS CO_Addition_CouponSeq

  , ISNULL(LTRIM(RTRIM(Coupon_AD.COUPON_NAME)), '') AS Coupon_AD_COUPON_NAME
  , Coupon_AD.Coupon_Code AS Coupon_AD_Coupon_Code

  , ISNULL(LTRIM(RTRIM(Coupon_ADD.COUPON_NAME)), '') AS Coupon_ADD_COUPON_NAME
  , Coupon_ADD.Coupon_Code AS Coupon_ADD_Coupon_Code
 INTO #T  
 FROM    #Custom_Order_year AS CO   WITH(NOLOCK)
  INNER JOIN  S2_CardView AS SCV  WITH(NOLOCK) ON CO.Card_Seq = SCV.Card_Seq  
     INNER JOIN Company AS C  WITH(NOLOCK) ON CO.Company_Seq = C.Company_Seq  
  LEFT OUTER JOIN S2_UserInfo_TheCard AS UI  WITH(NOLOCK) ON UI.uid = CO.member_id /* 20200714 김성동 본부장님 긴급 추가 요청 */  
          
  LEFT JOIN Custom_Order_Item AS COI2  WITH(NOLOCK) ON CO.Order_Seq = COI2.Order_Seq AND COI2.item_count > 0 AND COI2.item_type = 'C'  
  LEFT OUTER JOIN  
        (  
			select 
				order_seq,
				sum(Env_Option_Price) Env_Option_Price,
				b.card_code
			from (
					SELECT    
							CASE  
									WHEN ISNULL(Addnum_Price, 0) > ISNULL(Item_Sale_Price, 0) * ISNULL(Item_Count, 0) THEN ISNULL(Addnum_Price, 0)   
									ELSE ISNULL(Item_Sale_Price, 0) * ISNULL(Item_Count, 0)  
								END  
							AS Env_Option_Price  
						,   B.Order_Seq
						,case when (CASE   
									WHEN ISNULL(Addnum_Price, 0) > ISNULL(Item_Sale_Price, 0) * ISNULL(Item_Count, 0) THEN ISNULL(Addnum_Price, 0)   
									ELSE ISNULL(Item_Sale_Price, 0) * ISNULL(Item_Count, 0)  
								END  
							)  > 0 then B.card_seq
						else null end card_seq
					FROM    Custom_Order_Item B  WITH(NOLOCK) INNER JOIN #Custom_Order_year C ON B.order_seq = C.order_seq
					WHERE   Item_Type = 'E'  
				) as a
			left join s2_card as b  WITH(NOLOCK)
				on a.card_seq = b.card_seq
			where Env_Option_Price > 0
            GROUP BY   a.Order_Seq, b.card_code

        ) AS COI   
            ON CO.Order_Seq = COI.Order_Seq  
         
  LEFT JOIN #Custom_Order_Coupon AS Coupon_Default ON Coupon_Default.Coupon_Type_Code = '131001' AND  Coupon_Default.Order_Seq = CO.Order_Seq  
  LEFT JOIN #Custom_Order_Coupon AS Coupon_Dup ON Coupon_Dup.Coupon_Type_Code = '131002' AND  Coupon_Dup.Order_Seq = CO.Order_Seq  
  LEFT JOIN #Custom_Order_Coupon AS Coupon_AD ON Coupon_AD.Coupon_Type_Code = '131003' AND  Coupon_AD.Order_Seq = CO.Order_Seq  
  LEFT JOIN #Custom_Order_Coupon AS Coupon_Add ON Coupon_Add.Coupon_Type_Code = '131004' AND  Coupon_Add.Order_Seq = CO.Order_Seq  
  
  /* 주소 출력 여부 */  
  LEFT JOIN Delivery_Info AS DI  WITH(NOLOCK) ON CO.Order_Seq = DI.Order_Seq     
    AND (  
      (@P_Address_View_YorN = 'Y' AND DI.Delivery_Seq >= 1) OR (@P_Address_View_YorN = 'N' AND DI.Delivery_Seq = 1)  
     )  
  LEFT JOIN S2_CardOption OT  WITH(NOLOCK) ON CO.card_seq = OT.Card_Seq  
 WHERE 1 = 1  
        --AND  CO.Company_Seq = C.Company_Seq  
  
     /* 사이트 */  
     AND  CO.Sales_Gubun IN ( SELECT VALUE FROM FN_SPLIT(REPLACE(@P_Sales_Gubun_List, ' ', ''), ',') )  
  
     /* 부서코드 */  
     AND  (C.ERP_PartCode = @P_ERP_Part_Code OR @P_ERP_Part_Code = '')  
  
     /* 날짜 검색 */  
     /* 0 : 주문일, 1 : 배송일, 2 : 결제일, 3 : 인쇄일 */  
     AND  (  
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
     AND  (  
        (@P_Order_Trouble_Type = 0)  
        OR (@P_Order_Trouble_Type = 1 AND CO.Pay_Type <> '4')  
        OR (@P_Order_Trouble_Type = 2 AND CO.Pay_Type <> '4' AND CO.Up_Order_Seq IS NULL)  
        OR (@P_Order_Trouble_Type = 3 AND CO.Pay_Type = '4')  
        OR (@P_Order_Trouble_Type = 4 AND CO.Pay_Type <> '4' AND CO.Up_Order_Seq IS NOT NULL)  
       )  
  
     /* 주문 타입 [전체, 청첩장, 감사장, 시즌] */  
     /* 0 : 전체, 1 : 청첩장(초대장), 2 : 감사장, 3 : 시즌 */  
     AND  (  
         (@P_Order_Type = 0)  
        OR (@P_Order_Type = 1 AND CO.Order_Type NOT IN ('2', '4'))  
        OR (@P_Order_Type = 2 AND CO.Order_Type  = '2')  
OR (@P_Order_Type = 3 AND CO.Order_Type  = '4')  
       )  
      
     /* 브랜드 */  
     AND  (SCV.Brand = @P_Brand OR @P_Brand = 0)  
  
     /* 가격 */  
     AND  (@P_MIN_Price = 0 OR (@P_MIN_Price <> 0 AND SCV.Card_Price >= @P_MIN_Price AND SCV.Card_Price < @P_MAX_Price))  
  
     /* 인쇄소 */  
     /* 0 : 내부, 1 : 경림, 2 : 용진, 3 : 기타인쇄, 4 : 직매장, 5 : 대리점, 6 : 학술 */  
     AND  (CO.SRC_Printer_Seq = @P_Printer OR @P_Printer = -1)  
  
     /* 카드코드 */  
     AND  (@P_Card_Code = '' OR SCV.Card_Code LIKE '%' + @P_Card_Code + '%')  
  
     /* 제본 여부 */  
     AND  (  
         @P_Jaebon_YorN = 'N'   
        OR (@P_Jaebon_YorN = 'Y' AND (CO.IsInpaper = '1' OR CO.IsHandmade = '1' OR CO.IsRibon = '1' OR CO.IsEnvInsert = '1'))  
       )  
  
     /* 유입 경로 */  
     /* 날짜 타입이 주문일, 결제일 일때만 적용  */  
     AND  (  
         (@P_Inflow_Route_Type = '' OR @P_Search_Date_Type IN (1, 3))  
        OR (@P_Search_Date_Type = 0 AND ISNULL(CO.Inflow_Route, 'PC') = @P_Inflow_Route_Type)  
        OR (@P_Search_Date_Type = 2 AND ISNULL(CO.Inflow_Route, 'PC') = @P_Inflow_Route_Type)  
       )  
  
        /* 주소 출력 여부 */  
  /*  
        AND     (  
                        (@P_Address_View_YorN = 'Y' AND DI.Delivery_Seq >= 1)  
                    OR  
                        (@P_Address_View_YorN = 'N' AND DI.Delivery_Seq = 1)  
                )  
 */  

IF @P_List_Type = 'Aggregate_Excel' OR @P_List_Type = 'List' OR @P_List_Type = 'List_Excel'
BEGIN
	CREATE NONCLUSTERED INDEX IDX_TEMP_T1 ON #T ([CouponSeq]) INCLUDE ([Coupon_Default_Coupon_Code],[CO_CouponSeq])
	CREATE NONCLUSTERED INDEX IDX_TEMP_T2 ON #T ([Sales_Gubun]) INCLUDE ([ERP_Code],[Card_Price])
	CREATE NONCLUSTERED INDEX IDX_TEMP_T3 ON #T ([CouponSeq]) INCLUDE ([Coupon_Default_COUPON_NAME])
	CREATE NONCLUSTERED INDEX IDX_TEMP_T4 ON #T ([Addition_CouponSeq]) INCLUDE ([Coupon_Dup_COUPON_NAME])
	CREATE NONCLUSTERED INDEX IDX_TEMP_T5 ON #T ([Member_ID])
	CREATE NONCLUSTERED INDEX IDX_TEMP_T6 ON #T ([Coupon_Ad]) INCLUDE ([Coupon_AD_COUPON_NAME])
	CREATE NONCLUSTERED INDEX IDX_TEMP_T7 ON #T ([Coupon_Add]) INCLUDE ([Coupon_ADD_COUPON_NAME])	

	-- 쿠폰관련 처리 시작
	ALTER TABLE #T ALTER COLUMN CouponSeq VARCHAR(1000)
	ALTER TABLE #T ALTER COLUMN Addition_CouponSeq VARCHAR(1000)
	ALTER TABLE #T ALTER COLUMN Coupon_Ad VARCHAR(1000)
	ALTER TABLE #T ALTER COLUMN Coupon_Add VARCHAR(1000)

	UPDATE A SET 
		CouponSeq = ISNULL(STUFF((SELECT
			'/' + CM.COUPON_NAME
		FROM
			Custom_Order_Coupon AS COC  WITH(NOLOCK)
			INNER JOIN Coupon_Issue AS CI WITH(NOLOCK) ON COC.Coupon_Issue_Seq = CI.Coupon_Issue_Seq
			INNER JOIN Coupon_Detail AS CD WITH(NOLOCK) ON CI.Coupon_Detail_Seq = CD.Coupon_Detail_Seq
			INNER JOIN Coupon_MST AS CM WITH(NOLOCK) ON CD.Coupon_MST_Seq = CM.Coupon_MST_Seq
		where
			COC.order_seq = A.ORDER_SEQ AND CM.COUPON_TYPE_CODE = '131001'		
		order by
			CM.Coupon_Type_Code FOR XML PATH ('')), 1, 1, ''), '')

		, Addition_CouponSeq = ISNULL(STUFF((SELECT
			'/' + CM.COUPON_NAME
		FROM
			Custom_Order_Coupon AS COC WITH(NOLOCK)
			INNER JOIN Coupon_Issue AS CI WITH(NOLOCK) ON COC.Coupon_Issue_Seq = CI.Coupon_Issue_Seq
			INNER JOIN Coupon_Detail AS CD WITH(NOLOCK) ON CI.Coupon_Detail_Seq = CD.Coupon_Detail_Seq
			INNER JOIN Coupon_MST AS CM WITH(NOLOCK) ON CD.Coupon_MST_Seq = CM.Coupon_MST_Seq
		where
			COC.order_seq = A.ORDER_SEQ AND CM.COUPON_TYPE_CODE = '131002'		
		order by
			CM.Coupon_Type_Code FOR XML PATH ('')), 1, 1, ''), '')

		, Coupon_Ad = ISNULL(STUFF((SELECT
			'/' + CM.COUPON_NAME
		FROM
			Custom_Order_Coupon AS COC WITH(NOLOCK)
			INNER JOIN Coupon_Issue AS CI WITH(NOLOCK) ON COC.Coupon_Issue_Seq = CI.Coupon_Issue_Seq
			INNER JOIN Coupon_Detail AS CD WITH(NOLOCK) ON CI.Coupon_Detail_Seq = CD.Coupon_Detail_Seq
			INNER JOIN Coupon_MST AS CM WITH(NOLOCK) ON CD.Coupon_MST_Seq = CM.Coupon_MST_Seq
		where
			COC.order_seq = A.ORDER_SEQ AND CM.COUPON_TYPE_CODE = '131003'		
		order by
			CM.Coupon_Type_Code FOR XML PATH ('')), 1, 1, ''), '')

		, Coupon_Add = ISNULL(STUFF((SELECT
			'/' + CM.COUPON_NAME
		FROM
			Custom_Order_Coupon AS COC WITH(NOLOCK)
			INNER JOIN Coupon_Issue AS CI WITH(NOLOCK) ON COC.Coupon_Issue_Seq = CI.Coupon_Issue_Seq
			INNER JOIN Coupon_Detail AS CD WITH(NOLOCK) ON CI.Coupon_Detail_Seq = CD.Coupon_Detail_Seq
			INNER JOIN Coupon_MST AS CM WITH(NOLOCK) ON CD.Coupon_MST_Seq = CM.Coupon_MST_Seq
		where
			COC.order_seq = A.ORDER_SEQ AND CM.COUPON_TYPE_CODE = '131004'		
		order by
			CM.Coupon_Type_Code FOR XML PATH ('')), 1, 1, ''), '')
	FROM 
		#T A WITH(NOLOCK)
		INNER JOIN Custom_Order_Coupon AS COC WITH(NOLOCK) ON A.order_seq = COC.ORDER_SEQ
		INNER JOIN Coupon_Issue AS CI WITH(NOLOCK) ON COC.Coupon_Issue_Seq = CI.Coupon_Issue_Seq

	-- CouponSeq 처리
	UPDATE #T SET CouponSeq = Coupon_Default_COUPON_NAME WHERE CouponSeq = ''
	UPDATE #T SET CouponSeq = ISNULL((SELECT TOP 1 ISNULL(coupon_desc, CO_CouponSeq) AS COUPON_NAME FROM S4_COUPON WHERE COUPON_CODE = ISNULL(Coupon_Default_Coupon_Code, CO_CouponSeq )), '') WHERE CouponSeq = ''
 
	-- Addition_CouponSeq 처리
	UPDATE #T SET Addition_CouponSeq = Coupon_Dup_COUPON_NAME WHERE Addition_CouponSeq = ''
	UPDATE #T SET Addition_CouponSeq = ISNULL(( SELECT TOP 1 ISNULL(coupon_desc, CO_Addition_CouponSeq) AS COUPON_NAME FROM S4_COUPON WHERE COUPON_CODE = ISNULL(Coupon_Dup_Coupon_Code, CO_Addition_CouponSeq )), '') WHERE Addition_CouponSeq = ''

	-- Coupon_Ad 처리
	UPDATE #T SET Coupon_Ad = Coupon_AD_COUPON_NAME WHERE Coupon_Ad = ''
	UPDATE #T SET Coupon_Ad = ISNULL((SELECT TOP 1 ISNULL(coupon_desc, Coupon_AD_Coupon_Code) AS COUPON_NAME FROM S4_COUPON WHERE COUPON_CODE = Coupon_AD_Coupon_Code), '') WHERE Coupon_Ad = ''

	-- Coupon_Add 처리
	UPDATE #T SET Coupon_Add = Coupon_ADD_COUPON_NAME WHERE Coupon_Add = ''
	UPDATE #T SET Coupon_Add = ISNULL((SELECT TOP 1 ISNULL(coupon_desc, Coupon_ADD_Coupon_Code) AS COUPON_NAME FROM S4_COUPON WHERE COUPON_CODE = Coupon_ADD_Coupon_Code), '') WHERE Coupon_Add = ''

	-- 인덱스 삭제
	DROP INDEX IDX_TEMP_T1 ON #T
	DROP INDEX IDX_TEMP_T3 ON #T
	DROP INDEX IDX_TEMP_T4 ON #T
	DROP INDEX IDX_TEMP_T6 ON #T
	DROP INDEX IDX_TEMP_T7 ON #T

	-- 쿠폰 처리 끝
 END

 -- 임시로 만든 컬럼 삭제
 ALTER TABLE #T DROP COLUMN Coupon_Default_COUPON_NAME
 ALTER TABLE #T DROP COLUMN Coupon_Default_Coupon_Code
 ALTER TABLE #T DROP COLUMN CO_CouponSeq

 ALTER TABLE #T DROP COLUMN Coupon_Dup_COUPON_NAME
 ALTER TABLE #T DROP COLUMN Coupon_Dup_Coupon_Code
 ALTER TABLE #T DROP COLUMN CO_Addition_CouponSeq

 ALTER TABLE #T DROP COLUMN Coupon_AD_COUPON_NAME
 ALTER TABLE #T DROP COLUMN Coupon_AD_Coupon_Code

 ALTER TABLE #T DROP COLUMN Coupon_ADD_COUPON_NAME
 ALTER TABLE #T DROP COLUMN Coupon_ADD_Coupon_Code
  
    /* 집계 요약 데이터 생성 */  
 IF @P_List_Type = 'Aggregate'  
  BEGIN  
  
   /* 집계 요약 [주문건수, 주문금액, 결제금액, 카드수량] */   
   SELECT   
                        ISNULL(COUNT(Order_Seq), 0) AS Order_CNT  
        , ISNULL(SUM(CASE WHEN Order_Count > 0 THEN 1 ELSE 0 END), 0) AS Order_Card_Only_CNT  
        , ISNULL(SUM(CAST(ISNULL(Last_Total_Price, 0) AS BIGINT)), 0) AS Total_Price  
        , ISNULL(SUM(CAST(ISNULL(Settle_Price ,0) AS BIGINT)), 0) AS Settle_Price   
   FROM #T AS T WITH(NOLOCK) 
  
  
   /* 브랜드별 주문 및 카드 수량 */  
            SELECT  
                    A.*  
            FROM  
            (  
       SELECT   
                        1 AS Sort  
                    ,   (SELECT code_value FROM manage_code  WITH(NOLOCK) WHERE code_type = 'cardbrand' AND etc1 = SCV.Brand) AS Title  
        , COUNT(T.Order_Seq) AS ORD_CNT  
        , SUM(COI.Item_Count) AS Card_CNT  
     --,   SUM(T.Order_Count) AS Card_CNT  
        , 'C' AS Item_Type  
       FROM #T AS T WITH(NOLOCK)  
           INNER JOIN  Custom_Order_Item AS COI    WITH(NOLOCK)
                        ON T.Order_Seq = COI.Order_Seq  
           INNER JOIN S2_CardView AS SCV    WITH(NOLOCK)
                        ON COI.Card_Seq = SCV.Card_Seq  
       WHERE 1 = 1  
           AND  COI.Item_Type = 'C'  
           AND  COI.Item_Count > 0  
       GROUP BY   
                        SCV.Brand   
      
       UNION ALL   
  
       SELECT  
                        2 AS Sort  
        , CASE   
          WHEN COI.Item_Type = 'E' THEN '봉투'  
          WHEN COI.Item_Type = 'I' THEN '내지'  
          WHEN COI.Item_Type = 'F' THEN '식권'  
          WHEN COI.Item_Type = 'M' THEN '미니청첩장'  
          WHEN COI.Item_Type = 'L' THEN '스크랩북'  
          ELSE ''  
         END AS Title  
        , COUNT(T.Order_Seq) AS ORD_CNT  
     --,   SUM(T.Order_Count) AS Card_CNT  
        , SUM(COI.Item_Count) AS Card_CNT  
        , COI.Item_Type  
       FROM #T AS T WITH(NOLOCK)  
           INNER JOIN Custom_Order_Item AS COI  WITH(NOLOCK)  
                        ON T.Order_Seq = COI.Order_Seq  
           INNER JOIN S2_CardView AS SCV    WITH(NOLOCK)
                        ON COI.Card_Seq = SCV.Card_Seq  
       WHERE 1 = 1  
           AND  COI.Item_Type IN ('E', 'I', 'F', 'M' ,'L')   
           AND     COI.Item_Count > 0  
       GROUP BY   
                        COI.Item_Type   
            ) AS A   
   ORDER BY   
                    A.Sort ASC  
                ,   A.Card_CNT DESC  
  
     
            /* 브랜드별 카드별 주문 및 카드 수량 */  
   SELECT  
                 SCV.Brand  
    , SCV.Card_Code  
    , Count(T.Order_Seq) AS ORD_CNT  
    , SUM(COI.Item_Count) AS Card_CNT  
   FROM #T AS T WITH(NOLOCK)  
       INNER JOIN Custom_Order_Item AS COI    WITH(NOLOCK)
                    ON T.Order_Seq = COI.Order_Seq  
       INNER JOIN S2_CardView AS SCV    WITH(NOLOCK)
                    ON COI.Card_Seq = SCV.Card_Seq  
   WHERE 1 = 1  
  AND  COI.Item_Type = 'C'  
       AND  COI.Item_Count > 0  
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
   FROM #T AS T WITH(NOLOCK)  
  
  END  
  
   
    /* 리스트 출력 */  
 ELSE IF @P_List_Type = 'List'  
  BEGIN  
     
   SELECT   
	*  
    , ISNULL(EII.ERP_ItemStatus, '') AS ERP_ItemStatus
	, B.IP
   FROM #T AS T WITH(NOLOCK)  
       LEFT OUTER JOIN [ERPDB.BhandsCard.Com].XERP.dbo.C_ERPItemInfo AS EII WITH(NOLOCK)  
                    ON T.ERP_Code = EII.ERP_ItemCode  
		LEFT OUTER JOIN (
			SELECT UID, IP FROM
			(
				SELECT 
					ROW_NUMBER() OVER(PARTITION BY UID ORDER BY SEQ ASC) AS RowNum, UID, IP 
				FROM 
					S4_LoginIpInfo L WITH(NOLOCK) INNER JOIN #T L2 WITH(NOLOCK) ON L.UID = L2.Member_ID
				WHERE L.IP IS NOT NULL
			) A 
			WHERE A.RowNum = 1
		) AS B ON T.Member_ID = B.UID
  
  END  
  
 /* 리스트 엑셀 출력 */  
 ELSE IF @P_List_Type = 'List_Excel'  
  BEGIN  
  
    
   --디얼디어 카드 표준가격이 0일경우 바른디자인ERP에서 소비자가격 업데이트. 강은지요청 20200422  
   UPDATE #T  
   SET card_price = ISNULL(P.C_sobi, 0)  
   FROM #T A WITH(NOLOCK)  
   JOIN [ERPDB.BhandsCard.Com].BHC.dbo.ItemSiteMaster AS P WITH(NOLOCK) ON P.SiteCode = 'BHC2' AND A.ERP_Code = P.ItemCode  
   WHERE ISNULL(A.card_price, 0) = 0 AND A.sales_Gubun = 'SD'  
  

    SELECT  CWO.Member_ID,   COUNT(CWO.ORDER_SEQ) AS WOrd_CNT  
     , STUFF  
     (  
      (  
       SELECT   
         '|' +   
         CWO_SUB.Sales_Gubun   
       FROM #Custom_Order_year AS CWO_SUB  
       WHERE CWO_SUB.Status_Seq = 15  
        AND  CWO_SUB.Member_ID = CWO.Member_ID  
        AND  CWO_SUB.SRC_SEND_DATE between dateadd(mm,-6,@P_Search_Start_Date) and  dateadd(dd,-1,@P_Search_Start_Date)
		AND  CWO_SUB.ORDER_TYPE in ('1','6','7')
		AND  CWO_SUB.UP_ORDER_SEQ is null and pay_type <> '4'
       FOR XML PATH('')  
      ) , 1, 1, ''  
     ) AS WOrd_Sales_Gubun
	INTO #Custom_WOrder  	 
    FROM #Custom_Order_year AS CWO   WITH(NOLOCK)
  JOIN #T AS T_SUB WITH(NOLOCK) ON CWO.Member_ID = T_SUB.Member_ID  
   WHERE CWO.Status_Seq = 15  
    AND  ISNULL(LTRIM(RTRIM(CWO.Member_ID)), '') <> ''        
    AND  CWO.SRC_SEND_DATE  between dateadd(mm,-6,@P_Search_Start_Date) and  dateadd(dd,-1,@P_Search_Start_Date)
		AND  CWO.ORDER_TYPE in ('1','6','7')
		AND  CWO.UP_ORDER_SEQ is null and pay_type <> '4'
  GROUP BY CWO.Member_ID
  
    SELECT  CSO.Member_ID,   MAX(CSO.Request_Date) AS Request_Date  
     , STUFF  
     (  
      (  
       SELECT   
         '|' +   
         CASE   
          WHEN ISNULL(CSO_SUB.JOIN_Division, 'WEB') = 'Mobile' THEN 'Mobile'   
          WHEN ISNULL(CSO_SUB.JOIN_Division, 'WEB') = 'Web' THEN 'PC'   
          ELSE ' '   
         END   
       FROM Custom_Sample_Order AS CSO_SUB   WITH(NOLOCK)
       WHERE 1 = 1  
        AND  CSO_SUB.Status_Seq = 12  
        AND  CSO_SUB.Member_ID IS NOT NULL  
        AND  CSO_SUB.Member_ID <> ''  
        AND  CSO_SUB.Member_ID = CSO.Member_ID  
        AND  CSO_SUB.Request_Date >= MIN(CSO.Request_Date)  
       FOR XML PATH('')  
      ) , 1, 1, ''  
     ) AS Inflow_Route_Sample  
    , STUFF  
     (  
      (  
       SELECT   
         '|' +   
         CSO_SUB.Sales_Gubun   
       FROM Custom_Sample_Order AS CSO_SUB   WITH(NOLOCK)
       WHERE 1 = 1  
        AND  CSO_SUB.Status_Seq = 12  
        AND  CSO_SUB.Member_ID IS NOT NULL  
        AND  CSO_SUB.Member_ID <> ''  
        AND  CSO_SUB.Member_ID = CSO.Member_ID  
        AND  CSO_SUB.Request_Date >= MIN(CSO.Request_Date)  
       FOR XML PATH('')  
      ) , 1, 1, ''  
     ) AS Sample_Sales_Gubun  
   INTO #Custom_Sample_Order  
   FROM Custom_Sample_Order AS CSO   WITH(NOLOCK)
   JOIN #T AS T_SUB WITH(NOLOCK) ON CSO.Member_ID = T_SUB.Member_ID  
   WHERE 1 = 1  
    AND  CSO.Status_Seq = 12  
    AND  ISNULL(LTRIM(RTRIM(CSO.Member_ID)), '') <> ''        
    AND  CSO.Request_Date >= DATEADD(YEAR, -1, T_SUB.Order_Date)  
   GROUP BY CSO.Member_ID  
  
/* 비회원 샘플 주문 조회용 데이터 */
/*
select
	member_email, 
	member_hphone,
	SALES_GUBUN,
	case 
		when lower(join_division) = 'mobile' then 'Mobile'
		when lower(join_division) = 'web' then 'PC'
		else NULL
	End join_division,
	request_date
INTO #SMP
from custom_sample_order with(nolock)
where status_seq = 12
-- and isnull(member_id, '') = ''
and sales_gubun in ('SB', 'SS', 'SD', 'B')
 */

select distinct
	member_email, 
	member_hphone,
	SALES_GUBUN,
	case 
		when lower(join_division) = 'mobile' then 'Mobile'
		when lower(join_division) = 'web' then 'PC'
		else NULL
	End join_division,
	request_date
	INTO #SMP
from custom_sample_order with(nolock)
where status_seq = 12
and ((isnull(member_id, '') = '' and sales_gubun in ('SB', 'SS', 'B')) or sales_gubun = 'SD')

 

     
   SELECT DISTINCT  
     T.*  
    , ISNULL(VUI.Member_Age, '') AS Member_Age  
    , COW.Wedd_Date  
    , COW.Wedd_Name  
      
    , CASE   
      WHEN LTRIM(ISNULL(COW.Wedd_Addr, '')) <> '' THEN LTRIM(RTRIM(COW.Wedd_Addr))   
      ELSE LTRIM(RTRIM(ISNULL(COW.wedd_road_Addr, '')))   
      END  AS Wedd_Addr  --, COW.Wedd_Addr  
    , VUI.Referer_Sales_Gubun  
	, CASE  
        WHEN VUI.Inflow_Route IN ('web', 'PC') THEN 'PC'   
        WHEN VUI.Inflow_Route = 'Mobile' THEN 'Mobile'  
        ELSE ''  
		END AS Inflow_Route_SignUp  
      
    , CASE WHEN ISNULL(CSO.Member_ID, 'N') = 'N' THEN 'N' ELSE 'Y' END AS R_Sample_Order_YN  
    , CASE WHEN ISNULL(SB.Member_ID, 'N') = 'N' THEN 'N' ELSE 'Y' END AS SampleBook_Order_YN      
     
    , CSO.Request_Date AS R_Sample_Request_Date  
    , CSO.Sample_Sales_Gubun  R_Sample_Sales_Gubun
    , CSO.Inflow_Route_Sample R_Inflow_Route_Sample
    , SB.Inflow_Route_SampleBook  
    , CASE   
        WHEN MI.CompletedTime IS NOT NULL THEN 'Y'   
        ELSE 'N'   
        END AS New_Mobile_Invitaion_YN  
    , CASE   
		WHEN MI.CompletedTime IS NOT NULL THEN MI.CompletedTime   
		ELSE NULL   
		END AS New_Mobile_Invitaion_Date  
	,   (CASE WHEN MS.UID IS NOT NULL AND MA.UID IS NULL THEN 'O' ELSE 'X' END) AS Sign_Marketing_Agree  
	,   (CASE WHEN MS.UID IS NOT NULL AND MA.UID IS NOT NULL THEN 'O' ELSE 'X' END) AS Order_Marketing_Agree  
    , ISNULL(EII.ERP_ItemStatus, '') AS ERP_ItemStatus  
     -- sql 수정  
    ,   STUFF(( SELECT '|' + SCKI.CardKind FROM S2_CardKindInfo SCKI WHERE SCKI.CardKind_Seq IN ( SELECT ISNULL(SCKIND.CardKind_Seq,0) FROM S2_CardKind SCKIND WHERE SCKIND.Card_Seq = SCV.Card_Seq) FOR XML PATH('')),1,1,'')  AS Card_Kind  
    ,   (SELECT IP FROM S4_LoginIpInfo WHERE seq = (SELECT MIN(seq) FROM S4_LoginIpInfo WHERE uid = T.Member_ID AND IP is not null)) AS IP  
    , ISNULL(T.ZIPCode, '') AS R_ZIPCode  
    , ISNULL(T.addr, '') AS R_addr  
    , ISNULL(T.Addr_Detail, '') AS R_Addr_Detail  
    , CASE WHEN T.PrintMethod <> '0' THEN 'Y' ELSE 'X' END AS R_PrintMethod  
    , CASE WHEN  T.isLaser <> '0' THEN 'Y' ELSE 'X' END AS R_isLaser  
    --, '' AS Card_Kind  
    , CASE WHEN (ISNULL(E.ORDER_SEQ,'') <> '' OR T.CouponSeq_CRN IN ('BSMSUPPORT50R','BSMSUPPORT50R2','BSMSUPPORT25R','BSMSUPPORT50RN')) THEN 'Y' ELSE 'N' END crnc_flag   
    , CWO.WOrd_CNT,CWO.WOrd_Sales_Gubun  
	INTO #R

   FROM #T AS T WITH(NOLOCK) 
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
				, UID  
				, ISNULL(Referer_Sales_Gubun, 'SB') AS Referer_Sales_Gubun  
                        ,   MAX(inflow_route) AS inflow_route  
            FROM vw_User_Info   WITH(NOLOCK) -- INNER JOIN #T ON vw_User_Info.uid = #T.Member_ID AND vw_User_Info.umail <> '@'
			WHERE vw_User_Info.umail <> '@'
            GROUP BY UID  , Referer_Sales_Gubun  
			) AS VUI ON T.Member_ID = VUI.UID  
        LEFT OUTER JOIN Custom_Order_WeddInfo AS COW  WITH(NOLOCK) ON T.Order_Seq = COW.Order_Seq  
        LEFT OUTER JOIN #Custom_Sample_Order AS CSO  ON CSO.Member_ID = T.Member_ID  
		LEFT OUTER JOIN #Custom_WOrder AS CWO  ON CWO.Member_ID = T.Member_ID  
        INNER JOIN S2_CardView AS SCV  WITH(NOLOCK) ON T.Card_Seq = SCV.Card_Seq  
		  LEFT OUTER JOIN  
		   (  
				SELECT   
				A.[USER_ID]  
				--, MAX(SITECODE) AS SITECODE  
				, MAX(A.REGIST_DATETIME) AS COMPLETEDTIME  
				FROM  BARUNSON.DBO.TB_ORDER A WITH(NOLOCK) INNER JOIN 
					  BARUNSON.DBO.TB_ORDER_PRODUCT B WITH(NOLOCK) ON A.ORDER_ID = B.ORDER_ID INNER JOIN 
					  BARUNSON.DBO.TB_PRODUCT C WITH(NOLOCK) ON B.PRODUCT_ID = C.PRODUCT_ID
					  INNER JOIN #T WITH(NOLOCK) ON A.[USER_ID] = #T.Member_ID
				WHERE A.PAYMENT_STATUS_CODE = 'PSC02' 
				GROUP BY A.[USER_ID]    
			) AS MI ON T.MEMBER_ID = MI.[USER_ID]-- AND T.SALES_GUBUN = MI.SITECODE
	  --  LEFT OUTER JOIN  
		 --  (  
			--	SELECT   
			--	OrderSeq  
			--	, MAX(SiteCode) AS SiteCode  
			--	, MAX(CompletedTime) AS CompletedTime  
			--	FROM MCard_Invitation  
			--	WHERE DeleteYN = 'N'  OR  (DeleteYN = 'Y' AND ExpireYN = 'Y')  
			--	GROUP BY OrderSeq  
			--) AS MI ON T.Order_Seq = MI.OrderSeq AND T.Sales_Gubun = MI.SiteCode  
		LEFT OUTER JOIN ( SELECT uid FROM S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT  WITH(NOLOCK) INNER JOIN #T WITH(NOLOCK) ON S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT.UID = #T.Member_ID GROUP BY uid ) AS MS ON T.Member_ID = MS.UID  
		LEFT OUTER JOIN ( SELECT uid FROM EVENT_MARKETING_AGREEMENT  WITH(NOLOCK) INNER JOIN #T WITH(NOLOCK) ON EVENT_MARKETING_AGREEMENT.UID = #T.Member_ID GROUP BY uid ) AS MA ON T.Member_ID = MA.UID  
        LEFT OUTER JOIN [ERPDB.BhandsCard.Com].XERP.dbo.C_ERPItemInfo AS EII  WITH(NOLOCK) ON T.ERP_Code = EII.ERP_ItemCode  
		LEFT OUTER JOIN  
            (  
				SELECT custom_etc_order.member_id  
					, /*CASE WHEN pg_shopid in ( 'bhands_c', 'pbhands') THEN 'PC' WHEN pg_shopid IN ('bhands_cm', 'pbhands_m') THEN 'Mobile' ELSE '' END AS Inflow_Route_SampleBook  */
					'' Inflow_Route_SampleBook
				FROM custom_etc_order WITH(NOLOCK) INNER JOIN #T WITH(NOLOCK) ON custom_etc_order.member_id = #T.Member_ID
				WHERE custom_etc_order.order_type = 'U' AND custom_etc_order.status_seq > 0  
                    GROUP BY custom_etc_order.member_id, pg_shopid  
            ) AS SB ON T.Member_ID = SB.member_id  
		LEFT JOIN  
			(  
				 SELECT A.ORDER_SEQ FROM   
				 CUSTOM_ORDER_COUPON A WITH(NOLOCK) 
				 INNER JOIN COUPON_ISSUE B  WITH(NOLOCK) ON A.COUPON_ISSUE_SEQ = B.COUPON_ISSUE_SEQ  
				 INNER JOIN COUPON_DETAIL C  WITH(NOLOCK) ON B.COUPON_DETAIL_SEQ = C.COUPON_DETAIL_SEQ
				 INNER JOIN #T WITH(NOLOCK) ON A.ORDER_SEQ = #T.order_seq
				 where C.COUPON_CODE IN   
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
				 ) group by A.ORDER_SEQ
			) AS E ON T.ORDER_SEQ = E.ORDER_SEQ  
			

		select 
			R.*
			,case when Member_ID = '비회원' THEN (CASE WHEN SR.MEMBER_HPHONE is null THEN 'N' else 'Y'END)  ELSE R_Sample_Order_YN END Sample_Order_YN
			,case when Member_ID = '비회원' THEN SR.request_date  ELSE R_Sample_Request_Date END Sample_Request_Date
			,case when Member_ID = '비회원' THEN stuff( (select '|'+SALES_GUBUN from #SMP where MEMBER_HPHONE = R.order_HPHONE	FOR XML PATH('')), 1 ,1, '')  ELSE R_Sample_Sales_Gubun END Sample_Sales_Gubun
			,case when Member_ID = '비회원' THEN SR.join_division ELSE R_Inflow_Route_Sample END Inflow_Route_Sample
			,R.R_ZIPCode as zipcode
			,R.R_addr as addr
			,R_Addr_Detail as addr_detail
			,R.R_isLaser as islaser
			,R.R_PrintMethod printmethod
		from #R AS R with (nolock)
			left join (
				select member_hphone,
					max(request_date) request_date,
					max(join_division) join_division
				from #SMP with (nolock)
				group by member_hphone			
			) SR
				ON R.order_hphone = SR.MEMBER_HPHONE

		ORDER BY R.Order_Date DESC   
  END  
  
END 


