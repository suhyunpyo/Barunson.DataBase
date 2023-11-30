IF OBJECT_ID (N'dbo.SP_EXEC_WEEKLY_HOTDEAL_COUPON_DOWNLOAD', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_WEEKLY_HOTDEAL_COUPON_DOWNLOAD
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

/*

346273

EXEC SP_EXEC_WEEKLY_SPECIAL_COUPON_DOWNLOAD 346273, 's4guest'

*/

CREATE PROCEDURE [dbo].[SP_EXEC_WEEKLY_HOTDEAL_COUPON_DOWNLOAD]
    @SEQ AS INT
,   @UID AS VARCHAR(50)
AS
BEGIN
    
    SET NOCOUNT ON

    DECLARE @MSG AS NVARCHAR(4000)

    IF EXISTS   (
                    SELECT  * 
                    FROM    S4_COUPON SC
					inner join S4_MD_Choice_UseCoupon smcu
					on sc.coupon_code = smcu.coupon_code
					inner join S4_MD_Choice smc
					on smcu.choice_seq = smc.seq and smc.md_seq = 368
                    WHERE   SC.SEQ = @SEQ 
                    AND     SC.reg_date <= GETDATE()
                    AND     smcu.down_end_dt >= convert(varchar(10), GETDATE(), 121)
                    AND     SC.ISYN = 'Y'
                )
        BEGIN
            
            IF NOT EXISTS   (
                            SELECT  * 
                            FROM    S4_MYCOUPON SMC
                            JOIN    S4_COUPON SC ON SMC.COUPON_CODE = SC.COUPON_CODE
                            WHERE   SMC.UID = @UID
                            AND     SC.SEQ = @SEQ
                            AND     SC.COMPANY_SEQ = SMC.COMPANY_SEQ
                        )
                BEGIN

                    INSERT INTO S4_MYCOUPON (COUPON_CODE, UID, COMPANY_SEQ, ISMYYN, END_DATE)
                    SELECT  COUPON_CODE
                        ,   @UID
                        ,   COMPANY_SEQ
                        ,   'Y'
                        ,   END_DATE
                    FROM    S4_COUPON
                    WHERE   SEQ = @SEQ

                    SET @MSG = '발급되었습니다'

                END

            ELSE
                BEGIN

                    SET @MSG = '이미 발급된 쿠폰입니다'

                END

        END

    ELSE
        BEGIN
            
            SET @MSG = '만료되었습니다'

        END



    SELECT @MSG AS MSG

END
GO
