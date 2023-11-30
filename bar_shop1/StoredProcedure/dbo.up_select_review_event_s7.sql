IF OBJECT_ID (N'dbo.up_select_review_event_s7', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_review_event_s7
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- EXEC up_select_review_event_s7 '5007','1','20','4', 's4guest','',''
-- =============================================
CREATE PROCEDURE [dbo].[up_select_review_event_s7]
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
	 
	IF @txt_card_seq = 0
		BEGIN
			IF (@company_seq = '5001' OR @company_seq = '5003')	--바른손
				BEGIN
					SELECT count(ER_Idx) FROM S4_Event_Review WITH(NOLOCK) WHERE ER_Type=@ER_Type AND ER_Company_Seq= @company_seq AND ER_View=0

					SELECT TOP (@pagesize) ER_Idx, ER_Company_Seq, ER_Order_Seq, ER_Type, ER_Userid, ER_Regdate, ER_Recom_Cnt, ISNULL(ER_Review_Title, '') AS ER_Review_Title
					, ISNULL(ER_Review_Url, '') AS ER_Review_Url , 
					ER_Review_Star, ER_Status, ER_View, ER_Review_Content, ER_card_seq, ER_Card_code, ER_UserName, 
					ERA_Status, ERA_Coupon_Status, ISNULL(ERA_Comment,'') AS ERA_Comment, ERA_Coupon_Code, ISNULL(ERA_Comment_Cancel,'') AS ERA_Comment_Cancel 
					FROM S4_Event_Review AS A WITH(NOLOCK) LEFT OUTER JOIN  S4_Event_Review_Status AS B WITH(NOLOCK) ON A.ER_Idx = B.ERA_ER_idx 
					WHERE ER_Type=@ER_Type AND  ER_Idx not in (SELECT TOP (@pagesize * (@page - 1)) ER_Idx FROM S4_Event_Review WITH(NOLOCK) 
					WHERE ER_Company_Seq = @company_seq AND ER_View=0  ORDER BY ER_Regdate DESC  ) 
					AND ER_Company_Seq =@company_seq  AND ER_View=0 ORDER BY ER_Regdate DESC
				
				END
			ELSE IF	(@company_seq = '5006')	--바른손	--바른손 외 모든 사이트(제휴포함)
				BEGIN
					SELECT count(ER_Idx) FROM S4_Event_Review WITH(NOLOCK) WHERE ER_Type=@ER_Type AND ER_Company_Seq !=5001 AND ER_Company_Seq !=5003 AND ER_View=0 

					
/*
					SELECT TOP (@pagesize)  ER_Idx, ER_Company_Seq, ER_Order_Seq, ER_Type, ER_Userid, ER_Regdate, ER_Recom_Cnt, ISNULL(ER_Review_Title, '') AS ER_Review_Title, ISNULL(ER_Review_Url, '') AS ER_Review_Url , 
					ER_Review_Star, ER_Status, ER_View, ER_Review_Content, ER_card_seq, ER_Card_code, ER_UserName, 
					ERA_Status, ERA_Coupon_Status, ISNULL(ERA_Comment,'') AS ERA_Comment, ERA_Coupon_Code, ISNULL(ERA_Comment_Cancel,'') AS ERA_Comment_Cancel FROM S4_Event_Review AS A WITH(NOLOCK) LEFT OUTER JOIN  S4_Event_Review_Status AS B WITH(NOLOCK) ON A.ER_Id



x = B.ERA_ER_idx 
					WHERE ER_Type=@ER_Type AND  ER_Idx not in (SELECT TOP (@pagesize * (@page - 1)) ER_Idx FROM S4_Event_Review WITH(NOLOCK) WHERE ER_Company_Seq !=5001 AND  ER_Company_Seq !=5003 AND ER_View=0  ORDER BY ER_Regdate ASC  ) 
					AND ER_Company_Seq !=5001  AND ER_Company_Seq !=5003  AND ER_View=0 ORDER BY ER_Regdate DESC
*/
					SELECT 
						TOP (@pagesize)  
						ER_Idx, ER_Company_Seq, ER_Order_Seq, ER_Type, ER_Userid, ER_Regdate, ER_Recom_Cnt, ISNULL(ER_Review_Title, '') AS ER_Review_Title, ISNULL(ER_Review_Url, '') AS ER_Review_Url , 
						ER_Review_Star, ER_Status, ER_View, ER_Review_Content, ER_card_seq, ER_Card_code, ER_UserName
						,ERA_Status, ERA_Coupon_Status, ISNULL(ERA_Comment,'') AS ERA_Comment, ERA_Coupon_Code, ISNULL(ERA_Comment_Cancel,'') AS ERA_Comment_Cancel 
					    ,ER_Review_Price
						,ER_Review_Design
						 ,ER_Review_Quality
						,ER_Review_Satisfaction
						, ISNULL(ER_Review_Url_a, '') AS ER_Review_Url_a
						, ISNULL(ER_Review_Url_b, '') AS ER_Review_Url_b
					FROM 
						S4_Event_Review AS A WITH(NOLOCK) LEFT OUTER JOIN  S4_Event_Review_Status AS B WITH(NOLOCK) ON A.ER_Idx = B.ERA_ER_idx 
					WHERE 
						ER_Type=@ER_Type 
						AND  ER_Idx NOT IN 
						(SELECT 
							TOP (@pagesize * (@page - 1)) B.ER_Idx FROM S4_Event_Review AS B WITH(NOLOCK) 
						WHERE 
							ER_Company_Seq !=5001 AND  ER_Company_Seq !=5003 AND ER_View=0 AND ER_Type=@ER_Type 
						ORDER BY B.ER_Regdate DESC 
						) 
					AND ER_Company_Seq !=5001  AND ER_Company_Seq !=5003  AND ER_View=0 
					ORDER BY A.ER_Regdate DESC					

				END
			ELSE --더카드
				BEGIN
					SELECT count(ER_Idx) FROM S4_Event_Review WITH(NOLOCK) WHERE ER_Type=@ER_Type AND ER_Company_Seq=5007 AND ER_View=0 AND ER_UserId = @ER_UserID 

					
/*
					SELECT TOP (@pagesize)  ER_Idx, ER_Company_Seq, ER_Order_Seq, ER_Type, ER_Userid, ER_Regdate, ER_Recom_Cnt, ISNULL(ER_Review_Title, '') AS ER_Review_Title, ISNULL(ER_Review_Url, '') AS ER_Review_Url , 
					ER_Review_Star, ER_Status, ER_View, ER_Review_Content, ER_card_seq, ER_Card_code, ER_UserName, 
					ERA_Status, ERA_Coupon_Status, ISNULL(ERA_Comment,'') AS ERA_Comment, ERA_Coupon_Code, ISNULL(ERA_Comment_Cancel,'') AS ERA_Comment_Cancel FROM S4_Event_Review AS A WITH(NOLOCK) LEFT OUTER JOIN  S4_Event_Review_Status AS B WITH(NOLOCK) ON A.ER_I


d

x = B.ERA_ER_idx 
					WHERE ER_Type=@ER_Type AND  ER_Idx not in (SELECT TOP (@pagesize * (@page - 1)) ER_Idx FROM S4_Event_Review WITH(NOLOCK) WHERE ER_Company_Seq !=5001 AND  ER_Company_Seq !=5003 AND ER_View=0  ORDER BY ER_Regdate ASC  ) 
					AND ER_Company_Seq !=5001  AND ER_Company_Seq !=5003  AND ER_View=0 ORDER BY ER_Regdate DESC
*/
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
						, ISNULL(C.SP_Level, '0') AS SP_Level
						, C.SP_Best
						, ISNULL(C.SP_Status, '0') AS SP_Status
						, C.SP_SeasonNo
						, A.ER_Review_Reply
					FROM 
						S4_Event_Review AS A WITH(NOLOCK) 
							LEFT OUTER JOIN S4_Event_Review_Status AS B WITH(NOLOCK) 
								ON A.ER_Idx = B.ERA_ER_idx
							LEFT OUTER JOIN  S5_Supporters_User AS C WITH(NOLOCK) 
								ON A.ER_UserId = C.SP_UserID 
								AND SP_Status = '1'
					WHERE 
						A.ER_Type=@ER_Type
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
		END
	ELSE
		BEGIN
			SELECT count(ER_Idx) FROM S4_Event_Review WITH(NOLOCK) WHERE ER_Type=@ER_Type AND ER_Company_Seq= @company_seq AND ER_card_seq=@txt_card_seq

			SELECT TOP (@pagesize)  ER_Idx, ER_Company_Seq, ER_Order_Seq, ER_Type, ER_Userid, ER_Regdate, ER_Recom_Cnt, ISNULL(ER_Review_Title, '') AS ER_Review_Title
			, ISNULL(ER_Review_Url, '') AS ER_Review_Url , 
			 ER_Review_Star, ER_Status, ER_View, ER_Review_Content, ER_card_seq, ER_Card_code, ER_UserName, 
			ERA_Status, ERA_Coupon_Status, ISNULL(ERA_Comment,'') AS ERA_Comment, ERA_Coupon_Code, ISNULL(ERA_Comment_Cancel,'') AS ERA_Comment_Cancel 
			FROM S4_Event_Review AS A WITH(NOLOCK) LEFT OUTER JOIN  S4_Event_Review_Status AS B WITH(NOLOCK) ON A.ER_Idx = B.ERA_ER_idx 
			WHERE ER_Type=@ER_Type 
			AND  ER_Idx not in (SELECT TOP (@pagesize * (@page - 1))  ER_Idx 
			FROM S4_Event_Review WITH(NOLOCK) WHERE ER_Company_Seq =@company_seq AND ER_card_seq=@txt_card_seq  AND ER_View=0 ORDER BY ER_Regdate DESC  ) 
			AND ER_Company_Seq = @company_seq AND ER_card_seq= @txt_card_seq  AND ER_View=0 ORDER BY ER_Regdate DESC
			

		END

END
GO
