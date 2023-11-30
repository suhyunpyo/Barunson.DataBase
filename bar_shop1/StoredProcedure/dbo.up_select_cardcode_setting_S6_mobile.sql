IF OBJECT_ID (N'dbo.up_select_cardcode_setting_S6_mobile', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_cardcode_setting_S6_mobile
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_select_cardcode_setting_S6_mobile]
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
	@seq	AS nvarchar(20),
	@star_rating1 tinyint,
	@star_rating2 tinyint,
	@star_rating3 tinyint,
	@star_rating4 tinyint,
	@Gift_Code TINYINT = NULL,
	@Review_Reply TEXT = NULL,	
	@img_name1 varchar(50),
	@upimg_name1 varchar(50),
	@img_name2 varchar(50),
	@upimg_name2 varchar(50),
	@img_name3 varchar(50),
	@upimg_name3 varchar(50)
	
AS
	declare @UserComment_seq int

IF @type = 'ins'

	BEGIN
		
		declare @uname varchar(50)
		declare @uhphone varchar(20)
/* 회원정보에서 회원명, 전화번호 조회 하도록 수정 by 15.01.28 khj		
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
*/
select @uname=uname,@uhphone=hand_phone1 + hand_phone2 + hand_phone3 from S2_UserInfo_thecard where uid=@uid		
/*				
		Insert S2_UserComment (sales_gubun,company_seq,card_seq,card_code,order_seq,uid,uname,title,comment,score, upimg, comm_div, resch_color, resch_bright, b_url, star_rating1, star_rating2, star_rating3, star_rating4)
					Values (
		@sgubun,@com_seq,@card_seq,@card_code,@order_seq,@uid
		,@uname,@title,@comment,@score,@upfile,@comm_div,@rcolor,@rbright,@b_url,@star_rating1,@star_rating2,@star_rating3,@star_rating4)
*/	
	
	
	INSERT INTO dbo.S4_Event_Review
	(
		ER_Company_Seq
		, ER_Order_Seq
		, ER_Type
		, ER_Card_Seq
		, ER_Card_Code
		, ER_UserId
		, ER_Regdate
		, ER_Recom_Cnt
		, ER_Review_Title
		, ER_Review_Url
		, ER_Review_Content
		, ER_Review_Star
		, ER_Review_Price
		, ER_Review_Design
		, ER_Review_Quality
		, ER_Review_Satisfaction
		, ER_Status
		, ER_View
		, ER_UserName
		, ER_isBest
		, ER_isPhoto
        , ER_Gift_Code
		, ER_Review_Reply
		, inflow_route           
	)
	VALUES
    ( 
		@com_seq
		, @order_seq
		, 1							--샘플 / 구매 후기 여부 (0 : 샘플 후기, 1 : 구매 후기)
		, @card_seq
		, @card_code
		, @uid
		, GETDATE()
		, 0							-- 추천수
		, @title
		, @b_url
		, @comment
		, @star_rating1 + @star_rating2 + @star_rating3 + @star_rating4
		, @star_rating1
		, @star_rating2
		, @star_rating3
		, @star_rating4
		, 0							--글 삭제 여부 (0 : 정상, 1 : 삭제)
		, 0							--전시여부 (0,1)?
		, @uname
		, 0	--BEST 여부 (0 : 일반, 1 : 베스트)
		, @comm_div --일반/포토 여부 (0 : 일반, 1 : 포토)
		, @Gift_Code -- 이용후기 사은품 (1 : 요구르트제조기, 2 : 전기주전자, 3 : 계란찜기, 4 : 토스터, 5 : 와플메이커)
		, @Review_Reply
		, 'MOBILE'
	)
	
	-- 이미지 파일명 저장
	if @img_name1 <> '' OR  @img_name2 <> '' OR  @img_name3 <> ''
		begin 
			select @UserComment_seq=ER_Idx
			from S4_Event_Review
			where ER_order_Seq = @order_seq
			AND   ER_UserId = @uid
		End 

	if @img_name1 <> ''
		begin	
			insert S2_UserComment_photo_the (seq, img_name, upimg_name) Values (@UserComment_seq,@img_name1,@upimg_name1)
		end

	if @img_name2 <> ''
		begin
			insert S2_UserComment_photo_the (seq, img_name, upimg_name) Values (@UserComment_seq,@img_name2,@upimg_name2)
		end 

	if @img_name3 <> ''
		begin
			insert S2_UserComment_photo_the (seq, img_name, upimg_name) Values (@UserComment_seq,@img_name3,@upimg_name3)
		end 


		--select ER_View,* from S4_Event_Review
	--셀레모쿠폰발급 2017-02-06추가
	--EXEC SP_INSERT_CELEMO_COUPON @uid , '5007'

	
	END
	
