IF OBJECT_ID (N'dbo.up_Select_S4_EventMusic_Str_Insert_S4_EventMusic_Reply_For_SAMSUNGELECT', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Select_S4_EventMusic_Str_Insert_S4_EventMusic_Reply_For_SAMSUNGELECT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		시스템지원팀, 장형일 과장
-- Create date: 2015-07-02
-- Description:	프론트, 삼성전자이벤트-청첩장+혼수가전_공항이용, 이벤트 참여 가능 체크 및 이벤트 참여

-- EXEC up_Select_S4_EventMusic_Str_Insert_S4_EventMusic_Reply_For_SAMSUNGELECT 1, 84, 'SA', 'bhandstest', 5006
-- EXEC up_Select_S4_EventMusic_Str_Insert_S4_EventMusic_Reply_For_SAMSUNGELECT 2, 84, 'SA', 'bhandstest', 5006
-- =============================================
CREATE proc [dbo].[up_Select_S4_EventMusic_Str_Insert_S4_EventMusic_Reply_For_SAMSUNGELECT]

	@gubun					smallint   -- 1 : 이벤트 참여 조건 체크, 2 : 이벤트 참여
	, @event_seq			int
	, @sales_gubun			varchar(2)
	, @uid					varchar(100)
	, @company_seq			int
	

as

set nocount on;

declare @rtnResult smallint, @rtnMsg varchar(100)


if @gubun = 1   --이벤트 참여 가능 체크
	begin
		
		if exists(select seq from S4_EventMusic_Str where seq = @event_seq and (convert(varchar(10), getdate(), 121) between start_date and end_date))
			begin
				
				if exists (select * from S4_EventMusic_Reply where company_seq  = @company_seq and reg_num = @event_seq and uid = @uid)
					begin

						set @rtnResult = 2
						set @rtnMsg = '이미 이벤트에 참여 하셨습니다.'

					end
				else if ( (@sales_gubun = 'SA' or @sales_gubun = 'B') 
						and (select chk_smembership from S2_UserInfo_BHands where uid = @uid and convert(varchar(10),reg_date,121) >= '2013-07-01') = 'Y'  )
					or 
					( (@sales_gubun = 'ST')
						and (select chk_smembership from S2_UserInfo_TheCard where uid = @uid and convert(varchar(10),reg_date,121) >= '2013-07-01') = 'Y'  )
					or 
					( (select chk_smembership from S2_UserInfo where uid = @uid and convert(varchar(10),reg_date,121) >= '2013-07-01') = 'Y'  )

					begin

						set @rtnResult = 1
						set @rtnMsg = '삼성전자 동의 체크'
						
					end
				else
					begin

						set @rtnResult = 0
						set @rtnMsg = '삼성전자 동의 미체크'

					end

			end
		else
			begin

				set @rtnResult = 2
				set @rtnMsg = '이벤트 기간이 아닙니다.'

			end

		
		select @rtnResult as result, @rtnMsg as msg
		
	end

else if @gubun = 2 
	begin

		declare @uname varchar(50)

		if @sales_gubun = 'SA' or @sales_gubun = 'B'
			begin

				if not exists (select uid from S2_UserInfo_BHands where uid = @uid and chk_smembership = 'Y')
					begin
						update S2_UserInfo_BHands
						set chk_smembership = 'Y', smembership_reg_date = GETDATE()
						where uid = @uid
					end

				select @uname = uname
				from S2_UserInfo_BHands
				where uid = @uid

			end

		else if @sales_gubun = 'ST'
			begin
				
				if not exists (select uid from S2_UserInfo_TheCard where uid = @uid and chk_smembership = 'Y')
					begin
						update S2_UserInfo_TheCard
						set chk_smembership = 'Y', smembership_reg_date = GETDATE()
						where uid = @uid

					end
				
				select @uname = uname
				from S2_UserInfo_TheCard
				where uid = @uid

			end

		else
			begin

				if not exists (select uid from S2_UserInfo_TheCard where uid = @uid and chk_smembership = 'Y')
					begin
						update S2_UserInfo
						set chk_smembership = 'Y', smembership_reg_date = GETDATE()
						where uid = @uid
					end

				select @uname = uname
				from S2_UserInfo
				where uid = @uid

			end

		if not exists (select * from S4_EventMusic_Reply where company_seq  = @company_seq and reg_num = @event_seq and uid = @uid)
			begin
				insert into S4_EventMusic_Reply
				(
					company_seq, reg_num, uid, uname, umail, comment
				)
				values
				(
					@company_seq, @event_seq, @uid, @uname, '', '삼성전자이벤트-청첩장+혼수가전_공항이용 참여'
				)
			end

		set @rtnResult = 1
		set @rtnMsg = '이벤트 참여에 성공하였습니다.'

		select @rtnResult as result, @rtnMsg as msg

	end















GO
