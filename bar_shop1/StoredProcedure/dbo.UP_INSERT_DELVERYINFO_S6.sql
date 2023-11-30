IF OBJECT_ID (N'dbo.UP_INSERT_DELVERYINFO_S6', N'P') IS NOT NULL DROP PROCEDURE dbo.UP_INSERT_DELVERYINFO_S6
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*----------------------------------------------------------
작성일		: 2014년 11월 27일
작성자		: 이중정
기능			: 배송정보입력
설명			: 배송정보저장
변수 			:
@B_MASTEREXCODE			등록자
--------------------------------------------------------------
수정일		수정자		요청자		내용
----------------------------------------------------------*/
CREATE	PROC [dbo].[UP_INSERT_DELVERYINFO_S6]
	@ORDER_SEQ				AS INT,
	@DELIVERY_SEQ				AS INT,
	@nt_code						AS CHAR(3),
	@NAME							AS VARCHAR(40),
	@EMAIL							AS VARCHAR(30),
	@PHONE						AS VARCHAR(20),
	@HPHONE						AS VARCHAR(20),
	@ZIP								AS VARCHAR(6),
	@ADDR							AS VARCHAR(500),
	@ADDR_DETAIL				AS VARCHAR(100),
	@DELIVERY_PRICE			AS INT,
	@DELIVERY_METHOD		AS INT,
	@DELIVERY_INFO				AS VARCHAR(500),
	@DELIVERY_MEMO			AS VARCHAR(50)
AS
SET NOCOUNT ON
	BEGIN
		BEGIN TRAN	
	
		 DELETE FROM dbo.DELIVERY_INFO_GROUP WHERE ORDER_G_SEQ = @ORDER_SEQ
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
				   (@ORDER_SEQ,
					@DELIVERY_SEQ,
					@nt_code,
					@NAME,
					@EMAIL,
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
