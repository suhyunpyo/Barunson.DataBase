IF OBJECT_ID (N'dbo.SP_MYORDERLIST_S6', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_MYORDERLIST_S6
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*----------------------------------------------------------
	작성일		: 2015년 04월 22일
	작성자		: 이중정
	기능		: 내가 주문한 상품 리스트
	설명		: 이용후기 등록을 위한 주문상품검색
	변수 		:
			 @UID			주문자
--------------------------------------------------------------
	수정일		수정자		요청자		내용
----------------------------------------------------------*/
-- SP_MYORDERLIST_S6 'hyonsam','P'
-- SP_MYORDERLIST_S6 'palaoh','C'

CREATE PROC [dbo].[SP_MYORDERLIST_S6]	
	@UID		VARCHAR(50),
	@FLAG	VARCHAR(1)
AS
SET NOCOUNT ON
	IF @FLAG = 'P'
		BEGIN
			SELECT 
				A.order_seq, A.card_seq , B.Card_Code, Card_Name, Card_Image, c.ER_Idx 
			FROM 
				dbo.custom_order A WITH(NOLOCK)
				INNER JOIN dbo.S2_Card AS B ON A.card_seq = B.card_seq
				LEFT OUTER JOIN dbo.S4_Event_Review C ON A.member_id = C.ER_UserId AND A.card_seq=c.ER_Card_Seq AND ER_Status = 0
			WHERE 
				member_id=@UID 
				AND A.status_seq=15
				--비전시제품도 구매후기 작성가능토록 2015.04.22
				--AND (SELECT TOP 1 isDisplay FROM S2_CardSalesSite WHERE Card_seq=B.Card_Seq) = 1				
				AND c.ER_Card_Seq IS NULL
				AND A.sales_Gubun = 'ST'

		END
	ELSE IF @FLAG = 'C' 
		BEGIN
			SELECT 
				COUNT(*)
			FROM 
				dbo.S4_Event_Review WITH(NOLOCK)
			WHERE 
				ER_UserId = @UID AND ER_Status = 0 AND ER_Type = '1'-- (0 : 샘플 후기, 1 : 구매 후기)
		END

SET NOCOUNT ON
GO
