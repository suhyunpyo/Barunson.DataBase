IF OBJECT_ID (N'dbo.SP_SELECT_USER_INFO_FOR_SAVE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_USER_INFO_FOR_SAVE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_SELECT_USER_INFO_FOR_SAVE '', 'SB|SA|ST|SS|B|C|H|BE|', '2017-01-01', '2017-06-01', '', '', 'N', '', '', '', 'N', 0

*/

CREATE PROCEDURE [dbo].[SP_SELECT_USER_INFO_FOR_SAVE]
		@P_SEARCH_VALUE								AS VARCHAR(100)
	,	@P_SIGN_UP_SITE								AS VARCHAR(50)
	,	@P_SIGN_UP_START_DATE						AS VARCHAR(10)
	,	@P_SIGN_UP_END_DATE							AS VARCHAR(10)
	,	@P_WEDDING_START_DATE						AS VARCHAR(10)
	,	@P_WEDDING_END_DATE							AS VARCHAR(10)
	,	@P_SAMPLE_ORDER_YORN						AS VARCHAR(10)
	,	@P_SAMPLE_ORDER_START_DATE					AS VARCHAR(10)
	,	@P_SAMPLE_ORDER_END_DATE					AS VARCHAR(10)
	,	@P_WEDDING_PLACE							AS VARCHAR(200)
	,	@P_WEDDINGINVITATION_ORDER_YORN				AS VARCHAR(10)
	,	@P_WEDDINGINVITATION_ORDER_QNT				AS INT
	,	@P_COUPON_MST_SEQ							AS INT
	,	@OUT_PARAM									AS INT OUTPUT

AS
BEGIN
	
	SET NOCOUNT ON;

	/* 쿼리 속도 향상을 위한 기준 날짜 (통합회원 이후 건들만 조회) */
	DECLARE @BASE_DATE AS DATETIME = '2016-07-01 00:00:00';

	--전체적용일경우 기존 DB정보는 삭제해달라함.(김현주D와 협의)
	DELETE FROM COUPON_APPLY_USER WHERE COUPON_MST_SEQ = @P_COUPON_MST_SEQ;

	WITH CTE_USER_INFO AS
	(

		SELECT	UId
		FROM	(

					SELECT	DISTINCT
							SUI.UID																AS UId
						,	SUI.UNAME															AS UName
						,	SUI.INTERGRATION_DATE												AS RegDate
						,	SUI.hand_phone1 + '-' + SUI.hand_phone2 + '-' + SUI.hand_phone3		AS Hphone

					FROM	S2_USERINFO_THECARD SUI

					/* 테스트 결과 WHERE 절에서 EXISTS 또는 NOT EXISTS 로 사용하는것 보다 LEFT JOIN이 빨라서 LEFT JOIN 으로 적용 */
					--LEFT
					--JOIN	(

					--			SELECT	MEMBER_ID
					--			FROM	CUSTOM_ORDER CO
					--			JOIN	CUSTOM_ORDER_WEDDINFO COW ON CO.ORDER_SEQ = COW.ORDER_SEQ
					--			WHERE	1 = 1
					--			AND		CO.ORDER_DATE >= @BASE_DATE
					--			AND		CO.SETTLE_STATUS = 2 
					--			AND		CO.ORDER_COUNT >= @P_WEDDINGINVITATION_ORDER_QNT
					--			AND		CO.UP_ORDER_SEQ IS NULL
					--			AND		CO.ORDER_TYPE IN (1,6,7)
					--			AND		(@P_WEDDING_PLACE = '' OR LEFT(ISNULL(COW.WEDD_ADDR, ''), 2) IN ( SELECT VALUE FROM dbo.[ufn_SplitTable](@P_WEDDING_PLACE, '|') ))
					--			--AND		(@P_WEDDING_PLACE = '' OR @P_WEDDING_PLACE LIKE '%' + LEFT(ISNULL(COW.WEDD_ADDR, ''), 2) + '%')
								
					--		) CO ON SUI.UID = CO.MEMBER_ID 
					
					/* 샘플은 LEFT JOIN보다 EXISTS 또는 NOT EXISTS 로 사용하는것이 조금이라도 성능향상이 있길래, LEFT JOIN으로 사용 안함 */
					--LEFT
					--JOIN	(

					--			SELECT	MEMBER_ID
					--			FROM	CUSTOM_SAMPLE_ORDER 
					--			WHERE	1 = 1
					--			AND		REQUEST_DATE >= @BASE_DATE
					--			AND		CASE WHEN @P_SAMPLE_ORDER_START_DATE = '' THEN '' ELSE REQUEST_DATE END 
					--					>= 
					--					@P_SAMPLE_ORDER_START_DATE
					--			AND		CASE WHEN @P_SAMPLE_ORDER_END_DATE = '' THEN 0 ELSE REQUEST_DATE END 
					--					<
					--					CASE WHEN @P_SAMPLE_ORDER_END_DATE = '' THEN 1 ELSE DATEADD(DAY, 1, @P_SAMPLE_ORDER_END_DATE) END 

					--		) CSO ON SUI.UID = CSO.MEMBER_ID

					WHERE	1 = 1

					AND		SUI.INTERGRATION_DATE >= @BASE_DATE

					/* 샘플 주문 여부 */
					AND		(
									(@P_SAMPLE_ORDER_YORN = '')
								OR	(	
											@P_SAMPLE_ORDER_YORN = 'Y'
										AND		EXISTS 	(
															SELECT	MEMBER_ID
															FROM	CUSTOM_SAMPLE_ORDER 
															WHERE	MEMBER_ID = SUI.UID
															AND		REQUEST_DATE >= @BASE_DATE
															AND		CASE WHEN @P_SAMPLE_ORDER_START_DATE = '' THEN '' ELSE REQUEST_DATE END 
																	>= 
																	@P_SAMPLE_ORDER_START_DATE
															AND		CASE WHEN @P_SAMPLE_ORDER_END_DATE = '' THEN 0 ELSE REQUEST_DATE END 
																	<
																	CASE WHEN @P_SAMPLE_ORDER_END_DATE = '' THEN 1 ELSE DATEADD(DAY, 1, @P_SAMPLE_ORDER_END_DATE) END 
														)
									)
								OR	(		
											@P_SAMPLE_ORDER_YORN = 'N'
										AND NOT EXISTS	(
															SELECT	MEMBER_ID 
															FROM	CUSTOM_SAMPLE_ORDER 
															WHERE	MEMBER_ID = SUI.UID
															AND		REQUEST_DATE >= @BASE_DATE
															AND		CASE WHEN @P_SAMPLE_ORDER_START_DATE = '' THEN '' ELSE REQUEST_DATE END 
																	>= 
																	@P_SAMPLE_ORDER_START_DATE
															AND		CASE WHEN @P_SAMPLE_ORDER_END_DATE = '' THEN 0 ELSE REQUEST_DATE END 
																	<
																	CASE WHEN @P_SAMPLE_ORDER_END_DATE = '' THEN 1 ELSE DATEADD(DAY, 1, @P_SAMPLE_ORDER_END_DATE) END 
														)
									)

							)

					/* 청첩장 주문 여부 */
					--AND		(
					--				(@P_WEDDINGINVITATION_ORDER_YORN = '')
					--			OR	(@P_WEDDINGINVITATION_ORDER_YORN = 'Y' AND CO.MEMBER_ID IS NOT NULL)
					--			OR	(@P_WEDDINGINVITATION_ORDER_YORN = 'N' AND CO.MEMBER_ID IS NULL)
					--		)

					AND		(
									(@P_WEDDINGINVITATION_ORDER_YORN = '')
								OR	(
											@P_WEDDINGINVITATION_ORDER_YORN = 'Y' 
										AND EXISTS (
												SELECT	DISTINCT MEMBER_ID
												FROM	CUSTOM_ORDER CO
												JOIN	CUSTOM_ORDER_WEDDINFO COW ON CO.ORDER_SEQ = COW.ORDER_SEQ
												WHERE	1 = 1
												AND		CO.MEMBER_ID = SUI.UID
												AND		CO.ORDER_DATE >= @BASE_DATE
												AND		CO.SETTLE_STATUS = 2 
												AND		CO.ORDER_COUNT >= @P_WEDDINGINVITATION_ORDER_QNT
												AND		CO.UP_ORDER_SEQ IS NULL
												AND		CO.ORDER_TYPE IN (1,6,7)												
												AND		(@P_WEDDING_PLACE = '' OR @P_WEDDING_PLACE LIKE '%' + LEFT(ISNULL(COW.WEDD_ADDR, ''), 2) + '%')
											)
									)

								OR	(
											@P_WEDDINGINVITATION_ORDER_YORN = 'N' 
										AND NOT EXISTS(
												SELECT	DISTINCT MEMBER_ID
												FROM	CUSTOM_ORDER CO
												JOIN	CUSTOM_ORDER_WEDDINFO COW ON CO.ORDER_SEQ = COW.ORDER_SEQ
												WHERE	1 = 1
												AND		CO.MEMBER_ID = SUI.UID
												AND		CO.ORDER_DATE >= @BASE_DATE
												AND		CO.SETTLE_STATUS = 2 
												AND		CO.ORDER_COUNT >= @P_WEDDINGINVITATION_ORDER_QNT
												AND		CO.UP_ORDER_SEQ IS NULL
												AND		CO.ORDER_TYPE IN (1,6,7)
												AND		(@P_WEDDING_PLACE = '' OR @P_WEDDING_PLACE LIKE '%' + LEFT(ISNULL(COW.WEDD_ADDR, ''), 2) + '%')
											)
									)
							)

					/* 가입 사이트 */
					AND		(
									ISNULL(SUI.REFERER_SALES_GUBUN, ISNULL(SELECT_SALES_GUBUN, 'SB')) IN ( SELECT VALUE FROM dbo.[ufn_SplitTable](@P_SIGN_UP_SITE, '|') )
								OR	@P_SIGN_UP_SITE = ''
							)

					/* 통합회원 가입일 */
					AND		CASE WHEN @P_SIGN_UP_START_DATE = '' THEN '' ELSE SUI.INTERGRATION_DATE END 
							>= 
							@P_SIGN_UP_START_DATE
					AND		CASE WHEN @P_SIGN_UP_END_DATE = '' THEN 0 ELSE SUI.INTERGRATION_DATE END 
							<
							CASE WHEN @P_SIGN_UP_END_DATE = '' THEN 1 ELSE DATEADD(DAY, 1, @P_SIGN_UP_END_DATE) END 

					/* 검색어 */
					AND		(	
									SUI.UID LIKE '%' + @P_SEARCH_VALUE + '%'
								OR	SUI.UNAME LIKE '%' + @P_SEARCH_VALUE + '%'
							)

					/* 결혼예정일 */
					AND		CASE WHEN @P_WEDDING_START_DATE = '' THEN '' ELSE SUI.WEDD_YEAR + '-' + SUI.WEDD_MONTH + '-' + SUI.WEDD_DAY END
							>=
							@P_WEDDING_START_DATE
					AND		CASE WHEN @P_WEDDING_END_DATE = '' THEN '' ELSE SUI.WEDD_YEAR + '-' + SUI.WEDD_MONTH + '-' + SUI.WEDD_DAY END
							<=
							@P_WEDDING_END_DATE
				) A
	)

	insert into COUPON_APPLY_USER (COUPON_MST_SEQ,UID,USER_ALLOW_YN)
	SELECT	@P_COUPON_MST_SEQ, UId, 'Y'
	FROM	CTE_USER_INFO

	SET @OUT_PARAM = 1;
END
GO
