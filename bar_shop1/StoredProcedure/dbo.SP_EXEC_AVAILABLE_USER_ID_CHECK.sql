IF OBJECT_ID (N'dbo.SP_EXEC_AVAILABLE_USER_ID_CHECK', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_AVAILABLE_USER_ID_CHECK
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*



*/
CREATE PROCEDURE [dbo].[SP_EXEC_AVAILABLE_USER_ID_CHECK]
    
    @USER_ID AS VARCHAR(50)
,   @AUTHCODE AS VARCHAR(100) = ''

AS
BEGIN
    
    SET NOCOUNT ON;

    DECLARE @RESULT_CODE AS VARCHAR(4)

    SET @RESULT_CODE =  (
                            SELECT  ISNULL(MAX('9000'), '0000')
                            FROM    (

                                        SELECT  UID
                                        FROM    VW_USER_INFO
                                        WHERE   DUPINFO <> @AUTHCODE
                                                    
                                        UNION

                                        SELECT  UID
                                        FROM    S2_USERBYE

                                    ) A
                            WHERE   A.UID = @USER_ID
                            
                        )

    SELECT  @RESULT_CODE AS RESULT_CODE

END

GO
