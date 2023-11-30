IF OBJECT_ID (N'dbo.proc_DelCodeAddPacking', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_DelCodeAddPacking
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_DelCodeAddPacking]
 @ORDER_SEQ INT,
 @DEL_SEQ INT,
 @DEL_CODE VARCHAR(15) OUTPUT
AS
BEGIN
	DECLARE @I INT,@DEL_ID INT,@ID BIGINT,@ISPACKING CHAR(1)

    DECLARE @DELIVERY_COMPANY_SHORT_NAME AS VARCHAR(10)
    --SET @DELIVERY_COMPANY_SHORT_NAME = 'HJ'
	--SELECT @DELIVERY_COMPANY_SHORT_NAME = CODE FROM DELIVERY_CODE WHERE USE_YN = 'Y' 
	
    /* 2015-08-03 이후 CJ택배로 변경 */
    IF GETDATE() >= '2015-08-03 00:00:00'
        BEGIN
            
            SET @DELIVERY_COMPANY_SHORT_NAME = 'CJ'

        END
    ELSE
        BEGIN
            
            SET @DELIVERY_COMPANY_SHORT_NAME = 'HJ'

        END

	-----------------------------------------------------------------------------------------------
	SELECT @DEL_ID = ID, @ISPACKING = CASE WHEN PACKING_DATE IS NULL THEN '0' ELSE '1' END
	FROM DELIVERY_INFO
	WHERE ORDER_SEQ=@ORDER_SEQ AND 
		  DELIVERY_SEQ=@DEL_SEQ
	
	IF @ISPACKING = '1'
	BEGIN	
		--SELECT TOP 1 @ID = CODESEQ,@DEL_CODE = CODE FROM CJ_DELCODE WHERE ISUSE='0' ORDER BY CODESEQ
		--INSERT INTO DELIVERY_INFO_DELCODE(ORDER_SEQ,DELIVERY_ID,DELIVERY_CODE_NUM,DELIVERY_COM) VALUES(@ORDER_SEQ,@DEL_ID,@DEL_CODE, @DELIVERY_COMPANY_SHORT_NAME)
		--UPDATE CJ_DELCODE SET ISUSE='1' WHERE CODESEQ = @ID
		
			EXEC [DBO].[SP_CJ_DELEVERY_20221212] 'DELIVERY_INFO_DELCODE|', @ORDER_SEQ, @DEL_ID, @DELIVERY_COMPANY_SHORT_NAME, @DEL_CODE OUTPUT
		
	END
	ELSE
	BEGIN
		SET @DEL_CODE = ''
		SELECT @DEL_CODE
	END

END
GO