IF OBJECT_ID (N'dbo.PROC_SELECT_GIFT_DETAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_SELECT_GIFT_DETAIL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_SELECT_GIFT_DETAIL
-- Author        : 박혜림
-- Create date   : 2020-08-07
-- Description   : 답례품 상세정보 조회
-- Update History:
-- Comment       : 웹/모바일 공통
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_SELECT_GIFT_DETAIL]
       @Card_Seq    INT
	 , @Company_Seq INT
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
		-- 상품정보 조회
		----------------------------------------------------------------------------------
		SELECT T1.card_seq
			 , T1.card_code
			 , T1.card_erpcode
			 , T1.Card_Name
			 , T1.Card_Image	-- 카드 메인이미지
			 , T1.Card_Price
			 , T3.card_category
			 , ISNULL(T3.composition, '') AS composition	-- 중량/용량
			 , ISNULL(T3.summary, '') AS summary			-- 상품상세 > 설명
			 , ISNULL(T3.Delivery_Price_Str, '') AS Delivery_Price_Str -- 배송비(상세보기)
			 , ISNULL(T3.etc1, '') AS etc1	-- 문의연락처
			 , ISNULL(T3.etc2, '') AS etc2	-- 유통기한
			 , ISNULL(T3.min_onum, 0) AS min_onum	-- 최소수량
			 , T3.option_str1	-- 옵션1
			 , T3.option_str2
			 , T3.option_str3
			 , ISNULL(T1.View_Discount_Percent, 0)	AS View_Discount_Percent	-- 노출용 할인율
			 , ISNULL(T1.Cost_Price, 0) AS Cost_Price		-- 원가
			 , ISNULL(T3.Delivery_Ty, '') AS Delivery_Ty	-- 배송구분
			 , ISNULL(T3.Delivery_Request_Dt, 0) AS Delivery_Request_Dt	-- 배송요청일

			 , ISNULL(T3.delivery_price, 0) AS Delivery_Price	-- 배송비(결제용)
			 , ISNULL(T3.Sub_Title, '') AS Sub_Title	-- 리스트 > 서브타이틀
			 , ISNULL(T3.Contents_Main_Copy, '') AS Contents_Main_Copy 	-- 상품상세 > 메인카피
			 , ISNULL(T3.Contents_Sub_Copy, '') AS Contents_Sub_Copy  	-- 상품상세 > 서브카피
			 , ISNULL(T3.Contents_Option_Name, '') AS Contents_Option_Name			-- 상세정보 > 상품명
			 , ISNULL(T3.Contents_Option_Summary, '') AS Contents_Option_Summary	-- 상세정보 > 설명
			 , ISNULL(T3.QnA_Title, '') AS QnA_Title	-- 상품문의 > 타이틀
			 , ISNULL(T3.QnA_Info, '') AS QnA_Info		-- 상품문의 > 정보
		  FROM bar_shop1.dbo.S2_Card               AS T1 WITH(NOLOCK)
		 INNER JOIN bar_shop1.dbo.S2_CardSalesSite AS T2 WITH(NOLOCK) ON (T1.Card_Seq = T2.card_seq AND T2.Company_Seq =  @Company_Seq AND T2.IsDisplay = '1')
		 INNER JOIN bar_shop1.dbo.S2_CardDetailEtc AS T3 WITH(NOLOCK) ON (T2.Card_Seq = T3.card_seq)
		 INNER JOIN bar_shop1.dbo.manage_code      AS T4 WITH(NOLOCK) ON (T3.card_category = T4.code AND T4.code_type ='etcprod' AND T4.use_yorn = 'Y')
		 WHERE T1.Card_Seq = @Card_Seq
		   AND T1.DISPLAY_YORN = 'Y'

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

EXEC bar_shop1.dbo.PROC_SELECT_GIFT_DETAIL
     38189
   , '5001'
   , @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/ 
GO
