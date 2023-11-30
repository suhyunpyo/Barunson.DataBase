IF OBJECT_ID (N'dbo.up_select_supporters_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_supporters_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec up_select_supporters_list '', '', 'list', '', 5007, '','','','','','','','','','','','',0,0,0,0,0,'',1,10
--exec up_select_supporters_list '', '', 'list', '', 5007, '','','','','','','','','','','','',0,0,0,0,0,'',2,10
--exec up_select_supporters_list '', '', 'list', '', 5007, '','','','','','','','','','','','',0,0,0,0,0,'',3,10

CREATE PROCEDURE [dbo].[up_select_supporters_list]
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
	@b_url varchar(2000),      -- 리스트일경우 검색조건 파라미터로 사용
	-----삭제-----------------------
	@seq	AS nvarchar(20),
	@star_rating1 tinyint,
	@star_rating2 tinyint,
	@star_rating3 tinyint,
	@star_rating4 tinyint,

	@Gift_Code TINYINT = NULL,
	@Review_Reply TEXT = NULL,
	@page				AS INT,				
	@pagesize			AS INT
		
	
AS

IF @type = 'first'
	BEGIN
		
		SELECT 
			  b.card_seq
			, (select card_code from s2_card a where a.Card_Seq = b.card_seq) card_code
			, isnull((select c.ER_Idx from S4_Event_Review c where c.ER_Order_Seq = b.order_seq),0) seq
			, b.order_seq
		FROM 
			dbo.custom_order b
		WHERE 
			b.member_id =@uid
			AND status_seq = 15
				
	END

ELSE IF @type = 'list'

	BEGIN
		SELECT 
			COUNT(ER_Idx) AS tot
		FROM 
			dbo.S4_Event_Review A
		WHERE
			A.ER_Company_Seq = @com_seq
			AND A.ER_View = 0
			AND A.ER_Type = 15
			--AND A.ER_Status = 0
			--AND ( ISNULL(@b_url, '') = '' OR A.ER_Card_Code LIKE '%' + @b_url + '%' OR B.Card_Name LIKE '%' + @b_url+ '%' )

		SELECT TOP (@pagesize) 
				A.ER_Idx	
			  , A.ER_Card_Seq					
			  , A.ER_Order_Seq	
			  , A.ER_Review_Title
			  , A.ER_Review_Star
			  , CONVERT(VARCHAR(10), A.ER_Regdate, 120) AS reg_date
			  , A.ER_Card_Code
			  ,	A.ER_Review_Content
			  , ISNULL(A.ER_Review_Url, '') ER_Review_Url
			  ,	ISNULL(A.ER_Review_Url_a, '') sns_url_1
			  ,	ISNULL(A.ER_Review_Url_b, '') sns_url_2
			  , A.ER_Review_Reply
			  , A.ER_UserName	
			  , A.ER_UserId	
			  , A.ER_Regdate
		  FROM 
				dbo.S4_Event_Review A
		  WHERE
				A.ER_Company_Seq = 5007 
				--A.ER_Company_Seq = 5007
				AND A.ER_Type = 15
				AND A.ER_View = 0
				AND A.ER_Idx NOT IN (SELECT TOP (@pagesize * (@page - 1)) A.ER_Idx FROM dbo.S4_Event_Review A WITH(NOLOCK) WHERE  A.ER_Company_Seq = 5007 AND A.ER_Type = 15 AND A.ER_View = 0 ORDER BY a.ER_IDX DESC)

		  ORDER BY A.ER_Idx DESC
	END
	
	
ELSE

	select 1 
GO
