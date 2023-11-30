IF OBJECT_ID (N'dbo.sp_Insert_S2Review_bhands', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_Insert_S2Review_bhands
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김수경
-- Create date: 2012.11.08
-- Description:	고객 이용후기 작성 저장 & 담당자에게 메일 보내기

-- 2018.08.27
-- 비핸즈 평가 : 가격 추가 resch_price 
-- =============================================
CREATE PROCEDURE [dbo].[sp_Insert_S2Review_bhands]
	@sgubun varchar(2),
	@com_seq integer,
	@card_seq integer,
	@card_code varchar(20),
	@order_seq integer,
	@uid varchar(100),
	@title varchar(100),
	@comment text,
	@comment_min varchar(2000),
	@score tinyint,
	@upfile varchar(50),
	@comm_div char(1),
	@rcolor tinyint,
	@rbright tinyint,
	@rprice tinyint,
	@b_url varchar(2000)
	
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @uname varchar(50)
	declare @uhphone varchar(20)
	
	if @order_seq > 0 
		select @uname=order_name,@uhphone=order_hphone from custom_order where order_seq=@order_seq
	else	
	begin
		if @sgubun='SB' or @sgubun='SS' or @sgubun='H'
			select @uname=uname,@uhphone=hand_phone1 + hand_phone2 + hand_phone3 from S2_UserInfo where uid=@uid
		else if @sgubun='SA'
			select @uname=uname,@uhphone=hand_phone1 + hand_phone2 + hand_phone3 from S2_UserInfo_bhands where uid=@uid
		else if @sgubun='SA'
			select @uname=uname,@uhphone=hand_phone1 + hand_phone2 + hand_phone3 from S2_UserInfo_thecard where uid=@uid
		else
		begin
			set @uname = ''
			set @uhphone='16440708'
		end
	end
	


    /* Photo 후기 체크 */
    /* 바른손카드만 사용 */
    IF UPPER(@sgubun) = 'SB' OR UPPER(@sgubun) = 'SA' 
        BEGIN
            
            -- P : Photo후기
            -- T : Text후기
            -- 이미지 태그가 있으면 Photo후기로 분류한다.
            BEGIN TRY
                SET @comm_div = CASE 
                                        WHEN (CAST(@comment AS XML)).exist('//img') = 1 
                                        THEN 'P' 
                                        ELSE 'T' 
                                END
            END TRY
            BEGIN CATCH
                SET @comm_div = CASE 
                                        WHEN CHARINDEX('<IMG', UPPER(CAST(@comment AS VARCHAR(MAX)))) > 0
                                        THEN 'P'
                                        ELSE 'T'
                                END
            END CATCH

        END

	Insert S2_UserComment (sales_gubun,company_seq,card_seq,card_code,order_seq,uid,uname,title,comment,score, upimg, comm_div, resch_color, resch_bright, resch_price, b_url)
				Values (
	@sgubun,@com_seq,@card_seq,@card_code,@order_seq,@uid
	,@uname,@title,@comment,@score,@upfile,@comm_div,@rcolor,@rbright,@rprice, @b_url)
	
	if ( @score <=2 ) 		--2점 이하인 경우 담당자에게 메일과 SMS 전송
	begin
		declare @isSMS char(1)
		declare @email varchar(100)
		declare @name varchar(50)
		declare @hphone varchar(20)
		declare @sms_msg varchar(70)
		declare @sgubun_str varchar(30)
		declare @email_title varchar(500)
		declare @email_msg varchar(5000)
		
		select @sgubun_str=code_value from manage_code where code_type='sales_gubun' and code=@sgubun
		
		set @sms_msg = @sgubun_str + '/' + @uname + '/' + @uid + '/' + left(@title,20)
		
		set @email_title = @sgubun_str + ' 이용후기 확인하세요'
		set @email_msg = '회원아이디:' +  @uid +', 이름: ' + @uname + ',주문번호:' + cast(@order_seq as varchar(20))
		set @email_msg = @email_msg + '<br><br>제목:' +  @title
		set @email_msg = @email_msg + '<br><br>' +  @comment_min
		if (LEN(@comment_min)=2000)set @email_msg += '<br>...(중략)'
		
		DECLARE item_cursor CURSOR
		FOR 		
		select admin_name,admin_mail,admin_hphone,is_reviewSMS from S2_AdminList where is_reviewMail='Y'
		OPEN item_cursor
		FETCH NEXT FROM item_cursor INTO @name,@email,@hphone,@isSMS
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			exec sp_sendtNeoMail_wedd @sgubun_str,'no-reply@barunson.com',@name,@email,@email_title,@email_msg
	
			if (@isSMS = 'Y')
			begin
				exec invtmng.sp_DacomSMS @hphone,@uhphone,@sms_msg
			end
		FETCH NEXT FROM item_cursor  INTO @name,@email,@hphone,@isSMS

		END			-- end of while
		CLOSE item_cursor
		DEALLOCATE item_cursor
	
	end
END

GO
