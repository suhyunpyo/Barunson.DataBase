IF OBJECT_ID (N'dbo.SP_EVENT_MARKETING_AGREEMENT_PROC', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EVENT_MARKETING_AGREEMENT_PROC
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_EVENT_MARKETING_AGREEMENT_PROC 's4guest','SB','LG'

2021-03-09
마케팅활용 이벤트 페이지

*/

CREATE PROCEDURE [dbo].[SP_EVENT_MARKETING_AGREEMENT_PROC]
    @USER_ID				AS VARCHAR(50)
    , @SALES_GUBUN			AS VARCHAR(2)
	, @JEHU_GUBUN			AS VARCHAR(10)
AS
BEGIN

	DECLARE @cnt				AS	INT
			, @COMPANY_SEQ		AS	INT
			, @COUPON_MST_SEQ	AS	INT
			, @COUPON_CODE		AS	VARCHAR(50) = ''
			, @MEM_CNT			AS	INT = 0


    DECLARE @RESULT_MESSAGE AS VARCHAR(500)	= '가입완료되었습니다.'


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
	 	
	--select @cnt4 = count(*) from S4_Event_Raina where uid = @USER_ID 
	
	--if @CNT4 = 0
	--	BEGIN
	--		INSERT INTO S4_Event_Raina (UID, company_seq, event_div, reg_date) values (@USER_ID , @COMPANY_SEQ,'MKevent', getdate())
	--	end 
	
	-- 추후 제휴업체가 새로 생성되면, 그때 JEHU_GUBUN 값을 따지자.

	-- LG전자 마케팅동의여부 확인 
	SELECT  @MEM_CNT = COUNT(UID)
	FROM    S2_USERINFO_BHANDS
	WHERE   uid = @USER_ID
	AND chk_lgmembership = 'N'

	IF @MEM_CNT = 1
		BEGIN
				update S2_UserInfo_TheCard 
				set   
				   chk_lgmembership = 'Y'  
				   , lgmembership_reg_date = GETDATE()  
				where uid= @USER_ID  
  
				update S2_UserInfo 
				set   
				   chk_lgmembership = 'Y'  
				   , lgmembership_reg_date = GETDATE()  
				where uid= @USER_ID  
  
  
				update S2_UserInfo_bhands 
				set   
				   chk_lgmembership = 'Y'  
				   , lgmembership_reg_date = GETDATE()  
				where uid= @USER_ID  

				-- 2018.06.11 주문단 약관동의 고객 ID 남김
				select @cnt = count(*) from EVTPAGE_MARKETING_AGREEMENT_LOG where uid = @USER_ID
				
				if @cnt = 0 
					begin
						INSERT INTO EVTPAGE_MARKETING_AGREEMENT_LOG (uid, sales_gubun, created_tmstmp,jehu_gubun) VALUES (@USER_ID, @SALES_GUBUN, getdate(),@JEHU_GUBUN)
					end
		END
	else
		begin
			set @RESULT_MESSAGE ='LG멤버십 가입 고객입니다.'
		end

	

    SELECT  @RESULT_MESSAGE AS RESULT_MESSAGE
			
END		

GO
