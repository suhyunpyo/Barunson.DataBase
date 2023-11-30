IF OBJECT_ID (N'dbo.usp_premierpaper_coupon_issue_insert', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_premierpaper_coupon_issue_insert
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*******************************************************
1.대상자 쿠폰 일괄 등록은 2020년 8월5일 1회 실행.
2.해당 프로시저 등록 배치는 이벤트 시작 익일인 2020년 8월 6일 부터 실행.
usp_premierpaper_coupon_issue_insert
*********************************************************/
CREATE PROCEDURE [dbo].[usp_premierpaper_coupon_issue_insert]
AS
BEGIN

    DECLARE @COMPANY_SEQ INT = 5003
	DECLARE @SALES_GUBUN VARCHAR(100) = 'SS' --프리미어페이퍼
	DECLARE @COUPON_CODE VARCHAR(100) = '1BEA-B84B-43EE-8018' -- NEW_PRODUCT_COUPON_FW_신제품전용쿠폰

	--커서를 이용하여 해당되는 고객정보를 얻는다.
	DECLARE CUR_USER_FOR_COUPON CURSOR FAST_FORWARD
	FOR
	
	SELECT
	RTRIM(LTRIM(uid))  
	FROM s2_userinfo a
	WHERE SITE_DIV ='SS' --프페 계정에서
	AND REFERER_SALES_GUBUN ='SS' --유입사이트가 프페
	AND INTERGRATION_DATE >= '2019-08-05' -- 가입일 1년 이내
	AND uid not in 
	(
		--자사 모든 브랜드 내 청첩장 결제 이력 X
		SELECT  member_id 
		FROM custom_order 
		WHERE 1=1
		AND order_type in (1,6,7) --청접장
		AND settle_status = 2 --결제이력이 있는 계정
		AND a.uid = member_id
	)
	AND CONVERT(CHAR(8),a.INTERGRATION_DATE,112) = CONVERT(CHAR(8),DATEADD(dd, -1, GETDATE()),112) --가입일이 전일인 경우 : 8월5일 대상 일괄 처리시 해당부분 주석처리!!!
	

	OPEN CUR_USER_FOR_COUPON

	DECLARE @USER_ID VARCHAR(100)

	FETCH NEXT FROM CUR_USER_FOR_COUPON INTO @USER_ID

	WHILE @@FETCH_STATUS = 0

	BEGIN
		--쿠폰발급
		EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, @SALES_GUBUN, @USER_ID, @COUPON_CODE

		FETCH NEXT FROM CUR_USER_FOR_COUPON INTO @USER_ID
	END

	CLOSE CUR_USER_FOR_COUPON

	DEALLOCATE CUR_USER_FOR_COUPON

END
GO
