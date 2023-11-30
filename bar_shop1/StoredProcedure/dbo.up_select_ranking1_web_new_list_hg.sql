IF OBJECT_ID (N'dbo.up_select_ranking1_web_new_list_hg', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_ranking1_web_new_list_hg
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  김덕중(daniel, kim)  
-- Create date: 2014-03-25  
-- Description: 비핸즈 신상품 리스트 출력 product_list_new_res.asp  
-- exec up_select_ranking1_web_new_list_hg 5001, 'new', 'ALL', 1, 200, 'NEW', '', 'recom', 400, 0, 0
-- =============================================  
CREATE PROCEDURE [dbo].[up_select_ranking1_web_new_list_hg]  
 -- Add the parameters for the stored procedure here  
 @company_seq AS int,  -- 회사고유코드  
 @tabgubun AS nvarchar(20), -- 탭구분(추천, 신상품, etc)  
 @brand AS nvarchar(20),  -- 고유브랜드(없을경우 all값 넘겨받으면 됨)  
 @page int,    -- 페이지넘버  
 @pagesize int,    -- 페이지사이즈(페이지당 노출갯수)  
 @code nvarchar(20),  -- 고유코드(신상품:NEW 스타일별:STYLE)  
 @orderby nvarchar(20),  -- 정렬컬럼  
 @Sequence nvarchar(20), -- 정렬조건(ASC, DESC)  
 @order_num int,    -- 주문수량  
 @jehyu int,  
 @tot    int output -- 총갯수  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
   
 DECLARE @T_CNT INT  
 DECLARE @SQL nvarchar(1000)  
   
 exec dbo.up_select_ranking1_web_new @company_seq, @tabgubun, @brand, @code, @tot output  
   
 select @tot;  
   
  --36443,36444,36437,35971,36229,36200,36109,36341,36239,36209,36238,36261,36199,36235,35840,36237,36268,36271,36094,36269,36260,36272,36097,36236,36226,36264,36265,36249,36095,36270,36262,36281,36295,36108,36274,36254,36255,36266,36267,36110
 declare @data_arry nvarchar(2000)  
 declare @data_arry_title nvarchar(2000)  
 select @data_arry=ST_Card_Code_Arry, @data_arry_title=ST_Title from S4_Ranking_Sort where ST_company_seq=@company_seq  and ST_Code=@code;  
  
  select @data_arry
      select @jehyu
	  select @data_arry_title
 if @jehyu = '1'  
  begin  
   
   select top (@pagesize) ItemSEQ, itemvalue, itemvalue2, card_name, card_code, cardbrand, cardset_price, B.card_seq, B.RegDate,   
   brand_all, convert(integer, discount_rate) AS discount_rate , cardimage_filename,  
   IsJumun, IsNew, IsBest, IsExtra, IsSale, IsExtra2, isRecommend, isSSPre, C.Company_Seq, IsSample, ISNULL(H.isFSC, '0') AS isFSC, Ranking_m  
            ,   CASE WHEN BHANDSCARD_ONLY_CARD.CARD_SEQ IS NOT NULL THEN 'Y' ELSE 'N' END AS BHANDSCARD_ONLY_CARD_YORN,  
   isnull(post.post_cnt, 0) as post_cnt, isnull(post.score, 0) as score   
    from dbo.fn_SplitIn4Rows(@data_arry,@data_arry_title,',') AS A  
   left outer join S2_Card AS B with(nolock) on A.itemvalue = B.Card_Seq   
   join s2_cardsalessite AS C with(nolock) on B.Card_Seq= C.card_seq  
   join s2_carddiscount AS D with(nolock) on C.CardDiscount_Seq = D.CardDiscount_Seq  
   join s2_cardimage AS E with(nolock) on A.itemvalue=E.Card_Seq   
   join s2_cardoption AS H on B.card_seq=H.card_seq  
   join s2_cardkind AS I on C.card_seq = I.Card_Seq  
   join s2_cardkindinfo AS j on I.CardKind_Seq = j.CardKind_Seq  
   
            -- 비핸즈카드 전용 디지털카드를 위한 쿼리  
            LEFT JOIN   (  
                            SELECT  SMC.CARD_SEQ, MAX(SMCS.COMPANY_SEQ) AS COMPANY_SEQ  
                            FROM    S4_MD_Choice SMC JOIN S4_MD_Choice_Str SMCS ON SMC.MD_SEQ = SMCS.MD_SEQ   
                            WHERE   SMC.MD_SEQ = 363   
                            GROUP BY SMC.CARD_SEQ  
                        ) BHANDSCARD_ONLY_CARD ON B.CARD_SEQ = BHANDSCARD_ONLY_CARD.CARD_SEQ AND C.COMPANY_SEQ = BHANDSCARD_ONLY_CARD.COMPANY_SEQ  
   left join (select card_seq, COUNT(*) post_cnt, avg(score) * 20 as score from S2_UserComment where company_seq = @company_seq group by card_seq) post on c.card_seq = post.card_seq  
   
   where C.Company_Seq=@company_seq and D.MinCount=@order_num and E.CardImage_WSize='210' and E.CardImage_HSize='210' and E.cardimage_div='E' and  
   C.IsDisplay='1' and E.Company_Seq=@company_seq and J.CardKind_Seq=1 and  
   (  
   CASE @brand  
    WHEN 'ALL' THEN brand_all  
    ELSE B.CardBrand  
    END  
   ) = @brand  
   
   and A.ItemSEQ not in (select top (@pagesize * (@page - 1)) ItemSEQ from dbo.fn_SplitIn4Rows(@data_arry,@data_arry_title,',')   
   AS C inner join S2_Card AS D with(nolock) on C.itemvalue = D.Card_Seq where   
   (  
   CASE @brand  
    WHEN 'ALL' THEN brand_all  
    ELSE D.CardBrand  
    END  
   ) = @brand  
   
   --정렬기준  
   order by   
   (  
   CASE @Sequence  
    WHEN 'ASC' THEN   
    CASE @orderby   
     WHEN 'REGDATE' THEN RegDate  
                    WHEN 'BEST' THEN Ranking_m  
     WHEN 'PRICE' THEN CardSet_Price END  
    END )  
    ASC,  
    (  
   CASE @Sequence  
    WHEN 'DESC' THEN   
    CASE @orderby   
     WHEN 'REGDATE' THEN RegDate  
                    WHEN 'BEST' THEN Ranking_m  
     WHEN 'PRICE' THEN CardSet_Price END  
    END )  
    DESC  
   )   
   
   
   order by   
   (  
   CASE @Sequence  
    WHEN 'ASC' THEN   
    CASE @orderby   
     WHEN 'REGDATE' THEN RegDate  
                    WHEN 'BEST' THEN Ranking_m  
     WHEN 'PRICE' THEN CardSet_Price END  
    END )  
    ASC,  
    (  
   CASE @Sequence  
    WHEN 'DESC' THEN   
    CASE @orderby   
     WHEN 'REGDATE' THEN RegDate  
                    WHEN 'BEST' THEN Ranking_m  
     WHEN 'PRICE' THEN CardSet_Price END  
    END )  
    DESC  
  end  
 else  
  begin  
   select top (@pagesize) ItemSEQ, itemvalue, itemvalue2, card_name, card_code, cardbrand, cardset_price, B.card_seq, B.RegDate,   
   brand_all, convert(integer, discount_rate) AS discount_rate , cardimage_filename,  
   IsJumun, IsNew, IsBest, IsExtra, IsSale, IsExtra2, isRecommend, isSSPre, C.Company_Seq, IsSample, ISNULL(H.isFSC, '0') AS isFSC, Ranking_m, ISNULL(C.isBgcolor, '0') AS isBgcolor  
   ,isnull((select count(1) from s2_cardkind where card_Seq = B.card_Seq and cardkind_Seq = 14),0) custom_card_yn  
            ,   CASE WHEN BHANDSCARD_ONLY_CARD.CARD_SEQ IS NOT NULL THEN 'Y' ELSE 'N' END AS BHANDSCARD_ONLY_CARD_YORN,  
   isnull(post.post_cnt, 0) as post_cnt, isnull(post.score, 0) as score   
   ,isnull((select Sticker_GroupSeq from s2_carddetail where card_Seq = B.card_Seq),0) Sticker_GroupSeq  
    from dbo.fn_SplitIn4Rows(@data_arry,@data_arry_title,',') AS A  
   left outer join S2_Card AS B with(nolock) on A.itemvalue = B.Card_Seq   
   join s2_cardsalessite AS C with(nolock) on B.Card_Seq= C.card_seq  
   join s2_carddiscount AS D with(nolock) on C.CardDiscount_Seq = D.CardDiscount_Seq  
   join s2_cardimage AS E with(nolock) on A.itemvalue=E.Card_Seq   
   join s2_cardoption AS H on B.card_seq=H.card_seq  
   join s2_cardkind AS I on C.card_seq = I.Card_Seq  
   join s2_cardkindinfo AS j on I.CardKind_Seq = j.CardKind_Seq  
           
            -- 비핸즈카드 전용 디지털카드를 위한 쿼리  
            LEFT JOIN   (  
                            SELECT  SMC.CARD_SEQ, MAX(SMCS.COMPANY_SEQ) AS COMPANY_SEQ  
                            FROM    S4_MD_Choice SMC JOIN S4_MD_Choice_Str SMCS ON SMC.MD_SEQ = SMCS.MD_SEQ   
                            WHERE   SMC.MD_SEQ = 363   
                            GROUP BY SMC.CARD_SEQ  
                        ) BHANDSCARD_ONLY_CARD ON B.CARD_SEQ = BHANDSCARD_ONLY_CARD.CARD_SEQ AND C.COMPANY_SEQ = BHANDSCARD_ONLY_CARD.COMPANY_SEQ  
   left join (select card_seq, COUNT(*) post_cnt, avg(score) * 20 as score from S2_UserComment where company_seq = @company_seq group by card_seq) post on c.card_seq = post.card_seq  
   
   where C.Company_Seq=@company_seq and D.MinCount=@order_num and E.CardImage_WSize='210' and E.CardImage_HSize='210' and E.cardimage_div='E' and  
   C.IsDisplay='1' and E.Company_Seq=@company_seq and J.CardKind_Seq=1 and  
   C.IsJehyu=0 and  
   (  
   CASE @brand  
    WHEN 'ALL' THEN brand_all  
    ELSE B.CardBrand  
    END  
   ) = @brand  
   
   and A.ItemSEQ not in (select top (@pagesize * (@page - 1)) ItemSEQ from dbo.fn_SplitIn4Rows(@data_arry,@data_arry_title,',')   
   AS C inner join S2_Card AS D with(nolock) on C.itemvalue = D.Card_Seq where   
   (  
   CASE @brand  
    WHEN 'ALL' THEN brand_all  
    ELSE D.CardBrand  
    END  
   ) = @brand  
   
   --정렬기준  
   order by   
   (  
   CASE @Sequence  
    WHEN 'ASC' THEN   
    CASE @orderby   
     WHEN 'REGDATE' THEN RegDate  
                    WHEN 'BEST' THEN Ranking_m  
     WHEN 'PRICE' THEN CardSet_Price END  
    END )  
    ASC,  
    (  
   CASE @Sequence  
    WHEN 'DESC' THEN   
    CASE @orderby   
     WHEN 'REGDATE' THEN RegDate  
                    WHEN 'BEST' THEN Ranking_m  
     WHEN 'PRICE' THEN CardSet_Price END  
    END )  
    DESC  
   )   
   
   
   order by   
   (  
   CASE @Sequence  
    WHEN 'ASC' THEN   
    CASE @orderby   
     WHEN 'REGDATE' THEN RegDate  
                    WHEN 'BEST' THEN Ranking_m  
     WHEN 'PRICE' THEN CardSet_Price END  
    END )  
    ASC,  
    (  
   CASE @Sequence  
    WHEN 'DESC' THEN   
    CASE @orderby   
     WHEN 'REGDATE' THEN RegDate  
                    WHEN 'BEST' THEN Ranking_m  
     WHEN 'PRICE' THEN CardSet_Price END  
    END )  
    DESC  
  end    
END  
GO
