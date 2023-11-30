IF OBJECT_ID (N'dbo.SP_INSERT_INTEGRATION_MEMBER_SIGN_UP_FOR_MANUAL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_INTEGRATION_MEMBER_SIGN_UP_FOR_MANUAL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 특별한 경우를 제외하고 사용하지 않는 프로시저 */

/*

EXEC SP_INSERT_INTEGRATION_MEMBER_SIGN_UP_FOR_MANUAL

*/

CREATE PROC [dbo].[SP_INSERT_INTEGRATION_MEMBER_SIGN_UP_FOR_MANUAL]

AS  
SET NOCOUNT ON
BEGIN
	
DECLARE @P_AUTHCODE               VARCHAR(100)		= ''
    ,   @P_CONNINFO               VARCHAR(100)      = ''
	,   @P_AUTHTYPE               VARCHAR(100)      = ''
    ,   @P_UID                    VARCHAR(50)       = ''
    ,   @P_PWD                    VARCHAR(16)       = ''
    ,   @P_UNAME                  VARCHAR(16)       = ''
    ,   @P_EMAIL                  VARCHAR(100)      = ''
    ,   @P_BIRTH                  VARCHAR(10)       = ''
    ,   @P_BIRTH_DIV              CHAR(1)           = ''
    ,   @P_ZIP1                   VARCHAR(3)        = ''
    ,   @P_ZIP2                   VARCHAR(3)        = ''
    ,   @P_ADDRESS                VARCHAR(150)      = ''
    ,   @P_ADDRESS_DETAIL         VARCHAR(150)      = ''
    ,   @P_PHONE1                 VARCHAR(4)        = ''
    ,   @P_PHONE2                 VARCHAR(4)        = ''
    ,   @P_PHONE3                 VARCHAR(4)        = ''
    ,   @P_HPHONE1                VARCHAR(4)        = ''
    ,   @P_HPHONE2                VARCHAR(4)        = ''
    ,   @P_HPHONE3                VARCHAR(4)        = ''
    ,   @P_CHK_SMS                CHAR(1)           = ''
    ,   @P_CHK_MAILSERVICE        CHAR(1)           = ''
	,   @P_CHK_SMEMBERSHIP		  CHAR(1)           = ''
    ,   @P_CHK_SMEMBERSHIP_PER    CHAR(1)           = ''
    ,   @P_CHK_SMEMBERSHIP_COOP   CHAR(1)           = ''
    ,   @P_MKT_CHK_FLAG           CHAR(1)			= ''
	,   @P_WEDDING_YEAR			  VARCHAR(4)		= ''
	,   @P_WEDDING_MONTH		  VARCHAR(2)		= ''
	,   @P_WEDDING_DAY			  VARCHAR(2)		= ''
	,   @P_WEDDING_HALL			  CHAR(1)			= ''

	,   @P_ORI_BIRTH              VARCHAR(8)        = ''
	,	@P_GENDER				  CHAR(1)		    = ''
	,	@P_NATIONAL_INFO		  CHAR(1)		    = ''

	,	@P_ENCODE_DATA			  VARCHAR(500)      = ''
	,	@P_AUTH_MODULE_TYPE		  VARCHAR(500)      = ''



SELECT	
		@P_AUTHCODE					= DUPINFO
	,	@P_CONNINFO               	= CONNINFO
	,	@P_AUTHTYPE               	= AUTHTYPE
	,	@P_UID                    	= UID
	,	@P_PWD                    	= PWD
	,	@P_UNAME                  	= UNAME
	,	@P_EMAIL                  	= UMAIL
	,	@P_BIRTH                  	= BIRTH
	,	@P_BIRTH_DIV              	= BIRTH_DIV
	,	@P_ZIP1                   	= ZIP1
	,	@P_ZIP2                   	= ZIP2
	,	@P_ADDRESS                	= ADDRESS
	,	@P_ADDRESS_DETAIL         	= ADDR_DETAIL
	,	@P_PHONE1                 	= PHONE1
	,	@P_PHONE2                 	= PHONE2
	,	@P_PHONE3                 	= PHONE3
	,	@P_HPHONE1                	= HAND_PHONE1
	,	@P_HPHONE2                	= HAND_PHONE2
	,	@P_HPHONE3                	= HAND_PHONE3
	,	@P_CHK_SMS                	= CHK_SMS
	,	@P_CHK_MAILSERVICE        	= CHK_MAILSERVICE
	,	@P_CHK_SMEMBERSHIP		  	= CHK_SMEMBERSHIP
	,	@P_CHK_SMEMBERSHIP_PER    	= CHK_SMEMBERSHIP_PER
	,	@P_CHK_SMEMBERSHIP_COOP   	= CHK_SMEMBERSHIP_COOP
	,	@P_MKT_CHK_FLAG           	= MKT_CHK_FLAG
	,	@P_WEDDING_YEAR			  	= WEDD_YEAR
	,	@P_WEDDING_MONTH		  	= WEDD_MONTH
	,	@P_WEDDING_DAY			  	= WEDD_DAY
	,	@P_WEDDING_HALL			  	= WEDD_HOUR
	,	@P_ORI_BIRTH              	= BIRTHDATE
	,	@P_GENDER				  	= GENDER
	,	@P_NATIONAL_INFO		  	= NATIONALINFO
	,	@P_ENCODE_DATA			  	= ''
	,	@P_AUTH_MODULE_TYPE		  	= AUTHTYPE

FROM	S2_USERINFO
WHERE	1 = 1
AND		UID = 'gh6684'
AND		SITE_DIV = 'SB'




EXEC SP_INSERT_INTEGRATION_MEMBER_SIGN_UP_FOR_EXIST_MEMBER
																@P_AUTHCODE					
															,	@P_CONNINFO               	
															,	@P_AUTHTYPE               	
															,	@P_UID                    	
															,	@P_PWD                    	
															,	@P_UNAME                  	
															,	@P_EMAIL                  	
															,	@P_BIRTH                  	
															,	@P_BIRTH_DIV              	
															,	@P_ZIP1                   	
															,	@P_ZIP2                   	
															,	@P_ADDRESS                	
															,	@P_ADDRESS_DETAIL         	
															,	@P_PHONE1                 	
															,	@P_PHONE2                 	
															,	@P_PHONE3                 	
															,	@P_HPHONE1                	
															,	@P_HPHONE2                	
															,	@P_HPHONE3                	
															,	@P_CHK_SMS                	
															,	@P_CHK_MAILSERVICE        	
															,	@P_CHK_SMEMBERSHIP		  	
															,	@P_CHK_SMEMBERSHIP_PER    	
															,	@P_CHK_SMEMBERSHIP_COOP   	
															,	@P_MKT_CHK_FLAG           	
															,	@P_WEDDING_YEAR			  	
															,	@P_WEDDING_MONTH		  	
															,	@P_WEDDING_DAY			  	
															,	@P_WEDDING_HALL			  	
															,	@P_ORI_BIRTH              	
															,	@P_GENDER				  	
															,	@P_NATIONAL_INFO		  	
															,	@P_ENCODE_DATA			  	
															,	@P_AUTH_MODULE_TYPE		  	



END
GO
