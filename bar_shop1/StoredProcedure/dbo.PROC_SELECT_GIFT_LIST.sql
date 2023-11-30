IF OBJECT_ID (N'dbo.PROC_SELECT_GIFT_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_SELECT_GIFT_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_SELECT_GIFT_LIST
-- Author        : 박혜림
-- Create date   : 2020-08-03
-- Description   : 답례품 리스트 조회
-- Update History:
-- Comment       : 웹/모바일 공통
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_SELECT_GIFT_LIST]
	   @Company_Seq INT
	 , @Page        INT
	 , @PageSize    INT
	 , @SearchTy    VARCHAR(50)
	 , @SearchWord  VARCHAR(250)
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
		-- 답례품 총 카운트 조회
		----------------------------------------------------------------------------------
		SELECT COUNT(*)
		  FROM bar_shop1.dbo.S2_Card               AS T1 WITH(NOLOCK)
		 INNER JOIN bar_shop1.dbo.S2_CardSalesSite AS T2 WITH(NOLOCK) ON (T1.card_seq = T2.card_seq AND T2.IsDisplay = 1 AND T2.Company_Seq = @Company_Seq)
		 INNER JOIN bar_shop1.dbo.S2_CardDetailEtc AS T3 WITH(NOLOCK) ON (T2.Card_Seq = T3.Card_Seq AND T3.card_category NOT IN('V1', 'V2'))	-- 부가상품 제외
		 INNER JOIN bar_shop1.dbo.manage_code      AS T4 WITH(NOLOCK) ON (T3.card_category = T4.code AND T4.code_type ='etcprod' AND T4.use_yorn = 'Y')
		 WHERE T1.Card_Div = 'C08'
		   AND T1.DISPLAY_YORN = 'Y'

		----------------------------------------------------------------------------------
		-- 리스트 조회
		----------------------------------------------------------------------------------
		;
		WITH Gift_List_CTE
		  AS
		   (
				SELECT ROW_NUMBER() OVER (Order By T4.Seq ASC)as RowNum
				     , T1.card_seq
					 , T1.card_code
					 , T1.card_erpcode
					 , T1.card_name
					 , ISNULL(T1.card_image, '') AS card_image
					 , T1.card_price
					 , T4.code_value
					 , T3.card_category
					 , ISNULL(T3.Hover_Title, '') AS Hover_Title
					 , ISNULL(T3.Main_Title, '') AS Main_Title
					 , ISNULL(T3.Sub_Title, '') AS Sub_Title
					 , ISNULL(T1.Video_URL, '') AS Video_URL
					 , ISNULL(T3.Hover_Main_Title, '') AS Hover_Main_Title
					 , ISNULL(T3.Hover_Sub_Title, '') AS Hover_Sub_Title
				  FROM bar_shop1.dbo.S2_Card               AS T1 WITH(NOLOCK)
				 INNER JOIN bar_shop1.dbo.S2_CardSalesSite AS T2 WITH(NOLOCK) ON (T1.card_seq = T2.card_seq AND T2.IsDisplay = 1 AND T2.Company_Seq = @Company_Seq)
				 INNER JOIN bar_shop1.dbo.S2_CardDetailEtc AS T3 WITH(NOLOCK) ON (T2.Card_Seq = T3.Card_Seq AND T3.card_category NOT IN('V1', 'V2'))	-- 부가상품 제외
				 INNER JOIN bar_shop1.dbo.manage_code      AS T4 WITH(NOLOCK) ON (T3.card_category = T4.code AND T4.code_type ='etcprod' AND T4.use_yorn = 'Y')
				 WHERE T1.Card_Div = 'C08'
				   AND T1.DISPLAY_YORN = 'Y'
			)
			SELECT A.card_seq
				 , A.card_code  
				 , A.card_erpcode    
				 , A.card_name  
				 , A.card_image
				 , A.card_price
				 , A.code_value AS card_cate
				 , A.card_category
				 , A.Hover_Title	-- Hover 타이틀
				 , A.Main_Title		-- 메인타이틀
				 , A.Sub_Title		-- 서브타이틀
				 , A.Video_URL		-- 동영상 URL
				 , A.Hover_Main_Title	-- Hover 메인 타이틀
				 , A.Hover_Sub_Title	-- Hover 서브 타이틀
			  FROM Gift_List_CTE AS A
			 WHERE RowNum BETWEEN (@Page-1)*@PageSize+1 AND @Page*@PageSize

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

EXEC bar_shop1.dbo.PROC_SELECT_GIFT_LIST
     '5001'
   , 1
   , 10
   , ''
   , ''
   , @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/ 
GO
