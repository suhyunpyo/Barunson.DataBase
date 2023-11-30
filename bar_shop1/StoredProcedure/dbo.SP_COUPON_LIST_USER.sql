IF OBJECT_ID (N'dbo.SP_COUPON_LIST_USER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_COUPON_LIST_USER
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Author		:	황새롬
	Create date	:	2017-07-18
	Description	:	마이페이지 통합쿠폰 리스트

	EXEC SP_COUPON_LIST_USER 5007, 'mcmr56'

	기본쿠폰, 중복쿠폰, AD쿠폰 : 청첩장, 감사장, 초대장 카드할인금액에서 할인 (복수)
	추가쿠폰 : 기타 서비스 할인 (단수)

*/
 CREATE PROCEDURE [dbo].[SP_COUPON_LIST_USER]
		@COMPANY_SEQ				AS VARCHAR(4)
	,	@UID						AS VARCHAR(100)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT			CASE WHEN LTRIM(T.CMMN_CODE) ='식전영상' or LTRIM(T.CMMN_CODE) ='바른손스토어' or T.COUPON_MST_SEQ =  348 or T.COUPON_NAME ='삼성전자 제휴쿠폰 - 인천공항 라운지 이용권' THEN 
                    CASE WHEN T.COUPON_MST_SEQ = 103 THEN
                        '묘미제휴쿠폰'
                         WHEN T.COUPON_MST_SEQ = 132 OR T.COUPON_MST_SEQ = 133 OR T.COUPON_MST_SEQ = 134 THEN
                        '롯데면세점'
                        WHEN T.COUPON_MST_SEQ = 138 OR T.COUPON_MST_SEQ = 139 OR T.COUPON_MST_SEQ = 140 THEN
                        '롯데면세점'
                        WHEN T.COUPON_MST_SEQ = 135 OR T.COUPON_MST_SEQ = 136 OR T.COUPON_MST_SEQ = 137 THEN
                        '롯데면세점'
                        WHEN T.COUPON_MST_SEQ = 142 OR T.COUPON_MST_SEQ = 143 OR T.COUPON_MST_SEQ = 144 THEN
                        '롯데면세점'
                        WHEN T.COUPON_MST_SEQ = 217 OR T.COUPON_MST_SEQ = 214 OR T.COUPON_MST_SEQ = 215 THEN
                        '롯데면세점'
                        WHEN T.COUPON_MST_SEQ = 216 OR T.COUPON_MST_SEQ = 213 THEN
                        '롯데면세점'
                        WHEN T.COUPON_MST_SEQ = 171 OR T.COUPON_MST_SEQ = 172 THEN
                        'WIFI도시락'
                        WHEN T.COUPON_MST_SEQ = 160 OR T.COUPON_MST_SEQ =  292 OR T.COUPON_MST_SEQ =  304 OR T.COUPON_MST_SEQ =  348 THEN
                        '웨딩초대영상'
  						when T.COUPON_MST_SEQ = 519 OR T.COUPON_MST_SEQ =  520 OR T.COUPON_MST_SEQ =  521 OR T.COUPON_MST_SEQ =  522 OR T.COUPON_MST_SEQ =  523 THEN
						'라운지 이용권'
                         WHEN T.COUPON_MST_SEQ = 632 OR T.COUPON_MST_SEQ =  628 OR T.COUPON_MST_SEQ =  627 OR T.COUPON_MST_SEQ =  626 THEN
                        '감사인사영상'
                    ELSE
                        (T.CMMN_CODE) 
                    END
            ELSE T.DISCOUNT END AS DISCOUNT


		   , CASE WHEN LTRIM(T.CMMN_CODE) ='식전영상' or LTRIM(T.CMMN_CODE) ='바른손스토어' or T.COUPON_MST_SEQ =  348 or COUPON_NAME ='삼성전자 제휴쿠폰 - 인천공항 라운지 이용권' THEN T.COUPON_CODE ELSE T.COUPON_NAME END AS COUPON_NAME
		   , T.DTL_NAME
		   , T.START_DATE
		   , T.EXPIRY_TYPE
		   , T.EXPIRY_CUSTOM_VALUE
		   , T.END_DATE
		   , T.USE_DEVICE
		   , T.EXPIRES_YN
		   , T.COUPON_DESC
		   , T.CMMN_CODE
	FROM
	(
		SELECT	CC.DTL_NAME																	-- 쿠폰종류 (기본/중복/추가할인)
			,	REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,DISCOUNT_VALUE),1),'.00','')
			+	CASE WHEN DISCOUNT_FIXED_RATE_TYPE = 'W' THEN '원' ELSE '%' END AS DISCOUNT	-- 할인액
			,	COUPON_NAME																	-- 쿠폰명
			,	CD.COUPON_CODE
			,	CONVERT(VARCHAR, EXPIRY_START_DATE, 23) AS START_DATE						-- 시작일
			,	EXPIRY_TYPE
			,	EXPIRY_CUSTOM_VALUE
			,	CASE EXPIRY_TYPE								
								WHEN 'V' THEN CONVERT(VARCHAR, CI.END_DATE, 23)
								WHEN 'P' THEN CONVERT(VARCHAR, EXPIRY_END_DATE, 23)
				END AS END_DATE																-- 종료일
			,	CASE USE_DEVICE WHEN 'A' THEN 'PC/MOBILE'
								WHEN 'P' THEN 'PC'
								WHEN 'M' THEN 'MOBILE'
				END AS USE_DEVICE															-- 사용처
			,	CASE WHEN END_DATE < GETDATE() THEN 'Y' ELSE 'N' END AS EXPIRES_YN			-- 기간만료 : Y , 기간남음 : N
			,	ACTIVE_YN																	-- 사용가능 : Y	, 사용완료 : N
			,	COUPON_DESC																	-- 쿠폰내용
			,	STUFF
				(
					(
						SELECT	', ' + CC_SERVICE.DTL_NAME 
						FROM	COUPON_APPLY_SERVICE CAS 
						JOIN	COMMON_CODE CC_SERVICE ON CAS.CMMN_CODE = CC_SERVICE.CMMN_CODE  
						WHERE	COUPON_MST_SEQ = CD.COUPON_MST_SEQ 
						AND		CC_SERVICE.CLSS_CODE != 132
						FOR XML PATH ('')
					),1,1,''
				) AS CMMN_CODE
			,	CI.REG_DATE
            ,   CM.COUPON_MST_SEQ
		FROM	COUPON_ISSUE	CI 
		JOIN	COUPON_DETAIL	CD	ON CI.COUPON_DETAIL_SEQ = CD.COUPON_DETAIL_SEQ
		JOIN	COUPON_MST		CM	ON CD.COUPON_MST_SEQ = CM.COUPON_MST_SEQ
		JOIN	COMMON_CODE		CC	ON CC.CMMN_CODE = CM.COUPON_TYPE_CODE
		WHERE	1 = 1
		AND		CI.UID = @UID
		AND		CI.COMPANY_SEQ = @COMPANY_SEQ
		AND		CI.ACTIVE_YN = 'Y'

	) T
	ORDER BY	T.EXPIRES_YN ASC
	,		T.REG_DATE DESC

END
GO
