IF OBJECT_ID (N'dbo.UP_INSERT_CUSTOM_ORDER_GROUP_STEP1_MOBILE', N'P') IS NOT NULL DROP PROCEDURE dbo.UP_INSERT_CUSTOM_ORDER_GROUP_STEP1_MOBILE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*----------------------------------------------------------
작성일		: 2014년 12월 14일
작성자		: 김덕중
기능			: custom_order_group Insert
설명			: custom_order_group Insert
변수 			:
@B_MASTEREXCODE			등록자
--------------------------------------------------------------
수정일		수정자		요청자		내용
----------------------------------------------------------*/
CREATE	PROC [dbo].[UP_INSERT_CUSTOM_ORDER_GROUP_STEP1_MOBILE]
	@UID				AS VARCHAR(16),
	@COMPANY_SEQ					AS INT,
	@NAME							AS VARCHAR(40),
	@DELIVERY_PRICE			AS INT,
	@ORDER_PRICE			AS INT,
	@TOTAL_PRICE			AS INT
AS
SET NOCOUNT ON
	BEGIN

		DECLARE @ORDER_G_SEQ	AS INT
		BEGIN TRAN	
		

		--DELETE FROM dbo.DELIVERY_INFO_GROUP WHERE ORDER_G_SEQ = @ORDER_SEQ
		INSERT INTO Custom_order_Group (
			company_seq,
			member_id,
			order_name,
			order_price,
			order_total_price,
			delivery_price
		) VALUES (
		@COMPANY_SEQ,
		@UID,
		@NAME,
		@ORDER_PRICE,
		@TOTAL_PRICE,
		@DELIVERY_PRICE
		)
		set @ORDER_G_SEQ = SCOPE_IDENTITY() 
		--set @result_code = @ORDER_G_SEQ
		
		
		IF ( @@ERROR <> 0 )
			BEGIN
				ROLLBACK TRAN
			END
		ELSE
			BEGIN
				COMMIT TRAN
			END

			select @ORDER_G_SEQ
	END
GO
