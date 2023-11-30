IF OBJECT_ID (N'dbo.up_Update_Review_detail_Status2', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Update_Review_detail_Status2
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
CREATE PROCEDURE [dbo].[up_Update_Review_detail_Status2]
	-- Add the parameters for the stored procedure here
	@ER_Idx		int,
	@ERA_Coupon_Status			int,
	@ERA_Status			int,
	@ERA_Comment			nvarchar(2000),
	@ERA_Comment_Cancel		nvarchar(2000),
	@hand_phone		nvarchar(16),
	@ER_Userid			nvarchar(50),
	@ERA_Coupon_Code				nvarchar(20),
	@temp_key			nvarchar(20),
	@ER_View			int,
	@ER_UserName		nvarchar(20),
	@ER_Review_Title	nvarchar(150),
	@ER_Review_Url		nvarchar(250),
    @ER_Review_Url2		nvarchar(250),
	@ER_Review_Star		int,
	@company_seq		int,
	@result				INT=0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRAN
			
			declare @id	int;
DECLARE	@ErrNum   INT          
	  , @ErrSev   INT          
	  , @ErrState INT          
	  , @ErrProc  VARCHAR(50)  
	  , @ErrLine  INT          
	  , @ErrMsg   VARCHAR(2000)

declare @phone varchar(50)

set @phone = 'AA^'+@hand_phone
			
			
			
			/*리뷰 정보수정*/
			if (@ERA_Coupon_Status=0 and @ERA_Status=1)
				begin
					if @ERA_Coupon_Code = ''
						begin
						UPDATE S4_Event_Review_Status SET ERA_Comment=@ERA_Comment, ERA_Comment_Cancel=@ERA_Comment_Cancel, ERA_Status=@ERA_Status,
						ERA_Coupon_Status=1, ERA_Coupon_Code=@temp_key where ERA_ER_idx=@ER_Idx
						end
					else
						begin
							UPDATE S4_Event_Review_Status SET ERA_Comment=@ERA_Comment, ERA_Comment_Cancel=@ERA_Comment_Cancel, ERA_Status=@ERA_Status,
							ERA_Coupon_Status=1 where ERA_ER_idx=@ER_Idx
						end
					
					if @company_seq='5001'
						begin	

							EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', '[바른손카드] 샘플이용후기-1만원 할인쿠폰발급. 마이페이지>쿠폰보관함 확인', '', '16440708', 1, @phone, 0, '', 0, 'SB', '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

							INSERT INTO s4_coupon (coupon_code, company_seq, reg_date, discount_type, discount_value, limit_price, isYN, coupon_desc, isRecycle, isWeddingCoupon, isJehu,end_date,item_type)
							 values (@temp_key , 5001, GETDATE(),'P',10000,120000,'Y','바른손카드 1만원 할인쿠폰','N','Y','N',DATEADD(M,2,getdate()),'W1') 
						end
					
					--if (@company_seq='5006' or @company_seq !='5001')
					if @company_seq='5006'
						begin	
							
							EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', '[비핸즈카드] 샘플이용후기-1만원 할인쿠폰발급. 마이페이지>쿠폰보관함 확인', '', '16449713', 1, @phone, 0, '', 0, 'SA', '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

							INSERT INTO s4_coupon (coupon_code, company_seq, reg_date, discount_type, discount_value, limit_price, isYN, coupon_desc, isRecycle, isWeddingCoupon, isJehu,end_date,item_type)
							 values (@temp_key , @company_seq, GETDATE(),'P',10000,120000,'Y','비핸즈카드 1만원 할인쿠폰','N','Y','N',DATEADD(M,2,getdate()),'W1') 
						end


					if @company_seq='5007'
						begin	
							
							EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', '[더카드]샘플후기 2만원 할인쿠폰이 발급되었습니다. 마이페이지>쿠폰 보관함 확인', '', '16447998', 1, @phone, 0, '', 0, 'ST', '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT
							
							INSERT INTO s4_coupon (coupon_code, company_seq, reg_date, discount_type, discount_value, limit_price, isYN, coupon_desc, isRecycle, isWeddingCoupon, isJehu,end_date,item_type)
							 values (@temp_key , @company_seq, GETDATE(),'P',20000,120000,'Y','더카드 2만원 할인쿠폰','N','Y','N',DATEADD(M,2,getdate()),'W1') 
						end


					if @company_seq='5003'
						begin	
							declare @msg as varchar(100)
							set @msg = '[프리미어페이퍼] 샘플이용후기 감사합니다. 2만원 할인 쿠폰번호:'+@temp_key

							EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @msg, '', '16448796', 1, @phone, 0, '', 0, 'SS', '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

							INSERT INTO s4_coupon (coupon_code, company_seq, reg_date, discount_type, discount_value, limit_price, isYN, coupon_desc, isRecycle, isWeddingCoupon, isJehu,end_date,item_type)
							 values (@temp_key , @company_seq, GETDATE(),'P',20000,200000,'Y','프리미어페이퍼 2만원 할인쿠폰','N','Y','N',DATEADD(M,2,getdate()),'W1') 
						end

					if (@company_seq !='5001' and @company_seq !='5006'  and @company_seq !='5007'  and @company_seq !='5003')
						begin	

							EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', '[비핸즈카드] 샘플이용후기-1만원 할인쿠폰발급. 마이페이지>쿠폰보관함 확인', '', '16449713', 1, @phone, 0, '', 0, 'B', '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT
							
							INSERT INTO s4_coupon (coupon_code, company_seq, reg_date, discount_type, discount_value, limit_price, isYN, coupon_desc, isRecycle, isWeddingCoupon, isJehu,end_date,item_type)
							 values (@temp_key , @company_seq, GETDATE(),'P',10000,120000,'Y','비핸즈카드 1만원 할인쿠폰','N','Y','N',DATEADD(M,2,getdate()),'W1') 
						end
					 
					 INSERT INTO S4_MyCoupon (coupon_code, uid, company_seq, end_date )  values (@temp_key , @ER_Userid, @company_seq, DATEADD(M,2,getdate()) )
				end
    		
    		else 
    			begin
    				if @ERA_Status = 0	--승인대기로 변경될 경우 쿠폰상태 변경
    					begin
    						UPDATE S4_Event_Review_Status SET ERA_Comment=@ERA_Comment, ERA_Comment_Cancel=@ERA_Comment_Cancel, ERA_Status=@ERA_Status,
							ERA_Coupon_Status=0 where ERA_ER_idx=@ER_Idx
    					end
    				else
    					begin
    						UPDATE S4_Event_Review_Status SET ERA_Comment=@ERA_Comment, ERA_Comment_Cancel=@ERA_Comment_Cancel, ERA_Status=@ERA_Status
							 where ERA_ER_idx=@ER_Idx
    					end
    			
    			end
    		
    		UPDATE S4_Event_Review SET ER_View=@ER_View, ER_UserName=@ER_UserName, ER_Review_Title=@ER_Review_Title, ER_Review_Url=@ER_Review_Url, ER_Review_Url2=@ER_Review_Url2, ER_Review_Star=@ER_Review_Star where  ER_Idx=@ER_Idx
    		
			set @result = '0'
			set @result = @@Error
			IF (@result <> 0) GOTO PROBLEM
			COMMIT TRAN


			PROBLEM:
			IF (@result <> 0) BEGIN
				ROLLBACK TRAN
			END
			
			return @result

END
GO
