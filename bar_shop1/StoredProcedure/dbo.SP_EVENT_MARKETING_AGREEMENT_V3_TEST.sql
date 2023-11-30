IF OBJECT_ID (N'dbo.SP_EVENT_MARKETING_AGREEMENT_V3_TEST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EVENT_MARKETING_AGREEMENT_V3_TEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_EVENT_MARKETING_AGREEMENT 'sharniel1','B'

2018-06- 11 바른손몰 
마케팅활용 약관동의 가입단 외 주문단에서  - 쿠폰발급용
	섬성전자, 종근당, SK브로드밴드
	
	119001 통신
	119002 보험(비큐러스 - 제휴종료 2018.10.31)
	119004 건강(종근당 - 제휴종료 2018.11.19)
	119004 건강(종근당 - 제휴종료 2018.11.19)
	119006 신한생명(2020.04.01부터~)
	119007 렌탈/통신(LG헬로비젼) (2020.08.10부터~ 제휴종료 2021.09.30)

	SP_EVENT_MARKETING_AGREEMENT
	SP_EVENT_MARKETING_AGREEMENT_V2 
	SP_EVENT_MARKETING_AGREEMENT_V3 - 22.03.05 삼성전자 smembership_period 추가 (사이트 순차적용 후 v2 사용안할꺼임)
									- 22.03.29 KT 추가(바/몰만)

*/

CREATE PROCEDURE [dbo].[SP_EVENT_MARKETING_AGREEMENT_V3_TEST]
    @USER_ID				AS VARCHAR(50)
    , @SALES_GUBUN			AS VARCHAR(2)
	, @gubun				as varchar(1) -- S : 샘플 주문시 . C : 청첩장 주문 
	, @smembership_period	AS VARCHAR(1)
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
	 	
	-- 통신
	select @cnt1 = count(*) from S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where uid = @USER_ID and MARKETING_TYPE_CODE = '119001'
	
	if @CNT1 = 0
		BEGIN
			INSERT INTO S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT (UID, MARKETING_TYPE_CODE, USE_YORN) values (@USER_ID , '119001','Y')
		end 
	
	-- 보험(교보)
	--select @cnt5 = count(*) from S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where uid = @USER_ID and MARKETING_TYPE_CODE = '119005'
	
	--if @CNT5 = 0
	--	BEGIN
	--		INSERT INTO S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT (UID, MARKETING_TYPE_CODE, USE_YORN) values (@USER_ID , '119005','Y')
	--	end 
	
	-- 신한생명 보험 -------------------------------

	select @cnt6 = count(*) from S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where uid = @USER_ID and MARKETING_TYPE_CODE = '119006'
	
	if @CNT6 = 0
		BEGIN
			INSERT INTO S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT (UID, MARKETING_TYPE_CODE, USE_YORN) values (@USER_ID , '119006','Y')
		end 

	-- LG헬로비젼
	--select @cnt7 = count(*) from S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where uid = @USER_ID and MARKETING_TYPE_CODE = '119007'
	
	--if @CNT7 = 0
	--	BEGIN
	--		INSERT INTO S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT (UID, MARKETING_TYPE_CODE, USE_YORN) values (@USER_ID , '119007','Y')
	--	end 

	-- 교보생명
	--select @cnt8 = count(*) from S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where uid = @USER_ID and MARKETING_TYPE_CODE = '119008'
	
	--if @CNT8 = 0
	--	BEGIN
	--		INSERT INTO S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT (UID, MARKETING_TYPE_CODE, USE_YORN) values (@USER_ID , '119008','Y')
	--	end 


	select @cnt = count(*) from S4_Event_Raina where uid = @USER_ID 
	
	if @CNT = 0
		BEGIN
			INSERT INTO S4_Event_Raina (UID, company_seq, event_div, reg_date) values (@USER_ID , @COMPANY_SEQ,'MKevent', getdate())
		end 

	-- 삼성 / LG
	update S2_UserInfo_TheCard 
	set   
	   mkt_chk_flag = 'Y'
	   ,chk_smembership = 'Y'  
	   , smembership_reg_date = GETDATE()  
	   , smembership_chk_flag = 'Y'  
	   , chk_smembership_per = 'Y'
	   , chk_smembership_coop = 'Y'
	   , smembership_inflow_route = 'JOIN' 
	   , smembership_period = @smembership_period 
	   , chk_lgmembership = 'Y'
	   , lgmembership_reg_date  = GETDATE()  
	   , chk_casamiamembership ='Y' 
	   , casamiaship_reg_Date = GETDATE()
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
	   , smembership_period = @smembership_period   
	   , chk_lgmembership = 'Y'
	   , lgmembership_reg_date  = GETDATE()  
	   , chk_casamiamembership ='Y' 
	   , casamiaship_reg_Date = GETDATE()
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
	   , smembership_period = @smembership_period  
	   , chk_lgmembership = 'Y'
	   , lgmembership_reg_date  = GETDATE()   
	   , chk_casamiamembership ='Y' 
	   , casamiaship_reg_Date = GETDATE()
	where uid= @USER_ID  

	-- KT는 바/몰 따로 추가시킨다 (2022.03.29)
	IF @SALES_GUBUN = 'SB' OR @SALES_GUBUN = 'B' OR @SALES_GUBUN = 'C' OR @SALES_GUBUN = 'H'
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
		END 

	
	DECLARE @NOWDATE VARCHAR(10)
	DECLARE @COMPAREDATE VARCHAR(10)
	DECLARE @DAY_CNT INT 
	SET @NOWDATE = CONVERT(VARCHAR(10), GETDATE(), 120)
	SET @COMPAREDATE = '2022-08-01'

	SET @DAY_CNT = DATEDIFF(DAY, @NOWDATE,@COMPAREDATE) 

	-- 현대백화점 (2022.04.27)
	IF (@SALES_GUBUN = 'B' OR @SALES_GUBUN = 'C') AND  @DAY_CNT > 0 
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
		END 




	-- 2018.06.11 주문단 약관동의 고객 ID 남김
	INSERT INTO EVENT_MARKETING_AGREEMENT (uid, sales_gubun, created_tmstmp, gubun) VALUES (@USER_ID, @SALES_GUBUN, getdate() , @gubun )
	
	--If @gubun = 'C' 
		--begin
			-- 쿠폰대신 배송료 할인으로 변경 - 2022.02.15	
			IF @SALES_GUBUN ='B' OR @SALES_GUBUN ='H' OR @SALES_GUBUN ='C'
			  BEGIN
				INSERT INTO s4_mycoupon (coupon_code, uid, company_seq, ismyyn, reg_date)  VALUES ('BSMMARKETINGEVT', @USER_ID, 5006, 'Y', GETDATE() )
			  END 
			ELSE
				-- 이미 발급된 쿠폰이 있는 지 확인
				IF	NOT EXISTS(
				   SELECT		*
					FROM		COUPON_DETAIL			CD
					INNER JOIN	COUPON_ISSUE			CI	ON CD.COUPON_DETAIL_SEQ= CI.COUPON_DETAIL_SEQ
					WHERE		CI.UID = @USER_ID
					AND			CI.COMPANY_SEQ = @COMPANY_SEQ
					AND			CD.COUPON_MST_SEQ = @COUPON_MST_SEQ
				)

				BEGIN
					-- 쿠폰번호 검색 후, 쿠폰발급
					SELECT  TOP(1) @COUPON_CODE =  COUPON_CODE
					FROM	COUPON_DETAIL
					WHERE	COUPON_MST_SEQ = @COUPON_MST_SEQ
					AND		DOWNLOAD_ACTIVE_YN = 'Y'

					DECLARE @TABLE_TEMP TABLE (
												RESULT_CODE VARCHAR(4)
											,   RESULT_MESSAGE VARCHAR(100))

					INSERT @TABLE_TEMP EXEC	SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, @SALES_GUBUN, @USER_ID, @COUPON_CODE
		  
				END
	
		--end

END		

GO
