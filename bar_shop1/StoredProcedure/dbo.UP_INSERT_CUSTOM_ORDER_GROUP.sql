IF OBJECT_ID (N'dbo.UP_INSERT_CUSTOM_ORDER_GROUP', N'P') IS NOT NULL DROP PROCEDURE dbo.UP_INSERT_CUSTOM_ORDER_GROUP
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*----------------------------------------------------------
작성일		: 2014년 12월 14일
작성자		: 김덕중
기능			: 배송정보입력
설명			: 배송정보저장
변수 			:
@B_MASTEREXCODE			등록자
--------------------------------------------------------------
수정일		수정자		요청자		내용
----------------------------------------------------------*/
CREATE PROC [dbo].[UP_INSERT_CUSTOM_ORDER_GROUP]
	@UID					AS VARCHAR(16),
	@COMPANY_SEQ			AS INT,
	@nt_code				AS CHAR(3),
	@NAME					AS VARCHAR(40),
	@order_email			AS VARCHAR(50),
	@EMAIL					AS VARCHAR(50),
	@PHONE					AS VARCHAR(20),
	@HPHONE					AS VARCHAR(20),
	@ZIP					AS VARCHAR(6),
	@ADDR					AS VARCHAR(500),
	@ADDR_DETAIL			AS VARCHAR(100),
	@DELIVERY_PRICE			AS INT,
	@DELIVERY_METHOD		AS INT,
	@DELIVERY_INFO			AS VARCHAR(500),
	@DELIVERY_MEMO			AS VARCHAR(50),
	@ORDER_PRICE			AS INT,
	@TOTAL_PRICE			AS INT,
	@DELIVERY_NAME			AS VARCHAR(20),
	@PGTID					AS varchar(50),
	@order_g_seq			AS int
AS
SET NOCOUNT ON
	BEGIN

		BEGIN TRAN	
		

		UPDATE Custom_order_Group SET order_email=@order_email, order_phone=@PHONE, order_hphone=@HPHONE, delivery_name=@DELIVERY_NAME, pg_tid=@PGTID
		where order_g_seq=@order_g_seq
		
		 DELETE FROM dbo.DELIVERY_INFO_GROUP WHERE ORDER_G_SEQ = @order_g_seq

		IF @@ERROR <> 0 GOTO GO_ERROR

		INSERT INTO dbo.DELIVERY_INFO_GROUP
				   (ORDER_G_SEQ
				   ,DELIVERY_SEQ
				   ,nt_code
				   ,NAME
				   ,EMAIL
				   ,PHONE
				   ,HPHONE
				   ,ZIP
				   ,ADDR
				   ,ADDR_DETAIL
				   ,DELIVERY_PRICE
				   ,DELIVERY_METHOD
				   ,DELIVERY_INFO
				   ,DELIVERY_MEMO)

			 VALUES
				   (@order_g_seq,
					1,
					@nt_code,
					@NAME,
					@order_email,
					@PHONE,
					@HPHONE,
					@ZIP,
					@ADDR,
					@ADDR_DETAIL,
					@DELIVERY_PRICE,
					@DELIVERY_METHOD,
					@DELIVERY_INFO	,
					@DELIVERY_MEMO)
		IF (@@ERROR <> 0) GOTO GO_ERROR

		IF ( @@ERROR <> 0 )
			BEGIN
				GO_ERROR:
				ROLLBACK TRAN
			END
		ELSE
			BEGIN
				COMMIT TRAN
			END


	END
GO
