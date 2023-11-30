IF OBJECT_ID (N'dbo.PROC_SELECT_PRODUCT_IMAGE_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_SELECT_PRODUCT_IMAGE_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_SELECT_PRODUCT_IMAGE_LIST
-- Author        : 박혜림
-- Create date   : 2020-08-06
-- Description   : 상품 이미지 리스트 조회
-- Update History:
-- Comment       : 웹/모바일 공통
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_SELECT_PRODUCT_IMAGE_LIST]
       @Type               VARCHAR(20)
	 , @List_Cnt           INT
	 , @Card_Seq           INT
	 , @Company_Seq        INT
	 , @CardImage_Div      CHAR(1)
	 , @CardImage_WSize    VARCHAR(4)
	 , @CardImage_HSize    VARCHAR(4)
	 , @CardImage_FileName VARCHAR(30)
	-----------------------------------------------------------------------------
     , @ErrNum   INT           OUTPUT
     , @ErrSev   INT           OUTPUT
     , @ErrState INT           OUTPUT
     , @ErrProc  VARCHAR(50)   OUTPUT
     , @ErrLine  INT           OUTPUT
     , @ErrMsg   VARCHAR(2000) OUTPUT

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

-----------------------------------------------------------------------------------------------------------------------
-- Declare Block
-----------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
-- Execute Block
-----------------------------------------------------------------------------------------------------------------------
BEGIN

	BEGIN TRY

		----------------------------------------------------------------------------------
		-- 답례품 이미지 조회
		----------------------------------------------------------------------------------
		IF @Type = 'Gift'
		BEGIN
			IF @CardImage_Div <> ''	--이미지 구분이 존재하는 경우
			BEGIN
				SELECT TOP (@List_Cnt)
				       Card_Seq
					 , CardImage_WSize
					 , CardImage_HSize
					 , CardImage_FileName
				  FROM S2_CardImage
				 WHERE Card_Seq = @Card_Seq
				   AND Company_Seq = @Company_Seq
				   AND CardImage_Div = @CardImage_Div
				   AND (CardImage_FileName <> '' AND cardimage_filename IS NOT NULL AND CardImage_FileName LIKE '%'+ @CardImage_FileName +'%')
				ORDER BY cardimage_filename ASC
			END
			ELSE
			BEGIN
				SELECT TOP (@List_Cnt)
				       Card_Seq
					 , CardImage_WSize
					 , CardImage_HSize
					 , CardImage_FileName
				  FROM S2_CardImage
				 WHERE Card_Seq = @Card_Seq
				   AND Company_Seq = @Company_Seq
				   AND (CardImage_FileName <> '' AND cardimage_filename IS NOT NULL AND CardImage_FileName LIKE '%'+ @CardImage_FileName +'%')
				 ORDER BY cardimage_filename ASC
			END
		END	
		ELSE IF @Type = 'Card'
		BEGIN
			IF @CardImage_Div <> ''	--이미지 구분이 존재하는 경우
			BEGIN
				SELECT TOP (@List_Cnt)
				       Card_Seq
					 , CardImage_WSize
					 , CardImage_HSize
					 , CardImage_FileName
				  FROM S2_CardImage
				 WHERE Card_Seq = @Card_Seq
				   AND Company_Seq = @Company_Seq
				   AND CardImage_Div = @CardImage_Div
				   AND (CardImage_FileName <> '' AND cardimage_filename IS NOT NULL AND CardImage_FileName LIKE '%'+ @CardImage_FileName +'%')
				ORDER BY cardimage_filename ASC
			END
			ELSE
			BEGIN
				SELECT TOP (@List_Cnt)
				       Card_Seq
					 , CardImage_WSize
					 , CardImage_HSize
					 , CardImage_FileName
				  FROM S2_CardImage
				 WHERE Card_Seq = @Card_Seq
				   AND Company_Seq = @Company_Seq
				   AND (CardImage_FileName <> '' AND cardimage_filename IS NOT NULL AND CardImage_FileName LIKE '%'+ @CardImage_FileName +'%')
				 ORDER BY cardimage_filename ASC
			END
		END

	END TRY

	BEGIN CATCH

		SELECT @ErrNum   = ERROR_NUMBER()
		     , @ErrSev   = ERROR_SEVERITY()
		     , @ErrState = ERROR_STATE()
		     , @ErrProc  = ERROR_PROCEDURE()
		     , @ErrLine  = ERROR_LINE()
		     , @ErrMsg   = ERROR_MESSAGE();

	END CATCH

END

-- Execute Sample
/*

DECLARE	@ErrNum   INT          
	  , @ErrSev   INT          
	  , @ErrState INT          
	  , @ErrProc  VARCHAR(50)  
	  , @ErrLine  INT          
	  , @ErrMsg   VARCHAR(2000)

EXEC bar_shop1.dbo.PROC_SELECT_PRODUCT_IMAGE_LIST
     'Gift'
   , 10
   , 37919
   , 5001
   , ''
   , ''
   , ''
   , 'CS_'
   , @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/ 
GO
