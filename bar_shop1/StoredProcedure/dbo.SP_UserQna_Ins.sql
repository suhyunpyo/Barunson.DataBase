USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_UserQna_Ins]    Script Date: 2023-07-26 오후 5:07:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_UserQna_Ins
-- Author        : 임승인
-- Create date   : 2023-07-24
-- Description   : 1:1 문의게시판 글 등록
-- Update History:
-- Comment       : 
**********************************************************/
ALTER PROCEDURE [dbo].[SP_UserQna_Ins]        
     @SALES_GUBUN               VARCHAR(2)
	,@COMPANY_SEQ				INT
	,@MEMBER_ID					VARCHAR(100)
	,@MEMBER_NAME				VARCHAR(50)
	,@Q_TITLE					VARCHAR(100)
	,@Q_CONTENT					VARCHAR(2000)
	,@USER_UPFILE1				VARCHAR(100)
	,@USER_UPFILE2				VARCHAR(100)
	,@Q_KIND					VARCHAR(20)
	,@CARD_CODE					VARCHAR(20)
	,@ORDER_SEQ					INT
	,@INFLOW					VARCHAR(10)


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

		DECLARE @TEL_NO VARCHAR(15)
		DECLARE @E_MAIL VARCHAR(100)

		SET @E_MAIL = @MEMBER_ID

		SELECT @TEL_NO = HAND_PHONE1+'-'+HAND_PHONE2+'-'+HAND_PHONE3 
				,@E_MAIL = UMAIL
		FROM S2_USERINFO 
		WHERE UID = @MEMBER_ID
		
		INSERT S2_USERQNA (
			SALES_GUBUN
			,COMPANY_SEQ
			,E_MAIL
			,MEMBER_ID
			,MEMBER_NAME
			,Q_TITLE
			,Q_CONTENT
			,USER_UPFILE1
			,USER_UPFILE2
			,A_STAT
			,INFLOW
			,Q_KIND
			,CARD_CODE
			,ORDER_SEQ
			,TEL_NO
		)
		VALUES (
			@SALES_GUBUN
			,@COMPANY_SEQ
			,@E_MAIL
			,@MEMBER_ID
			,@MEMBER_NAME
			,@Q_TITLE
			,@Q_CONTENT
			,@USER_UPFILE1
			,@USER_UPFILE2
			,'S1'
			,@INFLOW
			,@Q_KIND
			,@CARD_CODE
			,@ORDER_SEQ
			,@TEL_NO
		)

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
