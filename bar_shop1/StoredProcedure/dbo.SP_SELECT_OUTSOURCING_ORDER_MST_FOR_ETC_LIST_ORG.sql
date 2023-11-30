IF OBJECT_ID (N'dbo.SP_SELECT_OUTSOURCING_ORDER_MST_FOR_ETC_LIST_ORG', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_OUTSOURCING_ORDER_MST_FOR_ETC_LIST_ORG
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
CREATE PROCEDURE [dbo].[SP_SELECT_OUTSOURCING_ORDER_MST_FOR_ETC_LIST_ORG]  
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
		   COMPANY_TYPE_CODE = CASE WHEN T.ORDER_TYPE = 'D' THEN '139001'  
									WHEN T.ORDER_TYPE = 'K' THEN '139002'  
									WHEN T.ORDER_TYPE = 'T' THEN '139004'  
									WHEN T.ORDER_TYPE = 'O' THEN '139003'  
									WHEN T.ORDER_TYPE = 'AA' THEN '139006'  
									WHEN T.ORDER_TYPE = 'BB' THEN '139007'  
									WHEN T.ORDER_TYPE = 'CC' THEN '139008'  
									WHEN T.ORDER_TYPE = 'DD' THEN '139009'  
									WHEN T.ORDER_TYPE = 'EE' THEN '139010' 
									WHEN T.ORDER_TYPE = 'FF' THEN '139011'  
									WHEN T.ORDER_TYPE = 'GG' THEN '139012'  
									WHEN T.ORDER_TYPE = 'HH' THEN '139013' 
									WHEN T.ORDER_TYPE = 'II' THEN '139014' 
									WHEN T.ORDER_TYPE = 'KK' THEN '139015' 
									WHEN T.ORDER_TYPE = 'LL' THEN '139016'  
									WHEN T.ORDER_TYPE = 'MM' THEN '139017'  
									WHEN T.ORDER_TYPE = 'NN' THEN '139018' 
									WHEN T.ORDER_TYPE = 'OO' THEN '139019'
									WHEN T.ORDER_TYPE = 'PP' THEN '139020' 
									WHEN T.ORDER_TYPE = 'QQ' THEN '139021'  
									WHEN T.ORDER_TYPE = 'RR' THEN '139022'  
									WHEN T.ORDER_TYPE = 'SS' THEN '139023' 
									WHEN T.ORDER_TYPE = 'TT' THEN '139024'
									WHEN T.ORDER_TYPE = 'JJ' THEN '139025'
									WHEN T.ORDER_TYPE = 'UU' THEN '139026'
									WHEN T.ORDER_TYPE = 'XX' THEN '139027'
									WHEN T.ORDER_TYPE = 'YY' THEN '139028'
									WHEN T.ORDER_TYPE = 'ZA' THEN '139029'
									WHEN T.ORDER_TYPE = 'ZB' THEN '139030'
									WHEN T.ORDER_TYPE = 'ZC' THEN '139031'
									WHEN T.ORDER_TYPE = 'ZD' THEN '139032'
									WHEN T.ORDER_TYPE = 'ZE' THEN '139033'
									WHEN T.ORDER_TYPE = 'ZF' THEN '139034'
									WHEN T.ORDER_TYPE = 'ZG' THEN '139035'
							   ELSE '139005' END, 
		   COMPANY_TYPE_NAME = CASE WHEN T.ORDER_TYPE = 'D' THEN '떡보의하루'  
									WHEN T.ORDER_TYPE = 'K' THEN '달콤베이커리'  
									WHEN T.ORDER_TYPE = 'T' THEN '송월타월'  
									WHEN T.ORDER_TYPE = 'O' THEN '손보자기'  
									WHEN T.ORDER_TYPE = 'AA' THEN '오설록'  
									WHEN T.ORDER_TYPE = 'BB' THEN '멜로소제이'  
									WHEN T.ORDER_TYPE = 'CC' THEN '에스텔플라워케익'  
									WHEN T.ORDER_TYPE = 'DD' THEN '김보람초콜릿'  
									WHEN T.ORDER_TYPE = 'EE' THEN '에코그린'  
									WHEN T.ORDER_TYPE = 'FF' THEN '시골이야기'  
									WHEN T.ORDER_TYPE = 'GG' THEN '진협제과'  
									WHEN T.ORDER_TYPE = 'HH' THEN '애꼼(묘약)'  
									WHEN T.ORDER_TYPE = 'II' THEN '광동생활건강' 
									WHEN T.ORDER_TYPE = 'KK' THEN '삼일기름집' 
									WHEN T.ORDER_TYPE = 'LL' THEN '김정환홍삼'  
									WHEN T.ORDER_TYPE = 'MM' THEN '허니올마이티'  
									WHEN T.ORDER_TYPE = 'NN' THEN '골든허니콤' 
									WHEN T.ORDER_TYPE = 'OO' THEN '딜리셔스마켓'
									WHEN T.ORDER_TYPE = 'PP' THEN '설다원' 
									WHEN T.ORDER_TYPE = 'QQ' THEN '완도청년'  
									WHEN T.ORDER_TYPE = 'RR' THEN '어글리솝'  
									WHEN T.ORDER_TYPE = 'SS' THEN '마음이가' 
									WHEN T.ORDER_TYPE = 'TT' THEN '보르딘커피'
									WHEN T.ORDER_TYPE = 'JJ' THEN '꽃을담다'
									WHEN T.ORDER_TYPE = 'UU' THEN '카카오패밀리'
									WHEN T.ORDER_TYPE = 'XX' THEN '헬리빈'
									WHEN T.ORDER_TYPE = 'YY' THEN '현대백화점'
									WHEN T.ORDER_TYPE = 'ZA' THEN '한국도자기리빙'
									WHEN T.ORDER_TYPE = 'ZB' THEN '모애당'
									WHEN T.ORDER_TYPE = 'ZC' THEN '점보'
									WHEN T.ORDER_TYPE = 'ZD' THEN '연경당'
									WHEN T.ORDER_TYPE = 'ZE' THEN '인테이크푸드'
									WHEN T.ORDER_TYPE = 'ZF' THEN '할리스'
									WHEN T.ORDER_TYPE = 'ZF' THEN '예사로이'
							   ELSE '비스트디자인' END,  

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
				   CEO.ORDER_TYPE IN ('D','K','T','O','B','AA','BB','CC','DD','EE','FF','GG','HH','II','KK','LL','MM','NN','OO','PP','QQ','RR','SS','TT','JJ','UU','XX','YY','ZA','ZB','ZC','ZD','ZE','ZF','ZG') AND  
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
						CEO.ORDER_TYPE = CASE	WHEN @P_COMPANY_TYPE_CODE = '139001' THEN 'D'  
												WHEN @P_COMPANY_TYPE_CODE = '139002' THEN 'K'  
												WHEN @P_COMPANY_TYPE_CODE = '139004' THEN 'T'  
												WHEN @P_COMPANY_TYPE_CODE = '139003' THEN 'O'  
												WHEN @P_COMPANY_TYPE_CODE = '139006' THEN 'AA'  
												WHEN @P_COMPANY_TYPE_CODE = '139007' THEN 'BB'  
												WHEN @P_COMPANY_TYPE_CODE = '139008' THEN 'CC'
												WHEN @P_COMPANY_TYPE_CODE = '139009' THEN 'DD'  
												WHEN @P_COMPANY_TYPE_CODE = '139010' THEN 'EE'
												WHEN @P_COMPANY_TYPE_CODE = '139011' THEN 'FF'  
												WHEN @P_COMPANY_TYPE_CODE = '139012' THEN 'GG'
												WHEN @P_COMPANY_TYPE_CODE = '139013' THEN 'HH'  
												WHEN @P_COMPANY_TYPE_CODE = '139014' THEN 'II'
												WHEN @P_COMPANY_TYPE_CODE = '139015' THEN 'KK'
												WHEN @P_COMPANY_TYPE_CODE = '139016' THEN 'LL'  
												WHEN @P_COMPANY_TYPE_CODE = '139017' THEN 'MM'
												WHEN @P_COMPANY_TYPE_CODE = '139018' THEN 'NN'  
												WHEN @P_COMPANY_TYPE_CODE = '139019' THEN 'OO'
												WHEN @P_COMPANY_TYPE_CODE = '139020' THEN 'PP'
												WHEN @P_COMPANY_TYPE_CODE = '139021' THEN 'QQ'  
												WHEN @P_COMPANY_TYPE_CODE = '139022' THEN 'RR'
												WHEN @P_COMPANY_TYPE_CODE = '139023' THEN 'SS'  
												WHEN @P_COMPANY_TYPE_CODE = '139024' THEN 'TT'
												WHEN @P_COMPANY_TYPE_CODE = '139025' THEN 'JJ'
												WHEN @P_COMPANY_TYPE_CODE = '139026' THEN 'UU'
												WHEN @P_COMPANY_TYPE_CODE = '139027' THEN 'XX'
												WHEN @P_COMPANY_TYPE_CODE = '139028' THEN 'YY'
												WHEN @P_COMPANY_TYPE_CODE = '139029' THEN 'ZA'
												WHEN @P_COMPANY_TYPE_CODE = '139030' THEN 'ZB'
												WHEN @P_COMPANY_TYPE_CODE = '139031' THEN 'ZC'
												WHEN @P_COMPANY_TYPE_CODE = '139032' THEN 'ZD'
												WHEN @P_COMPANY_TYPE_CODE = '139033' THEN 'ZE'
												WHEN @P_COMPANY_TYPE_CODE = '139034' THEN 'ZF'
												WHEN @P_COMPANY_TYPE_CODE = '139035' THEN 'ZG'
										 ELSE 'B' END     
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
