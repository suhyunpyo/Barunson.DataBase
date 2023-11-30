IF OBJECT_ID (N'dbo.V_OrderGroupDetailList', N'V') IS NOT NULL DROP View dbo.V_OrderGroupDetailList
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_OrderGroupDetailList]
AS
SELECT A.order_g_seq AS GSeq, A.Company_Seq AS CompanySeq, A.order_seq AS OrderSeq, A.pay_type AS PayType, 
       A.status_seq AS StatusSeq, ISNULL(A.settle_price,0) AS SettlePrice, A.order_date AS OrderDate, A.member_id AS MemberID, 
       A.order_name AS OrderName, A.order_email AS Email, A.order_phone AS Phone, A.order_hphone AS Hp, 
       A.settle_method AS Method, A.settle_status AS status, A.settle_date AS payDate, 
	   A.order_price AS orderPrice, A.order_total_price AS totalPrice, A.delivery_price AS deliveryPrice,
	   A.Pg_ResultInfo AS bankInfo, A.Pg_ResultInfo2 AS depositor,
	   B.NAME AS deliveryName, B.DELIVERY_DATE AS deliveryDate, B.DELIVERY_CODE_NUM AS deliveryNo, B.DELIVERY_METHOD AS deliveryMethod,
	   B.phone AS deliveryPhone, B.hphone AS deliveryHp, B.zip AS deliveryZip, B.addr AS deliveryAddr, B.addr_detail AS deliveryAddrDetail, 
	   B.nt_code AS deliveryCountry, A.Card_Seq AS CardSeq, A.Order_Count AS OrderCnt, 
	   A.couponSeq, A.reduce_price AS couponPrice, 'O' AS guBun,
	   (SELECT TOP 1 C.Subject +','+ RTRIM(CAST(C.Amt AS CHAR(6))) + (CASE RTRIM(C.amtGb) WHEN 'per' THEN '%' ELSE '원' END) FROM tCouponMst C JOIN tCouponSub CS ON C.CouponCD=CS.CouponCD WHERE CS.CouponNum=A.CouponSeq) AS couponTitle
FROM   Custom_Order A WITH (nolock) LEFT JOIN DELIVERY_INFO B WITH (nolock) ON B.order_seq=A.order_seq
UNION ALL
SELECT A.order_g_seq AS GSeq, A.Company_Seq AS CompanySeq, A.order_seq AS OrderSeq, '' AS PayType, 
       A.status_seq AS StatusSeq, ISNULL(A.settle_price,0) AS SettlePrice, A.order_date AS OrderDate, A.member_id AS MemberID, 
       A.order_name AS OrderName, A.order_email AS Email, A.order_phone AS Phone, A.order_hphone AS Hp, 
       A.settle_method AS Method, 0 AS status, A.settle_date AS payDate, 
	   0 AS orderPrice, 0 AS totalPrice, A.delivery_price AS deliveryPrice,
	   A.Pg_ResultInfo AS bankInfo, A.Pg_ResultInfo2 AS depositor,
	   B.NAME AS deliveryName, B.DELIVERY_DATE AS deliveryDate, B.DELIVERY_CODE_NUM AS deliveryNo, B.DELIVERY_METHOD AS deliveryMethod,
	   B.phone AS deliveryPhone, B.hphone AS deliveryHp, B.zip AS deliveryZip, B.addr AS deliveryAddr, B.addr_detail AS deliveryAddrDetail, 
	   B.nt_code AS deliveryCountry, '' AS CardSeq, '' AS OrderCnt, A.couponseq,
	   A.coupon_price AS couponPrice, 'E' AS guBun,
	   (SELECT TOP 1 C.Subject +','+ RTRIM(CAST(C.Amt AS CHAR(6))) + (CASE RTRIM(C.amtGb) WHEN 'per' THEN '%' ELSE '원' END) FROM tCouponMst C JOIN tCouponSub CS ON C.CouponCD=CS.CouponCD WHERE CS.CouponNum=A.CouponSeq) AS couponTitle
FROM   Custom_etc_Order A WITH (nolock) LEFT JOIN DELIVERY_INFO B WITH (nolock) ON B.order_seq=A.order_seq
GO
