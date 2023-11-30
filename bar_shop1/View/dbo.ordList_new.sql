IF OBJECT_ID (N'dbo.ordList_new', N'V') IS NOT NULL DROP View dbo.ordList_new
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ordList_new]
AS
SELECT   A.order_seq, A.order_type, A.isChoanRisk, A.isSpecial, A.sales_Gubun, 
                A.site_gubun, A.pay_Type, A.company_seq, C.COMPANY_NAME, A.up_order_seq, 
                A.order_add_flag, A.order_add_type, A.status_seq, A.member_id, A.order_hphone, 
                A.order_email, A.src_compose_admin_id, A.order_date, A.src_compose_date, 
                A.src_compose_mod_date, A.src_confirm_date, A.src_modRequest_date, 
                A.src_printW_date, A.src_print_date, A.src_printCopy_date, A.src_jebon_date, 
                A.src_packing_date, A.src_send_date, A.order_name, A.settle_status, A.isinpaper, 
                A.ishandmade, A.fticket_price, A.mini_price, A.isCompose, 
                A.isChoanRisk AS Expr1, A.ProcLevel, A.couponseq, D.CARD_CODE, 
                A.order_count, A.order_price, ISNULL(A.settle_price, 0) AS settle_price, 
                A.last_total_price, 
                B.groom_name + '.' + B.bride_name + '.' + B.groom_father + '.' + B.groom_mother +
                 '.' + B.bride_father + '.' + B.bride_mother AS etc_name, B.wedd_name, 
                A.src_packing_date AS Expr2, D.COMPANY, B.map_trans_method, A.isCorel, 
                A.isBaesongRisk, A.isRibon, A.isColorPrint
FROM      dbo.custom_order A INNER JOIN
                dbo.custom_order_WeddInfo B ON A.weddinfo_id = B.order_seq INNER JOIN
                dbo.COMPANY C ON A.company_seq = C.COMPANY_SEQ INNER JOIN
                dbo.CARD D ON A.card_seq = D.CARD_SEQ
GO
