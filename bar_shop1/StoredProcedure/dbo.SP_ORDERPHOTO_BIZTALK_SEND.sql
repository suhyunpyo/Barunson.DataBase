IF OBJECT_ID (N'dbo.SP_ORDERPHOTO_BIZTALK_SEND', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ORDERPHOTO_BIZTALK_SEND
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************************************************************
-- SP Name       : SP_ORDERPHOTO_BIZTALK_SEND
-- Author        : 변미정
-- Create date   : 2023-02-24
-- Description   : 이미지보정 주문 결제 완료 메세지 발송
-- Update History:
-- Comment       : 
*************************************************************/
CREATE PROCEDURE [dbo].[SP_ORDERPHOTO_BIZTALK_SEND]
     @SalesGubun          VARCHAR(10)
    ,@CompanySeq          INT
    ,@TemplateCode        VARCHAR(30)
    ,@UserName            VARCHAR(50)
    ,@UserHphone          VARCHAR(50)

    ,@OrderNo             VARCHAR(50)
    ,@ProductName         VARCHAR(50)
    ,@ProductPriceText    VARCHAR(50)     

    ,@ErrNum              INT             OUTPUT
    ,@ErrSev              INT             OUTPUT
    ,@ErrState            INT             OUTPUT
    ,@ErrProc             VARCHAR(50)     OUTPUT
    ,@ErrLine             INT             OUTPUT
    ,@ErrMsg              VARCHAR(2000)   OUTPUT
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

----------------------------------------------
-- Declare Block
----------------------------------------------
DECLARE @Content        VARCHAR(800) -- 알림톡내용
      , @SenderKey      VARCHAR(40)
      , @MsgType        INT
      , @KkoBtnType     CHAR(1)
      , @KkoBtnInfo     VARCHAR(4000)

      , @Callback       VARCHAR(15)
      , @LmsSubject     VARCHAR(200)      

BEGIN
    BEGIN TRY        
        -------------------------------------------------------
        -- 파라메터 유효성 체크
        -------------------------------------------------------            
        IF ISNULL(@UserName,'') = ''
            OR ISNULL(@UserHphone,'') = '' 
            OR ISNULL(@OrderNo,'') = '' 
            OR ISNULL(@ProductName,'') = '' 
            OR ISNULL(@ProductPriceText,'') = ''  BEGIN
            SET @ErrNum = 2001
            SET @ErrMsg = '입력데이터에 빈값이 있습니다.'            
            RETURN
        END

        -------------------------------------------------------
        -- 발송 비즈톡 정보 조회
        -------------------------------------------------------
        SELECT    @Content     = CONTENT
                , @SenderKey   = SENDER_KEY
                , @MsgType     = MSG_TYPE
                , @KkoBtnType  = KKO_BTN_TYPE
                , @KkoBtnInfo  = KKO_BTN_INFO 
                , @Callback    = CALLBACK
                , @LmsSubject  = LMS_SUBJECT
        FROM  WEDD_BIZTALK
        WHERE SALES_GUBUN   = @SalesGubun
        AND   TEMPLATE_CODE = @TemplateCode
        AND   COMPANY_SEQ   = @CompanySeq
        AND   USE_YORN      ='Y'
        IF @@ROWCOUNT <> 1 BEGIN             
            SET @ErrNum = 2002
            SET @ErrMsg = '메세지 템플릿 정보가 존재하지 않습니다.'            
            RETURN
        END

        -------------------------------------------------------
        -- 발송 메세지 생성
        -------------------------------------------------------        
        SET @Content = REPLACE(@Content , '#{name}',    @UserName)
        SET @Content = REPLACE(@Content , '#{0000000}', @OrderNo)
        SET @Content = REPLACE(@Content , '#{상품명}',  @ProductName)
        SET @Content = REPLACE(@Content , '#{금액}',    @ProductPriceText)        

        BEGIN TRAN    

        IF @CONTENT <> ''  BEGIN
            INSERT INTO ata_mmt_tran (date_client_req, [subject], content, callback, msg_status
                                    , recipient_num, msg_type, sender_key, template_code, kko_btn_type
                                    , kko_btn_info, etc_text_1, etc_text_2, etc_num_1)
                            VALUES  ( GETDATE(), @LmsSubject , @Content, @Callback , '1' 
                                    , @UserHphone , @MsgType, @SenderKey, @TemplateCode, @KkoBtnType 
                                    , @KkoBtnInfo, @SalesGubun, 'SP_ORDERPHOTO_BIZTALK_SEND', @CompanySeq)
       END

      COMMIT TRAN

      SET @ErrNum = 0
      SET @ErrMsg = 'OK'
      RETURN
    
    END TRY
    BEGIN CATCH
        IF ( XACT_STATE() ) <> 0  BEGIN            
            ROLLBACK TRAN          
        END

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
