IF OBJECT_ID (N'dbo.UP_USERINFO_GET', N'P') IS NOT NULL DROP PROCEDURE dbo.UP_USERINFO_GET
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*********************************************************
-- SP Name       : UP_USERINFO_GET
-- Author        : 변미정
-- Create date   : 2023-03-09
-- Description   : 회원 정보 조회
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[UP_USERINFO_GET]	
	 @UId	            VARCHAR(20)
    ,@SiteDiv	        VARCHAR(2) = NULL

    ,@ErrNum            INT             OUTPUT
    ,@ErrSev            INT             OUTPUT
    ,@ErrState          INT             OUTPUT
    ,@ErrProc           VARCHAR(50)     OUTPUT
    ,@ErrLine           INT             OUTPUT
    ,@ErrMsg            VARCHAR(2000)   OUTPUT
AS
SET NOCOUNT ON

BEGIN
    BEGIN TRY
        --절대 중간에 컬럼 추가하거나 빼지 말것 (추가시 맨 하위에 추가)
        IF EXISTS(SELECT [UID] 
                  FROM   S2_USERINFO_THECARD
                  WHERE  [UID]= @UId ) BEGIN

            SELECT   UID            
                    ,UNAME
                    ,UMAIL
                    ,JUMIN
                    ,BIRTH
                    ,BIRTH_DIV
                    ,ZIP1
                    ,ZIP2
                    ,ADDRESS
                    ,ADDR_DETAIL
                    ,PHONE1
                    ,PHONE2
                    ,PHONE3
                    ,HAND_PHONE1
                    ,HAND_PHONE2
                    ,HAND_PHONE3
                    ,CHK_MAIL_INPUT
                    ,CHK_SMS
                    ,CHK_MAILSERVICE
                    ,SITE_DIV
                    ,ISJEHU
                    ,COMPANY_SEQ
                    ,LOGIN_DATE
                    ,LOGIN_DATE_LASTEST
                    ,LOGIN_COUNT
                    ,IS_APPSAMPLE
                    ,REG_DATE
                    ,VAR1
                    ,SITE_DIV_LASTEST
                    ,REQUESTNUMBER
                    ,AUTHTYPE
                    ,DUPINFO
                    ,CONNINFO
                    ,GENDER
                    ,BIRTHDATE
                    ,NATIONALINFO
                    ,WEDD_YEAR
                    ,WEDD_MONTH
                    ,WEDD_DAY
                    ,NAME
                    ,ISMCARDABLE
                    ,UGUBUN
                    ,CHK_DM
                    ,WEDD_HOUR
                    ,WEDD_MINUTE
                    ,WEDD_PGUBUN
                    ,MOD_DATE
                    ,CHK_SMEMBERSHIP
                    ,ADDR_FLAG
                    ,SMEMBERSHIP_REG_DATE
                    ,SMEMBERSHIP_LEAVE_DATE
                    ,CHK_SMEMBERSHIP_LEAVE
                    ,CHK_SMEMBERSHIP_PER
                    ,CHK_SMEMBERSHIP_COOP
                    ,INFLOW_ROUTE
                    ,SMEMBERSHIP_INFLOW_ROUTE
                    ,SMEMBERSHIP_CHK_FLAG
                    ,MKT_CHK_FLAG
                    ,ZIP1_R
                    ,ZIP2_R
                    ,ADDRESS_R
                    ,ADDR_DETAIL_R
                    ,CHK_DORMANCYACCOUNT
                    ,INTEGRATION_MEMBER_YORN
                    ,INTERGRATION_DATE
                    ,INTERGRATION_BEFORE_ID
                    ,REFERER_SALES_GUBUN
                    ,SELECT_SALES_GUBUN
                    ,SELECT_USER_ID
                    ,USE_YORN                        
                    ,CHK_MYOMEE
                    ,MYOMEE_REG_DATE
                    ,ILOOMMEMBERSHIP_REG_DATE
                    ,CHK_ILOOMMEMBERSHIP
                    ,CHK_LGMEMBERSHIP
                    ,LGMEMBERSHIP_REG_DATE
                    ,LGMEMBERSHIP_LEAVE_DATE
                    ,CHK_CUCKOOSMEMBERSHIP
                    ,CUCKOOSSHIP_REG_DATE
                    ,CUCKOOSSHIP_LEAVE_DATE
                    ,CHK_CASAMIAMEMBERSHIP
                    ,CASAMIASHIP_REG_DATE
                    ,CASAMIASHIP_LEAVE_DATE
                    ,WEDD_NAME
                    ,SMEMBERSHIP_PERIOD
                    ,CHK_KTMEMBERSHIP
                    ,KTMEMBERSHIP_REG_DATE
                    ,KTMEMBERSHIP_LEAVE_DATE
                    ,CHK_HYUNDAIMEMBERSHIP
                    ,HYUNDAIMEMBERSHIP_REG_DATE
                    ,HYUNDAIMEMBERSHIP_LEAVE_DATE
            FROM S2_USERINFO_THECARD 
            WHERE [UID]= @UId 
        END
        ELSE BEGIN 
            SELECT   UID            
                    ,UNAME
                    ,UMAIL
                    ,JUMIN
                    ,BIRTH
                    ,BIRTH_DIV
                    ,ZIP1
                    ,ZIP2
                    ,ADDRESS
                    ,ADDR_DETAIL
                    ,PHONE1
                    ,PHONE2
                    ,PHONE3
                    ,HAND_PHONE1
                    ,HAND_PHONE2
                    ,HAND_PHONE3
                    ,CHK_MAIL_INPUT
                    ,CHK_SMS
                    ,CHK_MAILSERVICE
                    ,SITE_DIV
                    ,ISJEHU
                    ,COMPANY_SEQ
                    ,LOGIN_DATE
                    ,LOGIN_DATE_LASTEST
                    ,LOGIN_COUNT
                    ,IS_APPSAMPLE
                    ,REG_DATE
                    ,VAR1
                    ,SITE_DIV_LASTEST
                    ,REQUESTNUMBER
                    ,AUTHTYPE
                    ,DUPINFO
                    ,CONNINFO
                    ,GENDER
                    ,BIRTHDATE
                    ,NATIONALINFO
                    ,WEDD_YEAR
                    ,WEDD_MONTH
                    ,WEDD_DAY
                    ,NAME
                    ,ISMCARDABLE
                    ,UGUBUN
                    ,CHK_DM
                    ,WEDD_HOUR
                    ,WEDD_MINUTE
                    ,WEDD_PGUBUN
                    ,MOD_DATE
                    ,CHK_SMEMBERSHIP
                    ,ADDR_FLAG
                    ,SMEMBERSHIP_REG_DATE
                    ,SMEMBERSHIP_LEAVE_DATE
                    ,CHK_SMEMBERSHIP_LEAVE
                    ,CHK_SMEMBERSHIP_PER
                    ,CHK_SMEMBERSHIP_COOP
                    ,INFLOW_ROUTE
                    ,SMEMBERSHIP_INFLOW_ROUTE
                    ,SMEMBERSHIP_CHK_FLAG
                    ,MKT_CHK_FLAG
                    ,ZIP1_R
                    ,ZIP2_R
                    ,ADDRESS_R
                    ,ADDR_DETAIL_R
                    ,CHK_DORMANCYACCOUNT
                    ,INTEGRATION_MEMBER_YORN
                    ,INTERGRATION_DATE
                    ,INTERGRATION_BEFORE_ID
                    ,REFERER_SALES_GUBUN
                    ,SELECT_SALES_GUBUN
                    ,SELECT_USER_ID
                    ,USE_YORN                        
                    ,CHK_MYOMEE
                    ,MYOMEE_REG_DATE
                    ,ILOOMMEMBERSHIP_REG_DATE
                    ,CHK_ILOOMMEMBERSHIP
                    ,CHK_LGMEMBERSHIP
                    ,LGMEMBERSHIP_REG_DATE
                    ,LGMEMBERSHIP_LEAVE_DATE
                    ,CHK_CUCKOOSMEMBERSHIP
                    ,CUCKOOSSHIP_REG_DATE
                    ,CUCKOOSSHIP_LEAVE_DATE
                    ,CHK_CASAMIAMEMBERSHIP
                    ,CASAMIASHIP_REG_DATE
                    ,CASAMIASHIP_LEAVE_DATE
                    ,WEDD_NAME
                    ,SMEMBERSHIP_PERIOD
                    ,CHK_KTMEMBERSHIP
                    ,KTMEMBERSHIP_REG_DATE
                    ,KTMEMBERSHIP_LEAVE_DATE
                    ,CHK_HYUNDAIMEMBERSHIP
                    ,HYUNDAIMEMBERSHIP_REG_DATE
                    ,HYUNDAIMEMBERSHIP_LEAVE_DATE
            FROM S2_USERINFO
            WHERE [UID]= @UId 
            ANd   SITE_DIV = @SiteDiv
        END

    END TRY
    BEGIN CATCH
    
        SET @ErrNum   = ERROR_NUMBER()
        SET @ErrSev   = ERROR_SEVERITY()
        SET @ErrState = ERROR_STATE()
        SET @ErrProc  = ERROR_PROCEDURE()
        SET @ErrLine  = ERROR_LINE()
        SET @ErrMsg   = ERROR_MESSAGE()
        RETURN  
        
    END CATCH
END
GO
