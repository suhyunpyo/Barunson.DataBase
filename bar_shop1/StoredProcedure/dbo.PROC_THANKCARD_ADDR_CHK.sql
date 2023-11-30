IF OBJECT_ID (N'dbo.PROC_THANKCARD_ADDR_CHK', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_THANKCARD_ADDR_CHK
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_THANKCARD_ADDR_CHK
-- Author        : 박혜림
-- Create date   : 2020-11-16
-- Description   : 경상도 감사장 배너 노출 관련 추소 체크
-- Update History:
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_THANKCARD_ADDR_CHK]
      @Order_Seq INT	-- 주문번호
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
DECLARE @ADDR_COUNT_1 INT
      , @ADDR_COUNT_2 INT
      , @ADDR_COUNT_3 INT
	  , @ADDR_YN      CHAR(1)

SET @ADDR_COUNT_1 = 0
SET @ADDR_COUNT_2 = 0
SET @ADDR_COUNT_3 = 0
SET @ADDR_YN = 'N'

----------------------------------------------------------------------------------------------------
-- Execute Block
----------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY	
		----------------------------------------------------------------------------------
		-- 예식장 주소 체크
		----------------------------------------------------------------------------------
		SELECT @ADDR_COUNT_1 = COUNT(*)
		  FROM bar_shop1.dbo.custom_order_WeddInfo WITH(NOLOCK)
		 WHERE order_seq = @Order_Seq
		   AND ((wedd_addr LIKE '경남%'
		    OR wedd_addr LIKE '경북%'
			OR wedd_addr LIKE '부산%'
			OR wedd_addr LIKE '대구%'
			OR wedd_addr LIKE '울산%')
			OR (wedd_road_Addr LIKE '경남%'
			OR wedd_road_Addr LIKE '경북%'
			OR wedd_road_Addr LIKE '부산%'
			OR wedd_road_Addr LIKE '대구%'
			OR wedd_road_Addr LIKE '울산%'))

		----------------------------------------------------------------------------------
		-- 배송지 주소 체크
		----------------------------------------------------------------------------------
		SELECT @ADDR_COUNT_2 = COUNT(*)
		  FROM bar_shop1.dbo.DELIVERY_INFO WITH(NOLOCK)
		 WHERE order_seq = @Order_Seq
		   AND (ADDR LIKE '경남%'
		    OR ADDR LIKE '경북%' 
			OR ADDR LIKE '부산%'
			OR ADDR LIKE '대구%'
			OR ADDR LIKE '울산%')

		----------------------------------------------------------------------------------
		-- 봉투 주소 체크
		----------------------------------------------------------------------------------
		SELECT @ADDR_COUNT_3 = COUNT(*)
		  FROM bar_shop1.dbo.custom_order_plist WITH(NOLOCK)
		 WHERE order_seq = @Order_Seq
		   AND print_type = 'E'
		   AND env_addr IS NOT NULL
		   AND (env_addr LIKE '경남%'
		    OR env_addr LIKE '경북%' 
			OR env_addr LIKE '부산%'
			OR env_addr LIKE '대구%'
			OR env_addr LIKE '울산%')
		
		----------------------------------------------------------------------------------
		-- 경상도 소재의 주소가 존재하는 경우
		----------------------------------------------------------------------------------
		IF @ADDR_COUNT_1 > 0 OR @ADDR_COUNT_2 > 0 OR @ADDR_COUNT_3 > 0
		BEGIN
			SET @ADDR_YN = 'Y'
		END


		SELECT @ADDR_YN AS ADDR_YN


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

EXEC bar_shop1.dbo.PROC_THANKCARD_ADDR_CHK 3074929, '', '', '', '', '', ''

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/
GO
