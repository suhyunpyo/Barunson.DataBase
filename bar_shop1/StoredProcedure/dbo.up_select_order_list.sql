IF OBJECT_ID (N'dbo.up_select_order_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_order_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2014-04-014
-- Description:	주문결제리스트 
-- =============================================
CREATE PROCEDURE [dbo].[up_select_order_list]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,
	@uid	AS nvarchar(16),
	@member_email AS nvarchar(150),
	@member_name	AS nvarchar(20),
	@page	int,				-- 페이지넘버
	@pagesize int				-- 페이지사이즈(페이지당 노출갯수)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	if @uid <> ''
		begin
			select COUNT(order_seq) from v_order_list where COMPANY_seq=@company_seq and member_id=@uid
		end
	else
		begin
			select COUNT(order_seq) from v_order_list where COMPANY_seq=@company_seq and member_email=@member_email and member_name=@member_name  
		end
		
		
	if @uid <> ''
		BEGIN
			select top (@pagesize) order_case, order_type_str, order_seq, order_Date, status_seq, 
			status_seq_str, settle_price, settle_method, pg_tid, pg_shopid, pg_resultinfo, pg_resultinfo2, 
			settle_date, delivery_date, delivery_com, delivery_code, member_id, company_seq, member_name, member_email, unit_cnt
			from v_order_list 
			where COMPANY_seq=@company_seq and member_id=@uid
			and order_seq not in (select top (@pagesize * (@page - 1)) order_seq from v_order_list 
			where COMPANY_seq=@company_seq and member_id=@uid order by order_date desc )
			order by order_date desc
		END
	ELSE
		BEGIN
			select top (@pagesize) order_case, order_type_str, order_seq, order_Date, status_seq, 
			status_seq_str, settle_price, settle_method, pg_tid, pg_shopid, pg_resultinfo, pg_resultinfo2, 
			settle_date, delivery_date, delivery_com, delivery_code, member_id, company_seq, member_name, member_email, unit_cnt 
			from v_order_list 
			where COMPANY_seq=@company_seq and member_email=@member_email and member_name=@member_name  
			and order_seq not in (select top (@pagesize * (@page - 1)) order_seq from v_order_list 
			where COMPANY_seq=@company_seq and member_email=@member_email and member_name=@member_name  order by order_date desc )
			order by order_date desc
		END
	
END
GO
