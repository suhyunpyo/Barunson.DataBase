IF OBJECT_ID (N'dbo.SP_EXEC_MMS_SEND_FOR_GUUD', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_MMS_SEND_FOR_GUUD
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************  
  
- 까사미아 문자발송
- 조건 :
	전일 가입
	LMS 수신 동의 고객 (바, 더, 프, 몰, 비, 디 고객 전체)

 service  
 SB(바른손카드)/ SA(비핸즈)/ SS(프리미어페이퍼)/ ST(더카드)/ B(바른손몰)  
 exec SP_EXEC_MMS_SEND_FOR_GUUD

  010-9880-2629 김보미
  010-4720-0722 강솔
  010-8907-7890 제휴사

*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_MMS_SEND_FOR_GUUD]  
AS  
BEGIN  

	/****** 20201123 표수현 추가 START ****/
	DECLARE	@ErrNum   INT          
		  , @ErrSev   INT          
		  , @ErrState INT          
		  , @ErrProc  VARCHAR(50)  
		  , @ErrLine  INT          
		  , @ErrMsg   VARCHAR(2000)
	/****** 20201123 표수현 추가 END ****/

  
    DECLARE @TIME AS VARCHAR(10)  
    DECLARE @Today_Dt AS VARCHAR(8)  
    DECLARE @GUBUN AS VARCHAR(1)
	 
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_Uid CURSOR FAST_FORWARD  
 FOR  

 SELECT 
( SELECT CASE 
		WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN 
			CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(REFERER_SALES_GUBUN, 'SB') END
		ELSE 
			CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(SELECT_SALES_GUBUN, 'SB') END
	
	END 
	FROM S2_USERINFO_THECARD WHERE uid = a.uid) AS SITE_DIV
,HPHONE 
FROM ( 
  SELECT CASE WHEN INTEGRATION_MEMBER_YORN = 'N' THEN row_number()over(partition by A.HPHONE order by A.reg_date) 
      ELSE row_number()over(partition by A.UID order by A.reg_date) END rm 
    , SITE_DIV_NAME   
    , A.UID 
    , A.HPHONE 
    , REFERER_SALES_GUBUN  
	, chk_sms
  FROM ( 
    SELECT    SITE_DIV_NAME 
      , A.Reg_Date  
      , A.UID 
      , A.UNAME 
      , A.HPHONE    
      , A.REFERER_SALES_GUBUN 
      , ISNULL(A.INTEGRATION_MEMBER_YORN , 'N') INTEGRATION_MEMBER_YORN 
      , a.chk_sms
	 FROM VW_USER_INFO AS A  
     WHERE LEN(A.HPHONE) > 12   
     AND A.DupInfo IS NOT NULL    
     AND A.ConnInfo IS NOT NULL  
     AND a.INTERGRATION_DATE >= CONVERT(CHAR(10), getdate()-1, 23)
     AND a.INTERGRATION_DATE < CONVERT(CHAR(10), getdate(), 23)
     AND A.chk_sms = 'Y'     
    ) A  
 ) A 
WHERE RM = 1 

