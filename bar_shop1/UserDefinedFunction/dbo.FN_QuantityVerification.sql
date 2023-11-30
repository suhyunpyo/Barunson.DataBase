IF OBJECT_ID (N'dbo.FN_QuantityVerification', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_QuantityVerification', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_QuantityVerification', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_QuantityVerification', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_QuantityVerification', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.FN_QuantityVerification
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FN_QuantityVerification](
	@order_seq int,
	@check_copy tinyint		-- 지시서까지 검증 하나요? 1이면 지시서까지 검증
)
RETURNS @TEMP TABLE (
	order_seq int,
	rslt tinyint,			-- 검증 결과 : 1 정상, 0 오류
	rsltMsg varchar(1000)	-- 오류 내용
)
AS
BEGIN

	DECLARE @last_total_price int, @settle_price int, @card_seq int, @order_count int
	DECLARE @isFPrint char(1), @item_type char(1), @item_count int
	DECLARE @rslt tinyint
	DECLARE @rsltMsg VARCHAR(1000)
	DECLARE @pay_type char(1)
	DECLARE @order_add_type char(1) 

	-- 검사 결과를 성공이라고 가정하고 시작
	set @rslt = 1

	-- 검사에 필요한 주문 기본 정보 변수에 저장
	select	
			@last_total_price	=	last_total_price
		,	@settle_price		=	settle_price
		,	@card_seq			=	card_seq
		,	@order_count		=	order_count 
		,   @pay_type	        =   pay_type
		,   @order_add_type     =   order_add_type
	from	custom_order 
	where	order_seq = @order_seq
	
	-- 결제 금액 검증
	if @last_total_price <> @settle_price
	BEGIN
		SET @rslt = 0
		SET @rsltMsg = '결제금액 불일치'
		goto RETURN_RESULT
	END	

	-- 인쇄판 수량 검증
	-- custom_order_plist 의 수량은 custom_order_item 과 일치해야 한다. 
	-- custom_order_plist 를 기준으로 검증. custom_order_item에 있는 데이터 전체가 custom_order_plist 에 있는 것은 아니므로.
	IF Exists (
		SELECT * FROM
		(
			SELECT
				card_seq, SUM(print_count) AS print_count
			FROM
				custom_order_plist
			WHERE
				order_seq = @order_seq AND
				print_count <> 0 AND
				isFPrint <> '1'
			GROUP BY
				card_seq
		) A LEFT OUTER JOIN 
		(
			SELECT
				card_seq, SUM(item_count) AS item_count
			FROM
				custom_order_item
			WHERE
				order_seq = @order_seq AND
				item_count <> 0
			GROUP BY
				card_seq
		) B ON A.card_seq = B.card_seq
		WHERE
			A.print_count <> B.item_count
	)
	BEGIN
		SET @rslt = 0
		SET @rsltMsg = '인쇄판의 수량과 주문상품 수량 불일치'
		goto RETURN_RESULT
	END

	-- 배송상품 누락 검증
	-- custom_order_item 을 기준으로 delivery_info_detail 에 빠진 항목이 없는지 확인한다.
	IF Exists (
		SELECT
			A.*
		FROM
		(
			SELECT
				A.order_seq,
				A.item_type,
				CASE WHEN B.id IS NOT NULL THEN B.id ELSE A.id END AS id
			FROM
				custom_order_item A
				LEFT OUTER JOIN custom_order_plist B ON A.order_seq = B.order_seq AND A.card_seq = B.card_seq AND  B.print_count <> 0 AND B.isFPrint <> '1'
			WHERE
				A.order_seq = @order_seq AND
				A.item_count <> 0 AND
				A.item_type <> 'S' AND -- 스티커 제외
				A.item_type <> 'Z' AND -- 사은품 제외
				A.item_type <> 'D' AND -- 봉투 라이닝 제외
				A.item_type <> 'A' -- 악세사리는 배송상품에 추가 되어야 하지만 현재 누락이 많아서 우선 제외함. 아래 지시서 검증 때 악세사리 다시 체크함.
		) A
		LEFT OUTER JOIN delivery_info_detail B ON A.order_seq = B.order_seq AND A.id = B.item_id
		WHERE
			(B.ID IS NULL AND A.item_type <> 'C') OR
			(B.ID IS NULL AND A.item_type = 'C' AND NOT EXISTS(SELECT * FROM custom_order_item WHERE order_seq = A.order_seq AND item_type = 'I'))
	)
	BEGIN
		SET @rslt = 0
		SET @rsltMsg = '주문상품과 배송상품 불일치 (배송상품 누락)'
		goto RETURN_RESULT
	END

	-- 배송상품 수량 검증
	-- delivery_info_detail 의 수량은 custom_order_item 과 일치해야 한다.
	-- delivery_info_detail 을 기준으로 검증.
	IF Exists (
		SELECT * FROM
		(
			SELECT	
				A.item_count,
				CASE WHEN B.id IS NOT NULL THEN B.print_count ELSE C.item_count END AS print_count
			FROM
				(
					SELECT
						order_seq, item_id, SUM(item_count) AS item_count
					FROM
						delivery_info_detail
					WHERE
						order_seq = @order_seq
					GROUP BY
						order_seq, item_id
				) A
				LEFT OUTER JOIN custom_order_plist B ON A.order_seq = B.order_seq AND A.item_id = B.id
				LEFT OUTER JOIN custom_order_item C ON A.order_seq = C.order_seq AND A.item_id = C.id
		) A
		WHERE
			A.item_count <> A.print_count
	)
	BEGIN
		SET @rslt = 0
		SET @rsltMsg = '주문상품의 수량과 배송상품의 수량 불일치'
		goto RETURN_RESULT
	END	
	
	IF @pay_type <> '4' --사고건이 아닌경우만
	BEGIN
		-- custom_order 의 order_count 와 custom_order_item 수량체크
		IF Exists ( 
			SELECT * 
			FROM 
				custom_order_item A
				INNER JOIN custom_order B ON A.order_seq = B.order_seq
			WHERE 
				A.order_seq = @order_seq AND
				ISNULL(B.up_order_seq, 0) = 0 AND
				A.card_seq = B.card_seq AND 
				ISNULL(A.item_count, 0) <> ISNULL(B.order_count, 0)
		) 
		BEGIN	
			SET @rslt = 0
			SET @rsltMsg = '주문수량과 주문상품 카드 수량 불일치'
			goto RETURN_RESULT
		END

		-- 봉투와 스티커 수량 검증
		IF Exists ( 
			SELECT * FROM
			(
				SELECT
					A.order_seq,
					SUM(CASE WHEN B.item_type = 'E' THEN ISNULL(B.item_count, 0) ELSE 0 END) AS EnvCnt,
					SUM(CASE WHEN B.item_type = 'S' THEN ISNULL(B.item_count, 0) ELSE 0 END) AS StiCnt
				FROM
					custom_order A
					INNER JOIN custom_order_item B ON A.order_seq = B.order_seq
				WHERE
					A.order_seq = @order_seq AND
					A.pay_Type <> '4'
				GROUP BY
					A.order_seq
			) A
			WHERE
				A.EnvCnt > 0 AND A.StiCnt > 0 AND A.EnvCnt > A.StiCnt
		)
		BEGIN
			SET @rslt = 0
			SET @rsltMsg = '스티커 수량이 봉투 수량보다 작음'
			goto RETURN_RESULT
		END

		-- custom_order_plist 의 카드, 약도카드, 내지는 수량이 일치해야 합니다.
		IF Exists ( 
			SELECT * FROM
			(
				SELECT
					A.order_seq,
					SUM(CASE WHEN A.print_type = 'C' AND isFPrint = '0' THEN ISNULL(print_count, 0) ELSE 0 END) AS typeC,
					SUM(CASE WHEN A.print_type = 'C' AND isFPrint = '1' THEN ISNULL(print_count, 0) ELSE 0 END) AS typeCF,
					SUM(CASE WHEN A.print_type = 'P' AND isFPrint = '0' THEN CASE WHEN A.card_seq = 37352 THEN ISNULL(print_count, 0) - 50 ELSE ISNULL(print_count, 0) END ELSE 0 END) AS typeP,
					SUM(CASE WHEN A.print_type = 'P' AND isFPrint = '1' THEN ISNULL(print_count, 0) ELSE 0 END) AS typePF,
					SUM(CASE WHEN A.print_type = 'I' AND isFPrint = '0' THEN ISNULL(print_count, 0) ELSE 0 END) AS typeI,
					SUM(CASE WHEN A.print_type = 'I' AND isFPrint = '1' THEN ISNULL(print_count, 0) ELSE 0 END) AS typeIF
				FROM
					custom_order_plist A
					INNER JOIN custom_order B ON A.order_seq = B.order_seq
				WHERE
					A.order_seq = @order_seq AND
					A.print_type IN ('C', 'P', 'I') AND
					B.status_seq > 8 AND
					B.pay_type <> '4'
				GROUP BY
					A.order_seq
			) A
			WHERE
				(A.typeC > 0 AND A.typeCF > 0 AND A.typeC <> A.typeCF) OR
				(A.typeC > 0 AND A.typeP > 0 AND A.typeC <> A.typeP) OR
				(A.typeC > 0 AND A.typePF > 0 AND A.typeC <> A.typePF) OR
				(A.typeC > 0 AND A.typeI > 0 AND A.typeC <> A.typeI) OR
				(A.typeC > 0 AND A.typeIF > 0 AND A.typeC <> A.typeIF) OR

				(A.typeCF > 0 AND A.typeP > 0 AND A.typeCF <> A.typeP) OR
				(A.typeCF > 0 AND A.typePF > 0 AND A.typeCF <> A.typePF) OR
				(A.typeCF > 0 AND A.typeI > 0 AND A.typeCF <> A.typeI) OR
				(A.typeCF > 0 AND A.typeIF > 0 AND A.typeCF <> A.typeIF) OR

				(A.typeP > 0 AND A.typePF > 0 AND A.typeP <> A.typePF) OR
				(A.typeP > 0 AND A.typeI > 0 AND A.typeP <> A.typeI) OR
				(A.typeP > 0 AND A.typeIF > 0 AND A.typeP <> A.typeIF) OR

				(A.typePF > 0 AND A.typeI > 0 AND A.typePF <> A.typeI) OR
				(A.typePF > 0 AND A.typeIF > 0 AND A.typePF <> A.typeIF) OR

				(A.typeI > 0 AND A.typeIF > 0 AND A.typeI <> A.typeIF)
		)
		BEGIN
			SET @rslt = 0

			IF Exists(SELECT * FROM custom_order_plist WHERE order_seq = @order_seq AND card_seq = 37352)
			BEGIN
				SET @rsltMsg = '카드, 약도카드, 내지 수량 불일치 (약도카드 +50 주의)'
			END
			ELSE
			BEGIN
				SET @rsltMsg = '카드, 약도카드, 내지 수량 불일치'
			END
			
			goto RETURN_RESULT
		END	
	END

	IF @check_copy = 1		-- 지시서 검증 하나요?
	BEGIN
		-- 지시서 검증 : 상품 누락
		IF Exists (
			SELECT
				*
			FROM
				custom_order_item A
				LEFT OUTER JOIN S2_CardView C ON A.card_seq = C.Card_Seq
				LEFT OUTER JOIN CUSTOM_ORDER_COPY_DETAIL B 
					ON A.order_seq = B.order_seq AND 
					(CASE WHEN A.item_type = 'B' THEN 'S' ELSE A.item_type END = B.item_type OR (A.item_type = 'I' AND B.item_type = 'C') OR (A.item_type = 'A' AND B.item_type = 'C')) AND 
					(B.item_code Like C.erp_code + '%' OR B.item_code Like '%/' + C.erp_code + '%')
			WHERE
				A.order_seq = @order_seq AND
				A.item_count > 0 AND
				B.id IS NULL
		)
		BEGIN
			IF Exists(SELECT * FROM CUSTOM_ORDER_COPY_DETAIL WHERE order_seq = @order_seq AND item_type = '')
			BEGIN
				SET @rslt = 0
				SET @rsltMsg = '지시서 상품 타입 누락 (개발팀 확인 필요)'
			END
			ELSE
			BEGIN
				SET @rslt = 0
				SET @rsltMsg = '지시서 상품 누락'
			END
			goto RETURN_RESULT
		END

		-- 지시서 검증 : 배송지별 상품 일치 여부
		IF Exists (
			SELECT * FROM
				DELIVERY_INFO_DETAIL A
				INNER JOIN DELIVERY_INFO C ON A.delivery_id = C.ID
				INNER JOIN 
				(
					SELECT			
						A.order_seq,
						A.item_type,
						A.card_seq,
						CASE WHEN B.id IS NOT NULL THEN B.id ELSE A.id END AS id
					FROM
						custom_order_item A
						LEFT OUTER JOIN custom_order_plist B ON A.order_seq = B.order_seq AND A.card_seq = B.card_seq AND  B.print_count <> 0 AND B.isFPrint <> '1'
					WHERE
						A.order_seq = @order_seq AND
						A.item_count <> 0
				) B ON A.order_seq = B.order_seq AND A.item_id = B.id
				INNER JOIN S2_CardView E ON B.card_seq = E.Card_Seq
				LEFT OUTER JOIN custom_order_copy_detail D 
					ON A.order_seq = D.order_seq AND C.DELIVERY_SEQ = D.delivery_seq AND 
						(A.item_title = D.item_title OR A.item_title = REPLACE(REPLACE(D.item_title, '카드내지인쇄', '내지인쇄'), '카드기본인쇄', '기본인쇄') OR REPLACE(A.item_title, '마스킹 테이프', '마스킹테이프') = REPLACE(REPLACE(REPLACE(D.item_title, '어린이식권(신랑)', '신랑어린이식권'), '어린이식권(신부)', '신부어린이식권'), '기타', '사은품') OR D.item_code Like A.item_title + '%') AND 
						(CASE WHEN B.item_type = 'B' THEN 'S' ELSE B.item_type END = D.item_type OR (B.item_type = 'I' AND D.item_type = 'C')) AND
						(D.item_code Like E.erp_code + '%' OR D.item_code Like '%/' + E.erp_code + '%')
			WHERE
				A.order_seq = @order_seq AND
				A.item_count <> CASE WHEN D.item_type = 'F' THEN CAST((SELECT TOP 1 VALUE  FROM dbo.FN_SPLIT2(D.item_code, '_') ORDER BY NO DESC) AS INT) * ISNULL(D.item_count, 0) ELSE ISNULL(D.item_count, 0) END
		)
		BEGIN
			SET @rslt = 0
			SET @rsltMsg = '지시서 배송상품 누락 또는 수량 불일치'
			goto RETURN_RESULT
		END
	END

	-- 오류는 아니지만 주의 사항 검증
	-- 카드, 내지, 봉투 수량이 일치하지 않은 경우
	IF Exists (
		SELECT * FROM
		(
			SELECT
				SUM(CASE WHEN item_type = 'C' THEN item_count ELSE 0 END) AS CntC,
				SUM(CASE WHEN item_type = 'E' THEN item_count ELSE 0 END) AS CntE,
				SUM(CASE WHEN item_type = 'I' THEN item_count ELSE 0 END) AS CntI
			FROM
				custom_order_item
			WHERE
				order_seq = @order_seq AND
				item_type IN ('C', 'E', 'I') AND
				item_count > 0
		) A
		WHERE
			(A.CntC > 0 AND A.CntE > 0 AND A.CntC <> A.CntE) OR
			(A.CntC > 0 AND A.CntI > 0 AND A.CntC <> A.CntI) OR
			(A.CntE > 0 AND A.CntI > 0 AND A.CntE <> A.CntI)
	)
	BEGIN
		SET @rslt = 0
		SET @rsltMsg = '카드, 봉투, 내지 수량이 동일하지 않음'
		goto RETURN_RESULT
	END

	-- plist에서 내지와 겉면의 수량이 다른 경우, 내지와 겉면이 다 있는 경우 체크
	IF Exists (
		SELECT * FROM
		(
			SELECT
				card_seq,
				print_type,
				SUM(CASE WHEN isFPrint = '1' Then 1 ELSE 0 END) As isFPrint,
				SUM(CASE WHEN isFPrint = '0' Then 1 ELSE 0 END) As isPrint,
				SUM(CASE WHEN isFPrint = '1' Then print_count ELSE 0 END) As FPrintCnt,
				SUM(CASE WHEN isFPrint = '0' Then print_count ELSE 0 END) As PrintCnt
			FROM
				custom_order_plist
			WHERE
				order_seq = @order_seq
			GROUP BY
				card_seq, print_type
		) A
		WHERE
			A.isFPrint > 0 AND A.isPrint > 0 AND A.FPrintCnt <> A.PrintCnt
	)
	BEGIN
		SET @rslt = 0
		SET @rsltMsg = '인쇄판 내지 수량과 겉면 수량이 일치하지 않음'
		goto RETURN_RESULT
	END

RETURN_RESULT:
	-- 결과 반환
	INSERT INTO @TEMP (order_seq, rslt, rsltMsg) VALUES (@order_seq, @rslt, @rsltMsg)

	RETURN
END

GO