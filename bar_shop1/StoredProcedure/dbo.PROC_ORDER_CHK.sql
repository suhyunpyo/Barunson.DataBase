IF OBJECT_ID (N'dbo.PROC_ORDER_CHK', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_ORDER_CHK
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_ORDER_CHK
-- Author        : 박혜림
-- Create date   : 2022-10-17
-- Description   : 주문여부 체크
-- Update History:
-- Comment       : Type으로 구분하여 확장 사용 가능
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_ORDER_CHK]
	  @TYPE         VARCHAR(20)	-- 구분(MDDisplayCard:MD전시 청첩장 주문, Card:청첩장 주문, Sample: 샘플주문)
	, @MEMBER_ID    VARCHAR(50)	-- 아이디
	, @SALES_GUBUN  VARCHAR(10)	-- 사이트 구분
	, @MD_SEQ       INT			-- 전시 구분
-----------------------------------------------------------------------------------------------------------------     
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

----------------------------------------------------------------------------------------------------
-- Declare Block
----------------------------------------------------------------------------------------------------
DECLARE @ORDER_CNT INT
      , @ORDER_YN  VARCHAR(1)

SET @ORDER_YN = 'N'

----------------------------------------------------------------------------------------------------
-- Execute Block
----------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY
	
		----------------------------------------------------------------------------------
		-- 청첩장 주문 여부 체크
		----------------------------------------------------------------------------------
		IF @TYPE = 'Card'
		BEGIN
			SELECT @ORDER_CNT = COUNT(*)
			  FROM bar_shop1.dbo.custom_order AS T1 WITH(NOLOCK)
			 WHERE T1.member_id = @MEMBER_ID
			   AND T1.sales_Gubun = @SALES_GUBUN
			   AND T1.status_seq NOT IN (3,5)	-- 주문취소건 제외
			   AND T1.settle_status = 2			-- 결제완료
			   AND T1.settle_date IS NOT NULL
		END

		----------------------------------------------------------------------------------
		-- 특정 청첩장 주문 여부 체크(전시관리 연동)
		----------------------------------------------------------------------------------
		IF @TYPE = 'MDDisplayCard'
		BEGIN
			SELECT @ORDER_CNT = COUNT(*)
			  FROM bar_shop1.dbo.custom_order      AS T1 WITH(NOLOCK)
			 INNER JOIN bar_shop1.dbo.S4_MD_Choice AS T2 WITH(NOLOCK) ON (T1.card_seq = T2.CARD_SEQ AND T2.MD_SEQ = @MD_SEQ)
			 WHERE T1.member_id = @MEMBER_ID
			   AND T1.sales_Gubun = @SALES_GUBUN
			   AND T1.status_seq NOT IN (3,5)	-- 주문취소건 제외
			   AND T1.settle_status = 2			-- 결제완료
			   AND T1.settle_date IS NOT NULL
		END

		----------------------------------------------------------------------------------
		-- 샘플 주문 여부(추후 개발 예정)
		----------------------------------------------------------------------------------
		--IF @TYPE = 'Sample'
		--BEGIN
		--END

		
		----------------------------------------------------------------------------------
		-- 이벤트 응모한 경우
		----------------------------------------------------------------------------------
		IF @ORDER_CNT > 0
		BEGIN
			SET @ORDER_YN = 'Y'
		END

		SELECT @ORDER_YN AS ORDER_YN


	END TRY


	BEGIN CATCH
		SELECT  @ErrNum   = ERROR_NUMBER()
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

EXEC bar_shop1.dbo.PROC_ORDER_CHK 'MDDisplayCard', 's4guest', 'SB', 979, '', '', '', '', '', ''

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/
GO
