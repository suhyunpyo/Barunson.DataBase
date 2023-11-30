IF OBJECT_ID (N'dbo.SP_ORDER_UPDATE_COMPANY', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ORDER_UPDATE_COMPANY
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_ORDER_UPDATE_COMPANY] 
-------------------------------------------------------------------------------
--  설  명 : 비핸즈카드로 접수된 주문건을 제휴사로 변경 
--  작성자 : 김수경
--  작성일 : 2012.10.08
-------------------------------------------------------------------------------
@order_seq int, 
@sgubun varchar(2),
@com_id varchar(20)
AS  
SET NOCOUNT ON

BEGIN

	DECLARE	@com_seq integer
	DECLARE	@coupon_code varchar(50)
	DECLARE	@uid varchar(50)
	DECLARE	@umail varchar(50)


	--company_seq 가져오기
	select @com_seq = company_seq from COMPANY 	where sales_gubun=@sgubun and LOGIN_ID=@com_id  and status='S2' 

	--쿠폰코드와 회원정보 가져오기
	select @coupon_code = coupon_code,@uid = B.member_id,@umail=B.order_email from S4_COUPON A inner join custom_order B 
	on A.company_seq = B.company_seq ,S2_Card C 
	where B.card_seq = C.Card_Seq and A.cardbrand = C.cardbrand 
	and B.order_seq = @order_seq

	if (@uid = '' ) set @uid = @umail

	update custom_order set sales_Gubun=@sgubun,company_seq = @com_seq where order_seq = @order_seq
	insert into S4_MyCoupon(company_seq,coupon_code,uid) values(@com_seq,@coupon_code,@uid)

end
GO
