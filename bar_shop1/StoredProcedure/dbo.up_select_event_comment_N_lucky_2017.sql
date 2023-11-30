IF OBJECT_ID (N'dbo.up_select_event_comment_N_lucky_2017', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_event_comment_N_lucky_2017
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  황새롬 
-- Create date: 2017-11-30
-- Description: 럭키박스 이벤트 페이지   
-- EXEC up_select_event_comment_N_lucky 5007, 88, 0, NULL, 1, 20  
-- =============================================  
CREATE PROCEDURE [dbo].[up_select_event_comment_N_lucky_2017]
 -- Add the parameters for the stored procedure here  
 @company_seq  int,  
 @ER_Card_Seq   int=0, --특정리뷰만만 조회  
 @ER_Type    int=0,  
 @userid     nvarchar(50),  
 @page     int=1,  
 @pagesize    int=50  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
   
    -- Insert statements for procedure here  
 -- total count  
 SELECT COUNT(ER_Idx) AS TOT   
 FROM   
  S4_Event_Review_New  
 WHERE   
  ER_Company_Seq = @company_seq  
  AND ER_card_seq = ISNULL(@ER_Card_Seq, ER_card_seq)  
  AND ER_Type = ISNULL(@ER_Type, ER_Type)  
  AND ER_UserId = ISNULL(@userid, ER_UserId)  
  AND ER_View = 0  
  
 -- goods list  
 SELECT *   
 FROM  
 (  
  SELECT  ROW_NUMBER() OVER (ORDER BY A.ER_Idx DESC ) AS RowNum      
   , A.ER_Idx       --1  
   , A.ER_Type       --2  
   , A.ER_Card_Seq      --3  
   , A.ER_Regdate      --4  
   , ISNULL(A.ER_Recom_Cnt, 0) AS ER_Recom_Cnt    --5  
   , ISNULL(A.ER_Review_Title, '') AS ER_Review_Title  --6  
   , ISNULL(A.ER_Review_Url, '') AS ER_Review_Url   --7  
   , ISNULL(A.ER_Review_Content, '') AS ER_Review_Content --8  
   , A.ER_Review_Star     --9  
   , A.ER_Status      --10  
   , A.ER_View       --11  
   , A.ER_UserId      --12  
   , A.ER_UserName      --13  
   , ISNULL(B.ERA_Comment,'') AS ERA_Comment  ----14  
   , ( SELECT top 1 ts.COUPON_CODE FROM VW_COUPON_USER_LIST TS WHERE TS.UID = A.ER_UserId AND TS.COUPON_CODE IN ('FAB1-2147-4B62-92D8', '7F1D-6A78-4037-87EB', '4960-2F2A-4CAF-978A', '46BB-161F-4BB9-AFA1', 'E928-A90A-493E-A6E4') AND CONVERT(CHAR(10),TS.REG_DATE) = CONVERT(CHAR(10),A.ER_Regdate)) AS couponCD  
  FROM   
   S4_Event_Review_New A  
   LEFT OUTER JOIN S4_Event_Review_Status_NEW B ON A.ER_Idx=B.ERA_ER_idx  
   --JOIN tCouponSub C ON A.ER_UserId = C.UserID AND C.COUPONCD IN ('C0000190', 'C0000191', 'C0000192', 'C0000193', 'C0000194') AND   
  WHERE   
   A.ER_Company_Seq = 5007  
   AND A.ER_card_seq = ISNULL(116, A.ER_card_seq)  
   AND A.ER_Type = ISNULL(0, A.ER_Type)  
   AND A.ER_UserId = ISNULL(null, A.ER_UserId)  
   AND A.ER_View = 0  
 ) AS RESULT  
 WHERE RowNum BETWEEN ( ( (@page - 1) * @pagesize ) + 1 ) AND ( @page * @pagesize )  
 --ORDER BY RowNum DESC  
    
  
END  
GO
