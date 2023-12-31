USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_UserQna_Del]    Script Date: 2023-07-26 오후 5:07:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_UserQna_Del
-- Author        : 임승인
-- Create date   : 2023-07-24
-- Description   : 1:1 문의게시판 글 삭제
-- Update History:
-- Comment       : 
**********************************************************/
ALTER PROCEDURE [dbo].[SP_UserQna_Del]        
     @QNAID                       VARCHAR(20)

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
	
		DELETE S2_USERQNA 
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
		SET @ErrMsg   = '등록 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH
END
