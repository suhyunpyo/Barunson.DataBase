IF OBJECT_ID (N'dbo.up_select_cardcode_setting', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_cardcode_setting
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		zen
-- Create date: 2014-07-12
-- Description:	이용후기 쓰기 할때 카드코드값 세팅
-- [up_select_cardcode_setting] 'phs8761','1970459','first','','','','','','','','','','','','','',''
-- [up_select_cardcode_setting] 'phs8761','1970459','list','','5007','','','','','','','','','','','',''
-- [up_select_cardcode_setting] 'phs8761','1970459','insert','','','','','','','','','','','','','',''
-- [up_select_cardcode_setting] 'phs8761','1970459','del','','','','','','','','','','','','','','53764'

-- =============================================
CREATE PROCEDURE [dbo].[up_select_cardcode_setting]
	-- Add the parameters for the stored procedure here
	
	@uid	AS nvarchar(20),
	@order_seq AS nvarchar(20),
	@type AS nvarchar(20),
	-----인써트-----------------------
	@sgubun varchar(2),
	@com_seq integer,
	@card_seq integer,
	@card_code varchar(20),	
	@title varchar(100),
	@comment text,
	@comment_min varchar(2000),
	@score tinyint,
	@upfile varchar(50),
	@comm_div char(1),
	@rcolor tinyint,
	@rbright tinyint,
	@b_url varchar(2000),
	-----삭제-----------------------
	@seq	AS nvarchar(20)
	
AS


IF @type = 'first'
	BEGIN
		
	
		
		select b.card_seq, (select card_code from s2_card a where a.Card_Seq = b.card_seq) card_code
		, isnull((select c.seq from S2_UserComment c where c.order_seq = b.order_seq),0) seq
		, b.order_seq
		from custom_order b
		where b.member_id =@uid
		and b.status_seq = 15 and b.trouble_type=0
				
	END
	
ELSE IF @type = 'insert'

	BEGIN
		
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
			
		--이용후기 인써트	
		Insert S2_UserComment (sales_gubun,company_seq,card_seq,card_code,order_seq,uid,uname,title,comment,score, upimg, comm_div, resch_color, resch_bright, b_url)
					Values (
		@sgubun,@com_seq,@card_seq,@card_code,@order_seq,@uid
		,@uname,@title,@comment,@score,@upfile,@comm_div,@rcolor,@rbright,@b_url)
		
		-- NTHER2020140714(뉴더카드 이용후기_감사장 20%	
			
		insert into S4_MyCOUPON (coupon_code, uid, company_seq, isMyYn) 
		values 
		('NTHER2020140714', @uid, '5007', 'Y')
		
		
	END
	
ELSE IF @type = 'del'

	BEGIN
	
		Delete S2_UserComment Where seq=@seq	
		
		select 2	
		
	END
	
ELSE IF @type = 'edit'

	BEGIN
	
	update S2_UserComment
	set title = @title
	,comment = @comment
	,score = @score
	,comm_div = @comm_div
	,b_url = @b_url
	Where seq=@seq
		
		
		
	END
	
	
ELSE IF @type = 'list'

	BEGIN
		select
		A.seq,A.card_seq,A.order_seq,A.title,A.score,convert(varchar(10), A.reg_date, 120) reg_date,B.card_code
		, B.Card_Image, A.upimg, A.comment
		from 
		S2_UserComment A JOIN S2_card B ON A.CARD_SEQ=B.CARD_SEQ
		where
		A.COMPANY_SEQ = @com_seq 
		AND A.UID = @uid		
		
	END
	
	
ELSE

	select 1




GO
