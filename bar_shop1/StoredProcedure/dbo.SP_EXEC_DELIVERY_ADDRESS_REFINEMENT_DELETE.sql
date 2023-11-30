IF OBJECT_ID (N'dbo.SP_EXEC_DELIVERY_ADDRESS_REFINEMENT_DELETE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_DELIVERY_ADDRESS_REFINEMENT_DELETE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

    EXEC SP_EXEC_DELIVERY_ADDRESS_REFINEMENT '서울 은평구 불광동 636 북한산 한양수자인아파트 192동 901호', '122853'

*/
CREATE PROCEDURE [dbo].[SP_EXEC_DELIVERY_ADDRESS_REFINEMENT_DELETE]
    @P_ADDRESS      AS NVARCHAR(1000)
,   @P_ZIPCODE      AS NVARCHAR(1000)
AS
BEGIN

SET NOCOUNT ON;

DECLARE
        @avc_CLNTNUM            NVARCHAR(1000)              --CJ대한통운고객ID
    ,   @avc_CLNTMGMCUSTCD      NVARCHAR(1000)              --CJ대한통운고객관리거래처코드 
                                                            --(고객관리거래처코드를모를고객ID와경우동일한값)
    ,   @avc_PRNGDIVCD          NVARCHAR(1000)              --예약구분코드 : 일반(01) / 반품(02)
    ,   @avc_CGOSTS             NVARCHAR(1000)              --상품상태코드 : 집화(11) / 배달(91)
    ,   @avc_ADDRESS            NVARCHAR(1000)              --주소 : 서울은평구신사동200-63 202호

DECLARE
        @vc_ZIPNUM              NVARCHAR(1000)              --우편번호 : 122888
    ,   @i_ZIPID                INT                         --우편번호ID : 6574 (CJ대한통운고유의값)
    ,   @vc_OLDADDRESS          NVARCHAR(1000)              --지번주소 : 서울은평구신사동
    ,   @vc_OLDADDRESSDTL       NVARCHAR(1000)              --지번주소상세 : 200-63번지202호
    ,   @vc_NEWADDRESS          NVARCHAR(1000)              --도로명주소 : 서울은평구은평터널로
    ,   @vc_NEWADDRESSDTL       NVARCHAR(1000)              --도로명주소상세: 182-13, 202호
    ,   @vc_ETCADDR             NVARCHAR(1000)              --기타주소 : 신사동, 그린아트빌라
    ,   @vc_SHORTADDR           NVARCHAR(1000)              --주소약칭 : 은평신사
    ,   @vc_CLSFADDR            NVARCHAR(1000)              --분류주소 : 200-63
    ,   @vc_CLLDLVBRNACD        NVARCHAR(1000)              --집배송점소코드 : 801
    ,   @vc_CLLDLVBRANNM        NVARCHAR(1000)              --집배송점소명 : 김포특판
    ,   @vc_CLLDLCBRANSHORTNM   NVARCHAR(1000)              --집배송점소약칭 : 김포특판
    ,   @vc_CLLDLVEMPNUM        NVARCHAR(1000)              --집배송사원번호 : 467759
    ,   @vc_CLLDLVEMPNM         NVARCHAR(1000)              --집배송사원명 : 장석천
    ,   @vc_CLLDLVEMPNICKNM     NVARCHAR(1000)              --집배송사원분류코드
    ,   @vc_CLSFCD              NVARCHAR(1000)              --분류터미널코드: 0073
    ,   @vc_CLSFNM              NVARCHAR(1000)              --분류터미널명 : 김포특판Sub
    ,   @vc_SUBCLSFCD           NVARCHAR(1000)              --소분류코드 : 1
    ,   @vc_RSPSDIV             NVARCHAR(1000)              --전담구분 : 04 (CJ대한통운고유의값)
    ,   @vc_NEWADDRYN           NVARCHAR(1000)              --도로명주소여부 : N
    ,   @vc_ERRORCD             NVARCHAR(1000)              --에러코드 : 0
    ,   @vc_ERRORMSG            NVARCHAR(1000)              --에러메세지 : 정제성공

----기존
SELECT  @avc_CLNTNUM = '30184122'
    ,   @avc_CLNTMGMCUSTCD = '30184122'
    ,   @avc_PRNGDIVCD = '01'
    ,   @avc_CGOSTS = '91'
    ,   @avc_ADDRESS = @P_ADDRESS
---추가
    ,   @vc_ZIPNUM = ''
    ,   @i_ZIPID = -1
    ,   @vc_OLDADDRESS = ''
    ,   @vc_OLDADDRESSDTL = ''
    ,   @vc_NEWADDRESS = ''
    ,   @vc_NEWADDRESSDTL = ''
    ,   @vc_ETCADDR = ''
    ,   @vc_SHORTADDR = ''
    ,   @vc_CLSFADDR = ''
    ,   @vc_CLLDLVBRNACD = ''
    ,   @vc_CLLDLVBRANNM = ''
    ,   @vc_CLLDLCBRANSHORTNM = ''
    ,   @vc_CLLDLVEMPNUM = ''
    ,   @vc_CLLDLVEMPNM = ''
    ,   @vc_CLLDLVEMPNICKNM = ''
    ,   @vc_CLSFCD = ''
    ,   @vc_CLSFNM = ''
    ,   @vc_SUBCLSFCD = ''
    ,   @vc_RSPSDIV = ''
    ,   @vc_NEWADDRYN = ''
    ,   @vc_ERRORCD = ''
    ,   @vc_ERRORMSG = ''





BEGIN TRY
    EXEC    ('BEGIN PKG_RVAP_ADDRSEARCH.PR_RVAP_SEARCHADDRESS(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?); END;'
                ,   @avc_CLNTNUM
                ,   @avc_CLNTMGMCUSTCD
                ,   @avc_PRNGDIVCD
                ,   @avc_CGOSTS
                ,   @avc_ADDRESS
                ,   @vc_ZIPNUM OUTPUT
                ,   @i_ZIPID OUTPUT
                ,   @vc_OLDADDRESS OUTPUT
                ,   @vc_OLDADDRESSDTL OUTPUT
                ,   @vc_NEWADDRESS OUTPUT
                ,   @vc_NEWADDRESSDTL OUTPUT
                ,   @vc_ETCADDR OUTPUT
              ,   @vc_SHORTADDR OUTPUT
                ,   @vc_CLSFADDR OUTPUT
                ,   @vc_CLLDLVBRNACD OUTPUT
                ,   @vc_CLLDLVBRANNM OUTPUT
                ,   @vc_CLLDLCBRANSHORTNM OUTPUT
                ,   @vc_CLLDLVEMPNUM OUTPUT
                ,   @vc_CLLDLVEMPNM OUTPUT
                ,   @vc_CLLDLVEMPNICKNM OUTPUT
                ,   @vc_CLSFCD OUTPUT
                ,   @vc_CLSFNM OUTPUT
                ,   @vc_SUBCLSFCD OUTPUT
                ,   @vc_RSPSDIV OUTPUT
                ,   @vc_NEWADDRYN OUTPUT
                ,   @vc_ERRORCD OUTPUT
                ,   @vc_ERRORMSG OUTPUT
            ) AT CJ_CGIS
END TRY

BEGIN CATCH
    
    SET @vc_ERRORCD = '-0'  

END CATCH



IF @vc_ERRORCD <> '0'
BEGIN
    
    SELECT  @vc_ZIPNUM              = ZIP_NO
        ,   @i_ZIPID                = ''
        ,   @vc_OLDADDRESS          = ''
        ,   @vc_OLDADDRESSDTL       = ''
        ,   @vc_NEWADDRESS          = ''
        ,   @vc_NEWADDRESSDTL       = ''
        ,   @vc_ETCADDR             = ''
        ,   @vc_SHORTADDR           = ''
        ,   @vc_CLSFADDR            = ''
        ,   @vc_CLLDLVBRNACD        = ''
        ,   @vc_CLLDLVBRANNM        = MAN_BRAN_NM
        ,   @vc_CLLDLCBRANSHORTNM   = SUBSTRING(MAN_BRAN_NM, 1, 4)
        ,   @vc_CLLDLVEMPNUM        = ''
        ,   @vc_CLLDLVEMPNM         = CLDV_EMP_NM
        ,   @vc_CLLDLVEMPNICKNM     = ''
        ,   @vc_CLSFCD              = END_NO
        ,   @vc_CLSFNM              = MAN_BRAN_NM
        ,   @vc_SUBCLSFCD           = SUB_END_NO
        ,   @vc_RSPSDIV             = ''
        ,   @vc_NEWADDRYN           = ''
        ,   @vc_ERRORCD             = '0'
        ,   @vc_ERRORMSG            = @vc_ERRORMSG + ' - [정제실패] 집배권역 테이블 조회 성공'

    FROM    CJ_ZIPCODE
    WHERE   1 = 1
    AND     ZIP_NO = @P_ZIPCODE
    AND     USE_YN = 'Y'

END



SELECT
        ISNULL(@vc_ZIPNUM               , '')           AS ZIPNUM
    ,   ISNULL(@i_ZIPID                 , -1)           AS ZIPID
    ,   ISNULL(@vc_OLDADDRESS           , '')           AS OLDADDRESS
    ,   ISNULL(@vc_OLDADDRESSDTL        , '')           AS OLDADDRESSDTL
    ,   ISNULL(@vc_NEWADDRESS           , '')           AS NEWADDRESS
    ,   ISNULL(@vc_NEWADDRESSDTL        , '')           AS NEWADDRESSDTL
    ,   ISNULL(@vc_ETCADDR              , '')           AS ETCADDR
    ,   ISNULL(@vc_SHORTADDR            , '')           AS SHORTADDR
    ,   ISNULL(@vc_CLSFADDR             , '')           AS CLSFADDR
    ,   ISNULL(@vc_CLLDLVBRNACD         , '')           AS CLLDLVBRNACD
    ,   ISNULL(@vc_CLLDLVBRANNM         , '')           AS CLLDLVBRANNM
    ,   ISNULL(@vc_CLLDLCBRANSHORTNM    , '')           AS CLLDLCBRANSHORTNM
    ,   ISNULL(@vc_CLLDLVEMPNUM         , '')           AS CLLDLVEMPNUM
    ,   ISNULL(@vc_CLLDLVEMPNM          , '')           AS CLLDLVEMPNM
    ,   ISNULL(@vc_CLLDLVEMPNICKNM      , '')           AS CLLDLVEMPNICKNM
    ,   ISNULL(@vc_CLSFCD               , '')           AS CLSFCD
    ,   ISNULL(@vc_CLSFNM               , '')           AS CLSFNM
    ,   ISNULL(@vc_SUBCLSFCD            , '')           AS SUBCLSFCD
    ,   ISNULL(@vc_RSPSDIV              , '')           AS RSPSDIV
    ,   ISNULL(@vc_NEWADDRYN            , '')           AS NEWADDRYN
    ,   ISNULL(@vc_ERRORCD              , '')           AS ERRORCD
    ,   ISNULL(@vc_ERRORMSG             , '')           AS ERRORMSG

END

GO
