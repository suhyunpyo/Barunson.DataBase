IF OBJECT_ID (N'dbo.SP_EXEC_EVENT_COUPON_DOWNLOAD', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_EVENT_COUPON_DOWNLOAD
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

CREATE PROCEDURE [dbo].[SP_EXEC_EVENT_COUPON_DOWNLOAD]
    @COUPON_CODE AS VARCHAR(50)
	, @COMPANY_SEQ VARCHAR(4)   
	, @UID AS VARCHAR(50)
AS
BEGIN
    
    SET NOCOUNT ON

    DECLARE @MSG AS NVARCHAR(4000)

    IF EXISTS   (
                    SELECT  * 
                    FROM    S4_COUPON SC
                    WHERE   SC.COUPON_CODE  = @COUPON_CODE 
                    AND     SC.end_date > GETDATE()
                )
        BEGIN
            
            IF NOT EXISTS   (
                            SELECT  * 
                            FROM    S4_MYCOUPON SMC
                            JOIN    S4_COUPON SC ON SMC.COUPON_CODE = SC.COUPON_CODE
                            WHERE   SMC.UID = @UID
                            AND     SMC.COUPON_CODE = @COUPON_CODE
                        )
                BEGIN

                    INSERT INTO S4_MYCOUPON (COUPON_CODE, UID, COMPANY_SEQ, ISMYYN, END_DATE)
                    
					SELECT  COUPON_CODE
                        ,   @UID
                        ,   @COMPANY_SEQ
                        ,   'Y'
                        ,   END_DATE
                    FROM    S4_COUPON
                    WHERE   COUPON_CODE = @COUPON_CODE

                    SET @MSG = '쿠폰이 발급되었습니다. \n마이페이지에서 확인해 주세요!'

                END

            ELSE
                BEGIN

                    SET @MSG = '이미 발급된 쿠폰이 존재합니다. \n마이페이지에서 확인해 주세요!'

                END

        END

    ELSE
        BEGIN
            
            SET @MSG = '만료되었습니다'

        END



    SELECT @MSG AS MSG

END
GO
