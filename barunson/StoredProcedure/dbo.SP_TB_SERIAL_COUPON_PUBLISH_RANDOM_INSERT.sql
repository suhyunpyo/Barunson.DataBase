IF OBJECT_ID (N'dbo.SP_TB_SERIAL_COUPON_PUBLISH_RANDOM_INSERT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_TB_SERIAL_COUPON_PUBLISH_RANDOM_INSERT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_TB_SERIAL_COUPON_PUBLISH_RANDOM_INSERT]
/***************************************************************
작성자	:	송태정
작성일	:	2022-01-11
DESCRIPTION	: 시리얼 난수 쿠폰 생성
SPECIAL LOGIC	: SP_TB_SERIAL_COUPON_PUBLISH_RANDOM_INSERT 7 , '127,0.0.01', 'mwdka'
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
@Coupon_ID INT,
@User_IP VARCHAR(50),
@Admin_ID VARCHAR(50),
@Expiration_Date VARCHAR(10) = NULL
AS 

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 
BEGIN
DECLARE @NUM INT
DECLARE @SerialNumber VARCHAR(11)
SET @NUM = 0
	BEGIN
		WHILE @NUM < 200
		BEGIN
			SELECT @SerialNumber = dbo.ufn_SerialNumber()

			IF NOT EXISTS(SELECT Coupon_Publish_ID FROM TB_Serial_Coupon_Publish WHERE Coupon_Number = @SerialNumber)
			BEGIN
				INSERT INTO TB_Serial_Coupon_Publish
				(
					Coupon_ID, Coupon_Number, Regist_User_ID, Regist_DateTime, Regist_IP, Update_User_ID, Update_DateTime, Update_IP, Expiration_Date
				) 
				VALUES
				(
					@Coupon_ID,@SerialNumber, @Admin_ID, GETDATE(), @User_IP, @Admin_ID, GETDATE(), @User_IP, @Expiration_Date
				)
				SET @NUM = @NUM + 1
			END
		END
	END
END 
GO
