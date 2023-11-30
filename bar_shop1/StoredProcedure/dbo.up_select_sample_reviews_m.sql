IF OBJECT_ID (N'dbo.up_select_sample_reviews_m', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_sample_reviews_m
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- EXEC up_select_sample_reviews_m '5007','1','20','4', 's4guest','',''
-- =============================================
CREATE PROCEDURE [dbo].[up_select_sample_reviews_m]
	@company_seq		INT,
	@page				INT=1,
	@pagesize			INT=15,
	@ER_Type			INT=0,
	@ER_UserID			VARCHAR(20),
	@sort_desc			NVARCHAR(20),
	@txt_card_seq		INT=0	--특정카드만 조회
AS
BEGIN
	SET NOCOUNT ON;
	
	IF @company_seq IS NULL OR @company_seq=''
		BEGIN
			set @company_seq='1'
		END

		SELECT count(ER_Idx) FROM S4_Event_Review WITH(NOLOCK) WHERE ER_Type in (11,12) AND ER_Company_Seq=5007 AND ER_View=0 AND ER_UserId = @ER_UserID 

		SELECT 
			TOP (@pagesize)  
				A.ER_Idx
			, A.ER_Company_Seq
			, A.ER_Order_Seq
			, A.ER_Type
			, A.ER_Userid
			, A.ER_Regdate
			, A.ER_Recom_Cnt
			, ISNULL(A.ER_Review_Title, '') AS ER_Review_Title
			, ISNULL(A.ER_Review_Url, '') AS ER_Review_Url
			, A.ER_Review_Star
			, A.ER_Status
			, A.ER_View
			, A.ER_Review_Content
			, A.ER_card_seq
			, A.ER_Card_code
			, A.ER_UserName
			, B.ERA_Status
			, B.ERA_Coupon_Status
			, ISNULL(B.ERA_Comment,'') AS ERA_Comment
			, B.ERA_Coupon_Code
			, ISNULL(B.ERA_Comment_Cancel,'') AS ERA_Comment_Cancel 
			, A.ER_Review_Price
			, A.ER_Review_Design
			, A.ER_Review_Quality
			, A.ER_Review_Satisfaction
			, ISNULL(A.ER_Review_Url_a, '') AS ER_Review_Url_a
			, ISNULL(A.ER_Review_Url_b, '') AS ER_Review_Url_b
			, A.ER_Review_Reply
		FROM 
			S4_Event_Review AS A WITH(NOLOCK) 
				LEFT OUTER JOIN S4_Event_Review_Status AS B WITH(NOLOCK) 
					ON A.ER_Idx = B.ERA_ER_idx
		WHERE 
			A.ER_Type in (11,12)
					
			AND A.ER_Idx NOT IN 
			(
				SELECT TOP (@pagesize * (@page - 1)) AA.ER_Idx 
				FROM S4_Event_Review AS AA WITH(NOLOCK) 
				WHERE AA.ER_Company_Seq = @company_seq AND AA.ER_View = 0 AND AA.ER_Type = @ER_Type AND A.ER_UserId = @ER_UserID
				ORDER BY AA.ER_Regdate DESC 
			) 
			AND A.ER_Company_Seq = @company_seq  
			AND A.ER_View = 0
			AND A.ER_UserId = @ER_UserID 
		ORDER BY A.ER_Regdate DESC					
END
GO
