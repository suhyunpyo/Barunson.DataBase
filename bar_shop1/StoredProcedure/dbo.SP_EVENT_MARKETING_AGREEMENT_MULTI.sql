IF OBJECT_ID (N'dbo.SP_EVENT_MARKETING_AGREEMENT_MULTI', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EVENT_MARKETING_AGREEMENT_MULTI
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_EVENT_MARKETING_AGREEMENT_MULTI 'sharniel1','B'

2018-06- 11 바른손몰 
마케팅활용 약관동의 가입단 외 주문단에서  - 쿠폰발급용
	섬성전자, 종근당, SK브로드밴드
	
	119001 통신
	119002 보험(비큐러스 - 제휴종료 2018.10.31)
	119004 건강(종근당 - 제휴종료 2018.11.19)
	119004 건강(종근당 - 제휴종료 2018.11.19)
	119006 신한생명(2020.04.01부터~)
	119007 렌탈/통신(LG헬로비젼) (2020.08.10부터~ 제휴종료 2021.09.30)
*/

CREATE PROCEDURE [dbo].[SP_EVENT_MARKETING_AGREEMENT_MULTI]
    @USER_ID				AS VARCHAR(50)
    , @SALES_GUBUN			AS VARCHAR(2)
	, @smembership_period	AS VARCHAR(1)
	, @Marketing_agreement  AS VARCHAR(100)
AS
BEGIN

	DECLARE @cnt				AS	INT
			, @cnt1				AS	INT
			, @cnt2				AS	INT
			, @cnt3				AS	INT 
			, @cnt4				AS	INT
			, @cnt5				AS	INT
			, @cnt6				AS	INT
			, @cnt7				AS	INT
			, @cnt8				AS	INT
			, @COMPANY_SEQ		AS	INT
			, @COUPON_MST_SEQ	AS	INT
			, @COUPON_CODE		AS	VARCHAR(50) = ''

	SET @COUPON_MST_SEQ = 670 

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
			SET @COUPON_MST_SEQ = 0 
		END 
	
	-- 멤플러스 
	IF Charindex('memplus' , @Marketing_agreement) > 0 
		BEGIN
			-- 통신
			select @cnt1 = count(*) from S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where uid = @USER_ID and MARKETING_TYPE_CODE = '119001'

			if @CNT1 = 0
				BEGIN
					INSERT INTO S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT (UID, MARKETING_TYPE_CODE, USE_YORN) values (@USER_ID , '119001','Y')
				end 
		
			-- 보험(신한생명)
			select @cnt6 = count(*) from S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where uid = @USER_ID and MARKETING_TYPE_CODE = '119006'
	
			if @CNT6 = 0
				BEGIN
					INSERT INTO S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT (UID, MARKETING_TYPE_CODE, USE_YORN) values (@USER_ID , '119006','Y')
				end 

			select @cnt = count(*) from S4_Event_Raina where uid = @USER_ID 
	
			if @CNT = 0
				BEGIN
					INSERT INTO S4_Event_Raina (UID, company_seq, event_div, reg_date) values (@USER_ID , @COMPANY_SEQ,'MKevent', getdate())
				end 

			update S2_UserInfo set	mkt_chk_flag = 'Y' where uid= @USER_ID  
			
			update S2_UserInfo_TheCard set	mkt_chk_flag = 'Y' where uid= @USER_ID 

			update S2_UserInfo_bhands set	mkt_chk_flag = 'Y' where uid= @USER_ID 
  
		END 

	-- lg
	IF Charindex('lg' , @Marketing_agreement) > 0
		BEGIN
			update S2_UserInfo_TheCard 
			set chk_lgmembership = 'Y', lgmembership_reg_date  = GETDATE()  
			where uid= @USER_ID  
  
  
			update S2_UserInfo 
			set chk_lgmembership = 'Y', lgmembership_reg_date  = GETDATE() 
			where uid= @USER_ID  
  

			update S2_UserInfo_bhands 
			set chk_lgmembership = 'Y', lgmembership_reg_date  = GETDATE() 
			where uid= @USER_ID  
		end 

	-- 까사미아
	IF Charindex('casamia' , @Marketing_agreement) > 0
		BEGIN
			update S2_UserInfo_TheCard 
			set chk_casamiamembership ='Y' , casamiaship_reg_Date = GETDATE() 
			where uid= @USER_ID  
  
  
			update S2_UserInfo 
			set chk_casamiamembership ='Y' , casamiaship_reg_Date = GETDATE() 
			where uid= @USER_ID  
  

			update S2_UserInfo_bhands 
			set chk_casamiamembership ='Y' , casamiaship_reg_Date = GETDATE() 
			where uid= @USER_ID  
		end 

/* 제휴 종료
	IF Charindex('samsung' , @Marketing_agreement) > 0
		BEGIN
			-- 삼성
			update S2_UserInfo_TheCard 
			set   
			     chk_smembership = 'Y'  
			   , smembership_reg_date = GETDATE()  
			   , smembership_chk_flag = 'Y'  
			   , chk_smembership_per = 'Y'
			   , chk_smembership_coop = 'Y'
			   , smembership_inflow_route = 'JOIN'  
			   , smembership_period = @smembership_period
			where uid= @USER_ID  
  
  
			update S2_UserInfo 
			set   
			   chk_smembership = 'Y'  
			   , smembership_reg_date = GETDATE()  
			   , smembership_chk_flag = 'Y'  
			   , chk_smembership_per = 'Y'
			   , chk_smembership_coop = 'Y'
			   , smembership_inflow_route = 'JOIN'
			   , smembership_period = @smembership_period  
			where uid= @USER_ID  
  
			update S2_UserInfo_bhands 
			set   
			    chk_smembership = 'Y'  
			   , smembership_reg_date = GETDATE()  
			   , smembership_chk_flag = 'Y'  
			   , chk_smembership_per = 'Y'
			   , chk_smembership_coop = 'Y'
			   , smembership_inflow_route = 'JOIN'
			   , smembership_period = @smembership_period  
			where uid= @USER_ID 
		END 

	IF Charindex('kt' , @Marketing_agreement) > 0
		BEGIN
			update S2_UserInfo_TheCard 
			set chk_ktmembership ='Y' , ktmembership_reg_Date = GETDATE() 
			where uid= @USER_ID  
  
  
			update S2_UserInfo 
			set chk_ktmembership ='Y' , ktmembership_reg_Date = GETDATE() 
			where uid= @USER_ID  
  

			update S2_UserInfo_bhands 
			set chk_ktmembership ='Y' , ktmembership_reg_Date = GETDATE() 
			where uid= @USER_ID  
		end 

	
	IF Charindex('hyundai' , @Marketing_agreement) > 0
		BEGIN
			update S2_UserInfo_TheCard 
			set chk_hyundaimembership ='Y' , hyundaimembership_reg_Date = GETDATE() 
			where uid= @USER_ID  
  
  
			update S2_UserInfo 
			set chk_hyundaimembership ='Y' , hyundaimembership_reg_Date = GETDATE() 
			where uid= @USER_ID  
  

			update S2_UserInfo_bhands 
			set chk_hyundaimembership ='Y' , hyundaimembership_reg_Date = GETDATE() 
			where uid= @USER_ID  
		end 
*/
	-- 혹시.확인차 
	insert into EVENT_ENTER_MEMBER (EVENT_GUBUN , MEMBER_ID, SALES_GUBUN, reg_Date ) values ('agreeMent', @USER_ID, @SALES_GUBUN, getdate() ) 
END		

GO
