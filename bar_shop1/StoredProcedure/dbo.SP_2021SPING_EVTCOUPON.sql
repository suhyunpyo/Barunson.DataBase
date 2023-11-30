IF OBJECT_ID (N'dbo.SP_2021SPING_EVTCOUPON', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_2021SPING_EVTCOUPON
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- 바/몰 SP_2021SPING_EVTCOUPON
-- Create date: 2021-01-25
-- Description:	원주문 기준, 디자인봉투 + 실링스티커구매
-- EXEC dbo.[SP_INSERT_COUPON_MST_SEQ] 134, 's4guest'
-- =============================================

CREATE PROCEDURE [dbo].[SP_2021SPING_EVTCOUPON]
	@ORDER_SEQ    							AS INT,
	@SALES_GUBUN       					    AS VARCHAR(2)
AS
BEGIN
	
    SET NOCOUNT ON

	DECLARE		@COUPON_CODE					AS	VARCHAR(50) = ''
        ,       @d_env_cnt                      AS  INT = 0
        ,       @s_sticker_cnt                  AS  INT = 0
		,		@uid							AS	VARCHAR(50) 
		,		@END_DATE						AS	VARCHAR(50)	= ''

	-- 1. 디자인봉투 / 실링스티커 수량
	SELECT @uid = m.uid
	, @s_sticker_cnt = ISNULL((select count(item_count) from custom_order_item where order_seq = @order_seq and item_type ='T') ,0) -- 실링스티커 수량	
	, @d_env_cnt = isnull((select top 1 id from custom_order_item where order_seq = @order_seq and item_type ='E' AND memo1 ='디자인봉투' and item_count > 0),0) --디자인봉투  
	FROM custom_order c, s2_userinfo_bhands m
	where c.order_seq = @order_Seq
	and c.up_order_Seq is null
	and c.member_id = m.uid
	

		
	if @d_env_cnt > 0 
	begin

		-- 바른손인 경우
		IF @SALES_GUBUN = 'SB'
		BEGIN
		
			if @s_sticker_cnt = 0
			 set @coupon_code = ''	
			else if @s_sticker_cnt  = 1 
				set @COUPON_CODE = '1C8D-B6A6-4A7D-86EE'
			else if @s_sticker_cnt  = 2
				set @COUPON_CODE ='B986-BEBE-4026-A109'
			ELSE 
				set @COUPON_CODE ='B7A7-56F3-4D52-9F92'	
			
			if @coupon_code <> ''
			
			begin
				EXEC	SP_EXEC_COUPON_ISSUE_FOR_ONE 5001, @SALES_GUBUN, @UID, @COUPON_CODE
			end
				 
		END 
		---------------------------------------
		-- 바른손몰인 경우
		IF @SALES_GUBUN = 'B'
		BEGIN
			if @s_sticker_cnt = 0
			 set @coupon_code = ''	
			else if @s_sticker_cnt  = 1 
				set @COUPON_CODE = 'BHSEALING3000'
			else if @s_sticker_cnt  = 2
				set @COUPON_CODE ='BHSEALING5000'
			ELSE 
				set @COUPON_CODE ='BHSEALING7000'		 

				set	@END_DATE =	'2021-05-31 23:59:59' 
			

			if @coupon_code <> ''
				begin		
				-- 이미 발급된 쿠폰이 있는 지 확인
				IF	NOT EXISTS(
					SELECT	*
					FROM	S4_MYCOUPON 
					WHERE	UID = @UID
					AND		COUPON_CODE = @COUPON_CODE
				)
				
					begin			
						INSERT INTO S4_MYCOUPON (UID, COUPON_CODE, COMPANY_SEQ, ISMYYN, END_DATE) VALUES (@UID, @COUPON_CODE, '5006', 'Y', @END_DATE)
					end
				end
				 
		END 
						
	end 

END
GO
