IF OBJECT_ID (N'dbo.C_spOrderOption_SAVE', N'P') IS NOT NULL DROP PROCEDURE dbo.C_spOrderOption_SAVE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[C_spOrderOption_SAVE]
   @OrderSeq INT
	, @UpdateGubun NVARCHAR(10)
	, @ID INT	
	, @CardCode NVARCHAR(50)
	, @SaleAmnt INT
	, @ItemQty INT
	, @ItemPrice INT
	, @isinpaper SMALLINT
	, @ishandmade SMALLINT
	, @isRibon SMALLINT
	, @isLiningJaebon SMALLINT
	, @isEnvInsert SMALLINT
	, @isColorInpaper SMALLINT
	, @isPerfume SMALLINT
	, @isColorPrint SMALLINT
	, @isEmbo SMALLINT

	, @OK_CHECK nchar(1) = null  OUTPUT
	, @RETURN_MSG nvarchar(50) = null  OUTPUT
as    


SET NOCOUNT ON


--EXEC [C_spOrderOption_SAVE] 2912539, 'SERVICE', 2912539, 'perfume_price', 500, 0, 0, 0, 0, 0, 0, 0, 0, 1, 3, 3


SET @OK_CHECK = 'N'
SET @RETURN_MSG = '저장실패'


IF ( @UpdateGubun <> 'SERVICE' )
BEGIN


	--신규추가시 체크
	IF ( ISNULL(@ID, 0) = 0 )
	BEGIN 
		--중복등록 체크
		IF EXISTS ( 
						SELECT A.card_seq, B.Card_Code
						FROM custom_order_item A
						JOIN S2_Card B ON A.card_seq = B.Card_Seq 
						WHERE order_seq = @OrderSeq AND B.Card_Code = LTRIM(RTRIM(@CardCode))
		)
		BEGIN 			
				SELECT @OK_CHECK = 'N', @RETURN_MSG = '['+LTRIM(RTRIM(@CardCode))+'] 이미 등록된 코드를 중복으로 등록 할 수 없습니다.'
				GOTO ERROR_EXIT_01
		END

		
		--추가 할 경우 카드, 내지, 봉투, 약도카드, 식권 코드는 추가못하도록...
		IF EXISTS ( 
						SELECT A.card_seq, A.card_code
							, B.code, B.code_value
							, C.code, C.code_value 
						FROM S2_Card A
						JOIN manage_code B ON B.code = A.Card_Div	AND B.code_type = 'card_div'
						JOIN manage_code C ON C.code = B.etc1		AND C.code_type = 'item_type'
						WHERE A.Card_code = LTRIM(RTRIM(@CardCode))  
							AND C.code IN ( 'C', 'I', 'E', 'P', 'F', 'S' )
		)
		BEGIN 			
				SELECT @OK_CHECK = 'N', @RETURN_MSG = '['+LTRIM(RTRIM(@CardCode))+'] 카드, 내지, 봉투, 약도카드, 식권 코드는 등록 할 수 없습니다.'
				GOTO ERROR_EXIT_01
		END

		
		--추가할경우 코드존재여부 확인.
		IF NOT EXISTS ( SELECT TOP 1 A.Card_seq FROM S2_Card A  WHERE A.Card_Code = @CardCode )
		BEGIN 			
				SELECT @OK_CHECK = 'N', @RETURN_MSG = '['+LTRIM(RTRIM(@CardCode))+'] 해당 코드는 존재하지 않는 코드입니다.'
				GOTO ERROR_EXIT_01
		END

		
		--같은 코드가 여러개 등록되어 있을경우
		IF EXISTS ( 
				SELECT Card_Code, Count(*)
				FROM ( SELECT DISTINCT Card_Code, Card_div AS Cnt FROM s2_card where card_code = @CardCode and DISPLAY_YORN = 'Y'  ) A
				GROUP BY Card_Code
				HAVING COUNT(*) > 1 
		)
		BEGIN 
				SELECT @OK_CHECK = 'N', @RETURN_MSG = '시스템에 같은 코드가 여러개 등록되어 있습니다. 개발팀에 문의하세요.'
				GOTO ERROR_EXIT_01
		END


	END 
	   	  
		  		   		   		  
	--수량 체크
	IF ( ISNULL(@ItemQty, 0) <= 0 )
	BEGIN 
		SELECT @OK_CHECK = 'N', @RETURN_MSG = '수량은 0보다 커야 합니다.'
		GOTO ERROR_EXIT_01
	END

END





--########################################################################################################################################
--저장쿼리 BEGIN 


--트랜잭션 호출
BEGIN TRANSACTION

