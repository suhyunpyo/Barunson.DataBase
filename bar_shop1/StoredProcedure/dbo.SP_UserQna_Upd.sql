USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_UserQna_Upd]    Script Date: 2023-07-26 오후 5:08:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_UserQna_Upd
-- Author        : 임승인
-- Create date   : 2023-07-24
-- Description   : 1:1 문의게시판 글 수정
-- Update History:
-- Comment       : 
**********************************************************/
ALTER PROCEDURE [dbo].[SP_UserQna_Upd]        
     @QNAID                       VARCHAR(20)
	,@Q_TITLE					VARCHAR(100)
	,@Q_CONTENT					TEXT
	,@UPFILE1					VARCHAR(100)
	,@UPFILE2					VARCHAR(100)
	,@Q_KIND					VARCHAR(20)
	,@CARD_CODE					VARCHAR(20)
	,@ORDER_SEQ					INT

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
		UPDATE 
			S2_USERQNA 
		SET Q_TITLE = @Q_TITLE
			,Q_CONTENT = @Q_CONTENT		
			,USER_UPFILE1 = @UPFILE1
			,USER_UPFILE2 = @UPFILE2
			,Q_KIND = @Q_KIND
			,CARD_CODE = @CARD_CODE
			,ORDER_SEQ = @ORDER_SEQ
			WHERE QA_IID = @QNAID		

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
		SET @ErrMsg   = '정보 조회 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH
END