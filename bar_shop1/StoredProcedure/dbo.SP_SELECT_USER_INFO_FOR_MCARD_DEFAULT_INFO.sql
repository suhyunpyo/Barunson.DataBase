IF OBJECT_ID (N'dbo.SP_SELECT_USER_INFO_FOR_MCARD_DEFAULT_INFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_USER_INFO_FOR_MCARD_DEFAULT_INFO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC SP_SELECT_USER_INFO_FOR_MCARD_DEFAULT_INFO 's5guest'

*/
CREATE PROCEDURE [dbo].[SP_SELECT_USER_INFO_FOR_MCARD_DEFAULT_INFO]
    
	@P_USER_ID			AS VARCHAR(16)
,	@P_USER_PW			AS VARCHAR(20) = ''
AS
BEGIN
    
    SET NOCOUNT ON;

	SELECT	TOP 1
			UID
		,	UNAME
		,	UMAIL
		,	BIRTH
		,	CASE WHEN BIRTH_DIV = 'S' THEN 'SOLAR' ELSE 'LUNAR' END AS LUNAR_OR_SOLAR
		,	CAST(ZIP1 AS VARCHAR(3)) + CASE WHEN LEN(CAST(ZIP2 AS VARCHAR(3))) = 3 THEN '-' ELSE '' END + CAST(ZIP2 AS VARCHAR(3)) AS ZIPCODE
		,	CAST(ZIP1 AS VARCHAR(3)) AS ZIPCODE_HEADER
		,	CAST(ZIP2 AS VARCHAR(3)) AS ZIPCODE_FOOTER
		,	ADDRESS
		,	ADDR_DETAIL AS ADDRESS_DETAIL
		,	CAST(PHONE1 AS VARCHAR(4)) + '-' + CAST(PHONE2 AS VARCHAR(4)) + '-' + CAST(PHONE3 AS VARCHAR(4)) AS PHONE
		,	CAST(PHONE1 AS VARCHAR(4)) AS PHONE_HEADER
		,	CAST(PHONE2 AS VARCHAR(4)) AS PHONE_MIDDLE
		,	CAST(PHONE3 AS VARCHAR(4)) AS PHONE_FOOTER
		,	CAST(HAND_PHONE1 AS VARCHAR(4)) + '-' + CAST(HAND_PHONE2 AS VARCHAR(4)) + '-' + CAST(HAND_PHONE3 AS VARCHAR(4)) AS HPHONE
		,	CAST(HAND_PHONE1 AS VARCHAR(4)) AS HPHONE_HEADER
		,	CAST(HAND_PHONE2 AS VARCHAR(4)) AS HPHONE_MIDDLE
		,	CAST(HAND_PHONE3 AS VARCHAR(4)) AS HPHONE_FOOTER
		,	CHK_SMS AS SMS_SERVICE_YORN
		,	CHK_MAILSERVICE AS MAIL_SERVICE_YORN
		,	CASE WHEN ISNULL(GENDER, '1') = '1' OR GENDER = '' THEN '남자' ELSE '여자' END GENDER

	FROM	S2_USERINFO
	WHERE	1 = 1
	AND		SITE_DIV = 'SB'
	AND		UID = @P_USER_ID

	-- @P_USER_PW가 공백일 경우에는		''  = ''
	-- @P_USER_PW에 값이 있을 경우		PWD = @P_USER_PW
	AND		CASE WHEN @P_USER_PW = '' THEN @P_USER_PW ELSE PWD END = @P_USER_PW

END
GO
