IF OBJECT_ID (N'dbo.UP_UPDATE_EXPECTED_DELIVERYDATE_AUTO', N'P') IS NOT NULL DROP PROCEDURE dbo.UP_UPDATE_EXPECTED_DELIVERYDATE_AUTO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UP_UPDATE_EXPECTED_DELIVERYDATE_AUTO]   --4118246  
	--@ORDER_SEQ INT
AS        
BEGIN     
	IF OBJECT_ID('tempdb.dbo.#ORDER_LIST') IS NOT NULL 
	BEGIN 
		DROP TABLE #ORDER_LIST 
	END

	-- JebonExpectedDate 값이 없는 작업 대상을 임시테이블에 넣음
	SELECT * INTO #ORDER_LIST 
	from 
		(		
			SELECT
				A.order_Seq
			FROM
				custom_order AS A
				LEFT OUTER JOIN custom_order_chasu AS E ON A.order_seq = E.order_seq
				INNER JOIN DELIVERY_INFO AS B ON A.order_Seq = B.order_seq
				INNER JOIN S2_CardView AS C ON A.card_seq = C.card_seq
				LEFT OUTER JOIN Company AS D ON A.company_seq = D.company_seq
				LEFT OUTER JOIN manage_code AS F ON A.sales_gubun = F.code AND F.code_type = 'sales_gubun'
				LEFT OUTER JOIN admin_lst AS G ON A.src_PrintCopy_admin_id = G.admin_id
			WHERE
				A.settle_status = 2
				AND (
					A.src_printer_Seq IS NULL
					OR A.src_printer_seq <= 2
				)
				AND A.sales_gubun IN (
					'SA',
					'SB',
					'ST',
					'SS',
					'B',
					'C',
					'H',
					'U',
					'D',
					'Q',
					'P',
					'SG',
					'X',
					'XB',
					'G',
					'SD',
					'BM',
					''
				)
				and a.src_confirm_date >= convert(varchar(10), dateadd(day, - 30, getdate()), 120)
				AND a.src_confirm_date <= convert(varchar(10), dateadd(day, 1, getdate()), 120) + ' 23:59'
				and a.JebonExpectedDate is null
		) TT 


	-- 임시테이블에 있는 ORDER_SEQ 커서로 돌리면서 작업 진행
	DECLARE @ORDER_SEQ INT
	DECLARE CURSORTMP CURSOR FOR
	SELECT
		ORDER_SEQ
	FROM
		#ORDER_LIST 

	OPEN CURSORTMP

	FETCH NEXT FROM CURSORTMP INTO @ORDER_SEQ

	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE @ORDER_SEQ_item INT
		DECLARE @WorkDay INT
		DECLARE @confirm_date datetime
		DECLARE @SendDate varchar(10)
		DECLARE @JebonExpectedDate varchar(10)		-- 제본예정일은 예상발송일 - 1일 입니다.

		SELECT 
			@ORDER_SEQ_item = order_seq, 
			@WorkDay = WorkDay, 
			@confirm_date = confirm_date, 
			@SendDate = CONVERT(varchar(10), SendDate, 120)		-- 예상발송일 = 포장예정일
		FROM 
			dbo.FN_GET_Days_of_making_cards(@ORDER_SEQ)
		
		IF @ORDER_SEQ_item > 0		-- 예상발송일을 구할 수 없는 주문건의 경우 @ORDER_SEQ_item 에 0이 들어옴
		BEGIN
			-- 제본예정일 구하기 (제본예정일은 예상발송일 - 1일)
			-- @WorkDay - 1 을 하지 않고 @WorkDay 를 그대로 사용하는 이유는 FN_GET_Days_of_making_cards 함수에서 예상발송일 구할 때 @WorkDay + 1 로 구하고 있기 때문
			SET @JebonExpectedDate = dbo.fn_IsWorkDay(CONVERT(varchar(10), @confirm_date, 120), @WorkDay)

			-- 포장예정일과 제본예정일을 UPDATE 합니다.
			UPDATE
				CUSTOM_ORDER
			SET
				PACKING_EXPECTED_DATE = @SendDate,
				JebonExpectedDate = @JebonExpectedDate,
				PACKING_EXPECTED_CHECK = 'Y'
			WHERE
				ORDER_SEQ = @ORDER_SEQ	
		END

		FETCH NEXT FROM CURSORTMP INTO @ORDER_SEQ
	END

	CLOSE CURSORTMP
	DEALLOCATE CURSORTMP

END

GO