IF OBJECT_ID (N'dbo.up_backend_job_settle_list_create', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_job_settle_list_create
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	작성정보   : [2003:07:31    16:39]  JJH: 
	관련페이지 : job 처리
	내용	   : 매달 1일마다 이전달의 제휴사 판매내역및 취소 내역을 가져와서 
		   제휴사에 정산해줘야될 금액을 산출한다
	
	수정정보   : 
		  매출관리에서 정상건 취소건이 같이나오기 떄문에 여기서 정상/취소를
		따로 처리하지 않고.. 합해서 값을 올린다.
*/
CREATE Procedure [dbo].[up_backend_job_settle_list_create]
	@KIND			varchar(10)
,	@SDAY_STR		varchar(6) =''
,	@EDAY_STR		varchar(6) =''
as
	DECLARE	@SDAY		DATETIME
			,@EDAY		DATETIME
CREATE TABLE #TEMP_TABLE
(
	COMPANY_SEQ		int
	,SETTLE_DT		varchar(6)
	,TOTAL_SELL_PRICE	money
	,COMM_PRICE		money
	,SETTLE_PRICE		money
	,KIND			char(1)
	
)	
		DECLARE	@TEMP_STR		VARCHAR(100)
				,@TEMP_VAL		INT
-- 자동으로 처리할경우
IF @KIND = 'A'
	BEGIN
		SET 	@TEMP_VAL  =  DAY(GETDATE())
		IF @TEMP_VAL != 1  RETURN			-- 1일이 아니면 더이상 작업을 할필요가 없다.
		SET @SDAY =  DATEADD(month,-1,GETDATE())	-- 이전달 01 일 00분터
		SET @EDAY =  convert(varchar(6),GETDATE(),112) + '01' --다음달 01일 00분 까지
-- 정상건에 대한 결제금액
		INSERT INTO #TEMP_TABLE(COMPANY_SEQ,SETTLE_DT,TOTAL_SELL_PRICE,COMM_PRICE,SETTLE_PRICE,KIND)
		SELECT    COM.COMPANY_SEQ
			,convert(varchar(6),COM.SETTLE_DATE,112)
			,ISNULL(SUM(SETTLE_PRICE),0) AS SETTLE_PRICE
			,ISNULL(SUM(CARD_COMM),0) AS CARD_COMM
			,ISNULL(SUM(CARD_COMM),0) AS CARD_COMM
			,'1'
			 FROM dbo.custom_order_master COM 
			WHERE 	COM.SETTLE_DATE BETWEEN @SDAY AND @EDAY
			AND	COM.STATUS_SEQ >= 4 		-- 결제를 했던건 그냥 다~~ 가져온다 (취소 되었건 말건) 취소건은 나중에 -로 처리해준다
			AND	COM.COMPANY_SEQ > 1
			GROUP BY convert(varchar(6),COM.SETTLE_DATE,112) , COM.COMPANY_SEQ
-- 취소건에 대한 결제금액
		INSERT INTO #TEMP_TABLE(COMPANY_SEQ,SETTLE_DT,TOTAL_SELL_PRICE,COMM_PRICE,SETTLE_PRICE,KIND)
		SELECT    COM.COMPANY_SEQ
			,convert(varchar(6),COM.SETTLE_DATE,112)
			,ISNULL(SUM(SETTLE_PRICE),0)* -1  AS SETTLE_PRICE
			,ISNULL(SUM(CARD_COMM),0) * -1 AS CARD_COMM
			,ISNULL(SUM(CARD_COMM),0) * -1 AS CARD_COMM
			,'2'
			 FROM dbo.custom_order_master COM 
			WHERE 	COM.CANCEL_DT BETWEEN @SDAY AND @EDAY
			AND	COM.STATUS_SEQ = 5 		-- 결제를 했던건 그냥 다~~ 가져온다 (취소 되었건 말건) 취소건은 나중에 -로 처리해준다
			AND	COM.COMPANY_SEQ > 1
			GROUP BY convert(varchar(6),COM.SETTLE_DATE,112)  , COM.COMPANY_SEQ
	END
-- 수작업으로 처리할경우
IF @KIND = 'M'
	BEGIN
			
		SET @SDAY =  @SDAY_STR + '01 00:00:00'
		SET @EDAY = @EDAY_STR + '01 00:00:00'
		SET @EDAY =  DATEADD(month,1,@EDAY)		-- 다음달  1일 00 시 00분전까지
-- 정상건에 대한 결제금액
		INSERT INTO #TEMP_TABLE(COMPANY_SEQ,SETTLE_DT,TOTAL_SELL_PRICE,COMM_PRICE,SETTLE_PRICE,KIND)
		SELECT    COM.COMPANY_SEQ
			,convert(varchar(6),COM.SETTLE_DATE,112)
			,ISNULL(SUM(SETTLE_PRICE),0) AS SETTLE_PRICE
			,ISNULL(SUM(CARD_COMM),0) AS CARD_COMM
			,ISNULL(SUM(CARD_COMM),0) AS CARD_COMM
			,'1'
			 FROM dbo.custom_order_master COM 
			WHERE 	COM.SETTLE_DATE BETWEEN @SDAY AND @EDAY
			AND	COM.STATUS_SEQ >= 4 		-- 결제를 했던건 그냥 다~~ 가져온다 (취소 되었건 말건) 취소건은 나중에 -로 처리해준다
			AND	COM.COMPANY_SEQ > 1
			GROUP BY convert(varchar(6),COM.SETTLE_DATE,112) , COM.COMPANY_SEQ 
-- 취소건에 대한 결제금액
		INSERT INTO #TEMP_TABLE(COMPANY_SEQ,SETTLE_DT,TOTAL_SELL_PRICE,COMM_PRICE,SETTLE_PRICE,KIND)
		SELECT    COM.COMPANY_SEQ
			,convert(varchar(6),COM.SETTLE_DATE,112)
			,ISNULL(SUM(SETTLE_PRICE),0)* -1 AS SETTLE_PRICE 
			,ISNULL(SUM(CARD_COMM),0) * -1 AS CARD_COMM
			,ISNULL(SUM(CARD_COMM),0) * -1 AS CARD_COMM
			,'2'
			 FROM dbo.custom_order_master COM 
			WHERE 	COM.CANCEL_DT BETWEEN @SDAY AND @EDAY
			AND	COM.STATUS_SEQ = 5 		-- 결제를 했던건 그냥 다~~ 가져온다 (취소 되었건 말건) 취소건은 나중에 -로 처리해준다
			AND	COM.COMPANY_SEQ > 1
			GROUP BY  convert(varchar(6),COM.SETTLE_DATE,112),  COM.COMPANY_SEQ
	END
-- 똑같은 값이 존재한다면 해당값의ONOFF를 'N' 로 처리하고다시 INSERT
	UPDATE CST SET  ONOFF='N'
	FROM dbo.coop_settle_tbl  CST , #temp_table TT
	WHERE CST.COMPANY_SEQ = TT.COMPANY_SEQ
	AND	CST.SETTLE_DT = TT.SETTLE_DT
-- 다시 INSERT
	INSERT INTO dbo.coop_settle_tbl(COMPANY_SEQ
				,SETTLE_DT
				,TOTAL_SELL_PRICE
				,COMM_PRICE
				,SETTLE_PRICE
				,KIND)
	SELECT	COMPANY_SEQ
				,SETTLE_DT
				,SUM(TOTAL_SELL_PRICE)
				,SUM(COMM_PRICE)
				,ISNULL(SUM(SETTLE_PRICE),0) AS SETTLE_PRICE
				,3
			 FROM #temp_table GROUP BY SETTLE_DT , COMPANY_SEQ

GO
