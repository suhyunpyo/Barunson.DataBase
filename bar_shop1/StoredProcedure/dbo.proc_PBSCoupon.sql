IF OBJECT_ID (N'dbo.proc_PBSCoupon', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_PBSCoupon
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROC [dbo].[proc_PBSCoupon]
@c_code varchar(50),			--쿠폰코드
@u_id varchar(20),				--회원 아이디
@c_price integer				--쿠폰금액
AS
Begin

BEGIN TRAN
-- 1. 쿠폰금액만큼 적립금 넣어준다.
insert into photobook_point(member_id,point,comment,admin_id) values(
@u_id,@c_price,@c_code,'admin')

-- 2. 내 쿠폰보관함에 해당 쿠폰 넣어준다.
Insert PHOTOBOOK_MYCOUPON (uid,coupon_code) Values (
@u_id,@c_code)

-- 3. 쿠폰 테이블의 쿠폰 사용여부를 '사용완료'로 업데이트
update photobook_coupon set use_yn='N' where coupon_code=@c_code

commit TRAN
end 
GO
