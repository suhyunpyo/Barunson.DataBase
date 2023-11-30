IF OBJECT_ID (N'dbo.SP_EXEC_AVAILABLE_PARTNER_ID_CHECK', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_AVAILABLE_PARTNER_ID_CHECK
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC SP_EXEC_AVAILABLE_PARTNER_ID_CHECK 's'

*/
CREATE PROCEDURE [dbo].[SP_EXEC_AVAILABLE_PARTNER_ID_CHECK]
    
    @PARTNER_ID AS VARCHAR(50)

AS
BEGIN
    
    DECLARE @BHANDS_PARTNER_YORN AS VARCHAR(1)
    DECLARE @PREMIER_PARTNER_YORN AS VARCHAR(1)

    SET NOCOUNT ON;

    SET @BHANDS_PARTNER_YORN =  ISNULL  (
                                            (
                                                SELECT  TOP 1 'Y'
                                                FROM    COMPANY
                                                WHERE   1 = 1
                                                AND     SALES_GUBUN IN ('B' , 'C')
                                                AND     STATUS = 'S2'
                                                AND     LOGIN_ID = @PARTNER_ID
                                            ), 'N'
                                        )

    SET @PREMIER_PARTNER_YORN = ISNULL  (
                                            (
                                                SELECT  TOP 1 'Y'
                                                FROM    COMPANY
                                                WHERE   1 = 1
                                                AND     SALES_GUBUN = 'H'
                                                AND     STATUS = 'S2'
                                                AND     LOGIN_ID = @PARTNER_ID
                                            ), 'N'
                                        )

    SELECT  @BHANDS_PARTNER_YORN    AS BHANDS_PARTNER_YORN
        ,   @PREMIER_PARTNER_YORN   AS PREMIER_PARTNER_YORN

END

GO
