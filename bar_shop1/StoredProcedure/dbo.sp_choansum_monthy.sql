IF OBJECT_ID (N'dbo.sp_choansum_monthy', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_choansum_monthy
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--초안작업 건수조회
CREATE proc [dbo].[sp_choansum_monthy]
	@Year	AS VARCHAR(4)	
AS 


CREATE TABLE #CardTemp            
( Gubun VARCHAR(10) NOT NULL, Card_seq int NOT NULL )    

INSERT INTO #CardTemp ( Gubun, Card_Seq )            
SELECT DISTINCT '3디지털' AS Gubun, Card_Seq FROM S2_CardKind WHERE ISNULL(CardKind_Seq, '') IN ( '14' )        
    AND Card_Seq NOT IN ( SELECT Card_Seq FROM #CardTemp )    

INSERT INTO #CardTemp ( Gubun, Card_Seq )            
SELECT DISTINCT '1청첩장' AS Gubun, Card_Seq FROM S2_CardKind WHERE ISNULL(CardKind_Seq, '') IN ( '1', '2' )             
    AND Card_Seq NOT IN ( SELECT Card_Seq FROM #CardTemp )        

INSERT INTO #CardTemp ( Gubun, Card_Seq )            
SELECT DISTINCT '2답례장' AS Gubun, Card_Seq FROM S2_CardKind WHERE ISNULL(CardKind_Seq, '') IN ( '3', '4', '5',' 16' )             
    AND Card_Seq NOT IN ( SELECT Card_Seq FROM #CardTemp )        

INSERT INTO #CardTemp ( Gubun, Card_Seq )            
SELECT DISTINCT '4기타' AS Gubun, Card_Seq FROM S2_CardKind WHERE ISNULL(CardKind_Seq, '') NOT IN ( '14', '1', '2',  '3', '4', '5',' 16' )             
    AND Card_Seq NOT IN ( SELECT Card_Seq FROM #CardTemp )        

--INSERT INTO #CardTemp ( Gubun, Card_Seq )            
--SELECT DISTINCT '4식순지' AS Gubun, Card_Seq FROM S2_CardKind WHERE ISNULL(CardKind_Seq, '') IN ( '17')             
--    AND Card_Seq NOT IN ( SELECT Card_Seq FROM #CardTemp )        

delete from temp_choansum

insert into temp_choansum 
SELECT A.Gubun
    , SUM(CASE WHEN RIGHT(A.ComposeDate, 2) = '01' THEN A.Cnt ELSE 0 END) AS 'Month01'
    , SUM(CASE WHEN RIGHT(A.ComposeDate, 2) = '02' THEN A.Cnt ELSE 0 END) AS 'Month02'
    , SUM(CASE WHEN RIGHT(A.ComposeDate, 2) = '03' THEN A.Cnt ELSE 0 END) AS 'Month03'
    , SUM(CASE WHEN RIGHT(A.ComposeDate, 2) = '04' THEN A.Cnt ELSE 0 END) AS 'Month04'
    , SUM(CASE WHEN RIGHT(A.ComposeDate, 2) = '05' THEN A.Cnt ELSE 0 END) AS 'Month05'
    , SUM(CASE WHEN RIGHT(A.ComposeDate, 2) = '06' THEN A.Cnt ELSE 0 END) AS 'Month06'
    , SUM(CASE WHEN RIGHT(A.ComposeDate, 2) = '07' THEN A.Cnt ELSE 0 END) AS 'Month07'
    , SUM(CASE WHEN RIGHT(A.ComposeDate, 2) = '08' THEN A.Cnt ELSE 0 END) AS 'Month08'
    , SUM(CASE WHEN RIGHT(A.ComposeDate, 2) = '09' THEN A.Cnt ELSE 0 END) AS 'Month09'
    , SUM(CASE WHEN RIGHT(A.ComposeDate, 2) = '10' THEN A.Cnt ELSE 0 END) AS 'Month10'
    , SUM(CASE WHEN RIGHT(A.ComposeDate, 2) = '11' THEN A.Cnt ELSE 0 END) AS 'Month11'
    , SUM(CASE WHEN RIGHT(A.ComposeDate, 2) = '12' THEN A.Cnt ELSE 0 END) AS 'Month12'
FROM ( 

    SELECT ISNULL(B.Gubun, '기타') AS Gubun
        , CONVERT(VARCHAR(6), ISNULL(src_compose_mod_date, ''), 112) AS ComposeDate
        , COUNT(order_seq) as cnt 
    from custom_order A    
    LEFT JOIN #CardTemp B ON A.Card_seq = B.card_seq    
    where status_seq >=1 
        AND CONVERT(VARCHAR(8), ISNULL(src_compose_mod_date, ''), 112) LIKE @Year+'%'    --초안 최종 수정일    
        AND src_compose_mod_admin_id NOT IN  ('jaewon.cha', 'admin')
        and member_id not in ( 's4guest' )

    GROUP BY ISNULL(B.Gubun, '기타')     
        , CONVERT(VARCHAR(6), ISNULL(src_compose_mod_date, ''), 112)

) A
GROUP BY A.Gubun

ORDER BY ISNULL(A.Gubun, '기타') 


select gubun,	month1,	month2,	month3,	month4,	month5,	month6,	month7,	month8,	month9,	month10,	month11	month12
from temp_choansum
GO
