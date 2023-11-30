IF OBJECT_ID (N'dbo.SP_GUEST_SAMPLE_CONVERSION', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_GUEST_SAMPLE_CONVERSION
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		황새롬
-- Create date: 2018-01-09
-- Description:	바른손카드 비회원 샘플 장바구니 회원 전환

-- EXEC dbo.[SP_GUEST_SAMPLE_CONVERSION] GUID, UID
-- /member/login_proc.asp
-- =============================================

CREATE PROCEDURE [dbo].[SP_GUEST_SAMPLE_CONVERSION]
	@GUID 					            AS      VARCHAR(50) ,
	@UID								AS      VARCHAR(50)
AS
BEGIN

	DECLARE     @CARD_SEQ       INT
    DECLARE     @COMPANY_SEQ    INT = 5001

	DECLARE cur_sample CURSOR FOR
                                    SELECT	CARD_SEQ
		                            FROM	S2_SAMPLEBASKET
		                            WHERE	1=1
		                            AND		GUID = @GUID
		                            AND		UID = ''
                                    AND     COMPANY_SEQ = @COMPANY_SEQ

    OPEN cur_sample
	FETCH NEXT FROM cur_sample INTO @CARD_SEQ

	WHILE @@FETCH_STATUS = 0
	BEGIN
	        IF	NOT EXISTS(
		        SELECT		*
		        FROM		S2_SAMPLEBASKET
		        WHERE		1 = 1
		        AND			UID = @UID
		        AND			CARD_SEQ = @CARD_SEQ
                AND         COMPANY_SEQ = @COMPANY_SEQ
	        )
            BEGIN
                UPDATE  S2_SAMPLEBASKET
                SET     UID = @UID
                WHERE   UID = ''
                AND     CARD_SEQ = @CARD_SEQ
                AND     GUID = @GUID
                AND     COMPANY_SEQ = @COMPANY_SEQ
            END
            ELSE
            BEGIN
                DELETE FROM S2_SAMPLEBASKET WHERE UID = '' AND CARD_SEQ = @CARD_SEQ AND GUID = @GUID AND COMPANY_SEQ = @COMPANY_SEQ
            END

            FETCH NEXT FROM cur_sample INTO @CARD_SEQ
    END

	CLOSE cur_sample
	DEALLOCATE cur_sample

END
GO
