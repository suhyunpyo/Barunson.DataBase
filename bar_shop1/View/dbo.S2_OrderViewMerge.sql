IF OBJECT_ID (N'dbo.S2_OrderViewMerge', N'V') IS NOT NULL DROP View dbo.S2_OrderViewMerge
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create     VIEW [dbo].[S2_OrderViewMerge]
AS


SELECT   sales_gubun,order_seq,procLevel,src_confirm_date,A.order_type,order_name,A.pay_type,printW_status,A.order_count,a.isColorPrint,A.isColorInpaper,A.isEmbo,A.isCorel,A.card_seq,card_div,A.unicef_price,A.print_type
      ,B.CARD_CODE,card_code_str,B.print_group,b.print_sizeH,b.isDigital,b.isinpaper,c.isFPrint
FROM      custom_order A inner join S2_CardViewChasu B on A.card_seq = B.card_seq,CARD_COREL C 
WHERE B.card_code = C.card_code and status_Seq = 10 and src_closecopy_date is not null

GO
