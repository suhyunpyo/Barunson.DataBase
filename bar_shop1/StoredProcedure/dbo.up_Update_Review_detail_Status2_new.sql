IF OBJECT_ID (N'dbo.up_Update_Review_detail_Status2_new', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Update_Review_detail_Status2_new
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[up_Update_Review_detail_Status2_new]

	@ER_Idx		int,
	@ERA_Coupon_Status			int,
	@ERA_Status			int,
	@ERA_Comment			nvarchar(2000),
	@ERA_Comment_Cancel		nvarchar(2000),
	@hand_phone		nvarchar(16),
	@ER_Userid			nvarchar(50),
	@ERA_Coupon_Code				nvarchar(20),
	@temp_key			nvarchar(25),
	@ER_View			int,
	@ER_UserName		nvarchar(20),
	@ER_Review_Title	nvarchar(150),
	@ER_Review_Url		nvarchar(250),
	@ER_Review_Url2		nvarchar(250),
	@ER_Review_Url3		nvarchar(250),
	@ER_Review_Star		int,
	@company_seq		int,
	@result				INT=0 OUTPUT
AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRAN
			
			declare @id	int;
			DECLARE @temp_key2 as varchar(25)
			DECLARE @temp_key3 as varchar(25)
			DECLARE @temp_key4 as varchar(25)
			DECLARE @JEHU_MSG  as varchar(100)
			DECLARE @CALL_NUM  as varchar(10)
			DECLARE @SALES_GUBUN as varchar(2)

			DECLARE @DEST_INFO     VARCHAR(50)
			SET @DEST_INFO = 'AA^' + @hand_phone
			DECLARE @SEND_MSG     VARCHAR(100)
			
			
			/*리뷰 정보수정*/
			if (@ERA_Coupon_Status=0 and @ERA_Status=1)
				begin
					--쿠폰코드 존재 여부===================================================================================================================
					if @ERA_Coupon_Code = ''
						begin
							if (@company_seq = '5001' or @company_seq = '5007' or @company_seq = '5003')
								begin
									UPDATE S4_Event_Review_Status SET ERA_Comment=@ERA_Comment, ERA_Comment_Cancel=@ERA_Comment_Cancel, ERA_Status=@ERA_Status,
									ERA_Coupon_Status=1, ERA_Coupon_Code=@temp_key where ERA_ER_idx=@ER_Idx
								end
							else
								begin
									UPDATE S4_Event_Review_Status SET ERA_Comment=@ERA_Comment, ERA_Comment_Cancel=@ERA_Comment_Cancel, ERA_Status=@ERA_Status,
									ERA_Coupon_Status=1, ERA_Coupon_Code=@temp_key+'1' where ERA_ER_idx=@ER_Idx
								end
						end
					else
						begin
							UPDATE S4_Event_Review_Status SET ERA_Comment=@ERA_Comment, ERA_Comment_Cancel=@ERA_Comment_Cancel, ERA_Status=@ERA_Status,
							ERA_Coupon_Status=1 where ERA_ER_idx=@ER_Idx
						end

					--===================================================================================================================


					--바른손===================================================================================================================
					if @company_seq='5001'
						begin	
	
							EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', '[바른손카드] 샘플이용후기- 할인쿠폰발급. 마이페이지>쿠폰보관함 확인', '', '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
							
							/* 바른손카드 샘플이용후기 쿠폰 고정 */
							SET @temp_key = 'BRSSAMPLEREVIEWP10000'
							SET @temp_key2 = 'BRSSAMPLEREVIEWP20000'
							SET @temp_key3 = 'BRSSAMPLEREVIEWP30000'

						end
					
					--더카드===================================================================================================================
					if @company_seq='5007'
						begin	

							EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', '[더카드]샘플후기 2만원 할인쿠폰이 발급되었습니다. 마이페이지>쿠폰 보관함 확인', '', '16447998', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''

							INSERT INTO s4_coupon (coupon_code, company_seq, reg_date, discount_type, discount_value, limit_price, isYN, coupon_desc, isRecycle, isWeddingCoupon, isJehu,end_date,item_type)
							 values (@temp_key , @company_seq, GETDATE(),'P',20000,120000,'Y','더카드 2만원 할인쿠폰','N','Y','N',DATEADD(M,2,getdate()),'W1') 
						end

					--프리미어===================================================================================================================
					if @company_seq='5003'
						begin	

							SET @SEND_MSG = '[프리미어페이퍼] 샘플이용후기 감사합니다. 2만원 할인 쿠폰번호:'+@temp_key+''

							EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @SEND_MSG, '', '16448796', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''

							INSERT INTO s4_coupon (coupon_code, company_seq, reg_date, discount_type, discount_value, limit_price, isYN, coupon_desc, isRecycle, isWeddingCoupon, isJehu,end_date,item_type)
							 values (@temp_key , @company_seq, GETDATE(),'P',20000,200000,'Y','프리미어페이퍼 2만원 할인쿠폰','N','Y','N',DATEADD(M,2,getdate()),'W1') 
						end

					--제휴일때===================================================================================================================
					if (@company_seq !='5001' and @company_seq !='5006'  and @company_seq !='5007'  and @company_seq !='5003')
						begin	
							select top 1 
									@JEHU_MSG = (CASE 
													WHEN SALES_GUBUN IN ('B', 'C', 'SA') THEN '[바른손몰] 샘플이용후기-최대 3만원 할인쿠폰발급. 마이페이지>쿠폰보관함 확인'
													WHEN SALES_GUBUN IN ('H') THEN '[프리미어페이퍼] 샘플이용후기 감사합니다. 2만원 할인 쿠폰번호:'+@temp_key+''
													ELSE 'X'
													END) ,
									@CALL_NUM = (CASE 
														WHEN SALES_GUBUN IN ('B', 'C', 'SA') THEN '16449713'
														WHEN SALES_GUBUN IN ('H') THEN '16448796'
														ELSE 'X'
													END) ,
									@SALES_GUBUN = c.SALES_GUBUN		
							FROM	custom_sample_order c , S4_Event_Review e
							where c.member_id = e.er_userid
							and c.COMPANY_SEQ = e.ER_Company_Seq
							and e.er_idx = @ER_Idx
							and member_id = @ER_Userid


							if (@SALES_GUBUN = 'H')
								begin
									INSERT INTO s4_coupon (coupon_code, company_seq, reg_date, discount_type, discount_value, limit_price, isYN, coupon_desc, isRecycle, isWeddingCoupon, isJehu,end_date,item_type)
									values (@temp_key , @company_seq, GETDATE(),'P',20000,200000,'Y','프리미어페이퍼 2만원 할인쿠폰','N','Y','N',DATEADD(M,2,getdate()),'W1') ;

								end 

								
							/*
							insert into invtmng.SC_TRAN (TR_SENDSTAT, TR_SENDDATE, TR_ID, TR_RSLTSTAT,TR_PHONE, TR_CALLBACK, TR_MSG) 
							values ('0' ,GETDATE() ,'SM136890_002' ,'00' ,@hand_phone ,@CALL_NUM ,@JEHU_MSG)
							*/
							EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', '프리미어페이퍼 2만원 할인쿠폰', '', @CALL_NUM, 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''


							SET @TEMP_KEY  = 'BHCPSAMPLE20000_JEHU'
							SET @TEMP_KEY2 = 'BHCPSAMPLE30000_JEHU'
							SET @TEMP_KEY3 = 'BHCPSAMPLE40000_JEHU'
							SET @TEMP_KEY4 = 'BHCPSAMPLE50000_JEHU'

						end


				   --각 사이트별 쿠폰등록===================================================================================================================
				   if (@company_seq = '5007' or @company_seq = '5003')
						begin	
							INSERT INTO S4_MyCoupon (coupon_code, uid, company_seq, end_date )  values (@temp_key , @ER_Userid, @company_seq, DATEADD(M,2,getdate()) )
						end
				   else if @company_seq = '5001'
						begin
							INSERT INTO S4_MyCoupon (coupon_code, uid, company_seq, end_date )  values (@temp_key , @ER_Userid, @company_seq, DATEADD(M,2,getdate()) )
							INSERT INTO S4_MyCoupon (coupon_code, uid, company_seq, end_date )  values (@temp_key2 , @ER_Userid, @company_seq, DATEADD(M,2,getdate()) )
							INSERT INTO S4_MyCoupon (coupon_code, uid, company_seq, end_date )  values (@temp_key3 , @ER_Userid, @company_seq, DATEADD(M,2,getdate()) )
						end
				   else

						begin
							--2016.07.25 프리미어는 S4_MyCoupon에 등록할 필요가 없음. 로직 수정함.
							if (@SALES_GUBUN = 'H')
								begin
									set @company_seq = 5003;
								end
							else
								begin

									set @company_seq = 5006;

									INSERT INTO S4_MyCoupon (coupon_code, uid, company_seq, end_date )  values (@temp_key, @ER_Userid, @company_seq, DATEADD(M,2,getdate()) )
									INSERT INTO S4_MyCoupon (coupon_code, uid, company_seq, end_date ) values (@temp_key2, @ER_Userid, @company_seq, DATEADD(M,2,getdate()) )
									INSERT INTO S4_MyCoupon (coupon_code, uid, company_seq, end_date )  values (@temp_key3, @ER_Userid, @company_seq, DATEADD(M,2,getdate()) )
									INSERT INTO S4_MyCoupon (coupon_code, uid, company_seq, end_date )  values (@temp_key4, @ER_Userid, @company_seq, DATEADD(M,2,getdate()) )
								end

						end	

				end

    		
    		else 
    			begin
    				if @ERA_Status = 0	--승인대기로 변경될 경우 쿠폰상태 변경
    					begin
    						UPDATE S4_Event_Review_Status SET ERA_Comment=@ERA_Comment, ERA_Comment_Cancel=@ERA_Comment_Cancel, ERA_Status=@ERA_Status,
							ERA_Coupon_Status=0 where ERA_ER_idx=@ER_Idx
    					end
    				else if  @ERA_Status = 2    --승인대기로 변경될 경우 쿠폰상태 변경
    					begin

					/* 제휴사 공통 쿠폰 사용으로 인한 COMPANY_SEQ 통일 */
					if @company_seq = '5001'
						begin

							--쿠폰발급 사용처리
						UPDATE S4_MyCoupon
							SET isMyYN = 'N'
							WHERE UID = @ER_Userid
							AND COUPON_CODE IN ('BRSSAMPLEREVIEWP10000', 'BRSSAMPLEREVIEWP20000', 'BRSSAMPLEREVIEWP30000')
							AND company_seq = 5001

							-- 승인상태 변경
						UPDATE S4_Event_Review_Status SET  ERA_Status=@ERA_Status
							 where ERA_ER_idx=@ER_Idx

							--문자발송
							EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', '[바른손카드]발급 조건에 맞지않아 쿠폰이 취소되었습니다.', '', '16440708', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''

						end 
					else	
						begin
						UPDATE S4_MyCoupon
							SET isMyYN = 'N'
							WHERE UID = @ER_Userid
							AND COUPON_CODE IN ('BHCPSAMPLE20000_JEHU','BHCPSAMPLE30000_JEHU','BHCPSAMPLE40000_JEHU','BHCPSAMPLE50000_JEHU')
							AND company_seq = 5006

							-- 승인상태 변경
						UPDATE S4_Event_Review_Status SET  ERA_Status=@ERA_Status
							 where ERA_ER_idx=@ER_Idx

							--문자발송
							EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', '[바른손몰]발급 조건에 맞지않아 쿠폰이 취소되었습니다.', '', '16449713', 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''


						end
    					end
					else
    					begin
    						UPDATE S4_Event_Review_Status SET ERA_Comment=@ERA_Comment, ERA_Comment_Cancel=@ERA_Comment_Cancel, ERA_Status=@ERA_Status
							 where ERA_ER_idx=@ER_Idx
    					end
    			
    			end
    		
    		UPDATE S4_Event_Review SET ER_View=@ER_View, ER_UserName=@ER_UserName, ER_Review_Title=@ER_Review_Title, ER_Review_Url=@ER_Review_Url, ER_Review_Url2=@ER_Review_Url2, ER_Review_Url3=@ER_Review_Url3, ER_Review_Star=@ER_Review_Star where  ER_Idx=@ER_Idx
    		
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

/****** Object:  StoredProcedure [dbo].[SP_BIZTALK_CHECK_SMS]    Script Date: 2020-11-23 오후 2:37:14 ******/
SET ANSI_NULLS ON
GO
