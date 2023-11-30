USE [bar_shop1]
GO

/****** Object:  StoredProcedure [dbo].[UP_VW_USERINFO_GET]    Script Date: 2023-05-25 오전 10:12:45 ******/
DROP PROCEDURE [dbo].[UP_VW_USERINFO_GET]
GO

/****** Object:  StoredProcedure [dbo].[UP_VW_USERINFO_GET]    Script Date: 2023-05-25 오전 10:12:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : UP_VW_USERINFO_GET
-- Author        : 변미정
-- Create date   : 2023-05-17
-- Description   : 회원 정보 조회 (아이디/비번찾기용)
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[UP_VW_USERINFO_GET]	
	 @Uid               VARCHAR(50)     = NULL                    
    ,@DupInfo           CHAR(64)        = NULL         
    ,@SiteDiv	        VARCHAR(2)      = NULL

    ,@ErrNum            INT             OUTPUT
    ,@ErrSev            INT             OUTPUT
    ,@ErrState          INT             OUTPUT
    ,@ErrProc           VARCHAR(50)     OUTPUT
    ,@ErrLine           INT             OUTPUT
    ,@ErrMsg            VARCHAR(2000)   OUTPUT
AS
SET NOCOUNT ON

BEGIN
    -------------------------------------------------------
    -- 변수 정의
    -------------------------------------------------------
    DECLARE @Sql               NVARCHAR(MAX) = ''
    DECLARE @SqlWhere          NVARCHAR(MAX) = ''
    DECLARE @Param             NVARCHAR(MAX) = ''

    BEGIN TRY
        IF (ISNULL(@DupInfo,'')='' AND  ISNULL(@Uid,'')='') OR ISNULL(@SiteDiv,'')='' BEGIN
            SET @ErrNum = 2000
            SET @ErrMsg = '입력데이터가 잘못 되었습니다.'
            RETURN
        END

        -------------------------------------------------------
        -- 변수 및 조건문 정의
        -------------------------------------------------------
        IF ISNULL(@DupInfo,'') <> '' BEGIN
            SET @SqlWhere = @SqlWhere + N'
            AND     DUPINFO = @DupInfo '
        END

        IF ISNULL(@Uid,'') <> '' BEGIN
            SET @SqlWhere = @SqlWhere + N'
            AND     UID = @Uid '
        END

        IF ISNULL(@SiteDiv,'') <> '' BEGIN 
            --바른손몰인 경우 2개값 모두 검색
            IF @SiteDiv IN ('SA','B') BEGIN
                SET @SqlWhere = @SqlWhere + N'
                AND     SITE_DIV IN (''SA'',''B'') '
            END
            ELSE BEGIN
                SET @SqlWhere = @SqlWhere + N'
                AND     SITE_DIV = @SiteDiv '
            END
        END

        --절대 중간에 컬럼 추가하거나 빼지 말것 (추가시 맨 하위에 추가)    
        SET @Sql = N'          
            SELECT  UID
                   ,PWD
                   ,UNAME
                   ,UMAIL
                   ,BIRTH_DATE
                   ,BIRTH_DATE_TYPE
                   ,DUPINFO
                   ,CONNINFO
                   ,AUTHTYPE
                   ,ORIGINAL_BIRTH_DATE
                   ,GENDER
                   ,NATIONAL_INFO
                   ,WEDD_YEAR
                   ,WEDD_MONTH
                   ,WEDD_DAY
                   ,WEDDING_DAY
                   ,WEDDING_HALL
                   ,SITE_DIV
                   ,SITE_DIV_NAME
                   ,CHK_SMS
                   ,CHK_MAILSERVICE
                   ,HPHONE
                   ,PHONE
                   ,ZIPCODE
                   ,ISJEHU
                   ,ZIP1
                   ,ZIP2
                   ,ADDRESS
                   ,ADDR_DETAIL
                   ,MKT_CHK_FLAG
                   ,CHOICE_AGREEMENT_FOR_SAMSUNG_MEMBERSHIP
                   ,CHOICE_AGREEMENT_FOR_SAMSUNG_CHOICE_PERSONAL_DATA
                   ,CHOICE_AGREEMENT_FOR_SAMSUNG_THIRDPARTY
                   ,SMEMBERSHIP_REG_DATE
                   ,INTEGRATION_MEMBER_YORN
                   ,INTERGRATION_DATE
                   ,INTERGRATION_BEFORE_ID
                   ,REFERER_SALES_GUBUN
                   ,SELECT_SALES_GUBUN
                   ,SELECT_USER_ID
                   ,USE_YORN
                   ,REG_DATE
                   ,COMPANY_SEQ
                   ,CHK_MYOMEE
                   ,MYOMEE_REG_DATE
                   ,ISMCARDABLE
                   ,INFLOW_ROUTE
                   ,CHK_ILOOMMEMBERSHIP
                   ,ILOOMMEMBERSHIP_REG_DATE
                   ,CHK_LGMEMBERSHIP
                   ,LGMEMBERSHIP_REG_DATE
                   ,CHK_CUCKOOSMEMBERSHIP
                   ,CUCKOOSSHIP_REG_DATE
                   ,CHK_CASAMIAMEMBERSHIP
                   ,CASAMIASHIP_REG_DATE
                   ,CHK_KTMEMBERSHIP
                   ,KTMEMBERSHIP_REG_DATE
                   ,CHK_HYUNDAIMEMBERSHIP
                   ,HYUNDAIMEMBERSHIP_REG_DATE
                   ,WEDD_NAME
                   ,SMEMBERSHIP_PERIOD          
            FROM    VW_USER_INFO WITH(NOLOCK)      
            WHERE   1=1 '
                
        SET @Sql = @Sql + @SqlWhere
        
        SET @Param = N'
            @Uid        VARCHAR(50)   
           ,@DupInfo    CHAR(64)      
           ,@SiteDiv	VARCHAR(2)  '
        
        EXEC SP_EXECUTESQL @Sql
                          ,@Param
                          ,@Uid       = @Uid
                          ,@DupInfo   = @DupInfo
                          ,@SiteDiv   = @SiteDiv      
       
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


