USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_UserQna_View]    Script Date: 2023-07-26 오후 5:08:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_UserQna_Count
-- Author        : 임승인
-- Create date   : 2023-07-20
-- Description   : 1:1 문의게시판 글 상세
-- Update History:
-- Comment       : 
**********************************************************/
ALTER PROCEDURE [dbo].[SP_UserQna_View]        
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
		SELECT QA_IID,CARD_CODE,ORDER_SEQ,Q_TITLE,Q_CONTENT
				,USER_UPFILE1,USER_UPFILE2,ADMIN_UPFILE1,A_STAT,A_CONTENT
				,CODE_VALUE + ' > '+ CHILD_CODE_VALUE AS Q_KIND, CODE, CHILD_CODE
		FROM S2_USERQNA A 
		LEFT JOIN (
			SELECT
				A.CODE,                             -- 문의유형1 코드
				A.CODE_VALUE,                       -- 문의유형1 코드명
				A.USE_YORN,                         -- 문의유형1 사용여부
				B.CODE AS CHILD_CODE,               -- 문의유형2 코드
				B.CODE_VALUE AS CHILD_CODE_VALUE    -- 문의유형2 코드명
			FROM 
				MANAGE_CODE A 
				INNER JOIN MANAGE_CODE B ON A.CODE_ID = B.PARENT_ID
			WHERE
				A.CODE_TYPE = 'ADMIN_MENT_CATEGORY_M' AND
				(A.ETC1 IS NULL OR A.ETC1 <> 'CSMEMO_ONLY') AND
				(B.ETC1 IS NULL OR B.ETC1 <> 'CSMEMO_ONLY')
		) B ON A.Q_KIND = B.CHILD_CODE
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