--	SELECT ( CASE 
--			WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN 
--				CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(REFERER_SALES_GUBUN, 'SB') END
--			ELSE 
--				CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(SELECT_SALES_GUBUN, 'SB') END
--		END ) as site_div  
--		,  '010-4720-0722'
--	FROM VW_USER_INFO AS A  
--	WHERE LEN(A.HPHONE) > 12   
--		AND A.DupInfo IS NOT NULL    
--		AND A.ConnInfo IS NOT NULL  
--		AND site_div ='SB'
--		AND uid ='s4guest' 

 OPEN cur_AutoInsert_For_Uid  
  
 DECLARE @MMS_DATE VARCHAR(100)  
 DECLARE @PHONE_NUM VARCHAR(100)  
 DECLARE @U_ID VARCHAR(100)  
 DECLARE @SERVICE VARCHAR(4)  
  
 DECLARE @MMS_MSG VARCHAR(MAX)  
 DECLARE @MMS_SUBJECT VARCHAR(60)  
 DECLARE @CALLBACK VARCHAR(50)  
 DECLARE @UID VARCHAR(50)  
 DECLARE @YYYYMMDD VARCHAR(10)
  
  
 DECLARE @NO_REC_BRAND VARCHAR(50) --4.수신거부 브랜드  
 --DECLARE @NO_REC_TEL  VARCHAR(50) --4.수신거부 전화번호 

 DECLARE @DEST_INFO	VARCHAR(100)  
 DECLARE @RESERVED4      VARCHAR(50)

 DECLARE @ORDER_CNT AS INT = 0

 FETCH NEXT FROM cur_AutoInsert_For_Uid INTO @SERVICE,  @PHONE_NUM
  
 WHILE @@FETCH_STATUS = 0  
  
 BEGIN  
        
   IF @SERVICE = 'SB'  
    BEGIN  
     SET @NO_REC_BRAND = '바른손카드'      
     SET @CALLBACK  = '1644-0708'  
    END  
   ELSE IF @SERVICE = 'SA'  
    BEGIN  
     SET @NO_REC_BRAND = '비핸즈카드'      
     SET @CALLBACK  = '1644-9713'  
    END  
  
   ELSE IF @SERVICE = 'ST'  
    BEGIN  
     SET @NO_REC_BRAND = '더카드'       
     SET @CALLBACK  = '1644-7998' 
    END  
   ELSE IF @SERVICE = 'B'  
    BEGIN  
     SET @NO_REC_BRAND = '바른손몰'      
     SET @CALLBACK  = '1644-7413'  
    END  
   ELSE  
    BEGIN  
     SET @NO_REC_BRAND = '프리미어페이퍼'      
     SET @CALLBACK  = '1644-8796'  
    END  

	
select @YYYYMMDD = convert(varchar, getdate()-1, 102) 

SET @RESERVED4 = '1'
  
SET @MMS_SUBJECT = '(광고) 신세계 까사미아 X ' + @NO_REC_BRAND


SET @MMS_MSG = '(광고) 신세계 까사미아 X ' + @NO_REC_BRAND +'

예신예랑 여러분의
새출발을 응원합니다 :)

Living&Lifestyle
신세계 까사미아에서
' + @NO_REC_BRAND +' 회원님께
특별한 혜택을 드립니다.

▶ 10만원 쿠폰과 굳포인트 2만점 적립!

① 우선 까사미아 회원가입하고
https://bit.ly/3jQctXG
 
② 웨딩클럽 가입하기
https://bit.ly/36zcMhH
 
---------------------------
더 많은 상품과 혜택 보기 및
가까운 까사미아 매장 찾기
http://i-casamia.com/
 
(문의) 까사미아 고객센터
☎ 1588-3408

※ 본 문자는 '+@YYYYMMDD+' 기준,
SMS수신 동의한 고객님께
발송되었습니다.
 
[수신거부] '+ @NO_REC_BRAND+' 고객센터
'+ @CALLBACK + '로 수신거부 문자 전송'
					 
 	SET @DEST_INFO = 'AA^'+@PHONE_NUM
	
		/* 2020-11-23 KT 문자 서비스 작업 변경 */
	SET @PHONE_NUM = '^' + @PHONE_NUM

	EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, @MMS_SUBJECT, @MMS_MSG, '', @CALLBACK, 1, @PHONE_NUM, 0, '', 0, @SERVICE, '', '', @RESERVED4, '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT
    	   
  FETCH NEXT FROM cur_AutoInsert_For_Uid INTO  @SERVICE,  @PHONE_NUM
 END  
  
 CLOSE cur_AutoInsert_For_Uid  
 DEALLOCATE cur_AutoInsert_For_Uid  
END
GO
