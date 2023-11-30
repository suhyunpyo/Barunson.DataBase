IF OBJECT_ID (N'dbo.PROC_DELCODEADD_NEW', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_DELCODEADD_NEW
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PROC_DELCODEADD_NEW]
@ORDER_SEQ INT,
@DEL_ID INT,
@ADDNUM INT
--,@RSLT TINYINT OUTPUT
AS
BEGIN
	DECLARE @I INT,@DEL_CODE VARCHAR(12),@ID BIGINT

    DECLARE @DELIVERY_COMPANY_SHORT_NAME AS VARCHAR(10)

	DECLARE @RETURNVALUE INT	--0:성공

    SET @DELIVERY_COMPANY_SHORT_NAME = 'LT'

	SET @I = 0
	WHILE @I < @ADDNUM
	BEGIN
		-----------------------------------------------------------------------------------------------
		--SELECT TOP 1 @ID = CODESEQ,@DEL_CODE = CODE FROM CJ_DELCODE WHERE ISUSE='0' ORDER BY CODESEQ


		--UPDATE	CJ_DELCODE 
		--SET		ISUSE='1' 
		--	,	@ID = CODESEQ
		--	,	@DEL_CODE = CODE
		--WHERE	1 = 1
		--AND		CODESEQ IN (SELECT TOP 1 CODESEQ FROM CJ_DELCODE WHERE ISUSE='0' ORDER BY CODESEQ)
		
		--INSERT INTO DELIVERY_INFO_DELCODE (ORDER_SEQ,DELIVERY_ID,DELIVERY_CODE_NUM,DELIVERY_COM) 
		--VALUES (@ORDER_SEQ,@DEL_ID,@DEL_CODE, @DELIVERY_COMPANY_SHORT_NAME)
		----UPDATE CJ_DELCODE SET ISUSE='1' WHERE CODESEQ = @ID
		

			EXEC [DBO].[SP_CJ_DELEVERY_NEW] 'DELIVERY_INFO_DELCODE|', @ORDER_SEQ, @DEL_ID, @DELIVERY_COMPANY_SHORT_NAME, @DEL_CODE OUTPUT

		SET @I = @I + 1
	END			-- END OF WHILE

END

GO
