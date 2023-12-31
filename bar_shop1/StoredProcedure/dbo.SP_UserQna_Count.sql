USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_UserQna_Count]    Script Date: 2023-07-26 오후 5:07:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_UserQna_Count
-- Author        : 임승인
-- Create date   : 2023-07-20
-- Description   : 1:1 문의게시판 글 갯수
-- Update History:
-- Comment       : 
**********************************************************/
ALTER PROCEDURE [dbo].[SP_UserQna_Count]        
     @UID                       VARCHAR(100)
	,@COMPANYSEQ                INT

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
		DECLARE @TOTALCOUNT INT
		DECLARE @QNACOUNT INT
		DECLARE @ANSWERCOUNT INT
    
		-- 총 상담건수
		SELECT @TOTALCOUNT=TOTALCOUNT FROM(
			SELECT COUNT(*) AS TOTALCOUNT 
			FROM S2_USERQNA 
			WHERE MEMBER_ID=@UID AND COMPANY_SEQ=@COMPANYSEQ AND A_STAT<>'S4' AND A_STAT<>'S5'
		) AS X
        
		-- 답변 대기
		SELECT @QNACOUNT=QNACOUNT FROM(
			SELECT COUNT(*) AS QNACOUNT 
			FROM S2_USERQNA 
			WHERE MEMBER_ID=@UID AND COMPANY_SEQ=@COMPANYSEQ AND A_CONTENT IS NULL AND A_STAT<>'S4' AND A_STAT<>'S5'
		) AS X

		-- 답변 완료
		SELECT @ANSWERCOUNT=ANSWERCOUNT FROM(
			SELECT COUNT(*) AS ANSWERCOUNT 
			FROM S2_USERQNA 
			WHERE MEMBER_ID=@UID AND COMPANY_SEQ=@COMPANYSEQ AND A_CONTENT IS NOT NULL AND A_STAT<>'S4' AND A_STAT<>'S5'
		) AS X
    

		SELECT	@TOTALCOUNT AS TOTALCOUNT, 
				@ANSWERCOUNT AS ANSWERCOUNT,
				@QNACOUNT AS QNACOUNT

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
