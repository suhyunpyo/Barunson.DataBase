IF OBJECT_ID (N'dbo.SP_SELECT_OUTSOURCING_ORDER_MST_FOR_ETC_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_OUTSOURCING_ORDER_MST_FOR_ETC_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- =============================================  
-- AUTHOR:  <AUTHOR,,NAME>  
-- CREATE DATE: <CREATE DATE,,>  
-- DESCRIPTION: <DESCRIPTION,,>  
-- =============================================  
/*  
  
  EXEC SP_SELECT_OUTSOURCING_ORDER_MST_FOR_ETC_LIST '','SA|SB|ST','1','','2021-04-08','2021-04-15',''  
  
  SELECT VALUE FROM DBO.FN_SPLIT('ST|SB|SA', '|')

SELECT * FROM CUSTOM_ETC_ORDER  
WHERE MEMBER_ID = 'S4GUEST'  
AND ORDER_DATE >= '2017-08-29'  
ORDER BY ORDER_SEQ DESC  
  
*/  
CREATE PROCEDURE [dbo].[SP_SELECT_OUTSOURCING_ORDER_MST_FOR_ETC_LIST]  
    @P_COMPANY_TYPE_CODE AS VARCHAR(200)  
,   @P_SITE_TYPE_CODE AS VARCHAR(20)  
,   @P_SEARCH_TYPE_CODE AS VARCHAR(200)  
,   @P_SEARCH_VALUE AS VARCHAR(200)  
,   @P_START_DATE AS VARCHAR(20)  
,   @P_END_DATE AS VARCHAR(20)  
, @P_DELIVERY_CODE AS VARCHAR(1)  
--,   @P_ORDER_STATUS_CODE AS VARCHAR(20)  
AS  
 BEGIN  
    
	SELECT ROW_NUMBER() OVER(ORDER BY T.ORDER_DATE ASC) AS ROW_NUM, 
		   COMPANY_TYPE_CODE = isnull((SELECT ETC1 FROM MANAGE_CODE WHERE code_type = 'etcprod' and code = T.ORDER_TYPE and parent_id = 0 and etc1 is not null and etc1 <> ''),'139005'), 
		   COMPANY_TYPE_NAME = isnull((SELECT code_value FROM MANAGE_CODE WHERE code_type = 'etcprod' and code = T.ORDER_TYPE and parent_id = 0 and etc1 is not null and etc1 <> ''),'비스트디자인'),  

		   STATUS_SEQ_NAME = CASE WHEN T.SETTLE_METHOD = '3' AND T.STATUS_SEQ = '1' THEN '입금대기중'  
								  WHEN T.SETTLE_METHOD = '2' AND T.STATUS_SEQ = '4' THEN '카드결제'  
								  WHEN T.SETTLE_METHOD = '3' AND T.STATUS_SEQ = '4' THEN '무통장입금완료'  
								  WHEN T.SETTLE_METHOD = '1' AND T.STATUS_SEQ = '4' THEN '계좌이체'  
								  WHEN T.STATUS_SEQ = 10 THEN '상품준비중'  
								  WHEN T.STATUS_SEQ = 12 THEN '발송완료'  
								  WHEN T.STATUS_SEQ IN ('3','5') THEN '결제취소'  
							 ELSE '기타' END, 
		   /* (희망일자가 현재날짜보다 같거나 큼 OR 예상발송일이 현재날짜보다 같거나 큼) AND 주문상태값이 12가 아닌 경우 송장미기입으로 추가 표기*/
		   STATUS_INVOICE = CASE WHEN T.STATUS_SEQ = 12 THEN 'Y'  
							 ELSE  
									CASE WHEN DATEDIFF(DAY, CONVERT(VARCHAR(10), GETDATE(), 120),  CONVERT(VARCHAR(10), T.HOPE_DATE, 120)) <=0 OR 
											  DATEDIFF(DAY, CONVERT(VARCHAR(10), GETDATE(), 120),  CONVERT(VARCHAR(10), T.EXPECT_DATE, 120)) <= 0
									THEN 'N'
									ELSE 'Y'
											--CASE WHEN T.SETTLE_METHOD = '3' AND T.STATUS_SEQ = '1' THEN 'Y'  
  									--				WHEN T.SETTLE_METHOD = '3' AND T.STATUS_SEQ = '4' THEN 'Y'  
											--		WHEN T.SETTLE_METHOD = '2' AND T.STATUS_SEQ = '4' THEN 'Y' 
											--		WHEN T.SETTLE_METHOD = '1' AND T.STATUS_SEQ = '4' THEN 'Y'  
											--		WHEN T.STATUS_SEQ = 10 THEN 'Y' 
											--		WHEN T.STATUS_SEQ IN ('3','5') THEN 'Y'  
											--ELSE 'Y' END
									END
							 END,
     

		   DELIVERY_COM_NM = CASE WHEN T.DELIVERY_COM = 'PO' THEN '우체국'  
								  WHEN T.DELIVERY_COM = 'CJ' THEN '대한통운'  
								  WHEN T.DELIVERY_COM = 'HJ' THEN '한진택배'  
								  WHEN T.DELIVERY_COM = 'LG' THEN '로젠택배'  
								  WHEN T.DELIVERY_COM = 'LT' THEN '롯데택배'  
								  WHEN T.DELIVERY_COM = 'QC' THEN '퀵배송'  
							  ELSE '' END, 
		   T.*  
	FROM (  
			SELECT CEO.ORDER_SEQ, 
				   CEO.STATUS_SEQ, 
				   CEO.DELIVERY_DATE, 
				   CEO.DELIVERY_COM,
				   CEO.DELIVERY_CODE, 
				   CEO.ORDER_NAME, 
				   CEO.ORDER_HPHONE, 
				   SALES_GUBUN = CASE WHEN CEO.SALES_GUBUN = 'SA' THEN '비핸즈카드'  
									  WHEN CEO.SALES_GUBUN = 'ST' THEN '더카드'  
									  WHEN CEO.SALES_GUBUN = 'SB' THEN '바른손카드'  
									  WHEN CEO.SALES_GUBUN = 'SS' THEN '프리미어'  
									  ELSE '바른몰'  
								 END, 
				   CEO.ORDER_TYPE, 
				   CEO.ORDER_DATE, 
				   CEO.SETTLE_PRICE, 
				   CEO.SETTLE_DATE, 
				   CEO.SETTLE_METHOD,
				   CEOI.CARD_SEQ, 
				   CEOI.ORDER_COUNT, 
				   SC.CARD_NAME, 
				   SC.CARD_CODE, 
				   SC.CARD_IMAGE,
				   SC.CARD_DIV, 
				   CEO.RECV_ADDRESS, 
				   CEO.RECV_ADDRESS_DETAIL, 
				   CEO.RECV_NAME, 
				   CEO.RECV_HPHONE, 
				   CEO.RECV_PHONE, 
				   CEO.RECV_ZIP, 
				   CEO.RECV_MSG, 
				   CEO.ADMIN_MEMO, 
				   RECEIPT_DATE = CEO.PREPARE_DATE, -- 접수 일자  
				   EXPECT_DATE = CEO.PRINT_DATE,		-- 예상 발송일자  
				   CEOI.CARD_OPT, 
				   ETC_INFO = CEO.ETC_INFO_S,
				   CEO.DELIVERY_PRICE,  
				   CEO.RESULT_INFO, 
				   HOPE_DATE = CEO.PG_PAYDATE
			FROM   CUSTOM_ETC_ORDER AS CEO LEFT JOIN 
				   CUSTOM_ETC_ORDER_ITEM AS CEOI ON CEO.ORDER_SEQ = CEOI.ORDER_SEQ JOIN 
				   S2_CARD AS SC ON CEOI.CARD_SEQ = SC.CARD_SEQ  
			WHERE  1 = 1 AND  
				   CEO.ORDER_TYPE IN ((SELECT code FROM MANAGE_CODE WHERE code_type = 'etcprod' and parent_id = 0 and etc1 is not null and etc1 <> '')) AND  
				   SC.CARD_DIV = 'C08' AND  
				   CEO.STATUS_SEQ <> 0 AND --AND  CEO.ORDER_DATE >= '2017-08-01'  
				   CEO.SALES_GUBUN <> 'BS'AND  
				   ( ISNULL(@P_START_DATE, '') = '' OR CONVERT(VARCHAR(10),CEO.ORDER_DATE, 120) >= @P_START_DATE ) AND  
				   ( ISNULL(@P_END_DATE, '') = '' OR CONVERT(VARCHAR(10),CEO.ORDER_DATE, 120) <= @P_END_DATE ) AND  
				   ( ISNULL(@P_SITE_TYPE_CODE, '') = '' OR (CEO.SALES_GUBUN IN (SELECT VALUE FROM DBO.FN_SPLIT(@P_SITE_TYPE_CODE, '|'))) )  
			AND (  
					CASE WHEN @P_SEARCH_TYPE_CODE = '1' AND @P_SEARCH_VALUE <> '' THEN CONVERT(VARCHAR(50), ISNULL(CEO.ORDER_SEQ, ''))  
						 WHEN @P_SEARCH_TYPE_CODE = '2' AND @P_SEARCH_VALUE <> '' THEN CEO.ORDER_NAME  
						 WHEN @P_SEARCH_TYPE_CODE = '3' AND @P_SEARCH_VALUE <> '' THEN SC.CARD_CODE  
					ELSE '' END  
				)   
				=   
				(  
					CASE WHEN @P_SEARCH_TYPE_CODE IN ('1','2','3','4') AND @P_SEARCH_VALUE <> '' THEN CONVERT(VARCHAR(50), @P_SEARCH_VALUE)  
					ELSE '' END  
				) AND  
				(   
					( ISNULL(@P_COMPANY_TYPE_CODE, '') = '' ) OR   
					( 
						CEO.ORDER_TYPE = isnull((SELECT code FROM MANAGE_CODE WHERE code_type = 'etcprod' and parent_id = 0 and etc1 is not null and etc1 <> '' and etc1 = @P_COMPANY_TYPE_CODE), 'B')
				   )             
			   ) AND  
			   (    
				--(  
				-- @P_DELIVERY_CODE = 2  
				-- AND (  
				--    CASE WHEN @P_DELIVERY_CODE = '' THEN '' ELSE CEO.STATUS_SEQ END = 12  
				--  )  
				--)  
				--OR  
				(  
					@P_DELIVERY_CODE = 1 AND 
					(  
						CASE WHEN @P_DELIVERY_CODE = '' THEN '' ELSE CEO.STATUS_SEQ END = 12  
					)  
				) OR  
				(  
					@P_DELIVERY_CODE = 0 AND 
					(  
						CASE WHEN @P_DELIVERY_CODE = '' THEN '' ELSE CEO.STATUS_SEQ END <> 12  
					)  
				) OR  
				(  
					ISNULL(@P_DELIVERY_CODE, '' ) = ''  
				)  
  
			  )  
		)T  
    ORDER BY T.ORDER_DATE DESC  
  




 END  
GO
