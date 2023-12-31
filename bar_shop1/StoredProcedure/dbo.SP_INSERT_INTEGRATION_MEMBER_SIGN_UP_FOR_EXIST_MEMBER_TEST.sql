IF OBJECT_ID (N'dbo.SP_INSERT_INTEGRATION_MEMBER_SIGN_UP_FOR_EXIST_MEMBER_TEST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_INTEGRATION_MEMBER_SIGN_UP_FOR_EXIST_MEMBER_TEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
  
EXEC SP_INSERT_INTEGRATION_MEMBER_SIGN_UP_FOR_EXIST_MEMBER 'MC0GCCQGSIB3DQIJAYEAGQMN9E0TJMUP1YU5+WS1CMQPM5IO02LOWVZOC0HWN0O='  
  
EXEC SP_INSERT_INTEGRATION_MEMBER_SIGN_UP_FOR_EXIST_MEMBER   
 'MC0GCCQGSIB3DQIJAYEAGQMN9E0TJMUP1YU5+WS1CMQPM5IO02LOWVZOC0HWN0O='  
, 'SIKKKE2FJBHN+OXKUC4OSPFFTRNUARDLOEUFXLTLDOJZY1DJYTZZFNXN9WR4XDRGHXW3D3A/WCROJJPRNYIZWA=='  
, '2'           
, 'SHARNIEL'  
, 'QWER1234'  
, '차호용'  
, 'SHARNIEL@NATE.COM'  
, '1982-08-10'  
, 'S'  
, '108'  
, '81'  
, '경기 파주시 회동길 219 (문발동)'  
, '4층 개발팀'  
, '02'  
, '0000'  
, '0000'  
, '010'  
, '4934'  
, '9760'  
, 'N'  
, 'N'  
, 'N'  
, 'N'  
, 'N'  
, 'N'  
, '2017'  
, '10'  
, '28'  
, 'E'  
, ''  
, ''  
, ''   
, 'AGAERJU5NK7QUCLQODA1GO8EBE6O2GY/+WUPO5CEEFUONGK2DJDQZN5UQ0NLNIBK3HCG/4L1TCDVP7S8RA9OPE83GR9I0Z1IFJYJMUZW/OVBP9ZADA0JVRYLPSWJHMFM4VDV6N+4TDRDJ4+TJ2HZCBJBL5CFAGTR5QSCIC55YTPJJDFN2K4RFY4VMXZ/80V4KHBEHK16ERKG0J4ZXZKUOBCDNNT4VYUZO3GBG90V48QW4HYKQ26YPO1NQMT7




UDCUXGTC2Y0FTPN404OLAYHF7UK2RFUI45IWGO4FAT6OIFT7O4XI567ETEYOM6+VACCYH8H8ECVHO1EPM3UEVMG6HIDS6GOKF9NI8HNEXWQEQ3ATSE6WM1FET/LHFQ0SKDTU9JSGPONJ6XABJ/V97DDTDVZ2PF7JJQ4TJL/0UFQ8WAHOUUJ/6EXSGJEFUFXOPYHMOCJOM7UGKZXQNEQ6PUAHBNZZQXYOASOH56EEOIECJGQV80LWNZ2/'  
, ''  
  
*/  
  
CREATE PROC [dbo].[SP_INSERT_INTEGRATION_MEMBER_SIGN_UP_FOR_EXIST_MEMBER_TEST]  
 @P_AUTHCODE				VARCHAR(100),   
 @P_CONNINFO				VARCHAR(100) = '',   
 @P_AUTHTYPE				VARCHAR(100) = '',   
 @P_UID						VARCHAR(50) = '',   
 @P_PWD						VARCHAR(16) = '',   
 @P_UNAME					VARCHAR(16) = '',  
 @P_EMAIL					VARCHAR(100) = '',   
 @P_BIRTH					VARCHAR(10) = '',   
 @P_BIRTH_DIV				CHAR(1) = '',   
 @P_ZIP1					VARCHAR(3) = '',  
 @P_ZIP2					VARCHAR(3) = '',   
 @P_ADDRESS					VARCHAR(150) = '',   
 @P_ADDRESS_DETAIL			VARCHAR(150) = '',   
 @P_PHONE1					VARCHAR(4) = '',   
 @P_PHONE2					VARCHAR(4) = '',   
 @P_PHONE3					VARCHAR(4) = '',   
 @P_HPHONE1					VARCHAR(4) = '',   
 @P_HPHONE2					VARCHAR(4) = '',   
 @P_HPHONE3					VARCHAR(4) = '',   
 @P_CHK_SMS					CHAR(1) = '',   
 @P_CHK_MAILSERVICE			CHAR(1) = '',   
 @P_CHK_SMEMBERSHIP			CHAR(1) = '',   
 @P_CHK_SMEMBERSHIP_PER		CHAR(1) = '',   
 @P_CHK_SMEMBERSHIP_COOP	CHAR(1) = '',   
 @P_MKT_CHK_FLAG			CHAR(1) = '',   
 @P_WEDDING_YEAR			VARCHAR(4) = '',   
 @P_WEDDING_MONTH    		VARCHAR(2) = '',   
 @P_WEDDING_DAY     		VARCHAR(2) = '',   
 @P_WEDDING_HALL     		CHAR(1) = '',   
 @P_ORI_BIRTH				VARCHAR(8) = '', 	
 @P_GENDER      		  	CHAR(1) = '', 	
 @P_NATIONAL_INFO    		CHAR(1) = '', 	
 @P_ENCODE_DATA     		VARCHAR(500) = '', 	
 @P_AUTH_MODULE_TYPE    	VARCHAR(500) = '',   
 @P_CHK_MYOMEE       		CHAR(1) = '',   
 @P_CHK_ILOOMMBERSHIP		CHAR(1) = '',	
 @P_CHK_LGMEMBERSHIP		CHAR(1) = ''
  
 AS    
 SET NOCOUNT ON  
 BEGIN  
  
  SET NOCOUNT ON;  
                    
	DECLARE @UID                VARCHAR(50) = ''  
    DECLARE @PWD                VARCHAR(16) = ''  
	DECLARE @PASSWORD_ENCRYPT   VARCHAR(200) = ''  
    DECLARE @UNAME              VARCHAR(16) = ''  
    DECLARE @EMAIL              VARCHAR(100) = ''  
    DECLARE @BIRTH              VARCHAR(10) = ''  
    DECLARE @BIRTH_DIV          CHAR(1) = ''  
    DECLARE @ZIP1				VARCHAR(3) = ''  
    DECLARE @ZIP2               VARCHAR(3) = ''  
    DECLARE @ADDRESS            VARCHAR(150) = ''  
    DECLARE @ADDRESS_DETAIL     VARCHAR(150) = ''  
    DECLARE @PHONE1             VARCHAR(4) = ''  
    DECLARE @PHONE2             VARCHAR(4) = ''  
    DECLARE @PHONE3             VARCHAR(4) = ''  
    DECLARE @HPHONE1            VARCHAR(4) = ''  
    DECLARE @HPHONE2            VARCHAR(4) = ''  
    DECLARE @HPHONE3            VARCHAR(4) = ''  
    DECLARE @CHK_SMS            CHAR(1) = ''  
    DECLARE @CHK_MAILSERVICE    CHAR(1) = ''  
    DECLARE @ADDR_FLAG			INT = 0  
    DECLARE @CHK_SMEMBERSHIP	CHAR(1) = ''  
    DECLARE @CHK_SMEMBERSHIP_PER  CHAR(1) = ''  
    DECLARE @CHK_SMEMBERSHIP_COOP CHAR(1) = ''  
	DECLARE @MKT_CHK_FLAG		CHAR(1) = ''  
    DECLARE @WEDD_YEAR          VARCHAR(4) = ''  
    DECLARE @WEDD_MONTH         VARCHAR(2) = ''  
    DECLARE @WEDD_DAY           VARCHAR(2) = ''  
    DECLARE @WEDD_HOUR          VARCHAR(2) = ''  
    DECLARE @WEDD_MINUTE        VARCHAR(2) = ''  
    DECLARE @UGUBUN             VARCHAR(1) = ''  
    DECLARE @CHK_DM             VARCHAR(1) = ''  
    DECLARE @WEDD_PGUBUN        VARCHAR(1) = ''  
    DECLARE @CONNINFO           VARCHAR(100) = NULL  
	DECLARE @AUTHTYPE			VARCHAR(100) = ''  
	DECLARE @ORI_BIRTH          VARCHAR(8)  = ''  
	DECLARE @GENDER				CHAR(1) = ''  
	DECLARE @NATIONAL_INFO      CHAR(1) = ''  
    DECLARE @CHK_MYOMEE         CHAR(1) = ''  
    DECLARE @CHK_ILOOMMBERSHIP  CHAR(1) = ''  
    DECLARE @CHK_LGMEMBERSHIP	CHAR(1) = ''
  
   
  
 IF @P_ENCODE_DATA <> '' BEGIN  

	IF NOT EXISTS(SELECT * FROM S2_USERINFO_AUTH_INFO WHERE DUPINFO = @P_AUTHCODE) BEGIN  
  
		INSERT INTO S2_USERINFO_AUTH_INFO (ENCODE_DATA, DUPINFO, AUTH_MODULE_TYPE, BIRTH_DATE, GENDER, NATIONAL_INFO, AUTH_DESC)  
		SELECT	@P_ENCODE_DATA, @P_AUTHCODE, @P_AUTH_MODULE_TYPE, @P_ORI_BIRTH, @P_GENDER, @P_NATIONAL_INFO, ''  
	END  
 END  
  
 DECLARE @LOG_MSG VARCHAR(1000)  
 SET @LOG_MSG = '@AUTHCODE : ' + @P_AUTHCODE + ', @@P_UID : ' + @P_UID + ', @P_PWD : ' + @P_PWD  
 SET @LOG_MSG = @LOG_MSG + '@P_WEDDING_YEAR : ' + @P_WEDDING_YEAR + ', @P_WEDDING_MONTH : ' + @P_WEDDING_MONTH + ', @P_WEDDING_DAY : ' +  @P_WEDDING_DAY + ', @P_WEDDING_HALL : ' + @P_WEDDING_HALL  
 -- 전환 진행중 상태를 보기 위한 로그  
 --EXEC SP_INSERT_BARUNN_INTEGRATE_USER_CHANGE_PROGRESS_LOG @P_AUTHCODE, @P_UID, 'SP_INSERT_INTEGRATION_MEMBER_SIGN_UP_FOR_EXIST_MEMBER', @LOG_MSG  
  
    SELECT TOP 1 @UID = UID,   
			@PASSWORD_ENCRYPT = PWD,   
			@UNAME = UNAME,   
			@EMAIL = UMAIL, 
			@BIRTH = BIRTH, 
			@BIRTH_DIV = BIRTH_DIV,   
			@ZIP1 = ZIP1,   
			@ZIP2 = ZIP2,   
			@ADDRESS = ADDRESS,   
			@ADDRESS_DETAIL = ADDR_DETAIL,   
			@PHONE1 = PHONE1,   
			@PHONE2 = PHONE2, 
			@PHONE3 = PHONE3,  
			@HPHONE1 = HAND_PHONE1, 
			@HPHONE2 = HAND_PHONE2,
			@HPHONE3 = HAND_PHONE3,
			@CHK_SMS = CHK_SMS,
			@CHK_MAILSERVICE = CHK_MAILSERVICE,   
			@ADDR_FLAG = ADDR_FLAG, 
			@CHK_SMEMBERSHIP = CHK_SMEMBERSHIP,
			@CHK_SMEMBERSHIP_PER = CHK_SMEMBERSHIP_PER,
			@CHK_SMEMBERSHIP_COOP = CHK_SMEMBERSHIP_COOP, 
			@MKT_CHK_FLAG = MKT_CHK_FLAG, 
			@WEDD_YEAR = WEDD_YEAR, 
			@WEDD_MONTH = WEDD_MONTH,
			@WEDD_DAY = WEDD_DAY,
			@WEDD_HOUR = WEDD_HOUR, 
			@WEDD_MINUTE = WEDD_MINUTE, 
			@UGUBUN = UGUBUN,
			@CHK_DM = CHK_DM,
			@WEDD_PGUBUN = WEDD_PGUBUN, 
			@CONNINFO = CONNINFO,
			@AUTHTYPE = AUTHTYPE,
			@ORI_BIRTH = BIRTHDATE,
			@GENDER = GENDER,
			@NATIONAL_INFO = NATIONALINFO,
			@CHK_MYOMEE = CHK_MYOMEE,
			@CHK_ILOOMMBERSHIP = CHK_ILOOMMEMBERSHIP,
			@CHK_LGMEMBERSHIP = CHK_LGMEMBERSHIP
	FROM (  
            SELECT  DUPINFO,
					CONNINFO,
					AUTHTYPE, 
					UID,
					PWD, 
					UNAME,
					UMAIL, 
					BIRTH,
					BIRTH_DIV,
					ZIP1,
					ZIP2,
					ADDRESS,
					ADDR_DETAIL,
					PHONE1,
					PHONE2,
					PHONE3,
					HAND_PHONE1,
					HAND_PHONE2,
					HAND_PHONE3,
					CHK_SMS,
					CHK_MAILSERVICE,
					ADDR_FLAG,
					CHK_SMEMBERSHIP,
					CHK_SMEMBERSHIP_PER,
					CHK_SMEMBERSHIP_COOP,
					MKT_CHK_FLAG,
					WEDD_YEAR,
					WEDD_MONTH,
					WEDD_DAY,
					WEDD_HOUR,
					WEDD_MINUTE,
					UGUBUN,
					CHK_DM,
					WEDD_PGUBUN,
					BIRTHDATE,
					GENDER,
					NATIONALINFO,
					CHK_MYOMEE,
					CHK_ILOOMMEMBERSHIP,
					CHK_LGMEMBERSHIP
  
            FROM	S2_USERINFO  
			UNION ALL  
            SELECT  DUPINFO,
					CONNINFO,
					AUTHTYPE,
					UID,
					PWD,
					UNAME,
					UMAIL,
					BIRTH,
					BIRTH_DIV,
					ZIP1,
					ZIP2,
					ADDRESS,
					ADDR_DETAIL,
					PHONE1,
					PHONE2,
					PHONE3,
					HAND_PHONE1,
					HAND_PHONE2,
					HAND_PHONE3,
					CHK_SMS,
					CHK_MAILSERVICE,
					ADDR_FLAG,
					CHK_SMEMBERSHIP,
					CHK_SMEMBERSHIP_PER,
					CHK_SMEMBERSHIP_COOP,
					MKT_CHK_FLAG,
					WEDD_YEAR,
					WEDD_MONTH,
					WEDD_DAY,
					WEDD_HOUR,
					WEDD_MINUTE,
					UGUBUN,
					CHK_DM,
					WEDD_PGUBUN,
					BIRTHDATE,
					GENDER,
					NATIONALINFO,
					CHK_MYOMEE,
					CHK_ILOOMMEMBERSHIP,
					CHK_LGMEMBERSHIP
            FROM    S2_USERINFO_BHANDS  
            UNION ALL  
            SELECT  DUPINFO,
					CONNINFO,
					AUTHTYPE,
					UID,
					PWD,
					UNAME,
					UMAIL,
					BIRTH,
					BIRTH_DIV,
					ZIP1,
					ZIP2,
					ADDRESS,
					ADDR_DETAIL,
					PHONE1,
					PHONE2,
					PHONE3,
					HAND_PHONE1,
					HAND_PHONE2,
					HAND_PHONE3,
					CHK_SMS,
					CHK_MAILSERVICE,
					ADDR_FLAG,
					CHK_SMEMBERSHIP,
					CHK_SMEMBERSHIP_PER,
					CHK_SMEMBERSHIP_COOP,
					MKT_CHK_FLAG,
					WEDD_YEAR,
					WEDD_MONTH,
					WEDD_DAY,
					WEDD_HOUR,
					WEDD_MINUTE,
					UGUBUN,
					CHK_DM,
					WEDD_PGUBUN,
					BIRTHDATE,
					GENDER,
					NATIONALINFO,
					CHK_MYOMEE,
					CHK_ILOOMMEMBERSHIP,
					CHK_LGMEMBERSHIP
            FROM    S2_USERINFO_THECARD  
         ) A  
			WHERE   A.DUPINFO = @P_AUTHCODE  
  
    DECLARE @IS_NEW_MEMBER_YORN AS CHAR(1) = 'N'  
  
    IF @P_CONNINFO <> '' AND (@UID = '' OR @UID IS NULL) BEGIN  
          
        SET @IS_NEW_MEMBER_YORN = 'Y'  
  
    END  
  
    SELECT  @P_AUTHCODE			= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_AUTHCODE ELSE @P_AUTHCODE END,   
			@CONNINFO			= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_CONNINFO ELSE @CONNINFO END,	
			@AUTHTYPE			= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_AUTHTYPE ELSE @AUTHTYPE END, 
			@UID				= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_UID ELSE @P_UID END, 
			@PWD				= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_PWD ELSE @PWD END,
			@UNAME				= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_UNAME ELSE @UNAME END,  
			@EMAIL				= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_EMAIL ELSE @EMAIL END, 
			@BIRTH				= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_BIRTH ELSE @BIRTH END, 
			@BIRTH_DIV			= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_BIRTH_DIV ELSE @BIRTH_DIV END,
			@ZIP1				= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_ZIP1 ELSE @ZIP1 END,
			@ZIP2				= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_ZIP2 ELSE @ZIP2 END, 
			@ADDRESS			= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_ADDRESS ELSE @ADDRESS END, 
			@ADDRESS_DETAIL		= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_ADDRESS_DETAIL ELSE @ADDRESS_DETAIL END, 
			@PHONE1				= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_PHONE1 ELSE @PHONE1 END,
			@PHONE2				= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_PHONE2 ELSE @PHONE2 END,
			@PHONE3				= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_PHONE3 ELSE @PHONE3 END,
			@HPHONE1			= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_HPHONE1 ELSE @HPHONE1 END,
			@HPHONE2			= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_HPHONE2 ELSE @HPHONE2 END, 
			@HPHONE3			= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_HPHONE3 ELSE @HPHONE3 END,
			@CHK_SMS			= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_CHK_SMS ELSE @CHK_SMS END,
			@CHK_MAILSERVICE	= CASE @IS_NEW_MEMBER_YORN WHEN 'Y' THEN @P_CHK_MAILSERVICE ELSE @CHK_MAILSERVICE END,
			@ADDR_FLAG			= @ADDR_FLAG,
			@CHK_SMEMBERSHIP	= CASE WHEN @P_CHK_SMEMBERSHIP = '' THEN @CHK_SMEMBERSHIP ELSE @P_CHK_SMEMBERSHIP END, 
			@CHK_SMEMBERSHIP_PER = CASE WHEN @P_CHK_SMEMBERSHIP_PER = '' THEN @CHK_SMEMBERSHIP_PER ELSE @P_CHK_SMEMBERSHIP_PER  END,
			@CHK_SMEMBERSHIP_COOP = CASE WHEN @P_CHK_SMEMBERSHIP_COOP = '' THEN @CHK_SMEMBERSHIP_COOP ELSE @P_CHK_SMEMBERSHIP_COOP END,
			@MKT_CHK_FLAG		= CASE WHEN @P_MKT_CHK_FLAG = '' THEN @MKT_CHK_FLAG ELSE @P_MKT_CHK_FLAG END,
			@WEDD_YEAR			= CASE WHEN @P_WEDDING_YEAR = '' THEN @WEDD_YEAR ELSE @P_WEDDING_YEAR END, 
			@WEDD_MONTH			= CASE WHEN @P_WEDDING_MONTH = '' THEN @WEDD_MONTH ELSE @P_WEDDING_MONTH END,
			@WEDD_DAY			= CASE WHEN @P_WEDDING_DAY = '' THEN @WEDD_DAY ELSE @P_WEDDING_DAY END,   
			@WEDD_HOUR			= @WEDD_HOUR,   
			@WEDD_MINUTE		= @WEDD_MINUTE,   
			@UGUBUN				= @UGUBUN,
			@CHK_DM				= @CHK_DM,
			@WEDD_PGUBUN		= CASE WHEN @P_WEDDING_HALL = '' THEN @WEDD_PGUBUN ELSE @P_WEDDING_HALL END, 
			@GENDER				= CASE WHEN ISNULL(@GENDER, '') = '' THEN @P_GENDER ELSE @GENDER END,
			@ORI_BIRTH			= CASE WHEN ISNULL(@ORI_BIRTH, '')  = '' THEN @P_ORI_BIRTH ELSE @ORI_BIRTH END,
			@NATIONAL_INFO		= CASE WHEN ISNULL(@NATIONAL_INFO, '') = '' THEN @P_NATIONAL_INFO ELSE @NATIONAL_INFO END,
			@CHK_MYOMEE			= CASE WHEN @P_CHK_MYOMEE = '' THEN @CHK_MYOMEE ELSE @P_CHK_MYOMEE END,  
			@CHK_ILOOMMBERSHIP	= CASE WHEN @P_CHK_ILOOMMBERSHIP = '' THEN @CHK_ILOOMMBERSHIP ELSE @P_CHK_ILOOMMBERSHIP END,
			@CHK_LGMEMBERSHIP	= CASE WHEN @P_CHK_LGMEMBERSHIP = '' THEN @CHK_LGMEMBERSHIP ELSE @P_CHK_LGMEMBERSHIP	END
  
    EXEC SP_INSERT_INTEGRATION_MEMBER_SIGN_UP_TEST   @P_AUTHCODE, @CONNINFO, @AUTHTYPE, @UID, @PWD, @UNAME, @EMAIL, @BIRTH, @BIRTH_DIV, 
												@ZIP1, @ZIP2, @ADDRESS, @ADDRESS_DETAIL, @PHONE1, @PHONE2, @PHONE3, @HPHONE1, @HPHONE2,  
												@HPHONE3, @CHK_SMS, @CHK_MAILSERVICE, @ADDR_FLAG, @CHK_SMEMBERSHIP, @CHK_SMEMBERSHIP_PER,  
												@CHK_SMEMBERSHIP_COOP, @MKT_CHK_FLAG, @WEDD_YEAR, @WEDD_MONTH, @WEDD_DAY, @WEDD_HOUR,
												@WEDD_MINUTE, @UGUBUN, @CHK_DM, @WEDD_PGUBUN, @GENDER, @ORI_BIRTH, @NATIONAL_INFO, 5001, 
												@PASSWORD_ENCRYPT, @CHK_MYOMEE, @CHK_ILOOMMBERSHIP,	@CHK_LGMEMBERSHIP
  
 END


GO
