IF OBJECT_ID (N'dbo.S2_orderLstN_20201113', N'V') IS NOT NULL DROP View dbo.S2_orderLstN_20201113
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[S2_orderLstN_20201113]
AS
	SELECT
		  A.order_seq
		, A.order_type
		, A.isChoanRisk
		, A.isSpecial
		, A.sales_Gubun
		, A.site_gubun
		, A.pay_Type
		, A.company_seq
		, C.COMPANY_NAME
		, ISNULL(C.ERP_PartCode , '') AS erp_partcode
		, A.up_order_seq
		, A.order_add_flag
		, A.order_add_type
		, A.status_seq
		, A.member_id
		, A.order_hphone
		, A.order_email
		, A.src_compose_admin_id
		, A.src_compose_mod_admin_id
		, A.order_date
		, A.settle_date
		, A.src_ap_date
		, A.src_compose_date
		, A.src_confirm_date
		, A.src_modRequest_date
		, A.src_compose_mod_date
		, A.src_printW_date
		, A.src_print_date
		, A.src_printCopy_date
		, A.src_CloseCopy_date
		, A.src_printer_seq
		, A.src_packing_date
		, A.src_send_date
		, A.order_name
		, A.settle_status
		, A.isinpaper
		, A.ishandmade
		, A.isEnvInsert
		, A.isLiningJaebon
		, ISNULL(A.fticket_price, 0) AS fticket_price
		, ISNULL(A.embo_price, 0) AS embo_price
		, A.isEmbo
		, ISNULL(A.envInsert_price, 0) AS envInsert_price
		, ISNULL(A.mini_price, 0) AS mini_price
		, A.isColorInpaper
		, A.isCompose
		, A.isChoanRisk AS Expr1
		, A.ProcLevel
		, A.couponseq
		, D.card_code
		, D.old_code
		, D.card_code_str
		, D.Master_2Color
		, A.order_count
		, ISNULL(A.order_price, 0) AS order_price
		, ISNULL(A.settle_price , 0) AS settle_price
		, ISNULL(A.unicef_price, 0) AS unicef_price
		, ISNULL(A.last_total_price, 0) AS last_total_price
		, B.groom_name + '.' + B.bride_name + '.' + B.groom_father + '.' + B.groom_mother + '.' + B.bride_father + '.' + B.bride_mother AS etc_name
		, B.wedd_name
		, ISNULL(B.wedd_phone , '') AS wedd_phone
		, A.src_packing_date AS Expr2
		, D.brand_code
		, B.map_trans_method
		, A.isCorel
		, A.isBaesongRisk
		, A.isRibon
		, A.isColorPrint
		, A.trouble_type
		, A.isVar
		, A.settle_method
		, A.discount_in_advance_cancel_date
		, A.discount_in_advance_reg_date
		, A.discount_in_advance
		, A.cancel_user_type
		, A.cancel_type_comment
		, A.cancel_type
		, B.wedd_place
		, B.wedd_addr
		, A.order_g_seq
		, D.isLaser
		, ISNULL(A.laser_price, 0) AS laser_price
		, ISNULL(A.inflow_route , 'PC') AS Inflow_Route_Order
		, ISNULL(A.inflow_route_settle , 'PC') AS Inflow_Route_Settle
		, A.addition_couponseq
		, D.PrintMethod
		, D.isMasterDigital
		, A.Auto_Choan_Status_Code
        , CC.DTL_Name AS Auto_Choan_Status_Name
		, ISNULL(A.isEnvCharge , '0') AS isEnvCharge
        , ISNULL(A.isEnvSpecial, '0') AS isEnvSpecial
		, A.sasik_price
		, CASE WHEN (ISNULL(E.ORDER_SEQ,'') <> '' OR A.couponseq IN ('BSMSUPPORT50R','BSMSUPPORT50R2','BSMSUPPORT25R','BSMSUPPORT50RN')) THEN 'Y' ELSE 'N' END crnc_flag 
	FROM   custom_order AS A
		INNER JOIN custom_order_WeddInfo AS B
			ON A.weddinfo_id = B.order_seq
		INNER JOIN COMPANY AS C
			ON A.company_seq = C.COMPANY_SEQ
		INNER JOIN S2_CardViewN AS D
			ON A.card_seq = D.card_seq
        LEFT OUTER JOIN Common_Code AS CC
            ON A.Auto_Choan_Status_Code = CC.CMMN_Code
		LEFT JOIN
		(
			SELECT  ORDER_SEQ FROM 
			CUSTOM_ORDER_COUPON A
			INNER JOIN COUPON_ISSUE B ON A.COUPON_ISSUE_SEQ = B.COUPON_ISSUE_SEQ 
			INNER JOIN COUPON_DETAIL C ON B.COUPON_DETAIL_SEQ = C.COUPON_DETAIL_SEQ
			where COUPON_CODE IN 
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
			)
			group by ORDER_SEQ
		) AS E ON A.ORDER_SEQ = E.ORDER_SEQ
	WHERE  A.status_seq >= 1;

GO
