IF OBJECT_ID (N'dbo.UP_SELECT_REALBOARD_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.UP_SELECT_REALBOARD_LIST
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/***************************************************************   
작성자 : 표수현  
작성일 : 2022-05-31  
DESCRIPTION : 바른손몰 - 리얼 후기 리스트 
SPECIAL LOGIC :

[UP_SELECT_REALBOARD_LIST]  3, 1, 5, 37298

exec UP_SELECT_REALBOARD_LIST @GUBUN=1, @PAGE_NO=37, @PAGE_SIZE=5, @SEARCH_CARD_SEQ=37298, @SORT_DESC=1
******************************************************************  
MODIFICATION  
******************************************************************  
수정일           작업자                DESCRIPTION  
==================================================================  
2023-08-21		김광호				리뷰 집계 테이블 사용
******************************************************************/  
CREATE PROCEDURE [dbo].[UP_SELECT_REALBOARD_LIST]

	@GUBUN INT = 1,						--1: 이용후기 / 2: 샘플후기 
	@PAGE_NO INT = 1,
	@PAGE_SIZE INT = 5, 
	@SEARCH_CARD_SEQ INT = Null,		--우선순위 높음. 값이 있으면 아래 CardCode는 무시됨.
	@SEARCH_CARD_CODE varchar(100) = Null,
	@SORT_DESC INT = 1
AS  
BEGIN 
	SET NOCOUNT ON;  
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	IF @SORT_DESC NOT IN (1,2,3)
	BEGIN
		SET  @SORT_DESC = 1;
	END 

	IF @SEARCH_CARD_SEQ is not null
	BEGIN
		SET @SEARCH_CARD_CODE = NULL;
	END

	DECLARE @TOTALCNT INT, @OrderReviewCount int,  @SampleReviewCount int;

	-- 이용후기는 전체 사이트
	-- 샘플 리뷰는 몰 사이트 
	-- 특정카드 리뷰와 전채 리뷰 의 집계조건이 다르기 때문에 쿼리가 다르게 실행되어야 함.
	-- 카드선택 검색은 샘플 주문에 포함된 모든 리뷰로 출력하기 때문에 전채 리뷰에서는 동일카드가 중복발생됨, 별도로 집계 계산된 Colume 값으로 읽어옴
	If @SEARCH_CARD_SEQ is Null
	  begin
		Select	@OrderReviewCount = IsNull(sum(OrderReviewCount), 0)
		from	Custom_Order_Review_Count A 
			INNER JOIN  S2_CARD B ON A.CardSeq= B.CARD_SEQ
		Where	(@SEARCH_CARD_CODE is Null Or B.Card_Code Like '%' + @SEARCH_CARD_CODE + '%');

		Select	@SampleReviewCount = IsNull(sum(RealSampleReviewCount), 0) 
		from	Custom_Order_Review_Count A 
			INNER JOIN  S2_CARD B ON A.CardSeq= B.CARD_SEQ 
		Where	A.CompaySeq in (Select COMPANY_SEQ From COMPANY Where  sales_gubun in ('B', 'H','C'))
		AND		(@SEARCH_CARD_CODE is Null Or B.Card_Code Like '%' + @SEARCH_CARD_CODE + '%');
	  End
	ELSE
	  Begin
		Select	@OrderReviewCount = IsNull(sum(OrderReviewCount), 0)
		from	Custom_Order_Review_Count A 
			INNER JOIN  S2_CARD B ON A.CardSeq= B.CARD_SEQ 
		Where	A.CardSeq = @SEARCH_CARD_SEQ;

		Select	@SampleReviewCount = IsNull(sum(SampleReviewCount), 0) 
		from	Custom_Order_Review_Count A 
			INNER JOIN  S2_CARD B ON A.CardSeq= B.CARD_SEQ 
		Where	CardSeq = @SEARCH_CARD_SEQ
		And		CompaySeq in (Select COMPANY_SEQ From COMPANY Where  sales_gubun in ('B', 'H','C'));
	  End

	Set @TOTALCNT = @OrderReviewCount + @SampleReviewCount;

	-- otal
	Select @TOTALCNT;
	-- 이용후기 
	Select @OrderReviewCount;
	-- 샘플후기
	Select @SampleReviewCount;

	IF @GUBUN = 1 
	  BEGIN -- 이용후기 
		SELECT	S = 1, 
				GUBUN = '구매', 
				A.[UID], 
				A.UNAME, 
				A.TITLE, 
				A.SCORE,
				A.REG_DATE,
				A.COMM_DIV,
				A.ISDP, 
				COMMENT = REPLACE(CONVERT(VARCHAR(MAX),A.COMMENT), 'http://','https://'), 
				CARD_IMAGE = B.CARD_IMAGE,
				A.ISBEST,
				ER_IDX = A.SEQ, ER_ORDER_SEQ= A.Order_Seq, ER_USERID= A.[UID], ER_REGDATE = A.REG_DATE, ER_RECOM_CNT= '', 
				ER_REVIEW_TITLE = A.TITLE, ER_REVIEW_URL = ISNULL(A.B_URL, '')  , ER_REVIEW_STAR = A.SCORE, ER_STATUS = 0, ER_VIEW = 0, ER_REVIEW_CONTENT = '', ER_USERNAME = '', 
				ERA_STATUS = '', ERA_COUPON_STATUS = 0, ERA_COMMENT = (select uc_comment from S2_UserComment_reply where uc_seq=A.SEQ), ERA_COUPON_CODE = '', ERA_COMMENT_CANCEL = '', 
				ER_REVIEW_URL_A = '',ER_REVIEW_URL_B = '', ER_REVIEW_URL2 = '' , 
				ER_COMMENT = '', ER_ISPHOTO = '',
				ER_CARD_SEQ = B.CARD_SEQ,
				ER_CARD_CODE =	B.Card_Code ,
				ER_CARDIMAGE = '', 
				CARDCODE_CARDIMAGE = '',
				FIRST_UPLOAD_PHOTO = '',
				A.Company_seq as Company_seq,
				STUFF((select ','+upimg_name from S2_UserComment_photo As C where C.seq = A.seq  order by seq  for xml path('')),1,1,'') as img_nm
		FROM	S2_UserComment as A 
			INNER JOIN S2_CARD as B ON A.CARD_SEQ = B.CARD_SEQ 
		WHERE	A.ISDP=1 
		AND 	(@SEARCH_CARD_SEQ is Null Or A.CARD_SEQ= @SEARCH_CARD_SEQ  )
		AND		(@SEARCH_CARD_CODE is Null Or B.Card_Code Like '%' + @SEARCH_CARD_CODE + '%')
		ORDER BY (CASE WHEN @SORT_DESC = 1 THEN  A.REG_DATE --등록일
					WHEN @SORT_DESC = 2 THEN  A.ISBEST --베스트후기 
					WHEN @SORT_DESC = 3 THEN  A.SCORE --고객만족도 
				END) DESC,  A.REG_DATE DESC
	
		OFFSET (@PAGE_NO-1) * @PAGE_SIZE ROW
		FETCH NEXT @PAGE_SIZE ROW ONLY;

	  END 
	ELSE 
	  BEGIN -- 샘플후기, 샘플 리뷰는 몰 사이트 
		If @SEARCH_CARD_SEQ is Null
		  Begin
			SELECT	S = 2,  
					GUBUN = '샘플', 
					[UID] = ER_USERID, 
					UNAME = ER_USERNAME, 
					TITLE = ER_REVIEW_TITLE, 
					SCORE = ER_REVIEW_STAR, 
					REG_DATE = ER_REGDATE,
					COMM_DIV = 'T',
					ISDP = '1', 
					COMMENT = ISNULL(ER_COMMENT,ER_REVIEW_URL),
					CARD_IMAGE = B.CARD_IMAGE,
					ISBEST = ER_ISBEST,
					ER_IDX, ER_ORDER_SEQ, ER_USERID, ER_REGDATE, ER_RECOM_CNT, 
					ISNULL(ER_REVIEW_TITLE,'') AS ER_REVIEW_TITLE, ISNULL(ER_REVIEW_URL, '') AS ER_REVIEW_URL , 
					ER_REVIEW_STAR, ER_STATUS, ER_VIEW, ER_REVIEW_CONTENT, ER_USERNAME, 
					ERA_STATUS, ERA_COUPON_STATUS, ISNULL(ERA_COMMENT,'') AS ERA_COMMENT, ERA_COUPON_CODE, ISNULL(ERA_COMMENT_CANCEL,'') AS ERA_COMMENT_CANCEL, 
					ISNULL(ER_REVIEW_URL_A, '') AS ER_REVIEW_URL_A, ISNULL(ER_REVIEW_URL_B, '') AS ER_REVIEW_URL_B, ISNULL(ER_REVIEW_URL2, '') AS ER_REVIEW_URL2 , 
					ER_COMMENT = ISNULL(ER_COMMENT,ER_REVIEW_URL), ER_ISPHOTO,
					ER_CARD_SEQ =	B.CARD_SEQ,
					ER_CARD_CODE =	B.CARD_CODE,
					ER_CARDIMAGE =  B.CARD_IMAGE,
					CARDCODE_CARDIMAGE = CONCAT(B.CARD_SEQ ,'^' , B.CARD_CODE , '^' , B.CARD_IMAGE ),
					A.ER_Company_Seq as Company_seq,
					STUFF((select ','+upimg_name from S4_Event_Review_photo where seq = A.ER_Idx order by S4_Event_Review_PHOTO_SEQ  for xml path('')),1,1,'') as img_nm
			FROM	S4_EVENT_REVIEW A 
				INNER JOIN S2_CARD B ON a.ER_Card_Seq = B.CARD_SEQ  
				LEFT OUTER JOIN  S4_EVENT_REVIEW_STATUS C ON  A.ER_IDX = C.ERA_ER_IDX 
			WHERE	A.ER_TYPE = 0 
			AND		A.ER_VIEW = 0  --전시 / 0 -> 비노출 / 1
			And		A.ER_Status = 1
			And		A.ER_Company_Seq  in (Select COMPANY_SEQ From COMPANY Where  sales_gubun in ('B', 'H','C'))
			And		(@SEARCH_CARD_CODE is Null Or B.Card_Code Like '%' + @SEARCH_CARD_CODE + '%')
			ORDER BY  (CASE WHEN @SORT_DESC = 1 THEN  A.ER_REGDATE --등록일
				WHEN @SORT_DESC = 2 THEN  A.ER_ISBEST --베스트후기 
				WHEN @SORT_DESC = 3 THEN  A.ER_REVIEW_STAR --고객만족도 
			END) DESC ,  A.ER_REGDATE DESC
		
			OFFSET (@PAGE_NO-1) * @PAGE_SIZE ROW
			FETCH NEXT @PAGE_SIZE ROW ONLY;
		  End 
		Else 
		  Begin
			SELECT	S = 2,  
					GUBUN = '샘플', 
					[UID] = ER_USERID, 
					UNAME = ER_USERNAME, 
					TITLE = ER_REVIEW_TITLE, 
					SCORE = ER_REVIEW_STAR, 
					REG_DATE = ER_REGDATE,
					COMM_DIV = 'T',
					ISDP = '1', 
					COMMENT = ISNULL(ER_COMMENT,ER_REVIEW_URL),
					CARD_IMAGE = B.CARD_IMAGE,
					ISBEST = ER_ISBEST,
					ER_IDX, ER_ORDER_SEQ, ER_USERID, ER_REGDATE, ER_RECOM_CNT, 
					ISNULL(ER_REVIEW_TITLE,'') AS ER_REVIEW_TITLE, ISNULL(ER_REVIEW_URL, '') AS ER_REVIEW_URL , 
					ER_REVIEW_STAR, ER_STATUS, ER_VIEW, ER_REVIEW_CONTENT, ER_USERNAME, 
					ERA_STATUS, ERA_COUPON_STATUS, ISNULL(ERA_COMMENT,'') AS ERA_COMMENT, ERA_COUPON_CODE, ISNULL(ERA_COMMENT_CANCEL,'') AS ERA_COMMENT_CANCEL, 
					ISNULL(ER_REVIEW_URL_A, '') AS ER_REVIEW_URL_A, ISNULL(ER_REVIEW_URL_B, '') AS ER_REVIEW_URL_B, ISNULL(ER_REVIEW_URL2, '') AS ER_REVIEW_URL2 , 
					ER_COMMENT = ISNULL(ER_COMMENT,ER_REVIEW_URL), ER_ISPHOTO,
					ER_CARD_SEQ =	B.CARD_SEQ,
					ER_CARD_CODE =	B.CARD_CODE,
					ER_CARDIMAGE =  B.CARD_IMAGE,
					CARDCODE_CARDIMAGE = CONCAT(csoi.CARD_SEQ ,'^' , B.CARD_CODE , '^' , B.CARD_IMAGE ),
					A.ER_Company_Seq as Company_seq,
					STUFF((select ','+upimg_name from S4_Event_Review_photo where seq = A.ER_Idx order by S4_Event_Review_PHOTO_SEQ  for xml path('')),1,1,'') as img_nm
			FROM	S4_EVENT_REVIEW A 
				Inner Join CUSTOM_SAMPLE_ORDER_ITEM as csoi on A.ER_Order_Seq = csoi.SAMPLE_ORDER_SEQ
				INNER JOIN S2_CARD B ON csoi.CARD_SEQ = B.CARD_SEQ  
				LEFT OUTER JOIN  S4_EVENT_REVIEW_STATUS C ON  A.ER_IDX = C.ERA_ER_IDX 
			WHERE	csoi.CARD_SEQ = @SEARCH_CARD_SEQ 
			AND		A.ER_TYPE = 0 
			AND		A.ER_VIEW = 0  --전시 / 0 -> 비노출 / 1
			And		A.ER_Status = 1
			And		A.ER_Company_Seq  in (Select COMPANY_SEQ From COMPANY Where  sales_gubun in ('B', 'H','C'))
			ORDER BY  (CASE WHEN @SORT_DESC = 1 THEN  A.ER_REGDATE --등록일
				WHEN @SORT_DESC = 2 THEN  A.ER_ISBEST --베스트후기 
				WHEN @SORT_DESC = 3 THEN  A.ER_REVIEW_STAR --고객만족도 
			END) DESC ,  A.ER_REGDATE DESC
		
			OFFSET (@PAGE_NO-1) * @PAGE_SIZE ROW
			FETCH NEXT @PAGE_SIZE ROW ONLY;
		  End
	  END 
END 