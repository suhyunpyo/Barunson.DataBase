IF OBJECT_ID (N'dbo.SP_EVENT_MARKETING_AGREEMENT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EVENT_MARKETING_AGREEMENT
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
*/

CREATE PROCEDURE [dbo].[SP_EVENT_MARKETING_AGREEMENT]
    @USER_ID				AS VARCHAR(50)
    , @SALES_GUBUN			AS VARCHAR(2)
AS
BEGIN

	DECLARE @cnt				AS	INT
			, @cnt2				AS	INT
			, @cnt3				AS	INT 
			, @cnt4				AS	INT
			, @COMPANY_SEQ		AS	INT
			, @COUPON_MST_SEQ	AS	INT
			, @COUPON_CODE		AS	VARCHAR(50) = ''


	IF @SALES_GUBUN ='SB' -- 바른손 
		BEGIN
			SET @COMPANY_SEQ = 5001
			SET @COUPON_MST_SEQ = 272 
		END 
	else if @SALES_GUBUN ='ST' -- 더카드
		BEGIN
			SET @COMPANY_SEQ = 5007
			SET @COUPON_MST_SEQ = 283 
		END 	 
	else if @SALES_GUBUN ='SS' -- 프리미어페이퍼
		BEGIN
			SET @COMPANY_SEQ = 5003
			SET @COUPON_MST_SEQ = 285 
		END 	
	else if @SALES_GUBUN ='SA' -- 비핸즈
		BEGIN
			SET @COMPANY_SEQ = 5006
			SET @COUPON_MST_SEQ = 284 
		END 
	ELSE
		BEGIN
			SET @COMPANY_SEQ = 5000
			SET @COUPON_MST_SEQ = 0 
		END 
	 	
	-- 통신
	select @cnt = count(*) from S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where uid = @USER_ID and MARKETING_TYPE_CODE = '119001'
	
	if @CNT = 0
		BEGIN
			INSERT INTO S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT (UID, MARKETING_TYPE_CODE, USE_YORN) values (@USER_ID , '119001','Y')
		end 
	
	-- 보험
	--select @cnt2 = count(*) from S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where uid = @USER_ID and MARKETING_TYPE_CODE = '119002'
	
	--if @CNT2 = 0
	--	BEGIN
	--		INSERT INTO S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT (UID, MARKETING_TYPE_CODE, USE_YORN) values (@USER_ID , '119002','Y')
	--	end 

	-- 건강(종근당)
	--select @cnt3 = count(*) from S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT where uid = @USER_ID and MARKETING_TYPE_CODE = '119004'
	
	--if @CNT3 = 0
	--	BEGIN
	--		INSERT INTO S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT (UID, MARKETING_TYPE_CODE, USE_YORN) values (@USER_ID , '119004','Y')
	--	end 

	select @cnt4 = count(*) from S4_Event_Raina where uid = @USER_ID 
	
	if @CNT4 = 0
		BEGIN
			INSERT INTO S4_Event_Raina (UID, company_seq, event_div, reg_date) values (@USER_ID , @COMPANY_SEQ,'MKevent', getdate())
		end 


	-- 삼성
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


	-- 2018.06.11 주문단 약관동의 고객 ID 남김
	INSERT INTO EVENT_MARKETING_AGREEMENT (uid, sales_gubun, created_tmstmp) VALUES (@USER_ID, @SALES_GUBUN, getdate() )
	
	-- 쿠폰등록		
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
            --SET @MSG = (SELECT RESULT_MESSAGE FROM @TABLE_TEMP)
            
			--UPDATE COUPON_DETAIL SET DOWNLOAD_ACTIVE_YN = 'N' WHERE COUPON_CODE = @COUPON_CODE 
		  
        END


END		

GO
