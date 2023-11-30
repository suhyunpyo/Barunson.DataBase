IF OBJECT_ID (N'dbo.up_select_cardcode_setting_ALL_S6', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_cardcode_setting_ALL_S6
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[up_select_cardcode_setting_ALL_S6]  
 -- Add the parameters for the stored procedure here  
   
 @uid     AS NVARCHAR(20),  
 @order_seq   AS NVARCHAR(20),  
 @type    AS NVARCHAR(20),  
 -----인써트-----------------------  
 @sgubun   AS VARCHAR(2),  
 @com_seq   AS INTEGER,  
 @card_seq   AS INTEGER,  
 @card_code  AS VARCHAR(20),   
 @title     AS VARCHAR(100),  
 @comment   AS TEXT,  
 @comment_min AS VARCHAR(2000),  
 @score    AS tinyint,  
 @upfile    AS VARCHAR(50),  
 @comm_div   AS CHAR(1),  
 @rcolor    AS TINYINT,  
 @rbright    AS TINYINT,  
 @b_url    AS VARCHAR(2000),     -- 리스트일경우 검색조건 파라미터로 사용  
 -----삭제-----------------------  
 @seq     AS NVARCHAR(20),  
 @star_rating1  AS TINYINT,  
 @star_rating2  AS TINYINT,  
 @star_rating3  AS TINYINT,  
 @star_rating4  AS TINYINT,  
 @page    AS INT,      
 @pagesize   AS INT,  
 @tabflag    AS INT,  
   
 @Gift_Code   AS TINYINT = NULL,  
 @Review_Reply  AS TEXT = NULL  
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
   
ELSE IF @type = 'insert'  
  
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
     )  
 VALUES  
 (   
  @com_seq  
       , @order_seq  
       , 1       --샘플 / 구매 후기 여부 (0 : 샘플 후기, 1 : 구매 후기)  
       , @card_seq  
       , @card_code  
       , @uid  
       , GETDATE()  
       , 0       -- 추천수  
       , @title  
       , @b_url  
       , @comment  
       , @star_rating1 + @star_rating2 + @star_rating3 + @star_rating4  
       , @star_rating1  
       , @star_rating2  
       , @star_rating3  
       , @star_rating4  
       , 0       --글 삭제 여부 (0 : 정상, 1 : 삭제) 
       , 0       --전시여부 (0,1)?  
       , @uname  
       , 0 --BEST 여부 (0 : 일반, 1 : 베스트)  
       , 0  --일반/포토 여부 (0 : 일반, 1 : 포토)  
       , @Gift_Code -- 이용후기 사은품 (1 : 요구르트제조기, 2 : 전기주전자, 3 : 계란찜기, 4 : 토스터, 5 : 와플메이커)  
       , @Review_Reply  
    )  
  
   
  select ER_View,* from S4_Event_Review  
    
 END  
   
ELSE IF @type = 'del'  
  
 BEGIN  
   
  --Delete dbo.S4_Event_Review Where ER_Idx=@seq   
  UPDATE dbo.S4_Event_Review SET ER_Status = 1 WHERE ER_Idx=@seq   
  select 2   
    
 END  
   
ELSE IF @type = 'edit'  
  
 BEGIN  
   
 UPDATE   
  dbo.S4_Event_Review  
 SET   
    ER_Review_Title   = @title  
  , ER_Review_Content   = @comment  
  , ER_Review_Star   = @score  
  , ER_Review_Price   = @star_rating1  
  , ER_Review_Design   = @star_rating2  
  , ER_Review_Quality   = @star_rating3  
  , ER_Review_Satisfaction = @star_rating4  
        , ER_Card_Seq    = @card_seq  
        , ER_Card_Code    = @card_code  
  , ER_Review_Url    = @b_url  
  , ER_Gift_Code    = @Gift_Code  
  , ER_Review_Reply   = @Review_Reply  
 Where   
  ER_Idx=@seq  
 END  
   
   
