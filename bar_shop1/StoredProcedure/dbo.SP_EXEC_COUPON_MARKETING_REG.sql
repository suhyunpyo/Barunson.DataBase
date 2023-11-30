USE [bar_shop1]
GO

/****** Object:  StoredProcedure [dbo].[SP_EXEC_COUPON_MARKETING_REG]    Script Date: 2023-07-05 오후 3:10:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		jaeho.lee
-- Create date: 2023-06-30
-- Description:	마케팅 동의 변경 및 쿠폰 발급
/* Example
	declare @retVal int; 
	exec SP_EXEC_COUPON_MARKETING_REG 'jaeho.lee', 5003, 'jaeho.lee', @retVal out;
	select @retVal;
*/
-- =============================================
CREATE PROCEDURE [dbo].[SP_EXEC_COUPON_MARKETING_REG]
	@uid varchar(50),
	@company_seq int,
	@admin_id varchar(50),
	@retVal int out
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sales_gubun varchar(10) = '';

	-- Sales Gubun
	IF (@company_seq = 5001)
		SET @sales_gubun = 'SB';
	ELSE IF (@company_seq = 5003)
		SET @sales_gubun = 'SS';
	ELSE IF (@company_seq = 5000)
		SET @sales_gubun = 'B';

	-- 마케팅동의, LG, 까사미아 동의
	update S2_UserInfo set mkt_chk_flag = 'Y', chk_lgmembership = 'Y', chk_casamiamembership = 'Y' where uid = @uid;
	update S2_UserInfo_BHands set mkt_chk_flag = 'Y', chk_lgmembership = 'Y', chk_casamiamembership = 'Y' where uid = @uid;
	update S2_UserInfo_TheCard set mkt_chk_flag = 'Y', chk_lgmembership = 'Y', chk_casamiamembership = 'Y' where uid = @uid;

	-- S4_Event_Raina insert(마케팅 동의 약관 동의 내역)
	INSERT INTO S4_Event_Raina (uid,company_seq,event_div,reg_date,inflow_route) VALUES (@uid, @company_seq, 'MKEVENT', GETDATE(), @admin_id);

	-- S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT insert(마케팅 활용 약관동의)
	INSERT INTO S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT (UID, MARKETING_TYPE_CODE, USE_YORN, REG_DATE) VALUES (@uid, '119001', 'Y', GETDATE());
	INSERT INTO S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT (UID, MARKETING_TYPE_CODE, USE_YORN, REG_DATE) VALUES (@uid, '119006', 'Y', GETDATE());

	-- S4_MARKETING_AGREEMENT_LOG insert(마케팅 동의 로그)
	INSERT INTO S4_MARKETING_AGREEMENT_LOG (UID, SALES_GUBUN, MARKETING_TYPE_CODE, REG_DATE, DEL_DATE) VALUES (@uid, @sales_gubun, '119001', NULL, NULL);
	INSERT INTO S4_MARKETING_AGREEMENT_LOG (UID, SALES_GUBUN, MARKETING_TYPE_CODE, REG_DATE, DEL_DATE) VALUES (@uid, @sales_gubun, '119006', NULL, NULL);

	-- 쿠폰발급
	exec SP_EXEC_MEM_REGIST_GIFT_BARUNSONCARD_V3 @company_seq, @uid, null;

	SET @retVal = 1;

END
GO


