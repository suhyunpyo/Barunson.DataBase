USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_SEOINFO_CHECK_GET]    Script Date: 2023-06-20 오후 1:10:27 ******/
DROP PROCEDURE [dbo].[SP_SEOINFO_CHECK_GET]
GO
/****** Object:  StoredProcedure [dbo].[SP_SEOINFO_CHECK_GET]    Script Date: 2023-06-20 오후 1:10:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_SEOINFO_CHECK_GET
-- Author        : 변미정
-- Create date   : 2023-06-01
-- Description   : SEO 정보 체크 및 값 조회
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_SEOINFO_CHECK_GET]         
     @SiteCode                       VARCHAR(2)                 --사이트 구분코드 (SB:바른손카드, SS:프리미어페이퍼, B:바른손몰)
    ,@Device                         CHAR(1)                    --유입경로 (P:PC, M:Mobile)
    ,@Url                            VARCHAR(200)               --url 절대경로 / 로 시작해야함
    ,@QueryString                    VARCHAR(7000)               --웹사이트 호출시 넘겨진 QueryString
    
    ,@ErrNum                         INT             OUTPUT
    ,@ErrSev                         INT             OUTPUT
    ,@ErrState                       INT             OUTPUT
    ,@ErrProc                        VARCHAR(50)     OUTPUT
    ,@ErrLine                        INT             OUTPUT
    ,@ErrMsg                         VARCHAR(2000)   OUTPUT
AS

SET NOCOUNT ON


BEGIN
    BEGIN TRY        
        
        DECLARE @TitleName           VARCHAR(120)  = ''             --웹에 표시할 Title명
        DECLARE @Description         VARCHAR(300)  = ''             --웹페이지에 meta tag에 출력할 설명글
        DECLARE @CanonicalUri        VARCHAR(250)  = ''             --link 태그에 출력할 캐노니컬 url
        
        -------------------------------------------------------
        -- 파라메터 유효성 체크
        -------------------------------------------------------            
        IF  ISNULL(@SiteCode,'') = ''OR  ISNULL(@Device,'') = '' OR ISNULL(@Url,'') = '' BEGIN    
            SET @ErrNum = 2300
            SET @ErrMsg = '데이터가 유효하지 않습니다.'            
            RETURN
        END

        IF ISNULL(@QueryString,'') = '' BEGIN
            SET @QueryString = ''
        END

        -------------------------------------------------------
        -- SEOInfo정보 조회
        -------------------------------------------------------     
        IF @QueryString <> '' BEGIN
            SELECT @CanonicalUri = CANONICALURI
                  ,@Description  = [DESCRIPTION]
                  ,@TitleName    = TITLENAME
            FROM SEOINFO D WITH(NOLOCK)
            INNER JOIN (
                SELECT S.SEOSEQ,COUNT(*) AS MATCHCNT
                FROM (
                        SELECT  A.SEOSEQ, B.KEYVALUE
                        FROM SEOINFO A WITH(NOLOCK)
                        LEFT OUTER JOIN SEOKEYVALUE B WITH(NOLOCK)
                        ON    A.SEOSEQ = B.SEOSEQ
                        WHERE A.SITECODE = @SiteCode
                        AND   A.DEVICE   = @Device              
                        AND   A.[URL]    = @URL
                        AND   A.USEFLAG  = 1
                    ) S
                INNER JOIN (SELECT VALUE FROM dbo.FN_SPLIT(TRIM(@QueryString), '&') GROUP BY VALUE) Q ON S.KEYVALUE=Q.[VALUE]
                GROUP BY S.SEOSEQ
            ) M
            ON D.SEOSEQ = M.SEOSEQ AND D.KeyCount = M.MATCHCNT
            WHERE D.SITECODE =  @SiteCode
            AND   D.DEVICE   =  @Device
            AND   D.[URL]    =  @URL
            AND   D.USEFLAG  =  1           
        END

        -------------------------------------------------------------------------------
        --조회된 값이 없거나 @QueryString이 빈값이면 keyvalue가 없는 조건으로 한번더 조회
        -------------------------------------------------------------------------------
        IF @CanonicalUri = '' BEGIN
            SELECT @CanonicalUri = CANONICALURI
                  ,@Description  = [DESCRIPTION]
                  ,@TitleName    = TITLENAME
            FROM SEOINFO  WITH(NOLOCK)
            WHERE SITECODE =  @SiteCode
            AND   DEVICE   =  @Device
            AND   [URL]    =  @URL
            AND   KEYCOUNT =  0
            AND   USEFLAG  =  1   
        END

        -------------------------------------------------------
        --조회된 값이 없으면 기본값 셋팅 및 로그 등록
        -------------------------------------------------------
        IF @CanonicalUri = '' BEGIN
            SELECT @CanonicalUri = ''
                  ,@Description  = [DESCRIPTION]
                  ,@TitleName    = TITLENAME
            FROM SEOINFO  WITH(NOLOCK)
            WHERE SITECODE =  @SiteCode
            AND   DEVICE   =  @Device
            AND   [URL]    =  '/'            
            AND   USEFLAG  =  1  

        END

        --------------------------
        --결과값 출력
        --------------------------
        SELECT @TitleName AS TitleName
             , @Description AS [Description]
             , @CanonicalUri AS CanonicalUri

        SET @ErrNum = 0
        SET @ErrMsg = 'OK'
        RETURN
    
    END TRY
    BEGIN CATCH    

        SET @ErrNum   = ERROR_NUMBER()
		SET @ErrSev   = ERROR_SEVERITY()
		SET @ErrState = ERROR_STATE()
		SET @ErrProc  = ERROR_PROCEDURE()
		SET @ErrLine  = ERROR_LINE()
		SET @ErrMsg   = 'SEO 정보 조회 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END
