IF OBJECT_ID (N'dbo.up_Select_UserReview_List', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Select_UserReview_List
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
/*
	작성정보   : 조창연
	관련페이지 : product > detail.asp
	내용	   : 상품 이용후기
	
	수정정보   : 

	exec up_Select_UserReview_List 5007, 34700, 1, 10, 1, NULL, NULL
*/
-- =============================================
CREATE PROCEDURE [dbo].[up_Select_UserReview_List]
	
	@company_seq INT,		-- 회사고유코드
	@card_seq	 INT,		-- 제품코드
	@page		 INT,		-- 페이지 번호
	@pagesize	 INT,		-- 페이지 사이즈
	@isType		 INT,		-- 후기 종류 (0 : 샘플, 1 : 구매)
	@isBest		 INT,		-- BEST 여부 (0 : 일반, 1 : BEST)
	@isPhoto	 INT		-- 포토후기 여부 (0 : 일반, 1 : 포토)
	
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
	
	/*
	DECLARE @company_seq int = 5007
	DECLARE @card_seq	 int = 34700
	DECLARE @page		 int = 1
	DECLARE @pagesize	 int = 10
	DECLARE @isType		 int = 1	
	DECLARE @isBest		 int = 1
	DECLARE @isPhoto	 int = 0 
	*/
	
	DECLARE @Cnt INT
	
	-- 이용후기 게시물 갯수 --
	SELECT @Cnt = COUNT(ER_Idx) --AS Cnt
	FROM S4_Event_Review
	WHERE 1 = 1
	  AND ER_Card_Seq = @card_seq
	  AND ER_Type = @isType
	  AND ER_isBest = ISNULL(@isBest, ER_isBest)
	  AND ER_isPhoto = ISNULL(@isPhoto, ER_isPhoto) 
	  AND ER_Status = 0	--삭제 여부
	  AND ER_View = 0	--전시 여부
	
	SELECT @Cnt AS Cnt
	-- 이용후기 게시물 갯수 --  	
	
	
	-- 이용후기 게시물 페이지 크기만큼 호출 --	 
	--SELECT @Cnt - ((@page - 1) * @pagesize) - RowNum + 1 AS Num, * 
	--페이징 카운트 안맞아서 재수정(김덕중)
	SELECT @Cnt - RowNum + 1 AS Num, * 
	FROM
	(			
		SELECT   ROW_NUMBER() OVER (ORDER BY ER_Idx DESC) AS RowNum
				,ER_Idx
				,ER_Review_Title
				,ER_Review_Content
				,ISNULL(ER_Review_Star, 0) AS ER_Review_Star
				,ISNULL(ER_Review_Price, 0) AS ER_Review_Price 
				,ISNULL(ER_Review_Design, 0) AS ER_Review_Design
				,ISNULL(ER_Review_Quality, 0) AS ER_Review_Quality
				,ISNULL(ER_Review_Satisfaction, 0) AS ER_Review_Satisfaction
				,ER_isBest
				,ER_isPhoto
				,ER_View
				,ISNULL(ER_Review_Url, '') AS ER_Review_Url
				,ER_UserId
				,ER_UserName
				,ER_Regdate 
		FROM S4_Event_Review
		WHERE 1 = 1
		  AND ER_Card_Seq = @card_seq
		  AND ER_Type = @isType
		  AND ER_isBest = ISNULL(@isBest, ER_isBest)
		  AND ER_isPhoto = ISNULL(@isPhoto, ER_isPhoto)
		  AND ER_Status = 0	--삭제 여부
		  AND ER_View = 0	--전시 여부
	) AS RESULT
	WHERE RowNum BETWEEN ( ( (@page - 1) * @pagesize ) + 1 ) AND ( @page * @pagesize )
	-- 이용후기 게시물 페이지 크기만큼 호출 --
	
END


/*
select * FROM S4_Event_Review order by ER_Idx desc

insert into S4_Event_Review (ER_Company_Seq, ER_Order_Seq, ER_Type, ER_Card_Seq, ER_Card_Code, ER_UserId, ER_Regdate,
ER_Recom_Cnt, ER_Review_Title, ER_Review_Url, ER_Review_Content, ER_Review_Star, ER_Review_Price, ER_Review_Design, 
ER_Review_Quality, ER_Review_Satisfaction, ER_Status, ER_View, ER_UserName, ER_isBest, ER_isPhoto) values (
5007, 123456, 1, 34700, 0000, 'donald1', GETDATE(), 1, '후기 테스트4', 'http://cafe.naver.com/anyrespect/93501', '내용입니다4', 5, 4, 3, 2, 1, 0, 0, '김더준1', 0, 0
)
*/
GO
