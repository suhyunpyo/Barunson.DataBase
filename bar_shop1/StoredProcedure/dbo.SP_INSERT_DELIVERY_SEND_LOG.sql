IF OBJECT_ID (N'dbo.SP_INSERT_DELIVERY_SEND_LOG', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_DELIVERY_SEND_LOG
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

*/
CREATE PROCEDURE [dbo].[SP_INSERT_DELIVERY_SEND_LOG]
    @ORDER_SEQ          AS VARCHAR(20)
,   @ORDER_TABLE_NAME   AS VARCHAR(50)
,   @DELIVERY_CODE      AS VARCHAR(20)
,   @RESULT_CODE        AS VARCHAR(4)
,   @RESULT_MSG         AS NVARCHAR(500)
,   @ERROR_MSG          AS NVARCHAR(500)
,   @ERROR_DESC         AS NVARCHAR(500)

AS
BEGIN

    INSERT INTO DELIVERY_SEND_LOG 
    (
            ORDER_SEQ
        ,   ORDER_TABLE_NAME
        ,   DELIVERY_CODE
        ,   RESULT_CODE
        ,   RESULT_MSG
        ,   ERROR_MSG
        ,   ERROR_DESC
    )
    VALUES 
    (  
            @ORDER_SEQ        
        ,   @ORDER_TABLE_NAME 
        ,   @DELIVERY_CODE    
        ,   @RESULT_CODE      
        ,   @RESULT_MSG       
        ,   @ERROR_MSG        
        ,   @ERROR_DESC       
    )    

END
GO
