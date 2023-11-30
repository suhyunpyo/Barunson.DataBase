IF OBJECT_ID (N'dbo.up_Update_Review_detail_Status', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Update_Review_detail_Status
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[up_Update_Review_detail_Status]
	-- Add the parameters for the stored procedure here
	@ER_Idx             INT,
	@ERA_Coupon_Status  INT,
	@ERA_Status         INT,
	@ERA_Comment        NVARCHAR(2000),
	@ERA_Comment_Cancel NVARCHAR(2000),
	@hand_phone         NVARCHAR(16),
	@ER_Userid          NVARCHAR(50),
	@ERA_Coupon_Code    NVARCHAR(20),
	@temp_key           NVARCHAR(20),
	@ER_View            INT,
	@ER_UserName        NVARCHAR(20),
	@ER_Review_Title    NVARCHAR(150),
	@ER_Review_Url      NVARCHAR(250),
	@ER_Review_Star     INT,
	@company_seq        INT,
	@result             INT=0 OUTPUT
AS
----------------------------------------------------------------------------------------------------
-- Declare Block
----------------------------------------------------------------------------------------------------
DECLARE @MSG       VARCHAR(4000)
      , @DEST_INFO VARCHAR(50)

SET @DEST_INFO = 'AA^' + @hand_phone

----------------------------------------------------------------------------------------------------
-- Execute Block
----------------------------------------------------------------------------------------------------
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRAN	
			
	/*리뷰 정보수정*/
	IF (@ERA_Coupon_Status=0 and @ERA_Status=1)
	BEGIN
		IF @ERA_Coupon_Code = ''
		BEGIN
			UPDATE S4_Event_Review_Status
				SET ERA_Comment=@ERA_Comment, ERA_Comment_Cancel=@ERA_Comment_Cancel, ERA_Status=@ERA_Status, ERA_Coupon_Status=1, ERA_Coupon_Code=@temp_key
				WHERE ERA_ER_idx=@ER_Idx
		END
		ELSE
		BEGIN
			UPDATE S4_Event_Review_Status
				SET ERA_Comment=@ERA_Comment, ERA_Comment_Cancel=@ERA_Comment_Cancel, ERA_Status=@ERA_Status, ERA_Coupon_Status=1
				WHERE ERA_ER_idx=@ER_Idx
		END
					
		IF @company_seq='5001'
		BEGIN

			SET @MSG = '[바른손카드] 샘플이용후기-1만원 할인쿠폰발급. 마이페이지>쿠폰보관함 확인'

			----------------------------------------------------------------------------------
			-- KT
			----------------------------------------------------------------------------------
			EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @MSG, '', '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''

			----------------------------------------------------------------------------------
			-- LG 데이콤(구버전)
			----------------------------------------------------------------------------------
			--insert into invtmng.SC_TRAN (TR_SENDSTAT, TR_SENDDATE, TR_ID, TR_RSLTSTAT,TR_PHONE, TR_CALLBACK, TR_MSG) 
			--values 
			--('0',GETDATE(),'SM136890_002','00',@hand_phone,'16440708','[바른손카드] 샘플이용후기-1만원 할인쿠폰발급. 마이페이지>쿠폰보관함 확인')
							
			INSERT INTO s4_coupon (coupon_code, company_seq, reg_date, discount_type, discount_value, limit_price, isYN, coupon_desc, isRecycle, isWeddingCoupon, isJehu,end_date,item_type)
			VALUES (@temp_key , 5001, GETDATE(),'P',10000,120000,'Y','바른손카드 1만원 할인쿠폰','N','Y','N',DATEADD(M,2,getdate()),'W1') 
		END
					
		IF @company_seq='5006'
		BEGIN	
							
			SET @MSG = '[비핸즈카드] 샘플이용후기-1만원 할인쿠폰발급. 마이페이지>쿠폰보관함 확인'

			----------------------------------------------------------------------------------
			-- KT
			----------------------------------------------------------------------------------
			EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @MSG, '', '16449713', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''

			----------------------------------------------------------------------------------
			-- LG 데이콤(구버전)
			----------------------------------------------------------------------------------
			--insert into invtmng.SC_TRAN (TR_SENDSTAT, TR_SENDDATE, TR_ID, TR_RSLTSTAT,TR_PHONE, TR_CALLBACK, TR_MSG) 
			--values 
			--('0',GETDATE(),'SM136890_002','00',@hand_phone,'16449713','[비핸즈카드] 샘플이용후기-1만원 할인쿠폰발급. 마이페이지>쿠폰보관함 확인')
							
			INSERT INTO s4_coupon (coupon_code, company_seq, reg_date, discount_type, discount_value, limit_price, isYN, coupon_desc, isRecycle, isWeddingCoupon, isJehu,end_date,item_type)
			VALUES (@temp_key , @company_seq, GETDATE(),'P',10000,120000,'Y','비핸즈카드 1만원 할인쿠폰','N','Y','N',DATEADD(M,2,getdate()),'W1') 
		END

		IF @company_seq='5007'
		BEGIN

			SET @MSG = '[더카드]샘플후기 2만원 할인쿠폰이 발급되었습니다. 마이페이지>쿠폰 보관함 확인'

			----------------------------------------------------------------------------------
			-- KT
			----------------------------------------------------------------------------------
			EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @MSG, '', '16447998', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
							
			----------------------------------------------------------------------------------
			-- LG 데이콤(구버전)
			----------------------------------------------------------------------------------
			--insert into invtmng.SC_TRAN (TR_SENDSTAT, TR_SENDDATE, TR_ID, TR_RSLTSTAT,TR_PHONE, TR_CALLBACK, TR_MSG) 
			--values 
			--('0',GETDATE(),'SM136890_002','00',@hand_phone,'16447998',' [더카드]샘플후기 2만원 할인쿠폰이 발급되었습니다. 마이페이지>쿠폰 보관함 확인')
							
			INSERT INTO s4_coupon (coupon_code, company_seq, reg_date, discount_type, discount_value, limit_price, isYN, coupon_desc, isRecycle, isWeddingCoupon, isJehu,end_date,item_type)
			VALUES (@temp_key , @company_seq, GETDATE(),'P',20000,120000,'Y','더카드 2만원 할인쿠폰','N','Y','N',DATEADD(M,2,getdate()),'W1') 
		END

		IF @company_seq='5003'
		BEGIN

			SET @MSG = '[프리미어페이퍼] 샘플이용후기-2만원 할인쿠폰발급 쿠폰번호:' + @temp_key

			----------------------------------------------------------------------------------
			-- KT
			----------------------------------------------------------------------------------
			EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @MSG, '', '16448796', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''

			----------------------------------------------------------------------------------
			-- LG 데이콤(구버전)
			----------------------------------------------------------------------------------	
			--insert into invtmng.SC_TRAN (TR_SENDSTAT, TR_SENDDATE, TR_ID, TR_RSLTSTAT,TR_PHONE, TR_CALLBACK, TR_MSG) 
			--values 
			--('0',GETDATE(),'SM136890_002','00',@hand_phone,'16448796','[프리미어페이퍼] 샘플이용후기-2만원 할인쿠폰발급 쿠폰번호:'+@temp_key+'')
							
			INSERT INTO s4_coupon (coupon_code, company_seq, reg_date, discount_type, discount_value, limit_price, isYN, coupon_desc, isRecycle, isWeddingCoupon, isJehu,end_date,item_type)
			VALUES (@temp_key , @company_seq, GETDATE(),'P',20000,200000,'Y','프리미어페이퍼 2만원 할인쿠폰','N','Y','N',DATEADD(M,2,getdate()),'W1') 
		END

		IF (@company_seq != '5001' AND @company_seq != '5006' AND @company_seq != '5007' AND @company_seq != '5003')
		BEGIN

			SET @MSG = '[비핸즈카드] 샘플이용후기-1만원 할인쿠폰발급. 마이페이지>쿠폰보관함 확인'

			----------------------------------------------------------------------------------
			-- KT
			----------------------------------------------------------------------------------
			EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @MSG, '', '16449713', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''

			----------------------------------------------------------------------------------
			-- LG 데이콤(구버전)
			----------------------------------------------------------------------------------				
			--insert into invtmng.SC_TRAN (TR_SENDSTAT, TR_SENDDATE, TR_ID, TR_RSLTSTAT,TR_PHONE, TR_CALLBACK, TR_MSG) 
			--values 
			--('0',GETDATE(),'SM136890_002','00',@hand_phone,'16449713','[비핸즈카드] 샘플이용후기-1만원 할인쿠폰발급. 마이페이지>쿠폰보관함 확인')
							
			INSERT INTO s4_coupon (coupon_code, company_seq, reg_date, discount_type, discount_value, limit_price, isYN, coupon_desc, isRecycle, isWeddingCoupon, isJehu,end_date,item_type)
			VALUES (@temp_key , @company_seq, GETDATE(),'P',10000,120000,'Y','비핸즈카드 1만원 할인쿠폰','N','Y','N',DATEADD(M,2,getdate()),'W1') 
		END
					 
		INSERT INTO S4_MyCoupon (coupon_code, uid, company_seq, end_date ) VALUES (@temp_key , @ER_Userid, @company_seq, DATEADD(M,2,getdate()) )
	END
    ELSE
    BEGIN
    	IF @ERA_Status = 0	--승인대기로 변경될 경우 쿠폰상태 변경
    	BEGIN
    		UPDATE S4_Event_Review_Status
			   SET ERA_Comment=@ERA_Comment, ERA_Comment_Cancel=@ERA_Comment_Cancel, ERA_Status=@ERA_Status, ERA_Coupon_Status=0
			 WHERE ERA_ER_idx=@ER_Idx
    	END
    	ELSE
    	BEGIN
    		UPDATE S4_Event_Review_Status
			   SET ERA_Comment=@ERA_Comment, ERA_Comment_Cancel=@ERA_Comment_Cancel, ERA_Status=@ERA_Status
			 WHERE ERA_ER_idx=@ER_Idx
    	END 			
    END
    		
    UPDATE S4_Event_Review
	   SET ER_View=@ER_View, ER_UserName=@ER_UserName, ER_Review_Title=@ER_Review_Title, ER_Review_Url=@ER_Review_Url, ER_Review_Star=@ER_Review_Star
	 WHERE ER_Idx=@ER_Idx
    		
	SET @result = '0'
	SET @result = @@Error
	IF (@result <> 0) GOTO PROBLEM
	COMMIT TRAN

	PROBLEM:
	IF (@result <> 0) BEGIN
		ROLLBACK TRAN
	END
			
	return @result

END
GO
