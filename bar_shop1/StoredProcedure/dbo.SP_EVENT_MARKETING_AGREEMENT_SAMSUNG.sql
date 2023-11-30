IF OBJECT_ID (N'dbo.SP_EVENT_MARKETING_AGREEMENT_SAMSUNG', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EVENT_MARKETING_AGREEMENT_SAMSUNG
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_EVENT_MARKETING_AGREEMENT 'sharniel1','B'

2018-06- 11 바른손몰 
마케팅활용 약관동의 삼성이벤트 페이지

2023-03-10 사용하지 않음, 바로 리턴
*/

CREATE PROCEDURE [dbo].[SP_EVENT_MARKETING_AGREEMENT_SAMSUNG]
    @USER_ID				AS VARCHAR(50)
    , @SALES_GUBUN			AS VARCHAR(2)
AS
BEGIN
	
	RETURN;

	DECLARE @cnt				AS	INT
			, @cnt2				AS	INT
			, @cnt3				AS	INT 
			, @cnt4				AS	INT
			, @COMPANY_SEQ		AS	INT
			, @COUPON_MST_SEQ	AS	INT
			, @COUPON_CODE		AS	VARCHAR(50) = ''
			, @MEM_CNT			AS	INT


	IF @SALES_GUBUN ='SB' -- 바른손 
		BEGIN
			SET @COMPANY_SEQ = 5001
		END 
	else if @SALES_GUBUN ='ST' -- 더카드
		BEGIN
			SET @COMPANY_SEQ = 5007
		END 	 
	else if @SALES_GUBUN ='SS' -- 프리미어페이퍼
		BEGIN
			SET @COMPANY_SEQ = 5003
		END 	
	else if @SALES_GUBUN ='SA' -- 비핸즈
		BEGIN
			SET @COMPANY_SEQ = 5006
		END 
	ELSE
		BEGIN
			SET @COMPANY_SEQ = 5000
		END 
	 	
	select @cnt4 = count(*) from S4_Event_Raina where uid = @USER_ID 
	
	if @CNT4 = 0
		BEGIN
			INSERT INTO S4_Event_Raina (UID, company_seq, event_div, reg_date) values (@USER_ID , @COMPANY_SEQ,'MKevent', getdate())
		end 
	
	-- 삼성 
	SELECT  @MEM_CNT = COUNT(UID)
	FROM    S2_USERINFO_BHANDS
	WHERE   uid = @USER_ID
	AND chk_smembership = 'Y'

	IF @MEM_CNT = 0
	BEGIN
			update S2_UserInfo_TheCard 
			set   
			   mkt_chk_flag = 'Y'
			   ,chk_smembership = 'Y'  
			   , smembership_reg_date = GETDATE()  
			   , smembership_chk_flag = 'Y'  
			   , chk_smembership_per = 'Y'
			   , chk_smembership_coop = 'Y'
			   , smembership_inflow_route = 'JOIN'  
			where uid= @USER_ID  
  
  
			update S2_UserInfo 
			set   
			   mkt_chk_flag = 'Y'
			   , chk_smembership = 'Y'  
			   , smembership_reg_date = GETDATE()  
			   , smembership_chk_flag = 'Y'  
			   , chk_smembership_per = 'Y'
			   , chk_smembership_coop = 'Y'
			   , smembership_inflow_route = 'JOIN'  
			where uid= @USER_ID  
  
  
			update S2_UserInfo_bhands 
			set   
			   mkt_chk_flag = 'Y'
			   , chk_smembership = 'Y'  
			   , smembership_reg_date = GETDATE()  
			   , smembership_chk_flag = 'Y'  
			   , chk_smembership_per = 'Y'
			   , chk_smembership_coop = 'Y'
			   , smembership_inflow_route = 'JOIN'  
			where uid= @USER_ID  
	END
	
	-- 2018.06.11 주문단 약관동의 고객 ID 남김
	--INSERT INTO EVENT_MARKETING_AGREEMENT (uid, sales_gubun, created_tmstmp) VALUES (@USER_ID, @SALES_GUBUN, getdate() )
	
END		

GO
