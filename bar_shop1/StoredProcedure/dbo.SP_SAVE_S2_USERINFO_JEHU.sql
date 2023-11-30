IF OBJECT_ID (N'dbo.SP_SAVE_S2_USERINFO_JEHU', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SAVE_S2_USERINFO_JEHU
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : SP_SAVE_S2_USERINFO_JEHU
-- Author        : 박혜림
-- Create date   : 2023-04-20
-- Description   : 회원 제휴 정보 저장
-- Update History:
-- Comment       :
****************************************************************************************************************/

/*
EXEC SP_SAVE_S2_USERINFO_JEHU 'gpflawkd2','enmad', 1, 'GRrc67UskADm'
*/

CREATE PROCEDURE [dbo].[SP_SAVE_S2_USERINFO_JEHU]
	  @USERID      VARCHAR(50)
	, @PARTNERCODE VARCHAR(100)
	, @CONSENT     BIT
	, @EXTENDDATA  NVARCHAR(MAX)

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

-----------------------------------------------------------------------------------------------------------------------
-- Declare Block
-----------------------------------------------------------------------------------------------------------------------
DECLARE @ApplyChk CHAR(1)

SET @ApplyChk = 'N'


-----------------------------------------------------------------------------------------------------------------------
-- Execute Block
-----------------------------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY		
		BEGIN TRAN

			IF NOT EXISTS(SELECT * FROM S2_UserInfo_Jehu WHERE UserId = @USERID AND PartnerCode = @PARTNERCODE)
			BEGIN

				INSERT INTO S2_UserInfo_Jehu (UserId, PartnerCode, Consent, RegDate, UpdateDate, ExtendData)
				VALUES (@USERID, @PARTNERCODE, @CONSENT, GETDATE(), GETDATE(), @EXTENDDATA)

			END
			ELSE	-- 이미 응모한 경우
			BEGIN
				SET @ApplyChk = 'Y'
			END

			----------------------------------------------------------------------------------
			-- 처리상태 Return
			----------------------------------------------------------------------------------
			SELECT @ApplyChk

		COMMIT TRAN

	END TRY

	BEGIN CATCH
		IF ( XACT_STATE() ) <> 0
		 BEGIN
		     ROLLBACK TRAN
        END
	END CATCH
				
END		

GO
