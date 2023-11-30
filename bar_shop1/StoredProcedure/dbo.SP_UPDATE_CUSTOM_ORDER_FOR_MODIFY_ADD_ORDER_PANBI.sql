IF OBJECT_ID (N'dbo.SP_UPDATE_CUSTOM_ORDER_FOR_MODIFY_ADD_ORDER_PANBI', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_UPDATE_CUSTOM_ORDER_FOR_MODIFY_ADD_ORDER_PANBI
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_UPDATE_CUSTOM_ORDER_FOR_MODIFY_ADD_ORDER_PANBI]
    @P_ORDER_SEQ    AS INT
,   @P_PID          AS INT
,   @P_PANBI_PRICE  AS INT
AS
BEGIN
    
    SET NOCOUNT ON;

    IF EXISTS(SELECT * FROM CUSTOM_ORDER_PLIST WHERE ID = @P_PID AND ORDER_SEQ = @P_ORDER_SEQ AND ISNOTPRINT = '1')
        BEGIN
            
            UPDATE  CUSTOM_ORDER
            SET     OPTION_PRICE = OPTION_PRICE + @P_PANBI_PRICE
                ,   LAST_TOTAL_PRICE = LAST_TOTAL_PRICE + @P_PANBI_PRICE
            WHERE   ORDER_SEQ = @P_ORDER_SEQ
            AND     ORDER_ADD_TYPE = '1'
            AND     ORDER_ADD_FLAG = '1'

        END

END
GO
