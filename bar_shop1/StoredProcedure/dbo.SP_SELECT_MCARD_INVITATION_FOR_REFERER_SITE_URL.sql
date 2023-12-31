IF OBJECT_ID (N'dbo.SP_SELECT_MCARD_INVITATION_FOR_REFERER_SITE_URL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_MCARD_INVITATION_FOR_REFERER_SITE_URL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC SP_SELECT_MCARD_INVITATION_FOR_REFERER_SITE_URL 's5guest'

*/
CREATE PROCEDURE [dbo].[SP_SELECT_MCARD_INVITATION_FOR_REFERER_SITE_URL]
    
	@P_INVITATION_CODE AS VARCHAR(20)
AS
BEGIN
    
    SET NOCOUNT ON;

	SELECT	
			CASE		
					WHEN INVITATIONCODE LIKE 'SB%' THEN 'http://www.barunsoncard.com'
					WHEN INVITATIONCODE LIKE 'SA%' THEN 'http://www.bhandscard.com'
					WHEN INVITATIONCODE LIKE 'ST%' THEN 'http://www.thecard.co.kr'
					WHEN INVITATIONCODE LIKE 'SS%' THEN 'http://www.premierpaper.co.kr'
					WHEN INVITATIONCODE LIKE 'CE%' THEN 'http://www.celemo.co.kr'
					WHEN SUBSTRING(INVITATIONCODE , 1,2) <> 'BE'  AND (INVITATIONCODE LIKE 'B%' OR INVITATIONCODE LIKE 'C%' OR INVITATIONCODE LIKE 'H%')  THEN 'http://www.barunsonmall.com/'

					--WHEN INVITATIONCODE LIKE 'B%' OR INVITATIONCODE LIKE 'C%' THEN 'http://www.bhandscard.com'
					--WHEN INVITATIONCODE LIKE 'H%' THEN 'http://www.premierpaper.co.kr'

					--WHEN INVITATIONCODE LIKE 'B%' OR INVITATIONCODE LIKE 'C%' 
					--	THEN ISNULL(( SELECT 'http://wed.bhandscard.com/' + C.LOGIN_ID FROM CUSTOM_ORDER CO JOIN COMPANY C ON CO.COMPANY_SEQ = C.COMPANY_SEQ WHERE CO.ORDER_SEQ = REPLACE(REPLACE(INVITATIONCODE, 'B', ''), 'C', '')) , 'http://www.bhandscard.com')
					--WHEN INVITATIONCODE LIKE 'H%' 
					--	THEN ISNULL(( SELECT 'http://wed.premierpaper.co.kr/' + C.LOGIN_ID FROM CUSTOM_ORDER CO JOIN COMPANY C ON CO.COMPANY_SEQ = C.COMPANY_SEQ WHERE CO.ORDER_SEQ = REPLACE(INVITATIONCODE, 'H', '') ) , 'http://www.premierpaper.co.kr')

					-- 기본값 바른손카드
					ELSE 'http://www.barunsoncard.com'

			END AS REFERER_SITE_URL
		,	INVITATIONCODE

	FROM	MCARD_INVITATION 
	WHERE	INVITATIONCODE = @P_INVITATION_CODE

END
GO
