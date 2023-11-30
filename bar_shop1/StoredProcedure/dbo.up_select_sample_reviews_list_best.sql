IF OBJECT_ID (N'dbo.up_select_sample_reviews_list_best', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_sample_reviews_list_best
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- EXEC up_select_sample_reviews_list '5007','1','20','All',''
-- =============================================
CREATE PROCEDURE [dbo].[up_select_sample_reviews_list_best]
	@company_seq		INT,
	@page				INT=1,
	@pagesize			INT=15,
	@isBest			NVARCHAR(20),
	@sort_desc			NVARCHAR(20),
	@txt_card_seq		INT=0	--특정카드만 조회
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @TEMP TABLE 
	( ER_isBest NVARCHAR(20))

	--declare @er_type int = 11
	--select * from S4_Event_Review where (@er_type = 0 and er_type in ('11', '12')) OR (@er_type <> 0 AND er_type = @er_type)

	IF @isBest = 'All'
		BEGIN
			INSERT INTO @temp 
			SELECT '1' union all
			SELECT '0' union all
            SELECT NULL
		END 
	ELSE		
		BEGIN
			INSERT INTO @temp values(@isBest)
		END 

	IF @company_seq IS NULL OR @company_seq=''
		BEGIN
			set @company_seq='1'
		END
	
	 
	IF @txt_card_seq = 0
		if @isBest = 'All'
			BEGIN
				SELECT count(ER_Idx) FROM S4_Event_Review WITH(NOLOCK) WHERE  er_type in ('0','11','12') AND  ER_Company_Seq=5007 AND ER_View=0 

				SELECT   A.ER_Idx
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
    
                    FROM (
                        SELECT 	ER_Idx
                                , ER_Company_Seq
                                , ER_Order_Seq
                                , ER_Type
                                , ER_Userid
                                , ER_Regdate
                                , ER_Recom_Cnt
                                , ISNULL(ER_Review_Title, '') AS ER_Review_Title
                                , ISNULL(ER_Review_Url, '') AS ER_Review_Url
                                , ER_Review_Star
                                , ER_Status
                                , ER_View
                                , ER_Review_Content
                                , ER_card_seq
                                , ER_Card_code
                                , ER_UserName            
                                , ER_Review_Price
                                , ER_Review_Design
                                , ER_Review_Quality
                                , ER_Review_Satisfaction
                                , ISNULL(ER_Review_Url_a, '') AS ER_Review_Url_a
                                , ISNULL(ER_Review_Url_b, '') AS ER_Review_Url_b
                                , ER_Review_Reply
                                ,ROW_NUMBER() OVER(ORDER BY  ER_Regdate DESC) AS ROW_NUM
                        FROM S4_Event_Review  WITH(NOLOCK) 		 
                        WHERE er_type in ('0','11','12')
	                        AND ER_Company_Seq =5007  
	                        AND ER_View=0 
                        ) A
                           LEFT OUTER JOIN S4_Event_Review_Status AS B WITH(NOLOCK) 
			                        ON A.ER_Idx = B.ERA_ER_idx
                     WHERE ROW_NUM >  (@pagesize*(@page-1))
                     AND   ROW_NUM <= (@pagesize*@page)		
                     ORDER BY ROW_NUM ASC

			END
		else
			BEGIN
				SELECT count(ER_Idx) FROM S4_Event_Review WITH(NOLOCK) WHERE ER_isBest in ( SELECT ER_isBest FROM @TEMP) AND er_type in ('0','11','12') AND  ER_Company_Seq=5007 AND ER_View=0 
                				
                SELECT   A.ER_Idx
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
                FROM (
                    SELECT   ER_Idx
		                    , ER_Company_Seq
		                    , ER_Order_Seq
		                    , ER_Type
		                    , ER_Userid
		                    , ER_Regdate
		                    , ER_Recom_Cnt
		                    , ISNULL(ER_Review_Title, '') AS ER_Review_Title
		                    , ISNULL(ER_Review_Url, '') AS ER_Review_Url
		                    , ER_Review_Star
		                    , ER_Status
		                    , ER_View
		                    , ER_Review_Content
		                    , ER_card_seq
		                    , ER_Card_code
		                    , ER_UserName		    
		                    , ER_Review_Price
		                    , ER_Review_Design
		                    , ER_Review_Quality
		                    , ER_Review_Satisfaction
		                    , ISNULL(ER_Review_Url_a, '') AS ER_Review_Url_a
		                    , ISNULL(ER_Review_Url_b, '') AS ER_Review_Url_b
		                    , ER_Review_Reply
                            ,ROW_NUMBER() OVER(ORDER BY  ER_Regdate DESC) AS ROW_NUM
	                    FROM S4_Event_Review WITH(NOLOCK) 			    
	                    WHERE 
		                    ER_isBest in ( SELECT ER_isBest FROM @TEMP )
			                and er_type in ('0','11','12')	
		                    AND ER_Company_Seq =5007  
		                    AND ER_View=0 
                ) A
                LEFT OUTER JOIN S4_Event_Review_Status AS B WITH(NOLOCK) 
                    ON A.ER_Idx = B.ERA_ER_idx
                 WHERE ROW_NUM >  (@pagesize*(@page-1))
                 AND   ROW_NUM <= (@pagesize*@page)
                 ORDER BY ROW_NUM ASC
			END


	ELSE
		BEGIN
			SELECT count(ER_Idx) FROM S4_Event_Review WITH(NOLOCK) WHERE ER_isBest in ( SELECT ER_isBest FROM @TEMP ) AND ER_Company_Seq= @company_seq AND ER_card_seq=@txt_card_seq AND er_type in ('0','11','12')

			
            SELECT  ER_Idx
                , ER_Company_Seq
                , ER_Order_Seq
                , ER_Type
                , ER_Userid
                , ER_Regdate
                , ER_Recom_Cnt
                , ISNULL(ER_Review_Title, '') AS ER_Review_Title
	            , ISNULL(ER_Review_Url, '') AS ER_Review_Url 
	            , ER_Review_Star
                , ER_Status, ER_View
                , ER_Review_Content
                , ER_card_seq
                , ER_Card_code
                , ER_UserName
	            , ERA_Status
                , ERA_Coupon_Status
                , ISNULL(ERA_Comment,'') AS ERA_Comment
                , ERA_Coupon_Code
                , ISNULL(ERA_Comment_Cancel,'') AS ERA_Comment_Cancel 
        
            FROM (SELECT      ER_Idx
                            , ER_Company_Seq
                            , ER_Order_Seq
                            , ER_Type
                            , ER_Userid
                            , ER_Regdate
                            , ER_Recom_Cnt
                            , ISNULL(ER_Review_Title, '') AS ER_Review_Title
			                , ISNULL(ER_Review_Url, '') AS ER_Review_Url 
			                , ER_Review_Star
                            , ER_Status, ER_View
                            , ER_Review_Content
                            , ER_card_seq
                            , ER_Card_code
                            , ER_UserName			        
                            ,ROW_NUMBER() OVER(ORDER BY  ER_Regdate DESC) AS ROW_NUM
		            FROM S4_Event_Review WITH(NOLOCK)             
		            WHERE ER_isBest in ( SELECT ER_isBest FROM @TEMP ) 			
                    AND er_type in ('0','11','12')
		            AND ER_Company_Seq = @company_seq 
                    AND ER_card_seq= @txt_card_seq  
                    AND ER_View=0
            ) A
            LEFT OUTER JOIN  S4_Event_Review_Status AS B WITH(NOLOCK) 
                        ON A.ER_Idx = B.ERA_ER_idx 
             WHERE ROW_NUM >  (@pagesize*(@page-1))
             AND   ROW_NUM <= (@pagesize*@page)
             ORDER BY ROW_NUM ASC
			

		END

END
GO
