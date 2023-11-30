IF OBJECT_ID (N'dbo.sp_ERP_Transfer_Daeri_New', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ERP_Transfer_Daeri_New
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ##########################################################################################################      
-- 대리점 매출연동
-- ########################################################################################################## 
-- EXEC sp_ERP_Transfer_Daeri_New '20130604','20130604'
 

CREATE procedure [dbo].[sp_ERP_Transfer_Daeri_New]
 @SDate as char(8),
 @EDate as char(8)
as

set nocount on


--drop table #CompanyMaster
--drop table #CardMaster
--drop table #BillHeader
--drop table #BillItem


--DECLARE  @SDate as char(8), @EDate as char(8)
--SELECT @SDate = '20100319',  @EDate = '20100319'



--카드정보
SELECT Convert(VARCHAR, Card_Seq) AS Card_seq, Card_Code, CASE WHEN RTRIM(LTRIM(ISNULL(ERP_Code, ''))) = '' THEN Card_Code ELSE ERP_Code END  AS Card_ERPCode
	, Cont_Seq, Acc_Seq, Acc_seq2
INTO #CardMaster
FROM Card A
WHERE  ISNULL(A.CARD_CATE, '') <> 'SL' --사은품 제거
Union ALL
SELECT Convert(VARCHAR, A.Card_Seq) AS Card_seq, A.Card_Code, CASE WHEN RTRIM(LTRIM(ISNULL(A.Card_ERPCode, ''))) = '' THEN A.Card_Code ELSE A.Card_ERPCode END  AS Card_ERPCode 
	, ISNULL(B.Inpaper_seq, 0) AS Cont_Seq, ISNULL(B.Acc1_seq, 0) AS Acc_Seq, ISNULL(B.Acc2_seq, 0) AS Acc_seq2
FROM S2_Card A
LEFT JOIN S2_CardDetail B ON A.Card_Seq = B.Card_Seq
WHERE  ISNULL(A.Card_Div, '') <> 'C05' --사은품 제거




SELECT A.*
INTO #custom_order
FROM custom_order A
WHERE A.status_Seq = 15  -- 배송완료
	and convert(char(8), A.src_send_date, 112) BETWEEN @SDate AND @EDate
	and A.sales_gubun  ='Q'

--UNION ALL
--SELECT A.*
--FROM custom_order A
--JOIN company B ON A.company_seq = B.Company_seq
--WHERE A.status_Seq = 15  -- 배송완료
--	and convert(char(8), A.src_send_date, 112) BETWEEN @SDate AND @EDate
--	and A.sales_gubun  ='SG' AND  B.ERP_code = '2012563'

	


--서비스품목 쿼리
SELECT order_seq, '수수료' AS ItemName, option_price AS ServicePrice INTO #OrderItemPrice FROM #custom_order WHERE sales_gubun = 'Q' --서비스금액
UNION ALL SELECT order_seq, 'EMBO' AS ItemName, embo_price FROM #custom_order WHERE sales_gubun = 'Q' --엠보금액
UNION ALL SELECT order_seq, 'TBB' AS ItemName, delivery_price FROM #custom_order WHERE sales_gubun = 'Q' --배송비
UNION ALL SELECT order_seq, 'JAEBON' AS ItemName, jebon_price FROM #custom_order WHERE sales_gubun = 'Q' --제본비
UNION ALL SELECT order_seq, 'SASIK' AS ItemName, sasik_price FROM #custom_order WHERE sales_gubun = 'Q' --사식비
UNION ALL SELECT order_seq, 'COLPRTCHG' AS ItemName, print_price AS print_price FROM #custom_order --인쇄비

--UNION ALL SELECT order_seq, 'COLPRTCHG' AS ItemName, CASE WHEN sales_gubun  = 'SG' THEN order_count * 60 ELSE print_price END AS print_price FROM #custom_order --인쇄비


--UNION ALL SELECT order_seq, 'OPTION' AS ItemName, mini_price FROM #custom_order --미니청첩장
--UNION ALL SELECT order_seq, 'OPTION' AS ItemName, fticket_price FROM #custom_order --식권


	


--부모 거래처를 가지고 ERP와 연동한다.
SELECT A.Company_seq 
	, A.ParentCompany
	, B.ERP_Code
INTO #CompanyMaster
FROM ( 
		SELECT B.Company_seq
			, CASE WHEN B.company_upper_seq = 0 THEN B.Company_seq ELSE B.company_upper_seq END AS ParentCompany
		FROM company B
		WHERE sales_gubun  IN ( 'Q', 'SG' )
	) A
JOIN Company B ON A.ParentCompany = B.Company_Seq




--Header 데이터
SELECT 'BK10' AS SiteCode
		, 'SO' AS InoutGubun
		, Convert(char(8), A.src_send_date,112) AS BillDate
		, '270' AS SysCase
		, '270' AS CaseCode
		, B.ERP_code AS CsCode	
		, '10' AS TaxCode
		, 0 AS BillAmnt
		, 0 AS VatAmnt
		, 0 AS MoneySumAmnt
		--, CASE WHEN B.ERP_code in ('1115740') THEN '365' ELSE '300' END AS DeptCode		--B.ERP_PartCode  , '300' AS DeptCode --300 대리점영업팀으로 수정함   --이전쿼리, CASE WHEN E.itemGroup in ('G2000','P1100') THEN '830' ELSE '350' END AS DeptCode
		--, CASE WHEN B.ERP_code in ('1115740') THEN '020803' ELSE '040401' END AS EmpCode	--B.ERP_StaffCode, '040401' AS EmpCode --'040401' 김용재로 수정함   --이전쿼리, CASE WHEN E.itemGroup in ('G2000','P1100') THEN '980404' ELSE '040401' END AS EmpCode
		--, '109' AS CcCode --CASE WHEN B.ERP_code in ('1115740') THEN B.ERP_CostCode ELSE '109' END 	--, '109' AS CcCode --, CASE WHEN E.itemGroup in ('G2000','P1100') Then '138' ELSE '113' END AS CcCode
				
		--, CASE WHEN A.sales_gubun  = 'SG' AND B.ERP_code in ('2012563') THEN '400' ELSE CASE WHEN B.ERP_code in ('1115740') THEN '365' ELSE '300' END END AS DeptCode
		--, CASE WHEN A.sales_gubun  = 'SG' AND B.ERP_code in ('2012563') THEN '110301' ELSE CASE WHEN B.ERP_code in ('1115740') THEN '020803' ELSE '040401' END  END AS EmpCode
		--, CASE WHEN A.sales_gubun  = 'SG' AND B.ERP_code in ('2012563')  THEN '109' ELSE CASE WHEN B.ERP_code in ('1115740') THEN '109' ELSE '109' END END AS CcCode
			
		, CASE WHEN ISNULL(RTRIM(B.ERP_PartCode), '') = '' THEN '300' ELSE ISNULL(RTRIM(B.ERP_PartCode), '') END AS DeptCode
		, CASE WHEN ISNULL(RTRIM(B.ERP_StaffCode), '') = '' THEN '040401' ELSE ISNULL(RTRIM(B.ERP_StaffCode), '') END AS EmpCode
		, CASE WHEN ISNULL(RTRIM(B.ERP_CostCode), '') = '' THEN '109' ELSE ISNULL(RTRIM(B.ERP_CostCode), '') END AS CcCode
		, '110' AS PcCode		

		, a.pg_tid AS JumunNo
		, null AS JumunNo1
		, a.pg_tid AS JumunNo2
		, null AS JumunNo3	
		, A.Order_Seq
		, A.Card_seq		
INTO #BillHeader
FROM #custom_order A
JOIN company B ON A.company_seq = B.Company_seq
JOIN #CompanyMaster C ON B.Company_Seq = C.Company_Seq
JOIN #CardMaster D ON A.card_seq = D.card_seq
--LEFT JOIN  [erpdb.bhandscard.com].XERP.DBO.ItemSiteMaster E ON E.SiteCode = 'BK10' AND D.Card_ERPCode = E.ItemCode
WHERE Convert(char(8),a.src_send_date,112) BETWEEN @SDate AND @EDate
	and status_seq = 15
	and ISNULL(a.pay_type, '') <> '4' 
ORDER BY a.order_seq 



--drop table #BillItem

--Item 데이터
SELECT 'BK10' AS SiteCode
	, 'SO' AS InoutGubun
	, IDENTITY(int, 1, 1) AS SerNo
	, A.JumunNo
	, 0 AS ItemSerNo
	, 'MF03' AS WhCode
	, A.BillDate
	, ISNULL(E.ItemCode, B.Card_seq) AS ItemCode
	, B.item_count AS ItemQty
	, CASE WHEN F.C_Price_Choice = 'sb' THEN ISNULL(E.C_sobi, B.ServicePrice)
			WHEN F.C_Price_Choice = 'ch' THEN ISNULL(E.C_chool, B.ServicePrice)
			WHEN F.C_Price_Choice = 'dr' THEN ISNULL(E.C_daeri, B.ServicePrice)
			WHEN F.C_Price_Choice = 'dr2' THEN ISNULL(E.C_daeri2, B.ServicePrice)
			WHEN F.C_Price_Choice = 'dr3' THEN ISNULL(E.C_daeri3, B.ServicePrice)
			WHEN F.C_Price_Choice = 'dr4' THEN ISNULL(E.C_daeri4, B.ServicePrice)
			WHEN F.C_Price_Choice = 'gl1' THEN ISNULL(B.ServicePrice, B.ServicePrice)
			--WHEN F.C_Price_Choice = 'gl1' THEN ISNULL(E.C_GlobalPrice1, B.ServicePrice)
			
		ELSE ISNULL(E.C_daeri, B.ServicePrice) END AS ItemPrice
	, 0 AS ItemAmnt
	, 0 AS ItemVatAmnt
	, 0 AS ItemSumAmnt
	, NULL AS BillNo		
	, getdate() AS RegDate
	, 0 AS FeeAmnt
	, 'Item' AS ItemGubun
	, 'N' AS PGCheck
	, 0 AS PayAmnt
	, 'N' AS SampleCheck
	, 'N' AS XartCheck
	, 'DE' AS DeptGubun
INTO #BillItem
FROM #BillHeader A
JOIN (	
		SELECT Order_seq,  convert(varchar, card_seq) AS Card_seq, item_count, 0 AS ServicePrice FROM custom_order_item WHERE Order_seq IN ( SELECT Order_seq FROM #custom_order )
		UNION ALL
		SELECT Order_seq, ItemName, 1,ServicePrice  FROM #OrderItemPrice  WHERE ServicePrice <> 0 
) B ON  A.order_seq = B.order_seq
LEFT JOIN #CardMaster D ON B.card_seq = D.card_seq
LEFT JOIN  [erpdb.bhandscard.com].XERP.DBO.ItemSiteMaster E ON E.SiteCode = 'BK10' AND D.Card_ERPCode = E.ItemCode
LEFT JOIN  [erpdb.bhandscard.com].XERP.DBO.CsMaster F ON F.ComCode = 'BK01' AND A.CsCode = F.CsCode
--WHERE B.Order_seq = '996707'
ORDER BY A.Order_Seq, D.Card_Code




--Item 금액 업데이트
UPDATE #BillItem
SET ItemAmnt = ROUND( (ItemQty * ItemPrice)/1.1, 0)
	, ItemVatAmnt = (ItemQty * ItemPrice)-ROUND( (ItemQty * ItemPrice)/1.1, 0)
	, ItemSumAmnt = ItemQty * ItemPrice



--헤더 금액 update (아이템 금액의 합계로 Update)
UPDATE #BillHeader 
SET BillAmnt = B.ItemAmnt
	, VatAmnt = b.ItemVatAmnt
	, MoneySumAmnt = b.ItemSumAmnt
FROM #BillHeader A 
JOIN (	SELECT JumunNo, sum(ItemAmnt) as ItemAmnt, sum(ItemVatAmnt) as ItemVatAmnt, sum(ItemSumAmnt) as ItemSumAmnt 
		FROM #BillItem GROUP BY JumunNo 
	) B ON A.JumunNo = B.JumunNo



--Item 주문번호 그룹별 시리얼번호 업데이트
UPDATE #BillItem 
SET ItemSerNo = B.GroupItemSerNo
FROM #BillItem A
JOIN ( 
		SELECT A.SiteCode, A.JumunNo, A.SerNo
			, (A.SerNo-B.SerNo)+1 AS GroupItemSerNo
		FROM #BillItem A
		JOIN ( 
				SELECT SiteCode, JumunNo, Min(SerNo) AS SerNo
				from #BillItem A
				GROUP BY SiteCode, JumunNo
		) B ON A.Sitecode = B.SiteCode AND A.JumunNo = B.JumunNo 

) B ON A.Sitecode = B.SiteCode AND A.JumunNo = B.JumunNo AND A.SerNo = B.SerNo


--BH4021_I 내지는 수량이 반만 출고가 되도록 진행 (정광수차장 요청) 20141230
UPDATE #BillItem
SET ItemQty = CEILING(ISNULL(ItemQty, 0)/2.0)
WHERE ItemCode = 'BH4021_I' AND ISNULL(ItemQty, 0) > 0





--ERP Server로 Insert 연동.
INSERT INTO  [erpdb.bhandscard.com].XERP.DBO.Erp_salesData 
( h_biz, h_gubun, h_date, h_sysCode, h_usrCode
	, h_comcode, h_taxType, h_offerPrice, h_superTax, h_sumPrice
	, h_partCode, h_staffcode, h_sonik, h_cost, h_orderid, h_memo1, h_memo2, h_memo3
	
	, b_biz, b_goodGubun, b_seq, b_storeCode, b_date
	, b_goodCode, b_goodUnit
	, b_OrderNum, b_unitPrice, b_offerPrice, b_superTax, b_sumPrice
	, b_memo, FeeAmnt, ItemGubun, PGCheck
	, PayAmnt, SampleCheck, XartCheck, DeptGubun )

SELECT A.SiteCode, A.InoutGubun, A.BillDate, A.SysCase, A.CaseCode
	, A.CsCode, A.TaxCode, A.BillAmnt, A.VatAmnt, A.MoneySumAmnt
	, A.DeptCode, A.EmpCode, A.PcCode, A.CcCode
	, A.JumunNo, A.JumunNo1, A.JumunNo2, A.JumunNo3
	
	, B.SiteCode, B.InoutGubun, B.ItemSerNo, B.WhCode, B.BillDate
	, B.ItemCode, 'EA' AS ItemUnit
	, B.ItemQty, B.ItemPrice, B.ItemAmnt, B.ItemVatAmnt, B.ItemSumAmnt
	, B.BillNo, B.FeeAmnt, B.ItemGubun, B.PGCheck
	, B.PayAmnt, B.SampleCheck, B.XartCheck, B.DeptGubun
FROM #BillHeader A
JOIN #BillItem B ON A.SiteCode = B.SiteCode AND A.JumunNo = B.JumunNo
LEFT JOIN [erpdb.bhandscard.com].XERP.DBO.ERP_SalesData C ON A.JumunNo = C.h_orderid
WHERE C.h_orderid IS NULL



GO
