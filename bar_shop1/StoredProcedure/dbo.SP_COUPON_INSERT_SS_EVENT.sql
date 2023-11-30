IF OBJECT_ID (N'dbo.SP_COUPON_INSERT_SS_EVENT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_COUPON_INSERT_SS_EVENT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************  
  
2020-09-03 정혜련 
[프리미어페이퍼] 4분기 얼리버드

1. 이벤트 내용
- 20년 11월 ~ 21년 1월 예식자 대상
- 쿠폰 자동 발급 기간 : 2020년 9월3일 ~ 30일까지

2. 쿠폰 자동 발급 조건
1) 기존회원(20년 9월 2일 기준)
- 청첩장 미주문
- 회원정보 예식일 : 20년 11월 ~ 21년 1월
2) 신규회원
- 회원정보 예식일 : 20년 11월 ~ 21년 1월

EXEC SP_COUPON_INSERT_SS_EVENT
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_COUPON_INSERT_SS_EVENT]  
AS  
BEGIN  
 
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_coupon CURSOR FAST_FORWARD  
 FOR  

	select uid, wedd_month
	from (
	SELECT  a.uid, left(WEDDING_DAY,7) wedd_month
	,isnull((SELECT TOP  1 'Y' FROM CUSTOM_ORDER WHERE member_id = a.uid AND status_Seq > 0 AND status_seq NOT IN ('3','5') AND order_type IN ('1','6','7') ),'N') AS orderYN
	FROM VW_USER_INFO AS A  
	WHERE a.WEDDING_DAY >= '2020-11-01'
		AND a.WEDDING_DAY < '2021-02-01'	
		AND a.INTERGRATION_DATE >= CONVERT(CHAR(10), GETDATE()-1 , 23)
		AND a.INTERGRATION_DATE < CONVERT(CHAR(10), GETDATE(), 23)
		AND site_div ='SS'
		AND REFERER_SALES_GUBUN ='SS'
	) A where orderYN = 'N'

 OPEN cur_AutoInsert_For_coupon  
  
 
 DECLARE @UID VARCHAR(100)  
 DECLARE @SITE_DIV VARCHAR(4)  
 DECLARE @WEDD_MONTH VARCHAR(7) 
 DECLARE @COMPANY_SEQ INT 
 DECLARE @SALES_GUBUN VARCHAR(2)  
 DECLARE @COUPON_CODE VARCHAR(20)     
  
 FETCH NEXT FROM cur_AutoInsert_For_coupon INTO @UID, @WEDD_MONTH
  
 WHILE @@FETCH_STATUS = 0  
  
 BEGIN  
        
	SET @SALES_GUBUN = 'SS'
	SET @COMPANY_SEQ = '5003'
 
	IF @WEDD_MONTH = '2020-11'
		BEGIN 
			SET @COUPON_CODE = '0C37-F0C8-47C1-A3D7' 
		END
	ELSE IF 	@WEDD_MONTH = '2020-12'
		BEGIN 
			SET @COUPON_CODE = 'A93A-CEAB-4747-8F94' 
		END
	ELSE IF		@WEDD_MONTH = '2021-01'
		BEGIN 
			SET @COUPON_CODE = 'B342-8BA8-48DF-84E0' 
		END
									
   --쿠폰발급  
	EXEC	SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, @SALES_GUBUN, @UID, @COUPON_CODE
  
  FETCH NEXT FROM cur_AutoInsert_For_coupon INTO  @UID, @WEDD_MONTH
 END  
  
 CLOSE cur_AutoInsert_For_coupon  
 DEALLOCATE cur_AutoInsert_For_coupon  
END
GO
