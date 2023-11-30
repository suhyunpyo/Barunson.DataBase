IF OBJECT_ID (N'dbo.SP_INSERT_INTEGRATION_MEMBER_SIGN_UP_TEST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_INTEGRATION_MEMBER_SIGN_UP_TEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[SP_INSERT_INTEGRATION_MEMBER_SIGN_UP_TEST] 
 @AUTHCODE				VARCHAR(100),   
 @CONNINFO				VARCHAR(100),	
 @AUTHTYPE				VARCHAR(100),  
 @USER_ID				VARCHAR(50), 
 @PASSWORD              VARCHAR(16),
 @USER_NAME             VARCHAR(16),
 @EMAIL                 VARCHAR(100),
 @BIRTH                 VARCHAR(10),
 @BIRTH_DIV             CHAR(1),
 @ZIP1                  VARCHAR(3), 
 @ZIP2                  VARCHAR(3), 
 @ADDRESS               VARCHAR(150),
 @ADDRESS_DETAIL        VARCHAR(150), 
 @PHONE1                VARCHAR(4), 
 @PHONE2                VARCHAR(4),
 @PHONE3                VARCHAR(4), 
 @HPHONE1               VARCHAR(4),
 @HPHONE2               VARCHAR(4),   
 @HPHONE3               VARCHAR(4),
 @CHK_SMS				CHAR(1),
 @CHK_MAILSERVICE       CHAR(1),
 @ADDR_FLAG             INT = 0,   
 @CHK_SMEMBERSHIP       CHAR(1) = '', 
 @CHK_SMEMBERSHIP_PER   CHAR(1) = '',   
 @CHK_SMEMBERSHIP_COOP  CHAR(1) = '', 
 @MKT_CHK_FLAG          CHAR(1) = '', 
 @WEDD_YEAR             VARCHAR(4) = '', 
 @WEDD_MONTH            VARCHAR(2) = '', 
 @WEDD_DAY              VARCHAR(2) = '', 
 @WEDD_HOUR             VARCHAR(2) = '',   
 @WEDD_MINUTE           VARCHAR(2) = '',   
 @UGUBUN                CHAR(1)			= '',
 @CHK_DM                CHAR(1)			= '', 
 @WEDD_PGUBUN           CHAR(1)			= '', 
 @GENDER                CHAR(1)			= '',	
 @ORI_BIRTH    		    VARCHAR(8)		= '',	
 @NATIONAL_INFO			CHAR(1) = '', 
 @COMPANY_SEQ           INT = 5001,
 @PASSWORD_ENCRYPT		VARCHAR(200) = '', 
 @CHK_MYOMEE            CHAR(1) = '',   
 @CHK_ILOOMMBERSHIP     CHAR(1) = '',	
 @CHK_LGMEMBERSHIP		CHAR(1)	= ''

AS  
 SET NOCOUNT ON BEGIN
	
	SET @PASSWORD_ENCRYPT = CASE WHEN ISNULL(@PASSWORD, '') = '' THEN @PASSWORD_ENCRYPT ELSE CONVERT(VARCHAR(200), PWDENCRYPT(@PASSWORD), 1) END
	
	-- 삼성 맴버십 가입일
	DECLARE @SMEMBERSHI_REG_DATE AS VARCHAR(19) = CONVERT(VARCHAR(19), GETDATE(), 120)
	SET @SMEMBERSHI_REG_DATE = CONVERT(VARCHAR(19), GETDATE(), 120)
	IF EXISTS(SELECT TOP 1 * FROM VW_USER_INFO WHERE DUPINFO = @AUTHCODE)
	BEGIN
		SET @SMEMBERSHI_REG_DATE = (SELECT CONVERT(VARCHAR(19), MIN(SMEMBERSHIP_REG_DATE), 120) AS SMEMBERSHI_REG_DATE FROM VW_USER_INFO WHERE DUPINFO = @AUTHCODE)
	END

    -- 추가 2021-02-01
    IF (@SMEMBERSHI_REG_DATE) IS NULL
    BEGIN
        SET @SMEMBERSHI_REG_DATE = CONVERT(VARCHAR(19), GETDATE(), 120)
    END

    -- 롯데렌탈 묘미
  	DECLARE @MYOMEE_REG_DATE AS VARCHAR(19) = CONVERT(VARCHAR(19), GETDATE(), 120)
	SET @MYOMEE_REG_DATE = CONVERT(VARCHAR(19), GETDATE(), 120)
	IF EXISTS(SELECT TOP 1 * FROM VW_USER_INFO WHERE DUPINFO = @AUTHCODE)
	BEGIN
		SET @MYOMEE_REG_DATE = (SELECT CONVERT(VARCHAR(19), MIN(MYOMEE_REG_DATE), 120) AS MYOMEE_REG_DATE FROM VW_USER_INFO WHERE DUPINFO = @AUTHCODE)
	END

    -- 일룸
  	DECLARE @ILOOMMEMBERSHIP_REG_DATE AS VARCHAR(19) = CONVERT(VARCHAR(19), GETDATE(), 120)
	SET @ILOOMMEMBERSHIP_REG_DATE = CONVERT(VARCHAR(19), GETDATE(), 120)
	IF EXISTS(SELECT TOP 1 * FROM VW_USER_INFO WHERE DUPINFO = @AUTHCODE)
	BEGIN
		SET @ILOOMMEMBERSHIP_REG_DATE = (SELECT CONVERT(VARCHAR(19), MIN(@ILOOMMEMBERSHIP_REG_DATE), 120) AS ILOOMMEMBERSHIP_REG_DATE FROM VW_USER_INFO WHERE DUPINFO = @AUTHCODE)
	END

	-- LG
	DECLARE @LGMEMBERSHIP_REG_DATE AS VARCHAR(19) = CONVERT(VARCHAR(19), GETDATE(), 120)
	SET @LGMEMBERSHIP_REG_DATE = CONVERT(VARCHAR(19), GETDATE(), 120)
	IF EXISTS(SELECT TOP 1 * FROM VW_USER_INFO WHERE DUPINFO = @AUTHCODE)
	BEGIN
		SET @LGMEMBERSHIP_REG_DATE = (SELECT CONVERT(VARCHAR(19), MIN(@LGMEMBERSHIP_REG_DATE), 120) AS LGMEMBERSHIP_REG_DATE FROM VW_USER_INFO WHERE DUPINFO = @AUTHCODE)
	END

    -- 추가 2021-02-01
    IF (@LGMEMBERSHIP_REG_DATE) IS NULL
    BEGIN
        SET @LGMEMBERSHIP_REG_DATE = CONVERT(VARCHAR(19), GETDATE(), 120)
    END


    /* 비핸즈카드 묘미추가*/
    IF NOT EXISTS(SELECT TOP 1 * FROM S2_USERINFO_BHANDS WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SA' , 'B', 'C' )) BEGIN
        
        INSERT INTO S2_USERINFO_BHANDS (
                DUPINFO
            ,   CONNINFO
			,	AUTHTYPE
            ,   UID
            ,   PWD                     
            ,   UNAME
            ,   UMAIL  
            ,   SITE_DIV                 
            ,   JUMIN
            ,   BIRTH                   
            ,   BIRTH_DIV               
            ,   ZIP1                    
            ,   ZIP2                    
            , ADDRESS                 
            ,   ADDR_DETAIL             
            ,   PHONE1                  
            ,   PHONE2                  
            ,   PHONE3                  
            ,   HAND_PHONE1             
            ,   HAND_PHONE2             
            ,   HAND_PHONE3             
            ,   CHK_SMS                 
            ,   CHK_MAILSERVICE         
            ,   ADDR_FLAG               
            ,   CHK_SMEMBERSHIP         
            ,   SMEMBERSHIP_CHK_FLAG    
            ,   SMEMBERSHIP_REG_DATE    
            ,   SMEMBERSHIP_INFLOW_ROUTE
            ,   CHK_SMEMBERSHIP_PER     
            ,   CHK_SMEMBERSHIP_COOP    
            ,   MKT_CHK_FLAG   
            ,   WEDD_YEAR
            ,   WEDD_MONTH
            ,   WEDD_DAY
            ,   WEDD_HOUR
            ,   WEDD_MINUTE
            ,   UGUBUN
            ,   CHK_DM
            ,   WEDD_PGUBUN
            ,   INTEGRATION_MEMBER_YORN 
			,	INTERGRATION_DATE        
            ,   MOD_DATE 
            ,   REG_DATE
			,	USE_YORN

			,	BIRTHDATE
			,	GENDER
			,	NATIONALINFO

			,	PWD_BACKUP
			,	CHK_MYOMEE
            ,   MYOMEE_REG_DATE
        
            ,   CHK_ILOOMMEMBERSHIP         
            ,   ILOOMMEMBERSHIP_REG_DATE    
            ,	CHK_LGMEMBERSHIP
            , 	LGMEMBERSHIP_REG_DATE
		)



        SELECT  
                @AUTHCODE
            ,   @CONNINFO
			,	@AUTHTYPE
            ,   @USER_ID
            ,   @PASSWORD_ENCRYPT
            ,   @USER_NAME
            ,   @EMAIL
            ,   'SA'
            ,   ''
            ,   @BIRTH
            ,   @BIRTH_DIV
            ,   @ZIP1
            ,   @ZIP2
            ,   @ADDRESS
            ,   @ADDRESS_DETAIL
            ,   @PHONE1
            ,   @PHONE2
            ,   @PHONE3
            ,   @HPHONE1
            ,   @HPHONE2
            ,   @HPHONE3
            ,   @CHK_SMS
            ,   @CHK_MAILSERVICE
            ,   @ADDR_FLAG
            ,   CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'Y'					ELSE 'N'        END
            ,   CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'Y'					ELSE 'N'        END
            ,   CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN @SMEMBERSHI_REG_DATE	ELSE NULL       END 
            ,   CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'JOIN'					ELSE NULL       END
            ,   CASE WHEN @CHK_SMEMBERSHIP_PER    = 'Y'     THEN 'Y'					ELSE 'N'        END
            ,   CASE WHEN @CHK_SMEMBERSHIP_COOP   = 'Y'     THEN 'Y'					ELSE 'N'        END
            ,   CASE WHEN @MKT_CHK_FLAG           = 'Y'     THEN 'Y'					ELSE 'N'        END     
            ,   @WEDD_YEAR
            ,   @WEDD_MONTH
            ,   @WEDD_DAY
            ,   @WEDD_HOUR
            ,   @WEDD_MINUTE
            ,   CASE WHEN @UGUBUN != '' AND @UGUBUN IS NOT NULL THEN @UGUBUN ELSE NULL END
            ,   CASE WHEN @CHK_DM != '' AND @CHK_DM IS NOT NULL THEN @CHK_DM ELSE NULL END
            ,   CASE WHEN @WEDD_PGUBUN != '' AND @WEDD_PGUBUN IS NOT NULL THEN @WEDD_PGUBUN ELSE NULL END
            ,   'Y'
			,	GETDATE()
            ,   GETDATE()
            ,   GETDATE()
			,	'Y'

			,	@ORI_BIRTH
			,   @GENDER       
			,	@NATIONAL_INFO

			,	@PASSWORD
            ,   CASE WHEN @CHK_MYOMEE   =   'Y' THEN    'Y' ELSE    'N' END
            ,   CASE WHEN @CHK_MYOMEE   =   'Y' THEN    @MYOMEE_REG_DATE ELSE  NULL END

            ,   CASE WHEN @CHK_ILOOMMBERSHIP        = 'Y'     THEN 'Y'					ELSE 'N'       END
            ,   CASE WHEN @CHK_ILOOMMBERSHIP   =   'Y' THEN    @ILOOMMEMBERSHIP_REG_DATE ELSE  NULL END
            ,	CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN 'Y' ELSE 'N' END
            ,	CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN @LGMEMBERSHIP_REG_DATE ELSE NULL END

    END
    
    
    -- 전환가입시 삼성동의 체크 신규 추가 2021-02-02
    IF EXISTS(SELECT TOP 1 * FROM S2_USERINFO_BHANDS WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SA' , 'B', 'C' ) AND (CHK_SMEMBERSHIP IS NULL OR SMEMBERSHIP_CHK_FLAG IS NULL)) AND @CHK_SMEMBERSHIP = 'Y'
    BEGIN
	    UPDATE S2_USERINFO_BHANDS
	    	SET
	    		CHK_SMEMBERSHIP				= CASE WHEN @CHK_SMEMBERSHIP        = 'Y'   THEN 'Y'						ELSE 'N'        END
	    		, SMEMBERSHIP_CHK_FLAG 		= CASE WHEN @CHK_SMEMBERSHIP        = 'Y'   THEN 'Y'						ELSE 'N'        END
                , SMEMBERSHIP_REG_DATE 		= CASE WHEN @CHK_SMEMBERSHIP      	= 'Y'   THEN @SMEMBERSHI_REG_DATE	ELSE NULL       END 
                , SMEMBERSHIP_INFLOW_ROUTE 	= CASE WHEN @CHK_SMEMBERSHIP  		= 'Y'   THEN 'JOIN'					ELSE NULL       END
                , CHK_SMEMBERSHIP_PER 		= CASE WHEN @CHK_SMEMBERSHIP_PER   	= 'Y'   THEN 'Y'					ELSE 'N'        END
                , CHK_SMEMBERSHIP_COOP 		= CASE WHEN @CHK_SMEMBERSHIP_COOP 	= 'Y'   THEN 'Y'					ELSE 'N'        END
            WHERE
            	DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SA' , 'B', 'C' )
    END    
    
    -- 전환가입시 LG동의 체크 신규 추가 2021-02-02
    IF EXISTS(SELECT TOP 1 * FROM S2_USERINFO_BHANDS WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SA' , 'B', 'C' ) AND CHK_LGMEMBERSHIP IS NULL) AND @CHK_LGMEMBERSHIP = 'Y'
    BEGIN
	    UPDATE S2_USERINFO_BHANDS
	    	SET 
	    		CHK_LGMEMBERSHIP		= CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN 'Y' ELSE 'N' END
            	, LGMEMBERSHIP_REG_DATE	= CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN @LGMEMBERSHIP_REG_DATE ELSE NULL END
            WHERE
            	DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SA' , 'B', 'C' )
    END 
    
    -- 전환가입시 마케팅활용동의 신규 추가 2021-02-02
    IF EXISTS(SELECT TOP 1 * FROM S2_USERINFO_BHANDS WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SA' , 'B', 'C' ) AND MKT_CHK_FLAG IS NULL) AND @MKT_CHK_FLAG = 'Y'
    BEGIN
	    UPDATE S2_USERINFO_BHANDS
	    	SET 
	    		MKT_CHK_FLAG	= CASE WHEN @MKT_CHK_FLAG = 'Y' THEN 'Y' ELSE 'N'   END
	    	WHERE
	    		DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SA' , 'B', 'C' )
	END
    



    /* 더카드 묘미추가*/
    IF NOT EXISTS(SELECT TOP 1 * FROM S2_USERINFO_THECARD WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'ST' ))
    BEGIN
        
        INSERT INTO S2_USERINFO_THECARD (
                DUPINFO
            ,   CONNINFO
			,	AUTHTYPE
            ,   UID
            ,   PWD
            ,   UNAME                     
            ,   UMAIL  
            ,   SITE_DIV
            ,   JUMIN                 
            ,   BIRTH                   
            ,   BIRTH_DIV               
            ,   ZIP1                    
            ,   ZIP2                    
            ,   ADDRESS                 
            ,   ADDR_DETAIL             
            ,   PHONE1                  
            ,   PHONE2                  
            ,   PHONE3                  
            ,   HAND_PHONE1             
            ,   HAND_PHONE2             
            ,   HAND_PHONE3             
            ,   CHK_SMS                 
            ,   CHK_MAILSERVICE         
            ,   ADDR_FLAG               
            ,   CHK_SMEMBERSHIP         
            ,   SMEMBERSHIP_CHK_FLAG    
            ,   SMEMBERSHIP_REG_DATE    
            ,   SMEMBERSHIP_INFLOW_ROUTE
            ,   CHK_SMEMBERSHIP_PER     
            ,   CHK_SMEMBERSHIP_COOP    
            ,   MKT_CHK_FLAG   
            ,   WEDD_YEAR
            ,   WEDD_MONTH
            ,   WEDD_DAY
            ,   WEDD_HOUR
            ,   WEDD_MINUTE
            ,   UGUBUN
            ,   CHK_DM
            ,   WEDD_PGUBUN
            ,   INTEGRATION_MEMBER_YORN     
			,	INTERGRATION_DATE        
            ,   MOD_DATE 
            ,   REG_DATE
			,	USE_YORN         
			
			,	BIRTHDATE
			,	GENDER
			,	NATIONALINFO

			,	PWD_BACKUP
			,	CHK_MYOMEE
            ,   MYOMEE_REG_DATE

            ,   CHK_ILOOMMEMBERSHIP         
            ,   ILOOMMEMBERSHIP_REG_DATE    
            
            ,	CHK_LGMEMBERSHIP
            ,	LGMEMBERSHIP_REG_DATE
        )



        SELECT  
                @AUTHCODE
            ,   @CONNINFO
			,	@AUTHTYPE
            ,   @USER_ID
            ,   @PASSWORD_ENCRYPT
            ,   @USER_NAME
            ,   @EMAIL
            ,   'ST'
            ,   ''
            ,   @BIRTH
            ,   @BIRTH_DIV
            ,   @ZIP1
            ,   @ZIP2
            ,   @ADDRESS
            ,   @ADDRESS_DETAIL
            ,   @PHONE1
            ,   @PHONE2
            ,   @PHONE3
            ,   @HPHONE1
            ,   @HPHONE2
            ,   @HPHONE3
            ,   @CHK_SMS
            ,   @CHK_MAILSERVICE
            ,   @ADDR_FLAG
            ,   CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'Y'					ELSE 'N'        END
            ,   CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'Y'					ELSE 'N'        END
            ,   CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN @SMEMBERSHI_REG_DATE	ELSE NULL       END 
            ,   CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'JOIN'					ELSE NULL       END
            ,   CASE WHEN @CHK_SMEMBERSHIP_PER    = 'Y'     THEN 'Y'					ELSE 'N'        END
            ,   CASE WHEN @CHK_SMEMBERSHIP_COOP   = 'Y'     THEN 'Y'					ELSE 'N'        END
            ,   CASE WHEN @MKT_CHK_FLAG           = 'Y'     THEN 'Y'					ELSE 'N'        END       
            ,   @WEDD_YEAR
            ,   @WEDD_MONTH
            ,   @WEDD_DAY
            ,   @WEDD_HOUR
            ,   @WEDD_MINUTE
            ,   CASE WHEN @UGUBUN != '' AND @UGUBUN IS NOT NULL THEN @UGUBUN ELSE NULL END
            ,   CASE WHEN @CHK_DM != '' AND @CHK_DM IS NOT NULL THEN @CHK_DM ELSE NULL END
            ,   CASE WHEN @WEDD_PGUBUN != '' AND @WEDD_PGUBUN IS NOT NULL THEN @WEDD_PGUBUN ELSE NULL END            
            ,   'Y'
			,   GETDATE()
            ,   GETDATE()
            ,   GETDATE()
			,	'Y'

			,	@ORI_BIRTH
			,   @GENDER       
			,	@NATIONAL_INFO

			,	@PASSWORD

            ,   CASE WHEN @CHK_MYOMEE   =   'Y' THEN    'Y' ELSE    'N' END
            ,   CASE WHEN @CHK_MYOMEE   =   'Y' THEN    @MYOMEE_REG_DATE ELSE  NULL END

            ,   CASE WHEN @CHK_ILOOMMBERSHIP        = 'Y'     THEN 'Y'					ELSE 'N'       END
            ,   CASE WHEN @CHK_ILOOMMBERSHIP   =   'Y' THEN    @ILOOMMEMBERSHIP_REG_DATE ELSE  NULL END
            
            ,	CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN 'Y' ELSE 'N' END
            ,	CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN @LGMEMBERSHIP_REG_DATE ELSE NULL END

    END
    
    -- 전환가입시 삼성동의 체크 신규 추가 2021-02-02
    IF EXISTS(SELECT TOP 1 * FROM S2_USERINFO_THECARD WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'ST' ) AND (CHK_SMEMBERSHIP IS NULL OR SMEMBERSHIP_CHK_FLAG IS NULL)) AND @CHK_SMEMBERSHIP = 'Y'
    BEGIN
	    UPDATE S2_USERINFO_THECARD
	    	SET
	    		CHK_SMEMBERSHIP				= CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'Y'						ELSE 'N'        END
	    		, SMEMBERSHIP_CHK_FLAG 		= CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'Y'						ELSE 'N'        END
                , SMEMBERSHIP_REG_DATE 		= CASE WHEN @CHK_SMEMBERSHIP      	= 'Y'     THEN @SMEMBERSHI_REG_DATE		ELSE NULL       END 
                , SMEMBERSHIP_INFLOW_ROUTE 	= CASE WHEN @CHK_SMEMBERSHIP  		= 'Y'     THEN 'JOIN'					ELSE NULL       END
                , CHK_SMEMBERSHIP_PER 		= CASE WHEN @CHK_SMEMBERSHIP_PER   	= 'Y'     THEN 'Y'						ELSE 'N'        END
                , CHK_SMEMBERSHIP_COOP 		= CASE WHEN @CHK_SMEMBERSHIP_COOP 	= 'Y'     THEN 'Y'						ELSE 'N'  END
            WHERE
            	DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'ST' )
    END
    
    -- 전환가입시 LG동의 체크 신규 추가 2021-02-02
    IF EXISTS(SELECT TOP 1 * FROM S2_USERINFO_THECARD WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'ST' ) AND CHK_LGMEMBERSHIP IS NULL) AND @CHK_LGMEMBERSHIP = 'Y'
    BEGIN
	    UPDATE S2_USERINFO_THECARD
	    	SET 
	    		CHK_LGMEMBERSHIP		= CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN 'Y' ELSE 'N' END
            	, LGMEMBERSHIP_REG_DATE	= CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN @LGMEMBERSHIP_REG_DATE ELSE NULL END
            WHERE
            	DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'ST' )
    END 
    
    -- 전환가입시 마케팅활용동의 신규 추가 2021-02-02
    IF EXISTS(SELECT TOP 1 * FROM S2_USERINFO_THECARD WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'ST' ) AND MKT_CHK_FLAG IS NULL) AND @MKT_CHK_FLAG = 'Y'
    BEGIN
	    UPDATE S2_USERINFO_THECARD
	    	SET 
	    		MKT_CHK_FLAG	= CASE WHEN @MKT_CHK_FLAG = 'Y' THEN 'Y' ELSE 'N'   END
	    	WHERE
	    		DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'ST' )
	END
    
	
    /* 바른손카드 묘미추가*/
    IF NOT EXISTS(SELECT TOP 1 * FROM S2_USERINFO WHERE DUPINFO = @AUTHCODE AND SITE_DIV = 'SB')
    BEGIN
        
        INSERT INTO S2_USERINFO (
                DUPINFO
            ,   CONNINFO
			,	AUTHTYPE
            ,   UID
            ,   PWD
            ,   UNAME                     
            ,   UMAIL  
            ,   SITE_DIV 
            ,   JUMIN                
            ,   BIRTH                   
            ,   BIRTH_DIV               
            ,   ZIP1                    
            ,   ZIP2                    
            ,   ADDRESS                 
            ,   ADDR_DETAIL             
            ,   PHONE1                  
            ,   PHONE2                  
            ,   PHONE3                  
            ,   HAND_PHONE1             
            ,   HAND_PHONE2             
            ,   HAND_PHONE3             
            ,   CHK_SMS                 
            ,   CHK_MAILSERVICE         
            ,   ADDR_FLAG               
            ,   CHK_SMEMBERSHIP         
            ,   SMEMBERSHIP_CHK_FLAG    
            ,   SMEMBERSHIP_REG_DATE    
            ,   SMEMBERSHIP_INFLOW_ROUTE
            ,   CHK_SMEMBERSHIP_PER     
            ,   CHK_SMEMBERSHIP_COOP    
            ,   MKT_CHK_FLAG     
            ,   WEDD_YEAR
            ,   WEDD_MONTH
            ,   WEDD_DAY
            ,   WEDD_HOUR
            ,   WEDD_MINUTE
            ,   UGUBUN
            ,   CHK_DM
            ,   WEDD_PGUBUN                   
            ,   INTEGRATION_MEMBER_YORN    
			,	INTERGRATION_DATE
            ,   MOD_DATE 
            ,   REG_DATE
			,	USE_YORN      
			
			,	BIRTHDATE
			,	GENDER
			,	NATIONALINFO  
			
			,	PWD_BACKUP        
			,	CHK_MYOMEE
            ,   MYOMEE_REG_DATE

            ,   CHK_ILOOMMEMBERSHIP         
            ,   ILOOMMEMBERSHIP_REG_DATE    
            
            ,	CHK_LGMEMBERSHIP
            ,	LGMEMBERSHIP_REG_DATE
        )



        SELECT  
                @AUTHCODE
            ,   @CONNINFO
			,	@AUTHTYPE
            ,   @USER_ID
            ,   @PASSWORD_ENCRYPT
            ,   @USER_NAME
            ,   @EMAIL
            ,   'SB'
            ,   ''
            ,   @BIRTH
            ,   @BIRTH_DIV
            ,   @ZIP1
            ,   @ZIP2
            ,   @ADDRESS
            ,   @ADDRESS_DETAIL
            ,   @PHONE1
            ,   @PHONE2
            ,   @PHONE3
            ,   @HPHONE1
            ,   @HPHONE2
            ,   @HPHONE3
            ,   @CHK_SMS
            ,   @CHK_MAILSERVICE
            ,   @ADDR_FLAG
            ,   CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'Y'					ELSE 'N'        END
            ,   CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'Y'					ELSE 'N'        END
            ,   CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN @SMEMBERSHI_REG_DATE	ELSE NULL       END 
            ,   CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'JOIN'					ELSE NULL       END
            ,   CASE WHEN @CHK_SMEMBERSHIP_PER    = 'Y'     THEN 'Y'					ELSE 'N'        END
            ,   CASE WHEN @CHK_SMEMBERSHIP_COOP   = 'Y'     THEN 'Y'					ELSE 'N'        END
            ,   CASE WHEN @MKT_CHK_FLAG           = 'Y'     THEN 'Y'					ELSE 'N'        END       
            ,   @WEDD_YEAR
            ,   @WEDD_MONTH
            ,   @WEDD_DAY
            ,   @WEDD_HOUR
            ,   @WEDD_MINUTE
            ,   CASE WHEN @UGUBUN != '' AND @UGUBUN IS NOT NULL THEN @UGUBUN ELSE NULL END
            ,   CASE WHEN @CHK_DM != '' AND @CHK_DM IS NOT NULL THEN @CHK_DM ELSE NULL END
            ,   CASE WHEN @WEDD_PGUBUN != '' AND @WEDD_PGUBUN IS NOT NULL THEN @WEDD_PGUBUN ELSE NULL END            
            ,   'Y'
			,   GETDATE()
            ,   GETDATE()
            ,   GETDATE()
			,	'Y'

			,	@ORI_BIRTH
			,   @GENDER       
			,	@NATIONAL_INFO

			,	@PASSWORD

            ,   CASE WHEN @CHK_MYOMEE   =   'Y' THEN    'Y' ELSE    'N' END
            ,   CASE WHEN @CHK_MYOMEE   =   'Y' THEN    @MYOMEE_REG_DATE ELSE  NULL END

            ,   CASE WHEN @CHK_ILOOMMBERSHIP        = 'Y'     THEN 'Y'					ELSE 'N'       END
            ,   CASE WHEN @CHK_ILOOMMBERSHIP   =   'Y' THEN    @ILOOMMEMBERSHIP_REG_DATE ELSE  NULL END
            
            ,	CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN 'Y' ELSE 'N' END
            ,	CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN @LGMEMBERSHIP_REG_DATE ELSE NULL END
    END
    
    -- 전환가입시 삼성동의 체크 신규 추가 2021-02-02
    IF EXISTS(SELECT TOP 1 * FROM S2_USERINFO WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SB' ) AND (CHK_SMEMBERSHIP IS NULL OR SMEMBERSHIP_CHK_FLAG IS NULL)) AND @CHK_SMEMBERSHIP = 'Y'
    BEGIN
	    UPDATE S2_USERINFO
	    	SET
	    		CHK_SMEMBERSHIP				= CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'Y'						ELSE 'N'        END
	    		, SMEMBERSHIP_CHK_FLAG 		= CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'Y'						ELSE 'N'        END
                , SMEMBERSHIP_REG_DATE 		= CASE WHEN @CHK_SMEMBERSHIP      	= 'Y'     THEN @SMEMBERSHI_REG_DATE		ELSE NULL       END 
                , SMEMBERSHIP_INFLOW_ROUTE 	= CASE WHEN @CHK_SMEMBERSHIP  		= 'Y'     THEN 'JOIN'					ELSE NULL       END
                , CHK_SMEMBERSHIP_PER 		= CASE WHEN @CHK_SMEMBERSHIP_PER   	= 'Y'     THEN 'Y'						ELSE 'N'        END
                , CHK_SMEMBERSHIP_COOP 		= CASE WHEN @CHK_SMEMBERSHIP_COOP 	= 'Y'     THEN 'Y'						ELSE 'N'        END
            WHERE
            	DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SB' )
    END
    
    -- 전환가입시 LG동의 체크 신규 추가 2021-02-02
    IF EXISTS(SELECT TOP 1 * FROM S2_USERINFO WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SB' ) AND CHK_LGMEMBERSHIP IS NULL) AND @CHK_LGMEMBERSHIP = 'Y'
    BEGIN
	    UPDATE S2_USERINFO
	    	SET 
	    		CHK_LGMEMBERSHIP		= CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN 'Y' ELSE 'N' END
            	, LGMEMBERSHIP_REG_DATE	= CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN @LGMEMBERSHIP_REG_DATE ELSE NULL END
            WHERE
            	DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SB' )
    END 
    
    -- 전환가입시 마케팅활용동의 신규 추가 2021-02-02
    IF EXISTS(SELECT TOP 1 * FROM S2_USERINFO WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SB' ) AND MKT_CHK_FLAG IS NULL) AND @MKT_CHK_FLAG = 'Y'
    BEGIN
	    UPDATE S2_USERINFO
	    	SET 
	    		MKT_CHK_FLAG	= CASE WHEN @MKT_CHK_FLAG = 'Y' THEN 'Y' ELSE 'N'   END
	    	WHERE
	    		DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SB' )
	END
    
    

    /* 프리미어페이퍼 묘미추가*/
    IF NOT EXISTS(SELECT TOP 1 * FROM S2_USERINFO WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SS' , 'H' ))
    BEGIN
        
        INSERT INTO S2_USERINFO (
                DUPINFO
            ,   CONNINFO
			,	AUTHTYPE
            ,   UID
            ,   PWD
            ,   UNAME                     
            ,   UMAIL  
  ,   SITE_DIV
            ,   JUMIN                 
            ,   BIRTH                   
            ,   BIRTH_DIV               
            ,   ZIP1                    
            ,   ZIP2                    
            ,   ADDRESS                 
            ,   ADDR_DETAIL             
            ,   PHONE1                  
            ,   PHONE2                  
            ,   PHONE3                  
            ,   HAND_PHONE1             
            ,   HAND_PHONE2             
            ,   HAND_PHONE3             
            ,   CHK_SMS                 
            ,   CHK_MAILSERVICE         
            ,   ADDR_FLAG               
            ,   CHK_SMEMBERSHIP         
            ,   SMEMBERSHIP_CHK_FLAG    
            ,   SMEMBERSHIP_REG_DATE    
            ,   SMEMBERSHIP_INFLOW_ROUTE
            ,   CHK_SMEMBERSHIP_PER     
            ,   CHK_SMEMBERSHIP_COOP    
            ,   MKT_CHK_FLAG   
            ,   WEDD_YEAR
            ,   WEDD_MONTH
            ,   WEDD_DAY
            ,   WEDD_HOUR
            ,   WEDD_MINUTE
            ,   UGUBUN
            ,   CHK_DM
            ,   WEDD_PGUBUN                  
            ,   INTEGRATION_MEMBER_YORN       
			,	INTERGRATION_DATE
            ,   MOD_DATE 
            ,   REG_DATE
			,	USE_YORN          
			
			,	BIRTHDATE
			,	GENDER
			,	NATIONALINFO   
			
			,	PWD_BACKUP  
			,	CHK_MYOMEE
            ,   MYOMEE_REG_DATE

            ,   CHK_ILOOMMEMBERSHIP         
            ,   ILOOMMEMBERSHIP_REG_DATE    
            
            ,	CHK_LGMEMBERSHIP
            ,	LGMEMBERSHIP_REG_DATE
        )



        SELECT  
                @AUTHCODE
            ,   @CONNINFO
			,	@AUTHTYPE
            ,   @USER_ID
            ,   @PASSWORD_ENCRYPT
            ,   @USER_NAME
            ,   @EMAIL
            ,   'SS'
            ,   ''
            ,   @BIRTH
            ,   @BIRTH_DIV
            ,   @ZIP1
            ,   @ZIP2
            ,   @ADDRESS
            ,   @ADDRESS_DETAIL
            ,   @PHONE1
            ,   @PHONE2
            ,   @PHONE3
            ,   @HPHONE1
            ,   @HPHONE2
            ,   @HPHONE3
            ,   @CHK_SMS
            ,   @CHK_MAILSERVICE
            ,   @ADDR_FLAG
            ,   CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'Y'					ELSE 'N'        END
            ,   CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'Y'					ELSE 'N'        END
            ,   CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN @SMEMBERSHI_REG_DATE	ELSE NULL       END 
            ,   CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'JOIN'					ELSE NULL       END
            ,   CASE WHEN @CHK_SMEMBERSHIP_PER    = 'Y'     THEN 'Y'					ELSE 'N'        END
            ,   CASE WHEN @CHK_SMEMBERSHIP_COOP   = 'Y'     THEN 'Y'					ELSE 'N'        END
            ,   CASE WHEN @MKT_CHK_FLAG           = 'Y'     THEN 'Y'					ELSE 'N'        END       
            ,   @WEDD_YEAR
            ,   @WEDD_MONTH
            ,   @WEDD_DAY
            ,   @WEDD_HOUR
            ,   @WEDD_MINUTE
            ,   CASE WHEN @UGUBUN != '' AND @UGUBUN IS NOT NULL THEN @UGUBUN ELSE NULL END
            ,   CASE WHEN @CHK_DM != '' AND @CHK_DM IS NOT NULL THEN @CHK_DM ELSE NULL END
            ,   CASE WHEN @WEDD_PGUBUN != '' AND @WEDD_PGUBUN IS NOT NULL THEN @WEDD_PGUBUN ELSE NULL END            
            ,   'Y'
			,   GETDATE()
            ,   GETDATE()
            ,   GETDATE()
			,	'Y'

			,	@ORI_BIRTH
			,   @GENDER       
			,	@NATIONAL_INFO

			,	@PASSWORD

            ,   CASE WHEN @CHK_MYOMEE   =   'Y' THEN    'Y' ELSE    'N' END
            ,   CASE WHEN @CHK_MYOMEE   =   'Y' THEN    @MYOMEE_REG_DATE ELSE  NULL END

            ,   CASE WHEN @CHK_ILOOMMBERSHIP        = 'Y'     THEN 'Y'					ELSE 'N'       END
            ,   CASE WHEN @CHK_ILOOMMBERSHIP   =   'Y' THEN    @ILOOMMEMBERSHIP_REG_DATE ELSE  NULL END
           
            ,	CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN 'Y' ELSE 'N' END
            ,	CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN @LGMEMBERSHIP_REG_DATE ELSE NULL END

    END

    -- 전환가입시 삼성동의 체크 신규 추가 2021-02-02
    IF EXISTS(SELECT TOP 1 * FROM S2_USERINFO WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SS' , 'H' ) AND (CHK_SMEMBERSHIP IS NULL OR SMEMBERSHIP_CHK_FLAG IS NULL)) AND @CHK_SMEMBERSHIP = 'Y'
    BEGIN
	    UPDATE S2_USERINFO
	    	SET
	    		CHK_SMEMBERSHIP				= CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'Y'						ELSE 'N'        END
	    		, SMEMBERSHIP_CHK_FLAG 		= CASE WHEN @CHK_SMEMBERSHIP        = 'Y'     THEN 'Y'						ELSE 'N'        END
                , SMEMBERSHIP_REG_DATE 		= CASE WHEN @CHK_SMEMBERSHIP      	= 'Y'     THEN @SMEMBERSHI_REG_DATE		ELSE NULL       END 
                , SMEMBERSHIP_INFLOW_ROUTE 	= CASE WHEN @CHK_SMEMBERSHIP  		= 'Y'     THEN 'JOIN'					ELSE NULL       END
                , CHK_SMEMBERSHIP_PER 		= CASE WHEN @CHK_SMEMBERSHIP_PER   	= 'Y'     THEN 'Y'						ELSE 'N'        END
                , CHK_SMEMBERSHIP_COOP 		= CASE WHEN @CHK_SMEMBERSHIP_COOP 	= 'Y'     THEN 'Y'						ELSE 'N'        END
            WHERE
            	DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SS' , 'H' )
    END

    -- 전환가입시 LG동의 체크 신규 추가 2021-02-02
    IF EXISTS(SELECT TOP 1 * FROM S2_USERINFO WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SS' , 'H' ) AND CHK_LGMEMBERSHIP IS NULL) AND @CHK_LGMEMBERSHIP = 'Y'
    BEGIN
	    UPDATE S2_USERINFO
	    	SET 
	    		CHK_LGMEMBERSHIP		= CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN 'Y' ELSE 'N' END
            	, LGMEMBERSHIP_REG_DATE	= CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN @LGMEMBERSHIP_REG_DATE ELSE NULL END
            WHERE
            	DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SS' , 'H' )
    END 
    
    -- 전환가입시 마케팅활용동의 신규 추가 2021-02-02
    IF EXISTS(SELECT TOP 1 * FROM S2_USERINFO WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SS' , 'H' ) AND MKT_CHK_FLAG IS NULL) AND @MKT_CHK_FLAG = 'Y'
    BEGIN
	    UPDATE S2_USERINFO
	    	SET 
	    		MKT_CHK_FLAG	= CASE WHEN @MKT_CHK_FLAG = 'Y' THEN 'Y' ELSE 'N'   END
	    	WHERE
	    		DUPINFO = @AUTHCODE AND SITE_DIV IN ( 'SS' , 'H' )
	END


	--20210420 표수현 -바른손카드모바일 추가--
	IF NOT EXISTS(SELECT TOP 1 * FROM S2_USERINFO WHERE DUPINFO = @AUTHCODE AND SITE_DIV = 'BM') BEGIN 
		
		INSERT INTO S2_USERINFO ( DUPINFO, CONNINFO, AUTHTYPE, UID, PWD, UNAME, UMAIL, SITE_DIV, JUMIN, BIRTH, 
								  BIRTH_DIV, ZIP1, ZIP2, ADDRESS, ADDR_DETAIL, PHONE1, PHONE2, PHONE3, HAND_PHONE1, HAND_PHONE2, 
								  HAND_PHONE3, CHK_SMS, CHK_MAILSERVICE, ADDR_FLAG, CHK_SMEMBERSHIP, SMEMBERSHIP_CHK_FLAG, SMEMBERSHIP_REG_DATE, 
								  SMEMBERSHIP_INFLOW_ROUTE, CHK_SMEMBERSHIP_PER, CHK_SMEMBERSHIP_COOP, MKT_CHK_FLAG, WEDD_YEAR, WEDD_MONTH, 
								  WEDD_DAY, WEDD_HOUR, WEDD_MINUTE, UGUBUN, CHK_DM, WEDD_PGUBUN, INTEGRATION_MEMBER_YORN, INTERGRATION_DATE, 
								  MOD_DATE, REG_DATE, USE_YORN,	BIRTHDATE, GENDER, NATIONALINFO, PWD_BACKUP, CHK_MYOMEE, MYOMEE_REG_DATE, CHK_ILOOMMEMBERSHIP,
								  ILOOMMEMBERSHIP_REG_DATE, CHK_LGMEMBERSHIP, LGMEMBERSHIP_REG_DATE
								 )

        SELECT  @AUTHCODE, @CONNINFO, @AUTHTYPE, @USER_ID, @PASSWORD_ENCRYPT, @USER_NAME, @EMAIL, 'BM', '', @BIRTH, 
				@BIRTH_DIV, @ZIP1, @ZIP2, @ADDRESS, @ADDRESS_DETAIL, @PHONE1, @PHONE2, @PHONE3, @HPHONE1, @HPHONE2, @HPHONE3, 
				@CHK_SMS, @CHK_MAILSERVICE, @ADDR_FLAG, 
				CASE WHEN @CHK_SMEMBERSHIP = 'Y' THEN 'Y' ELSE 'N' END,   
				CASE WHEN @CHK_SMEMBERSHIP = 'Y' THEN 'Y' ELSE 'N' END,   
				CASE WHEN @CHK_SMEMBERSHIP = 'Y' THEN @SMEMBERSHI_REG_DATE	ELSE NULL END,   
				CASE WHEN @CHK_SMEMBERSHIP = 'Y' THEN 'JOIN' ELSE NULL END,
				CASE WHEN @CHK_SMEMBERSHIP_PER = 'Y' THEN 'Y' ELSE 'N' END,
				CASE WHEN @CHK_SMEMBERSHIP_COOP = 'Y' THEN 'Y' ELSE 'N' END,
				CASE WHEN @MKT_CHK_FLAG = 'Y' THEN 'Y' ELSE 'N' END,
				@WEDD_YEAR, @WEDD_MONTH, @WEDD_DAY, @WEDD_HOUR, @WEDD_MINUTE, 
				CASE WHEN @UGUBUN != '' AND @UGUBUN IS NOT NULL THEN @UGUBUN ELSE NULL END, 
				CASE WHEN @CHK_DM != '' AND @CHK_DM IS NOT NULL THEN @CHK_DM ELSE NULL END, 
				CASE WHEN @WEDD_PGUBUN != '' AND @WEDD_PGUBUN IS NOT NULL THEN @WEDD_PGUBUN ELSE NULL END, 'Y',   
				GETDATE(), GETDATE(), GETDATE(), 'Y', @ORI_BIRTH, @GENDER, @NATIONAL_INFO, @PASSWORD, 
				CASE WHEN @CHK_MYOMEE = 'Y' THEN 'Y' ELSE 'N' END,   
				CASE WHEN @CHK_MYOMEE = 'Y' THEN @MYOMEE_REG_DATE ELSE  NULL END,   
				CASE WHEN @CHK_ILOOMMBERSHIP = 'Y' THEN 'Y' ELSE 'N' END,   
				CASE WHEN @CHK_ILOOMMBERSHIP = 'Y' THEN @ILOOMMEMBERSHIP_REG_DATE ELSE NULL END,	
				CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN 'Y' ELSE 'N' END,	
				CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN @LGMEMBERSHIP_REG_DATE ELSE NULL END

	END

	  -- 전환가입시 삼성동의 체크 신규 추가 2021-02-02
    IF EXISTS(
				SELECT TOP 1 * FROM S2_USERINFO 
				WHERE	DUPINFO = @AUTHCODE AND 
						SITE_DIV IN ('BM') AND 
						(CHK_SMEMBERSHIP IS NULL OR SMEMBERSHIP_CHK_FLAG IS NULL)) AND 
				@CHK_SMEMBERSHIP = 'Y' BEGIN

						UPDATE S2_USERINFO
	    				SET CHK_SMEMBERSHIP = CASE WHEN @CHK_SMEMBERSHIP = 'Y' THEN 'Y' ELSE 'N' END, 
							SMEMBERSHIP_CHK_FLAG = CASE WHEN @CHK_SMEMBERSHIP = 'Y' THEN 'Y' ELSE 'N' END, 
							SMEMBERSHIP_REG_DATE = CASE WHEN @CHK_SMEMBERSHIP = 'Y' THEN @SMEMBERSHI_REG_DATE ELSE NULL END, 
							SMEMBERSHIP_INFLOW_ROUTE = CASE WHEN @CHK_SMEMBERSHIP = 'Y' THEN 'JOIN' ELSE NULL END, 
							CHK_SMEMBERSHIP_PER = CASE WHEN @CHK_SMEMBERSHIP_PER = 'Y' THEN 'Y' ELSE 'N' END, 
							CHK_SMEMBERSHIP_COOP = CASE WHEN @CHK_SMEMBERSHIP_COOP 	= 'Y' THEN 'Y' ELSE 'N' END
						WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ('BM')
				END
    
				-- 전환가입시 LG동의 체크 신규 추가 2021-02-02
				IF EXISTS(SELECT TOP 1 * FROM S2_USERINFO WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ('BM') AND CHK_LGMEMBERSHIP IS NULL) AND @CHK_LGMEMBERSHIP = 'Y' BEGIN
					UPDATE S2_USERINFO
					SET CHK_LGMEMBERSHIP = CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN 'Y' ELSE 'N' END, 
						LGMEMBERSHIP_REG_DATE = CASE WHEN @CHK_LGMEMBERSHIP = 'Y' THEN @LGMEMBERSHIP_REG_DATE ELSE NULL END
					WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ('BM')
				END 
    
				-- 전환가입시 마케팅활용동의 신규 추가 2021-02-02
				IF EXISTS(SELECT TOP 1 * FROM S2_USERINFO WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ('BM') AND MKT_CHK_FLAG IS NULL) AND @MKT_CHK_FLAG = 'Y' BEGIN
					UPDATE S2_USERINFO
					SET MKT_CHK_FLAG	= CASE WHEN @MKT_CHK_FLAG = 'Y' THEN 'Y' ELSE 'N' END
					WHERE DUPINFO = @AUTHCODE AND SITE_DIV IN ('BM')
				END
    
	
				/* 제3자 마케팅 활용 동의 */
				IF @MKT_CHK_FLAG = 'Y' BEGIN
        
					IF NOT EXISTS( SELECT * FROM S4_EVENT_RAINA WHERE UID = @USER_ID AND COMPANY_SEQ = @COMPANY_SEQ ) BEGIN
            
						INSERT S4_EVENT_RAINA (UID,COMPANY_SEQ,EVENT_DIV, INFLOW_ROUTE) 
						VALUES (@USER_ID, @COMPANY_SEQ, 'MKEVENT', 'MODIFY')

					END

    END ELSE IF @MKT_CHK_FLAG = 'N' BEGIN
        
        IF EXISTS( SELECT * FROM S4_EVENT_RAINA WHERE UID = @USER_ID AND COMPANY_SEQ = @COMPANY_SEQ ) BEGIN

            DELETE  S4_EVENT_RAINA
            WHERE   UID = @USER_ID
            AND     COMPANY_SEQ = @COMPANY_SEQ

        END

    END



END

GO
