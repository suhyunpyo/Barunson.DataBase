IF OBJECT_ID (N'dbo.up_select_event_s5_insert', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_event_s5_insert
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2015.03.06
-- Description: 카드뒤집기이벤트  조회
-- exec up_select_event_s5_insert 'palaoh', 5006
-- =============================================
CREATE PROCEDURE [dbo].[up_select_event_s5_insert]
	@uid				varchar(20),
	@company_seq		int
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON;
	
	DECLARE	@idx	INT
	DECLARE @cem_item	int
	DECLARe @coupon_code	nvarchar(20)
	DECLARE @coupon_cnt	int

	SET @idx = 0
	SET @cem_item = 0
	set @coupon_code = 'AHCD20SP'+convert(varchar,@company_seq)
	set @coupon_cnt	= 0
	SELECT top 1 @idx = cem_idx, @cem_item = CEM_Item
	FROM S5_Event_Member
	WHERE 
		CEM_UID is NULL
	order by CEM_IDX asc;

	update  S5_Event_Member set CEM_UID=@uid
	where cem_idx=@idx

	if @cem_item = 9
		begin
			if @company_seq=5006
				begin
					insert into S4_MyCoupon (coupon_code, uid, company_seq, isMyYN, end_date) values ('BHS20THK0306', @uid, @company_seq, 'Y', GETDATE())
				end
			else
				begin
					select @coupon_cnt = count(coupon_code) from S4_COUPON where company_seq=@company_seq and coupon_code=@coupon_code
					if @coupon_cnt = 0
						begin
							insert into S4_COUPON (coupon_code, company_seq, uid, discount_type, discount_value, limit_price, coupon_desc, isWeddingCoupon, isRecycle, isJehu, item_type)
							values (@coupon_code, @company_seq, '', 'R', 20, 1000, '[감사장 20% 할인쿠폰]', 'N', 'N', 'Y', 'W2')
						end
					insert into S4_MyCoupon (coupon_code, uid, company_seq, isMyYN, end_date) values (@coupon_code, @uid, @company_seq, 'Y', GETDATE())
				end
		end
	select CE_Item_NM, CE_IMG from S5_Event_Item
	where ce_idx=@cem_item
END





GO
