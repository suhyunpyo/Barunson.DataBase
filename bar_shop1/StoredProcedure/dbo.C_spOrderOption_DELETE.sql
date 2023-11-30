IF OBJECT_ID (N'dbo.C_spOrderOption_DELETE', N'P') IS NOT NULL DROP PROCEDURE dbo.C_spOrderOption_DELETE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[C_spOrderOption_DELETE]
   @OrderSeq INT
	, @UpdateGubun NVARCHAR(10)
	, @ID INT	

	, @OK_CHECK nchar(1) = null  OUTPUT
	, @RETURN_MSG nvarchar(50) = null  OUTPUT
as    


SET NOCOUNT ON


--EXEC [C_spOrderOption_DELETE] 2912539, 'SERVICE', 2912539


SET @OK_CHECK = 'N'
SET @RETURN_MSG = '삭제실패_C_spOrderOption_DELETE'
	
--EXEC [C_spOrderOption_SAVE] 2912539 , 'SERVICE' , 2912539 , 'sasik_price' , 200 , 0 , 0
--IF EXISTS ( SELECT JumunNo FROM  C_GlobalJumunHeader WHERE GlobalSite = @GlobalSite AND JumunNo = @JumunNo )
--BEGIN 
			
--	SELECT @OkCheck = 'N', @ErrorMsg = '['+LTRIM(RTRIM(@JumunNo))+'] 해당 주문건은 ERP에 이미 등록되어 있습니다.'
--	GOTO ERROR_EXIT_01

--END



--########################################################################################################################################
--저장쿼리 BEGIN 


--트랜잭션 호출
BEGIN TRANSACTION

BEGIN TRY

	DECLARE @HistoryInfo VARCHAR(100)
	DECLARE @ItemType VARCHAR(1)

	SELECT @HistoryInfo = B.Card_Code --+'('+ LTRIM(RTRIM(ISNULL(B.Card_Name, '')))+')'
	FROM custom_order_item A
	LEFT JOIN S2_Card B ON A.card_seq = B.Card_Seq
	WHERE A.order_seq = @OrderSeq AND A.id = @ID

	
	DELETE custom_order_item WHERE order_seq = @OrderSeq AND id = @ID

	
	--부가서비스 체크 및 DDL 저장
	--ItemType별 금액합계.
	UPDATE Custom_Order
	SET guestbook_price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type = 'L' )  --방명록(L)
		, moneyenv_price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type = 'K' )  --돈봉투(K)
		, sealing_sticker_price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type = 'T' )	--실링스티커(T)
		, flower_price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type = 'W' )		--프리저브드 플라워(W)
		, MemoryBook_Price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type = 'X' ) --메모리북(X)
		, AddPrice = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type = 'Z' )		--기타(Z)
		, ribbon_price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type = 'R' )
		, Mask_Price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type = 'J' )		--마스크(J)
		, MaskingTape_price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type = '5' )		--마스킹테이프(5)
		, paperCover_price = ( SELECT ISNULL(SUM(ISNULL(item_sale_price, 0)*ISNULL(item_count, 0)), 0) FROM custom_order_item WHERE order_seq = @OrderSeq AND item_type = 'U' )		--페이퍼 커버(U)
	WHERE Order_seq = @OrderSeq

	SELECT @OK_CHECK = 'Y', @RETURN_MSG = @HistoryInfo+' 삭제 되었습니다. 총 금액을 확인하세요.'
	
END TRY
BEGIN CATCH

	IF XACT_STATE() <> 0 
		ROLLBACK TRANSACTION

	
	SET @OK_CHECK = 'N' 
	SET @RETURN_MSG = '[C_spOrderOption_DELETE] 에러발생' --ERROR_MESSAGE() 
	
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
