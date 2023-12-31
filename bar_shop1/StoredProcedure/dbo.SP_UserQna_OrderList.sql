USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_UserQna_OrderList]    Script Date: 2023-07-26 오후 5:07:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_UserQna_OrderList
-- Author        : 임승인
-- Create date   : 2023-07-21
-- Description   : 1:1 문의게시판 주문리스트
-- Update History:
-- Comment       : 
**********************************************************/
ALTER PROCEDURE [dbo].[SP_UserQna_OrderList]
     @UID                       VARCHAR(100)
	,@UNAME						VARCHAR(20)
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
		IF @UID <> '' AND @UNAME <> ''
		BEGIN
			WITH CTE AS(
				SELECT A.ORDER_SEQ,A.ORDER_DATE,B.CARD_SEQ,B.CARD_CODE,B.CARD_IMAGE ,ORDER_TYPE
				FROM CUSTOM_ORDER A LEFT JOIN S2_CARD B ON A.CARD_SEQ=B.CARD_SEQ 
				WHERE A.ORDER_EMAIL=@UID 
					AND A.ORDER_NAME=@UNAME 
					AND MEMBER_ID = ''
					AND A.COMPANY_SEQ = @COMPANYSEQ
					AND STATUS_SEQ>=1 
					
				UNION ALL

				SELECT A.SAMPLE_ORDER_SEQ AS 'ORDER_SEQ',REQUEST_DATE AS 'ORDER_DATE',B.CARD_SEQ,CARD_CODE,CARD_IMAGE, '' AS ORDER_TYPE 
				FROM CUSTOM_SAMPLE_ORDER A LEFT JOIN CUSTOM_SAMPLE_ORDER_ITEM B ON A.SAMPLE_ORDER_SEQ=B.SAMPLE_ORDER_SEQ AND B.SORT=1
				INNER JOIN S2_CARD C ON B.CARD_SEQ=C.CARD_SEQ 
				WHERE A.MEMBER_EMAIL=@UID 
					AND A.MEMBER_NAME=@UNAME  
					AND MEMBER_ID = ''					
					AND A.COMPANY_SEQ = @COMPANYSEQ 
					AND STATUS_SEQ>=1  
				
				UNION ALL

				SELECT A.ORDER_SEQ,A.ORDER_DATE,'' CARD_SEQ,'' CARD_CODE,'' CARD_IMAGE ,'0' AS ORDER_TYPE
				FROM CUSTOM_ETC_ORDER A 
				WHERE A.ORDER_EMAIL=@UID 
					AND A.ORDER_NAME=@UNAME 
					AND MEMBER_ID = ''
					AND A.COMPANY_SEQ = @COMPANYSEQ
					AND STATUS_SEQ>=1 	
			) 

			SELECT * FROM CTE
			ORDER BY ORDER_DATE DESC
		END
		ELSE
		BEGIN
			WITH CTE AS(
				SELECT A.ORDER_SEQ,A.ORDER_DATE,B.CARD_SEQ,B.CARD_CODE,B.CARD_IMAGE ,ORDER_TYPE
				FROM CUSTOM_ORDER A LEFT JOIN S2_CARD B ON A.CARD_SEQ=B.CARD_SEQ 
				WHERE A.MEMBER_ID= @UID
					AND STATUS_SEQ>=1 					
					AND A.COMPANY_SEQ = @COMPANYSEQ

				UNION ALL

				SELECT A.SAMPLE_ORDER_SEQ AS 'ORDER_SEQ',REQUEST_DATE AS 'ORDER_DATE',B.CARD_SEQ,CARD_CODE,CARD_IMAGE, '' AS ORDER_TYPE 
				FROM CUSTOM_SAMPLE_ORDER A LEFT JOIN CUSTOM_SAMPLE_ORDER_ITEM B ON A.SAMPLE_ORDER_SEQ=B.SAMPLE_ORDER_SEQ AND B.SORT=1
				INNER JOIN S2_CARD C ON B.CARD_SEQ=C.CARD_SEQ 
				WHERE MEMBER_ID = @UID
					AND STATUS_SEQ>=1  					
					AND COMPANY_SEQ = @COMPANYSEQ
				UNION ALL

				SELECT A.ORDER_SEQ,A.ORDER_DATE,'' CARD_SEQ,'' CARD_CODE,'' CARD_IMAGE ,'0' AS ORDER_TYPE
				FROM CUSTOM_ETC_ORDER A 
				WHERE MEMBER_ID = @UID
					AND STATUS_SEQ>=1 					
					AND A.COMPANY_SEQ = @COMPANYSEQ					
			) 

			SELECT * FROM CTE
			ORDER BY ORDER_DATE DESC
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
		SET @ErrMsg   = '정보 조회 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH
END