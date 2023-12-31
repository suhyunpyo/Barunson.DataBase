IF OBJECT_ID (N'dbo.up_backend_coop_total_sell_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_coop_total_sell_info
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   : [2003:07:30    0:57]  JJH: 
	관련페이지 : shopadm/custom/settle/coop_sell_info.asp
	내용	   : 제휴사별 총 매출관리
	
	수정정보   : 
*/
CREATE  Procedure [dbo].[up_backend_coop_total_sell_info]
	@KIND		varchar(10)
,	@SDAY			datetime
,	@EDAY			datetime
as
CREATE TABLE #TEMP_TABLE
(
	COMPANY_NAME		VARCHAR(100)
,	COMPANY_SEQ		INT
,	ORDER_COUNT		INT
,	CARD_ORDER_COUNT	INT
,	ORDER_TOTAL_PRICE	MONEY
,	CARD_COST		MONEY
,	CARD_COMM		MONEY
,	KIND			INT		-- 1 : 정상건 , 2:취소건
)
	
	SET	@EDAY = @EDAY + ' 23:59:59'
-- 정산건 및 취소건 산출 (취소건은 다음에 취소일로 뽑아서 뺴준다)
	INSERT INTO  #TEMP_TABLE(COMPANY_NAME,COMPANY_SEQ,ORDER_COUNT,CARD_ORDER_COUNT,ORDER_TOTAL_PRICE,CARD_COST,CARD_COMM,KIND)
	SELECT CPY.COMPANY_NAME
		,SELL.COMPANY_SEQ
		,SELL.ORDER_COUNT
		,SELL.CARD_ORDER_COUNT
		,ISNULL(SELL.ORDER_TOTAL_PRICE,0)
		,SELL.CARD_COST
		,SELL.CARD_COMM
		 , 1
	 FROM	
	(  	SELECT  
		COM. COMPANY_SEQ
		,COUNT(*) AS ORDER_COUNT					-- 주문건수
		,SUM(COM.ORDER_COUNT) AS CARD_ORDER_COUNT		--주문카드수량
		,SUM(COM.ORDER_TOTAL_PRICE) AS ORDER_TOTAL_PRICE			--매출총액
		,isnull(SUM(COM.CARD_COST),0) AS CARD_COST				--공급원가
		,isnull(SUM(COM.CARD_COMM),0) AS CARD_COMM				--수수료
		FROM dbo.custom_order_master COM WHERE  COM.STATUS_SEQ NOT IN (0,1,2,3,11) 		-- 5 번이 취소건인데 취소건은 포함한다.(나중에 빼주므로)
					AND COM.SRC_DEL_DATE IS NULL 
					AND COM.SETTLE_DATE BETWEEN @SDAY AND @EDAY
					GROUP BY  COM.COMPANY_SEQ
	) SELL , dbo.company CPY
	WHERE SELL.COMPANY_SEQ =  CPY.COMPANY_SEQ
-- 취소건 산출 
	INSERT INTO  #TEMP_TABLE(COMPANY_NAME,COMPANY_SEQ,ORDER_COUNT,CARD_ORDER_COUNT,ORDER_TOTAL_PRICE,CARD_COST,CARD_COMM,KIND)
	SELECT CPY.COMPANY_NAME
		,SELL.COMPANY_SEQ
		,SELL.ORDER_COUNT
		,SELL.CARD_ORDER_COUNT
		,ISNULL(SELL.ORDER_TOTAL_PRICE,0)
		,SELL.CARD_COST
		,SELL.CARD_COMM
		 , 2
	 FROM	
	(  	SELECT  
		COM. COMPANY_SEQ 
		,SUM(-1) AS ORDER_COUNT					-- 주문건수
		,SUM(COM.ORDER_COUNT*-1) AS CARD_ORDER_COUNT		--주문카드수량
		,SUM(COM.ORDER_TOTAL_PRICE*-1) AS ORDER_TOTAL_PRICE			--매출총액
		,isnull(SUM(COM.CARD_COST*-1),0) AS CARD_COST				--공급원가
		,isnull(SUM(COM.CARD_COMM*-1),0) AS CARD_COMM			--수수료
		FROM dbo.custom_order_master COM WHERE  COM.STATUS_SEQ  = 5 		-- 취소건만 따로 모든다.
					AND COM.SRC_DEL_DATE IS NULL 
					AND COM.CANCEL_DT  BETWEEN @SDAY AND @EDAY	-- 취소일해당 취소일에 대한 모든건을 가져온다
					GROUP BY  COM.COMPANY_SEQ
	) SELL , dbo.company CPY
	WHERE SELL.COMPANY_SEQ =  CPY.COMPANY_SEQ
--	select * from #TEMP_TABLE
-- 취소건과 성공건을합하기 위해서
	SELECT  COMPANY_SEQ
		,COMPANY_NAME
		,SUM(ORDER_COUNT)  AS ORDER_COUNT 
		,SUM(CARD_ORDER_COUNT) AS CARD_ORDER_COUNT
		,SUM(ORDER_TOTAL_PRICE) AS ORDER_TOTAL_PRICE	
		,isnull(SUM(CARD_COST),0) AS CARD_COST
		,isnull(SUM(CARD_COMM),0) AS CARD_COMM
	FROM #TEMP_TABLE  
	GROUP BY COMPANY_SEQ , COMPANY_NAME
	ORDER BY  ORDER_TOTAL_PRICE DESC

GO