BEGIN TRY

	DECLARE @UpdateSql VARCHAR(500) 
	DECLARE @ItemGroup VARCHAR(50)

	IF ( @UpdateGubun = 'SERVICE' )
	BEGIN 
		
		
		SELECT @ItemGroup = CASE @CardCode 
				WHEN 'jebon_price' THEN '카드제본비' 
				WHEN 'envinsert_price' THEN '봉투제본비' 
				WHEN 'LiningJaebon_price' THEN '라이닝제본비' 
				WHEN 'option_price' THEN '인쇄판비' 
				WHEN 'sasik_price' THEN '사식수수료' 
				WHEN 'print_price' THEN '칼라인쇄' 
				WHEN 'embo_price' THEN '엠보인쇄' 
				WHEN 'cont_price' THEN '칼라내지' 
				WHEN 'EnvSpecial_Price' THEN '스페셜봉투' 
				WHEN 'perfume_price' THEN '향기서비스' 
				WHEN 'laser_price' THEN '레이저컷비' 
				WHEN 'mask_01' THEN '마스크' 
				ELSE '기타' END 

			

		SELECT @UpdateSql = 'UPDATE custom_order SET '+ @CardCode + ' = ' + CAST (@SaleAmnt AS VARCHAR(10)) + ' WHERE order_seq = '+ CAST (@OrderSeq AS VARCHAR(10)) 	

		EXEC (@UpdateSql)	

		
		SELECT @OK_CHECK = 'Y', @RETURN_MSG = @ItemGroup+ ' 저장 되었습니다1.'
	END
	ELSE
	BEGIN 
		

		DECLARE @CardSeq INT
		DECLARE @ItemType VARCHAR(1)
		SET @CardSeq = NULL
		SET @ItemType = NULL
		SET @ItemGroup = NULL
		
		SELECT TOP 1 @CardSeq = A.Card_seq 
					, @ItemType = M.etc1
					, @ItemGroup = ISNULL(M.code_value, A.Card_Code)
		FROM S2_Card A 
		JOIN manage_code M ON M.code_type = 'card_div' AND A.Card_Div = M.code
		WHERE A.Card_Code = @CardCode AND A.DISPLAY_YORN = 'Y'
		ORDER bY A.Card_seq DESC


		IF( ISNULL(LTRIM(RTRIM(@ID)), 0) <> 0 )
		BEGIN	
			UPDATE custom_order_item
			SET item_count = @ItemQty
				, item_sale_price = @ItemPrice
			WHERE order_seq = @OrderSeq AND id = LTRIM(RTRIM(@ID))		
			
		END
		ELSE 
		BEGIN
			INSERT INTO custom_order_item ( order_seq, card_seq, item_type, item_count, item_sale_price)
			VALUES ( @OrderSeq, @CardSeq, @ItemType,  @ItemQty, @ItemPrice )
			
		END
		
		SELECT @OK_CHECK = 'Y', @RETURN_MSG = ISNULL(@ItemGroup, @CardCode)  +' 저장 되었습니다2.'

	END



	--부가서비스 체크 및 DDL 저장
	--ItemType별 금액합계.
	UPDATE Custom_Order
	SET isinpaper = @isinpaper
		, ishandmade = @ishandmade
		, isRibon = @isRibon
		, isLiningJaebon = @isLiningJaebon
		, isEnvInsert = @isEnvInsert
		, isColorInpaper = @isColorInpaper
		, isPerfume = @isPerfume
		, isColorPrint = @isColorPrint
		, isEmbo = @isEmbo

		--방명록(L)
		, guestbook_price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type = 'L' ) 
		--돈봉투(K)
		, moneyenv_price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type = 'K' )  
		--실링스티커(T)
		, sealing_sticker_price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type = 'T' ) 
		--프리저브드 플라워(W)
		, flower_price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type = 'W' )
		--메모리북(X)
		, MemoryBook_Price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type = 'X' )
		--리본(R)
		, ribbon_price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type = 'R' )
		--페이퍼커버(U)
		, paperCover_price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type = 'U' )
		--기타(Z)
		, AddPrice = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type IN ( 'Z' ) )
		--마스크(J)
		, Mask_Price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type IN ( 'J' ) )
		--마스킹테이프(J)
		,  MaskingTape_price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type IN ( '5' ) )

	WHERE Order_seq = @OrderSeq
	
	
END TRY
BEGIN CATCH

	IF XACT_STATE() <> 0 
		ROLLBACK TRANSACTION

	
	SET @OK_CHECK = 'N' 
	SET @RETURN_MSG = '[C_spOrderOption_SAVE] 에러발생' --ERROR_MESSAGE() 
	
END CATCH


	
IF ( @@TRANCOUNT > 0 AND ISNULL(@OK_CHECK, 'N') = 'Y' )
    COMMIT TRANSACTION
ELSE IF ( @@TRANCOUNT > 0 AND ISNULL(@OK_CHECK, 'N') = 'N' )
	ROLLBACK TRANSACTION


--체크SP 에러시
ERROR_EXIT_01:



--저장쿼리 END 
--########################################################################################################################################


--성공, 실패 출력
SELECT @OK_CHECK AS OK_CHECK , @RETURN_MSG AS RETURN_MSG

GO
