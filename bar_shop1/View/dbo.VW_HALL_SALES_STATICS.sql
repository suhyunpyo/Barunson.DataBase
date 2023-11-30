IF OBJECT_ID (N'dbo.VW_HALL_SALES_STATICS', N'V') IS NOT NULL DROP View dbo.VW_HALL_SALES_STATICS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE VIEW [dbo].[VW_HALL_SALES_STATICS]    
AS   
SELECT company_seq,  
ISNULL([1],0) 'd30',  
ISNULL([3],0) 'd90',   
ISNULL([6],0) 'd120',  
ISNULL([12],0) 'd360'  
FROM  (  
  
 SELECT   
 company_seq, 1 gbn, count(*) cnt  from custom_order a  
 INNER JOIN DELIVERY_INFO b on a.order_seq = b.ORDER_SEQ and b.DELIVERY_SEQ =1  
 WHERE status_seq = 15  
 AND b.DELIVERY_DATE >= CONVERT(char(10),dateadd(m,-1,getdate()),121 )   
 AND sales_Gubun IN ('B','H')  
 GROUP BY company_seq  
  
 UNION  
  
 SELECT   
 company_seq, 3 gbn, count(*) cnt  from custom_order a  
 INNER JOIN DELIVERY_INFO b on a.order_seq = b.ORDER_SEQ and b.DELIVERY_SEQ =1  
 WHERE status_seq = 15  
 AND b.DELIVERY_DATE >= CONVERT(char(10),dateadd(m,-3,getdate()),121 )   
 AND sales_Gubun IN ('B','H')  
 GROUP BY company_seq  
  
 UNION  
  
 SELECT   
 company_seq, 6 gbn, count(*) cnt  from custom_order a  
 INNER JOIN DELIVERY_INFO b on a.order_seq = b.ORDER_SEQ and b.DELIVERY_SEQ =1  
 WHERE status_seq = 15  
 AND b.DELIVERY_DATE >= CONVERT(char(10),dateadd(m,-6,getdate()),121 )   
 AND sales_Gubun IN ('B','H')  
 GROUP BY company_seq  
  
 UNION  
  
 SELECT   
 company_seq, 12 gbn, count(*) cnt  from custom_order a  
 INNER JOIN DELIVERY_INFO b on a.order_seq = b.ORDER_SEQ and b.DELIVERY_SEQ =1  
 WHERE status_seq = 15  
 AND b.DELIVERY_DATE >= CONVERT(char(10),dateadd(m,-12,getdate()),121 )   
 AND sales_Gubun IN ('B','H')  
 GROUP BY company_seq  
  
) AS R  
pivot (  
 SUM(CNT)  
 for gbn in ([1],[3],[6],[12])  
) AS P_R  
GO
