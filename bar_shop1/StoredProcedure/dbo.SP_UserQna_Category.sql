USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_UserQna_Category]    Script Date: 2023-07-26 오후 5:06:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_UserQna_Category
-- Author        : 임승인
-- Create date   : 2023-07-21
-- Description   : 1:1 문의게시판 카테고리
-- Update History:
-- Comment       : 
**********************************************************/
ALTER PROCEDURE [dbo].[SP_UserQna_Category]
     @MODE                       INT
	 ,@CODE						VARCHAR(10)

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
		IF @MODE = '1' 
		BEGIN
			SELECT CODE, CODE_VALUE  
			FROM MANAGE_CODE 
			WHERE CODE_TYPE = 'ADMIN_MENT_CATEGORY_M' AND (ETC1 IS NULL OR ETC1 <> 'CSMEMO_ONLY') AND USE_YORN = 'Y' 
			ORDER BY SEQ
		END
		ELSE
		BEGIN
			SELECT
				B.CODE AS CHILD_CODE,               -- 문의유형2 코드
				B.CODE_VALUE AS CHILD_CODE_VALUE    -- 문의유형2 코드명
			FROM 
				MANAGE_CODE A 
				INNER JOIN MANAGE_CODE B ON A.CODE_ID = B.PARENT_ID
			WHERE
				A.CODE_TYPE = 'ADMIN_MENT_CATEGORY_M' AND
				(A.ETC1 IS NULL OR A.ETC1 <> 'CSMEMO_ONLY') AND
				(B.ETC1 IS NULL OR B.ETC1 <> 'CSMEMO_ONLY')
				AND A.CODE = @CODE
				AND B.USE_YORN = 'Y'
			ORDER BY
				A.SEQ, B.SEQ
		END

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
		SET @ErrMsg   = '정보 조회  실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH
END