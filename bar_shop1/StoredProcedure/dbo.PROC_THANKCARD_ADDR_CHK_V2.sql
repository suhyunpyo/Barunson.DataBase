IF OBJECT_ID (N'dbo.PROC_THANKCARD_ADDR_CHK_V2', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_THANKCARD_ADDR_CHK_V2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_THANKCARD_ADDR_CHK_V2
-- Author        : 박혜림
-- Create date   : 2022-09-23
-- Description   : 마이페이지 감사장 배너 노출 관련 주소 체크
-- Update History:
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_THANKCARD_ADDR_CHK_V2]
      @MEMBER_ID   VARCHAR(50)
	, @ORDER_EMAIL VARCHAR(50)
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
	  , @GSD_ADDR_YN  CHAR(1)
	  , @POPUP_YN     CHAR(1)

SET @ADDR_COUNT_1 = 0
SET @ADDR_COUNT_2 = 0
SET @ADDR_COUNT_3 = 0
SET @GSD_ADDR_YN  = 'N'
SET @POPUP_YN     = 'N'

----------------------------------------------------------------------------------------------------
-- Execute Block
----------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY

		----------------------------------------------------------------------------------
		-- 경상도 주문건 리스트
		----------------------------------------------------------------------------------
		SELECT T1.order_seq
		  INTO #GSD_ORDER_LIST
		  FROM bar_shop1.dbo.custom_order                     AS T1 WITH(NOLOCK)
		  LEFT OUTER JOIN bar_shop1.dbo.custom_order_WeddInfo AS T2 WITH(NOLOCK) ON (T1.order_seq = T2.order_seq AND ((T2.wedd_addr LIKE '경남%'
		                                                                                                          OR T2.wedd_addr LIKE '경북%'
																												  OR T2.wedd_addr LIKE '부산%'
																												  OR T2.wedd_addr LIKE '대구%'
																												  OR T2.wedd_addr LIKE '울산%')
																												  OR (T2.wedd_road_Addr LIKE '경남%'
																												  OR T2.wedd_road_Addr LIKE '경북%'
																												  OR T2.wedd_road_Addr LIKE '부산%'
																												  OR T2.wedd_road_Addr LIKE '대구%'
																												  OR T2.wedd_road_Addr LIKE '울산%')))
		  LEFT OUTER JOIN bar_shop1.dbo.DELIVERY_INFO      AS T3 WITH(NOLOCK) ON (T1.order_seq = T3.order_seq AND (T3.ADDR LIKE '경남%' OR T3.ADDR LIKE '경북%' OR T3.ADDR LIKE '부산%' OR T3.ADDR LIKE '대구%' OR T3.ADDR LIKE '울산%'))
		  LEFT OUTER JOIN bar_shop1.dbo.custom_order_plist AS T4 WITH(NOLOCK) ON (T1.order_seq = T4.order_seq AND T4.print_type = 'E' AND T4.env_addr IS NOT NULL AND (T4.env_addr LIKE '경남%' OR T4.env_addr LIKE '경북%' OR T4.env_addr LIKE '부산%' OR T4.env_addr LIKE '대구%' OR T4.env_addr LIKE '울산%'))
		 WHERE T1.member_id = (CASE WHEN @MEMBER_ID <> '' THEN @MEMBER_ID ELSE '' END)
		   AND T1.order_email = @ORDER_EMAIL
		   AND T1.order_type IN ('1','6','7')	-- 청첩장 주문건
		   AND T1.SALES_GUBUN = 'SB'
		   AND T1.settle_status = 2				-- 결제완료건
		   AND T1.status_seq NOT IN (3,5)		-- 주문/결제취소 제외
		   AND T1.up_order_seq IS NULL			-- 추가주문 제외
		   AND T1.settle_date IS NOT NULL
		   AND (T2.order_seq IS NOT NULL OR T3.order_seq IS NOT NULL OR T4.order_seq IS NOT NULL)
	
		----------------------------------------------------------------------------------
		-- 경상도 주문건 체크
		----------------------------------------------------------------------------------
		SELECT @ADDR_COUNT_1 = COUNT(*)
		  FROM #GSD_ORDER_LIST


		----------------------------------------------------------------------------------
		-- 경상도 주소가 아닌 주문건 체크
		----------------------------------------------------------------------------------
		SELECT @ADDR_COUNT_2 = COUNT(*)
		  FROM bar_shop1.dbo.custom_order AS T1 WITH(NOLOCK)
		  LEFT OUTER JOIN #GSD_ORDER_LIST AS T2 ON (T1.order_seq = T2.order_seq)
		 WHERE T1.member_id = (CASE WHEN @MEMBER_ID <> '' THEN @MEMBER_ID ELSE '' END)
		   AND T1.order_email = @ORDER_EMAIL
		   AND T1.order_type IN ('1','6','7')	-- 청첩장 주문건
		   AND T1.SALES_GUBUN = 'SB'
		   AND T1.settle_status = 2				-- 결제완료건
		   AND T1.status_seq NOT IN (3,5)		-- 주문/결제취소 제외
		   AND T1.up_order_seq IS NULL			-- 추가주문 제외
		   AND T1.settle_date IS NOT NULL
		   AND T2.order_seq IS NULL				-- 경상도 주소 주문건 제외

		
		----------------------------------------------------------------------------------
		-- 감사장 구매여부 체크
		----------------------------------------------------------------------------------
		SELECT @ADDR_COUNT_3 = COUNT(*)
		  FROM bar_shop1.dbo.custom_order WITH(NOLOCK)
		 WHERE member_id = (CASE WHEN @MEMBER_ID <> '' THEN @MEMBER_ID ELSE '' END)
		   AND order_email = @ORDER_EMAIL
		   AND order_type = '2'
		   AND SALES_GUBUN = 'SB'
		   AND settle_status = 2
		   AND status_seq NOT IN (3,5)
		
		----------------------------------------------------------------------------------
		-- 팝업 노출 여부 설정
		----------------------------------------------------------------------------------
		IF @ADDR_COUNT_1 > 0  AND @ADDR_COUNT_3 = 0	-- 경상도 주소 & 감사장 주문건 X
		BEGIN
			SET @GSD_ADDR_YN = 'Y'
			SET @POPUP_YN = 'Y'
		END
		ELSE IF @ADDR_COUNT_2 > 0  AND @ADDR_COUNT_3 = 0	-- 경상도 주문 X & 감사장 주문건 X
		BEGIN
			SET @GSD_ADDR_YN = 'N'
			SET @POPUP_YN = 'Y'
		END
		ELSE
		BEGIN
			SET @GSD_ADDR_YN = 'N'
			SET @POPUP_YN = 'N'
		END


		SELECT @GSD_ADDR_YN AS GSD_ADDR_YN
		     , @POPUP_YN AS POPUP_YN


		DROP TABLE #GSD_ORDER_LIST


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

EXEC bar_shop1.dbo.PROC_THANKCARD_ADDR_CHK_V2 'gpflawkd77', 'gpflawkd2@gmail.com', '', '', '', '', '', ''

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/
GO
