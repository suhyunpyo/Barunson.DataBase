IF OBJECT_ID (N'dbo.proc_HJChk', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_HJChk
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     Procedure [dbo].[proc_HJChk]
@delcode varchar(15)
as
begin

	--식권/시판시즌
	select 'E' as otype,order_seq,sales_gubun,delivery_date,isHJ
	from custom_etc_order where delivery_code=@delcode
	union all
	--청첩장
	select 'W' as otype,A.order_seq,sales_gubun,src_send_date as delivery_date,isHJ from custom_order A inner join DELIVERY_INFO_DELCODE B on A.order_seq = B.order_seq
	where A.status_seq>=1 and delivery_code_num=@delcode
	union all
	--샘플
	select 'S' as otype,sample_order_seq as order_seq,sales_gubun,delivery_date,isHJ from CUSTOM_sample_ORDER 
	where delivery_code_num=@delcode	
END
GO
