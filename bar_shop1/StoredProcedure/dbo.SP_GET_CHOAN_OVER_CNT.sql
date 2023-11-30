IF OBJECT_ID (N'dbo.SP_GET_CHOAN_OVER_CNT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_GET_CHOAN_OVER_CNT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/*  
초안 3번 이상신청했는가   
  
  초안 신청    결제일  
1.7/11   7/12  
2.7/11  
3.7/12      
  
  
결제일 이전의 초안신청 건수는 리셋 0건  
결제가 없을 경우 3건이 된다.  
  
  
exec SP_GET_CHOAN_OVER_CNT 'ST', 'eun901002', NULL , NULL  
  
exec SP_GET_CHOAN_OVER_CNT 'ST', 's4guest', '', ''  
  
exec SP_GET_CHOAN_OVER_CNT 'ST', NULL , '남승미테스트', 'mabin0110@nate.com'  
*/  
  
  
  
CREATE PROCEDURE [dbo].[SP_GET_CHOAN_OVER_CNT]  
 @P_CCOM_GUBUN  VARCHAR(2)  
  
, @P_MEMBER_ID  VARCHAR(50)  
, @P_ORDER_NAME  VARCHAR(50)  
, @P_ORDER_EMAIL  VARCHAR(50)  
  
AS   
BEGIN  

 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
     
 SET NOCOUNT ON; 

 DECLARE @CNT INT = 0  
  
  
 IF @P_MEMBER_ID IS NOT NULL  
  BEGIN  
   SELECT @CNT = SUM(CASE WHEN A.SRC_COMPOSE_DATE IS NOT NULL AND ISNULL(B.MAX_SETTLE_DATE, '1990-01-01') < A.SRC_COMPOSE_DATE THEN 1 ELSE 0 END )  
     FROM CUSTOM_ORDER A  
    LEFT JOIN (  
     SELECT MEMBER_ID, MAX(SETTLE_DATE) AS MAX_SETTLE_DATE  
       FROM CUSTOM_ORDER   
      WHERE STATUS_SEQ = 15  
     AND PAY_TYPE <> 4  
     AND MEMBER_ID = @P_MEMBER_ID  
     AND SALES_GUBUN = @P_CCOM_GUBUN  --// 사이트구분  
     AND ORDER_TYPE  IN (1,6,7)   --// 주문타입 (1:청첩장 2:감사장 3:초대장 4,시즌카드 5:미니청첩장 6:포토/디지탈 7:이니셜 8:포토미니)  
      GROUP BY MEMBER_ID  
    ) B ON A.MEMBER_ID = B.MEMBER_ID   
    WHERE A.STATUS_SEQ BETWEEN 1 AND 14  
    AND A.UP_ORDER_SEQ IS NULL  
    AND A.PAY_TYPE <> 4  
    AND A.MEMBER_ID = @P_MEMBER_ID  
    AND A.SALES_GUBUN = @P_CCOM_GUBUN  --// 사이트구분  
    AND A.ORDER_TYPE  IN (1,6,7)   --// 주문타입 (1:청첩장 2:감사장 3:초대장 4,시즌카드 5:미니청첩장 6:포토/디지탈 7:이니셜 8:포토미니)  
    GROUP BY A.MEMBER_ID  
      
  END   
 ELSE  
  BEGIN  
   SELECT @CNT = SUM(CASE WHEN A.SRC_COMPOSE_DATE IS NOT NULL AND ISNULL(B.MAX_SETTLE_DATE, '1990-01-01') < A.SRC_COMPOSE_DATE THEN 1 ELSE 0 END )  
     FROM CUSTOM_ORDER A  
    LEFT JOIN (  
     SELECT MEMBER_ID, MAX(SETTLE_DATE) AS MAX_SETTLE_DATE  
       FROM CUSTOM_ORDER   
      WHERE STATUS_SEQ = 15  
     AND PAY_TYPE <> 4  
     AND ORDER_NAME = @P_ORDER_NAME  
     AND ORDER_EMAIL = @P_ORDER_EMAIL  
  
     AND SALES_GUBUN = @P_CCOM_GUBUN  --// 사이트구분  
     AND ORDER_TYPE  IN (1,6,7)   --// 주문타입 (1:청첩장 2:감사장 3:초대장 4,시즌카드 5:미니청첩장 6:포토/디지탈 7:이니셜 8:포토미니)  
      GROUP BY MEMBER_ID  
    ) B ON A.MEMBER_ID = B.MEMBER_ID   
    WHERE A.STATUS_SEQ BETWEEN 1 AND 14  
    AND A.UP_ORDER_SEQ IS NULL  
    AND A.PAY_TYPE <> 4  
    AND A.ORDER_NAME = @P_ORDER_NAME  
    AND A.ORDER_EMAIL = @P_ORDER_EMAIL  
    AND A.SALES_GUBUN = @P_CCOM_GUBUN  --// 사이트구분  
    AND A.ORDER_TYPE  IN (1,6,7)   --// 주문타입 (1:청첩장 2:감사장 3:초대장 4,시즌카드 5:미니청첩장 6:포토/디지탈 7:이니셜 8:포토미니)  
    GROUP BY A.MEMBER_ID  
  END  
  
  SELECT @CNT AS CHOAN_CNT ;  
END   
  
  
  
/*  
select a.member_id, a.sasik_price, * from custom_order a  
 where a.order_seq = '2847100'   
*/  
GO
