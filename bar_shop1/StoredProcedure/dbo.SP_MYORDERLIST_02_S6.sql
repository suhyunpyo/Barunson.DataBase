IF OBJECT_ID (N'dbo.SP_MYORDERLIST_02_S6', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_MYORDERLIST_02_S6
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*----------------------------------------------------------
	작성일		: 2014년 11월 20일
	작성자		: 이중정
	기능		: 내가 주문한 상품 리스트
	설명		: 이용후기 등록을 위한 주문상품검색
	변수 		:
			 @UID			주문자
--------------------------------------------------------------
	수정일		수정자		요청자		내용
----------------------------------------------------------*/
-- SP_MYORDERLIST_02_S6 'ljj777','O'--내가 주문한 상품
-- SP_MYORDERLIST_02_S6 'ljj777','A'--전체상품

CREATE PROC [dbo].[SP_MYORDERLIST_02_S6]	
	@UID				VARCHAR(50),
	@FLAG			VARCHAR(1),
	@searchTxt		VARCHAR(250)
AS
SET NOCOUNT ON
	IF @FLAG = 'O'
		BEGIN
			SELECT 
				A.order_seq, A.card_seq , B.Card_Code, Card_Name, Card_Image
				,(
					SELECT
						COUNT(*)
					FROM 
						dbo.custom_order A  WITH(NOLOCK)
						INNER JOIN dbo.S2_Card B ON A.Card_seq = B.Card_seq
					WHERE 
						member_id=@UID AND (SELECT TOP 1 isDisplay FROM S2_CardSalesSite WHERE Card_seq=B.Card_Seq AND Company_Seq = '5007') = 1				
				) AS CNT
			FROM 
				dbo.custom_order A  WITH(NOLOCK)
				INNER JOIN dbo.S2_Card B ON A.Card_seq = B.Card_seq
			WHERE 
				member_id=@UID AND (SELECT TOP 1 isDisplay FROM S2_CardSalesSite WHERE Card_seq=B.Card_Seq AND Company_Seq = '5007') = 1

		END
	ELSE IF @FLAG = 'A' AND @searchTxt !=''
		BEGIN
			SELECT
				A.card_seq, Card_Code, Card_Name, Card_Image,
			(
			SELECT
				COUNT(*)
			FROM 
				dbo.S2_Card A WITH(NOLOCK)
			WHERE
				(SELECT TOP 1 isDisplay FROM S2_CardSalesSite WHERE Card_seq=A.Card_Seq AND Company_Seq = '5007') = 1
				AND (Card_Code LIKE '%' + @searchTxt + '%' OR  Card_Name LIKE '%' + @searchTxt + '%')
			)AS CNT
			FROM 
				dbo.S2_Card A WITH(NOLOCK)
			WHERE
				(SELECT TOP 1 isDisplay FROM S2_CardSalesSite WHERE Card_seq=A.Card_Seq AND Company_Seq = '5007') = 1
				AND (Card_Code LIKE '%' + @searchTxt + '%' OR  Card_Name LIKE '%' + @searchTxt + '%')
		END
	ELSE IF @FLAG = 'A'
		BEGIN
			SELECT
				A.card_seq, Card_Code, Card_Name, Card_Image,
			(
			SELECT
				COUNT(*)
			FROM 
				dbo.S2_Card A WITH(NOLOCK)
			WHERE
				(SELECT TOP 1 isDisplay FROM S2_CardSalesSite WHERE Card_seq=A.Card_Seq AND Company_Seq = '5007') = 1
			)AS CNT
			FROM 
				dbo.S2_Card A WITH(NOLOCK)
			WHERE
				(SELECT TOP 1 isDisplay FROM S2_CardSalesSite WHERE Card_seq=A.Card_Seq AND Company_Seq = '5007') = 1
		END
SET NOCOUNT ON
GO
