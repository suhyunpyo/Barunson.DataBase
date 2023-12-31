USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_UserQna_List]    Script Date: 2023-07-26 오후 5:07:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_UserQna_Count
-- Author        : 임승인
-- Create date   : 2023-07-20
-- Description   : 1:1 문의게시판 글 리스트
-- Update History:
-- Comment       : 
**********************************************************/
ALTER PROCEDURE [dbo].[SP_UserQna_List]        
     @UID                       VARCHAR(100)
	,@COMPANYSEQ                INT
	,@PAGE        INT
	,@PAGESIZE    INT

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
	
		SELECT * FROM (
			SELECT QA_IID, SALES_GUBUN, COMPANY_SEQ, CARD_CODE, ORDER_SEQ, MEMBER_ID, MEMBER_NAME, REG_DT
					,A_STAT, A_DT, A_CONTENT, A_ID, Q_CONTENT, Q_TITLE, Q_KIND,ISNULL(a_research1,'0') AS a_research
					,ROW_NUMBER() OVER (Order By QA_IID DESC) AS RowNum
			FROM S2_UserQnA
			WHERE COMPANY_SEQ = @CompanySeq AND A_STAT<>'S4' AND A_STAT<>'S5' and MEMBER_ID=@UID
		) X WHERE RowNum BETWEEN (@Page-1)*@PageSize+1 AND @Page*@PageSize
		ORDER BY RowNum 

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