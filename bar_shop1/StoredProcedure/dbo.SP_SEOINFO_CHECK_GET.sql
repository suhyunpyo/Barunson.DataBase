﻿USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_SEOINFO_CHECK_GET]    Script Date: 2023-06-20 ���� 1:10:27 ******/
DROP PROCEDURE [dbo].[SP_SEOINFO_CHECK_GET]
GO
/****** Object:  StoredProcedure [dbo].[SP_SEOINFO_CHECK_GET]    Script Date: 2023-06-20 ���� 1:10:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_SEOINFO_CHECK_GET
-- Author        : ������
-- Create date   : 2023-06-01
-- Description   : SEO ���� üũ �� �� ��ȸ
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_SEOINFO_CHECK_GET]         
     @SiteCode                       VARCHAR(2)                 --����Ʈ �����ڵ� (SB:�ٸ���ī��, SS:�����̾�������, B:�ٸ��ո�)
    ,@Device                         CHAR(1)                    --���԰�� (P:PC, M:Mobile)
    ,@Url                            VARCHAR(200)               --url ������ / �� �����ؾ���
    ,@QueryString                    VARCHAR(7000)               --������Ʈ ȣ��� �Ѱ��� QueryString
    
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
        
        DECLARE @TitleName           VARCHAR(120)  = ''             --���� ǥ���� Title��
        DECLARE @Description         VARCHAR(300)  = ''             --���������� meta tag�� ����� �����
        DECLARE @CanonicalUri        VARCHAR(250)  = ''             --link �±׿� ����� ĳ����� url
        
        -------------------------------------------------------
        -- �Ķ���� ��ȿ�� üũ
        -------------------------------------------------------            
        IF  ISNULL(@SiteCode,'') = ''OR  ISNULL(@Device,'') = '' OR ISNULL(@Url,'') = '' BEGIN    
            SET @ErrNum = 2300
            SET @ErrMsg = '�����Ͱ� ��ȿ���� �ʽ��ϴ�.'            
            RETURN
        END

        IF ISNULL(@QueryString,'') = '' BEGIN
            SET @QueryString = ''
        END

        -------------------------------------------------------
        -- SEOInfo���� ��ȸ
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
        --��ȸ�� ���� ���ų� @QueryString�� ���̸� keyvalue�� ���� �������� �ѹ��� ��ȸ
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
        --��ȸ�� ���� ������ �⺻�� ���� �� �α� ���
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
        --����� ���
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
		SET @ErrMsg   = 'SEO ���� ��ȸ ���� (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END
