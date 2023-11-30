IF OBJECT_ID (N'dbo.V_OrderGroupList', N'V') IS NOT NULL DROP View dbo.V_OrderGroupList
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_OrderGroupList]
AS
SELECT A.Company_Seq AS CompanySeq, A.order_g_seq AS OrderSeq, A.pay_type AS PayType, 
       (SELECT TOP 1 Status_seq FROM custom_order WHERE order_g_seq = A.order_g_seq) AS StatusSeq, 
	   ISNULL(A.settle_price,0) AS SettlePrice, A.order_date AS OrderDate, A.member_id AS MemberID, 
       A.order_name AS OrderName, A.order_email AS Email, A.order_phone AS Phone, A.order_hphone AS Hp, 
       A.settle_method AS Method, A.settle_status AS status, A.settle_date AS payDate, 
	   A.order_price AS orderPrice, A.order_total_price AS totalPrice, A.delivery_price AS deliveryPrice,
	   A.Pg_ResultInfo AS bankInfo, A.Pg_ResultInfo2 AS depositor,
	   B.NAME AS deliveryName, B.DELIVERY_DATE AS deliveryDate, B.DELIVERY_CODE_NUM AS deliveryNo, B.DELIVERY_METHOD AS deliveryMethod,
	   B.phone AS deliveryPhone, B.hphone AS deliveryHp, B.zip AS deliveryZip, B.addr AS deliveryAddr, B.addr_detail AS deliveryAddrDetail, 
	   B.nt_code AS deliveryCountry,
	   (SELECT TOP 1 order_seq FROM custom_order WHERE order_g_seq = A.order_g_seq AND order_type = 1) AS Wed_Order_Seq,
	   (SELECT COUNT(order_seq) FROM custom_order WHERE order_g_seq = A.order_g_seq AND order_type = 1) AS Wed_Order_Seq_CNT,
	   (SELECT TOP 1 order_seq FROM custom_order WHERE order_g_seq = A.order_g_seq AND order_type <> 1) AS Order_Seq
FROM   Custom_Order_Group A WITH (nolock) LEFT JOIN DELIVERY_INFO_GROUP B ON B.order_g_seq=A.order_g_seq
GO