ELSE IF @type = 'del'

	BEGIN
	
		--Delete dbo.S4_Event_Review Where ER_Idx=@seq	
		UPDATE dbo.S4_Event_Review SET ER_Status = 1 WHERE ER_Idx=@seq	
		select 2	
		
	END
	
ELSE IF @type = 'edt'

	BEGIN
	
	UPDATE 
		dbo.S4_Event_Review
	SET 
		  ER_Review_Title			= @title
		, ER_Review_Content			= @comment
		, ER_Review_Star			= @score
		, ER_Review_Price			= @star_rating1
		, ER_Review_Design			= @star_rating2
		, ER_Review_Quality			= @star_rating3
		, ER_Review_Satisfaction	= @star_rating4
        , ER_Card_Seq				= @card_seq
        , ER_Card_Code				= @card_code
		, ER_Review_Url				= @b_url
		, ER_isPhoto				= @comm_div
		, ER_Gift_Code				= @Gift_Code
		, ER_Review_Reply			= @Review_Reply		
		, ER_Regdate				= GETDATE()
		
	Where 
		ER_Idx=@seq
	

	--기존 파일을 삭제한다.
	/*
	delete from S2_UserComment_photo_the
	where seq = @seq
		
	if @img_name1 <> ''
		begin	
			insert S2_UserComment_photo_the (seq, img_name, upimg_name) Values (@UserComment_seq,@img_name1,@upimg_name1)
		end

	if @img_name2 <> ''
		begin
			insert S2_UserComment_photo_the (seq, img_name, upimg_name) Values (@UserComment_seq,@img_name2,@upimg_name2)
		end 

	if @img_name3 <> ''
		begin
			insert S2_UserComment_photo_the (seq, img_name, upimg_name) Values (@UserComment_seq,@img_name3,@upimg_name3)
		end 
	*/
END
	
ELSE IF @type = 'list'

	BEGIN
/*
		select
			A.seq,A.card_seq,A.order_seq,A.title,A.score,convert(varchar(10), A.reg_date, 120) reg_date,B.card_code
		, B.Card_Image, A.upimg, A.comment, A.b_url
		, star_rating1, star_rating2, star_rating3, star_rating4
		from 
		S2_UserComment A JOIN S2_card B ON A.CARD_SEQ=B.CARD_SEQ
		where
		A.COMPANY_SEQ = @com_seq 
		AND A.UID = @uid		
*/
		SELECT 
				A.ER_Idx	
			  , A.ER_Card_Seq					
			  , A.ER_Order_Seq	
			  , A.ER_Review_Title
			  , A.ER_Review_Star
			  , CONVERT(VARCHAR(10), A.ER_Regdate, 120) AS reg_date
			  , A.ER_Card_Code
			  , B.Card_Image
			  ,	A.ER_Review_Content
			  , ISNULL(A.ER_Review_Url, '') ER_Review_Url
			  ,	A.ER_Review_Price
			  ,	A.ER_Review_Design
			  ,	A.ER_Review_Quality
			  ,	A.ER_Review_Satisfaction
			  , A.ER_isPhoto
			  , A.ER_Gift_Code
			  , A.ER_Review_Reply			  
		  FROM 
				dbo.S4_Event_Review A JOIN S2_card B ON A.ER_Card_Seq = B.CARD_SEQ
		  WHERE
				A.ER_Company_Seq = @com_seq AND A.ER_UserId = @uid
				AND A.ER_Status = 0	
		  ORDER BY A.ER_Idx DESC
	END
	
	
ELSE

	select 1
GO
