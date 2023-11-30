IF OBJECT_ID (N'dbo.PROC_COUPON_LIST_BARUNSONMALL', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_COUPON_LIST_BARUNSONMALL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_COUPON_LIST_BARUNSONMALL
-- Author        : 박혜림
-- Create date   : 2022-01-09
-- Description   : 마이페이지 > 쿠폰보관함(바른손몰)
-- Update History:
-- Comment       : 웹/모바일 공통
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_COUPON_LIST_BARUNSONMALL]
       @Type               VARCHAR(20)	--Card:청첩장쿠폰, Jehu:제휴쿠폰
	 , @Member_YN          CHAR(1)
	 , @Company_Login_ID   VARCHAR(20)
	 , @UID                VARCHAR(50)
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
		-- 청첩장 쿠폰 조회
		----------------------------------------------------------------------------------
		IF @Type = 'Card'
		BEGIN
			SELECT T1.coupon_code
				    , T1.coupon_desc
					, T1.discount_type
					, T1.discount_value
					, ISNULL(T1.CouponLinkName, '') AS CouponLinkName
					, ISNULL(T1.CouponLinkUrl, '') AS CouponLinkUrl
					, ISNULL(T1.Memo, '') AS Memo
					, ISNULL(T1.MemoLinkName, '') AS MemoLinkName
					, ISNULL(T1.MemoLinkUrl, '') AS MemoLinkUrl
					, CONVERT(VARCHAR, ISNULL(T2.End_date, '9999-12-31 23:59:59'), 23) AS End_date
				FROM s4_coupon        AS T1 WITH(NOLOCK)
				INNER JOIN s4_myCoupon AS T2 WITH(NOLOCK) ON (T1.coupon_code = T2.coupon_code AND T2.uid = @UID AND T2.isMyYN = 'Y')
				WHERE T1.isJehu = 'Y'
				--AND T1.COUPON_TYPE_CODE IN ('114001','114002','114003','114004','114005','114006','114008','114013','114014','114015')
				AND T1.COUPON_TYPE_CODE NOT IN ('114007')
				AND (T1.company_seq = 5006 OR T1.company_seq IN ( SELECT company_seq
																	FROM COMPANY
																	WHERE Login_ID = @Company_Login_ID
																	AND SALES_GUBUN IN ('B','C','H')
																	AND [STATUS] = 'S2'
																))
			ORDER BY T1.reg_date DESC
		END	
		ELSE IF @Type = 'Jehu'
		BEGIN
			SELECT T1.coupon_code
			     , T2.MD_TITLE AS jehu_name
			     , T2.CARD_TEXT AS coupon_info
				 , T2.MD_CONTENT AS coupon_notice
				 , T2.MD_DESC AS brand_evtUrl
				 , T2.IMGFILE_PATH AS imgfile_path
				 , CONVERT(CHAR(10),T1.end_date, 23) AS end_date
				 , T2.LINK_URL AS brand_Url
			  FROM JEHU_COUPONBOX_ISSUE AS T1 WITH(NOLOCK)
			 INNER JOIN S4_MD_Choice    AS T2 WITH(NOLOCK) ON (T1.jehu_company = T2.MD_TITLE AND T2.md_seq = 1000)
			 WHERE T1.uid = @UID
			   AND T1.SalesGubun = 'B'
			   AND T1.end_date >= GETDATE()
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

EXEC bar_shop1.dbo.PROC_COUPON_LIST_BARUNSONMALL
     'Jehu'
   , 'Y'
   , 'arina'
   , 's4guest'
   , @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/ 
GO