ELSE IF @type = 'list'  
  
 BEGIN  
  IF @tabflag = 0  
   BEGIN  
    SELECT   
     COUNT(ER_Idx) AS tot  
    FROM   
     dbo.S4_Event_Review A  WITH(NOLOCK) JOIN S2_card B ON A.ER_Card_Seq = B.CARD_SEQ  
    WHERE  
     A.ER_Company_Seq = @com_seq  
     AND A.ER_View = 0  
     AND A.ER_Status = 0    
     AND ( ISNULL(@b_url, '') = '' OR A.ER_Card_Code LIKE '%' + @b_url + '%' OR B.Card_Name LIKE '%' + @b_url+ '%' )  
  
    SELECT TOP (@pagesize)   
      A.ER_Idx   
       , A.ER_Card_Seq       
       , A.ER_Order_Seq   
       , A.ER_Review_Title  
       , A.ER_Review_Star  
       , REPLACE(CONVERT(VARCHAR(10), A.ER_Regdate, 120),'-','.') reg_date  
       --, B.ER_Card_Code  
       , B.Card_Code  
       , B.Card_Image  
       , replace(convert(varchar(max), A.ER_Review_Content)  , 'http://image.thecard.co.kr', 'https://image.thecard.co.kr') as ER_Review_Content  
       , ISNULL(A.ER_Review_Url, '') ER_Review_Url  
       , A.ER_Review_Price  
       , A.ER_Review_Design  
       , A.ER_Review_Quality  
       , A.ER_Review_Satisfaction  
       , A.ER_UserName  
       , A.ER_isBest  
       , A.ER_isPhoto  
       , B.card_name  
       , isnull(C.SP_Level, '0'), C.SP_Best, isnull(C.SP_Status, '0') as SP_Status  
       , A.ER_Gift_Code  
       , A.ER_Review_Reply  
       , C.SP_SeasonNo  
       , STUFF((select ','+upimg_name from S2_UserComment_photo_the where seq = A.ER_idx order by seq  for xml path('')),1,1,'') as IMG_NUM       
  
      FROM   
      dbo.S4_Event_Review A  WITH(NOLOCK) JOIN S2_card B ON A.ER_Card_Seq = B.CARD_SEQ  
      left outer join  S5_Supporters_User AS C with(nolock) on A.ER_UserId = C.SP_UserID AND C.SP_Status = 1  
      WHERE  
      A.ER_Company_Seq = @com_seq  
      AND A.ER_View = 0  
      AND A.ER_Status = 0    
      AND A.ER_Idx NOT IN (SELECT TOP (@pagesize * (@page - 1)) A.ER_Idx FROM dbo.S4_Event_Review A WITH(NOLOCK) JOIN S2_card B ON A.ER_Card_Seq = B.CARD_SEQ WHERE A.ER_Company_Seq = @com_seq order by a.ER_IDX DESC)  
      AND ( ISNULL(@b_url, '') = '' OR A.ER_Card_Code LIKE '%' + @b_url + '%' OR B.Card_Name LIKE '%' + @b_url+ '%' )  
  
  ORDER BY  A.ER_Regdate DESC       
     -- ORDER BY ER_IDX DESC        
   END  
  ELSE IF @tabflag = 1--photo  
   BEGIN  
    SELECT   
     COUNT(ER_Idx) AS tot  
    FROM   
     dbo.S4_Event_Review A  WITH(NOLOCK) JOIN S2_card B ON A.ER_Card_Seq = B.CARD_SEQ  
    WHERE  
     A.ER_Company_Seq = @com_seq  
     AND A.ER_View = 0  
     AND A.ER_Status = 0   
     AND A.ER_isPhoto = 1   
     AND ( ISNULL(@b_url, '') = '' OR A.ER_Card_Code LIKE '%' + @b_url + '%' OR B.Card_Name LIKE '%' + @b_url+ '%' )  
  
    SELECT TOP (@pagesize)   
      A.ER_Idx   
       , A.ER_Card_Seq       
       , A.ER_Order_Seq   
       , A.ER_Review_Title  
       , A.ER_Review_Star  
       , REPLACE(CONVERT(VARCHAR(10), A.ER_Regdate, 120),'-','.') reg_date  
       --, B.ER_Card_Code  
       , B.Card_Code  
       , B.Card_Image  
       , replace(convert(varchar(max), A.ER_Review_Content)  , 'http://image.thecard.co.kr', 'https://image.thecard.co.kr') as ER_Review_Content  
       , ISNULL(A.ER_Review_Url, '') ER_Review_Url   
       , A.ER_Review_Price  
       , A.ER_Review_Design  
       , A.ER_Review_Quality  
       , A.ER_Review_Satisfaction  
       , A.ER_UserName  
       , A.ER_isBest  
       , A.ER_isPhoto  
       , B.card_name  
       , isnull(C.SP_Level, '0'), C.SP_Best, isnull(C.SP_Status, '0') as SP_Status  
       , A.ER_Gift_Code  
       , A.ER_Review_Reply  
       , C.SP_SeasonNo  
       , STUFF((select ','+upimg_name from S2_UserComment_photo_the where seq = A.ER_idx order by seq  for xml path('')),1,1,'') as IMG_NUM       
      FROM   
      dbo.S4_Event_Review A  WITH(NOLOCK) JOIN S2_card B ON A.ER_Card_Seq = B.CARD_SEQ  
      left outer join  S5_Supporters_User AS C with(nolock) on A.ER_UserId = C.SP_UserID   
      WHERE  
      A.ER_Company_Seq = @com_seq  
      AND A.ER_View = 0  
      AND A.ER_Status = 0   
      AND A.ER_isPhoto = 1    
      AND A.ER_Idx NOT IN (SELECT TOP (@pagesize * (@page - 1)) A.ER_Idx FROM dbo.S4_Event_Review A WITH(NOLOCK) JOIN S2_card B ON A.ER_Card_Seq = B.CARD_SEQ WHERE A.ER_Company_Seq = @com_seq AND A.ER_isPhoto = 1 ORDER BY a.ER_IDX DESC)  
      AND ( ISNULL(@b_url, '') = '' OR A.ER_Card_Code LIKE '%' + @b_url + '%' OR B.Card_Name LIKE '%' + @b_url+ '%' )  
      ORDER BY ER_IDX DESC    
   END  
  ELSE IF @tabflag = 2--best  
   BEGIN  
    SELECT   
     COUNT(ER_Idx) AS tot  
    FROM   
     dbo.S4_Event_Review A  WITH(NOLOCK) JOIN S2_card B ON A.ER_Card_Seq = B.CARD_SEQ  
    WHERE  
     A.ER_Company_Seq = @com_seq  
     AND A.ER_View = 0  
     AND A.ER_Status = 0    
     AND A.ER_isBest = 1   
     AND ( ISNULL(@b_url, '') = '' OR A.ER_Card_Code LIKE '%' + @b_url + '%' OR B.Card_Name LIKE '%' + @b_url+ '%' )  
  
    SELECT TOP (@pagesize)   
      A.ER_Idx   
       , A.ER_Card_Seq       
       , A.ER_Order_Seq   
       , A.ER_Review_Title  
       , A.ER_Review_Star  
       , REPLACE(CONVERT(VARCHAR(10), A.ER_Regdate, 120),'-','.') reg_date  
       --, B.ER_Card_Code  
       , B.Card_Code  
       , B.Card_Image  
       , replace(convert(varchar(max), A.ER_Review_Content)  , 'http://image.thecard.co.kr', 'https://image.thecard.co.kr') as ER_Review_Content
       , ISNULL(A.ER_Review_Url, '') ER_Review_Url  
       , A.ER_Review_Price  
       , A.ER_Review_Design  
       , A.ER_Review_Quality  
       , A.ER_Review_Satisfaction  
       , A.ER_UserName  
       , A.ER_isBest  
       , A.ER_isPhoto  
       , B.card_name  
       , isnull(C.SP_Level, '0'), C.SP_Best, isnull(C.SP_Status, '0') as SP_Status  
       , A.ER_Gift_Code  
       , A.ER_Review_Reply  
       , C.SP_SeasonNo  
         , STUFF((select ','+upimg_name from S2_UserComment_photo_the where seq = A.ER_idx order by seq  for xml path('')),1,1,'') as IMG_NUM       
  
      FROM   
      dbo.S4_Event_Review A  WITH(NOLOCK) JOIN S2_card B ON A.ER_Card_Seq = B.CARD_SEQ  
      left outer join  S5_Supporters_User AS C with(nolock) on A.ER_UserId = C.SP_UserID   
      WHERE  
      A.ER_Company_Seq = @com_seq  
      AND A.ER_View = 0  
      AND A.ER_Status = 0    
      AND A.ER_isBest = 1   
      AND A.ER_Idx NOT IN (SELECT TOP (@pagesize * (@page - 1)) A.ER_Idx FROM dbo.S4_Event_Review A WITH(NOLOCK) JOIN S2_card B ON A.ER_Card_Seq = B.CARD_SEQ WHERE A.ER_Company_Seq = @com_seq AND A.ER_isBest = 1 ORDER BY a.ER_IDX DESC)  
      AND ( ISNULL(@b_url, '') = '' OR A.ER_Card_Code LIKE '%' + @b_url + '%' OR B.Card_Name LIKE '%' + @b_url+ '%' )  
      ORDER BY ER_IDX DESC  
   END  
  ELSE  
   BEGIN  
    SELECT   
     COUNT(ER_Idx) AS tot  
    FROM   
     dbo.S4_Event_Review A  WITH(NOLOCK) JOIN S2_card B ON A.ER_Card_Seq = B.CARD_SEQ  
    WHERE  
     A.ER_Company_Seq = @com_seq  
     AND A.ER_Status = 0    
     AND ( ISNULL(@b_url, '') = '' OR A.ER_Card_Code LIKE '%' + @b_url + '%' OR B.Card_Name LIKE '%' + @b_url+ '%' )  
  
    SELECT TOP (@pagesize)   
      A.ER_Idx   
       , A.ER_Card_Seq       
       , A.ER_Order_Seq   
       , A.ER_Review_Title  
       , A.ER_Review_Star  
       , REPLACE(CONVERT(VARCHAR(10), A.ER_Regdate, 120),'-','.') reg_date  
       , A.ER_Card_Code  
       , B.Card_Image  
       , replace(convert(varchar(max), A.ER_Review_Content)  , 'http://image.thecard.co.kr', 'https://image.thecard.co.kr') as ER_Review_Content  
       , ISNULL(A.ER_Review_Url, '') ER_Review_Url  
       , A.ER_Review_Price  
       , A.ER_Review_Design  
       , A.ER_Review_Quality  
       , A.ER_Review_Satisfaction  
       , A.ER_UserName  
       , A.ER_isBest  
       , A.ER_isPhoto  
       , B.card_name  
       , isnull(C.SP_Level, '0')  
       , C.SP_Best, isnull(C.SP_Status, '0') as SP_Status  
       , A.ER_Gift_Code  
       , A.ER_Review_Reply  
       , C.SP_SeasonNo  
         , STUFF((select ','+upimg_name from S2_UserComment_photo_the where seq = A.ER_idx order by seq  for xml path('')),1,1,'') as IMG_NUM       
  
      FROM   
      dbo.S4_Event_Review A  WITH(NOLOCK) JOIN S2_card B ON A.ER_Card_Seq = B.CARD_SEQ  
      left outer join  S5_Supporters_User AS C with(nolock) on A.ER_UserId = C.SP_UserID   
      WHERE  
      A.ER_Company_Seq = @com_seq  
      AND A.ER_Status = 0    
      AND A.ER_Idx NOT IN (SELECT TOP (@pagesize * (@page - 1)) A.ER_Idx FROM dbo.S4_Event_Review A WITH(NOLOCK) JOIN S2_card B ON A.ER_Card_Seq = B.CARD_SEQ WHERE A.ER_Company_Seq = @com_seq ORDER BY a.ER_IDX DESC)  
      AND ( ISNULL(@b_url, '') = '' OR A.ER_Card_Code LIKE '%' + @b_url + '%' OR B.Card_Name LIKE '%' + @b_url+ '%' )  
      ORDER BY ER_IDX DESC  
   END  
  
 END  
   
   
ELSE  
 BEGIN  
  select 1  
 END
GO
