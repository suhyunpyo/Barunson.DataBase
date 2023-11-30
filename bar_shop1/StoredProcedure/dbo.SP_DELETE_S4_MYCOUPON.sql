IF OBJECT_ID (N'dbo.SP_DELETE_S4_MYCOUPON', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_DELETE_S4_MYCOUPON
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************  
 EXEC SP_DELETE_S4_MYCOUPON
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_DELETE_S4_MYCOUPON]  
AS  
BEGIN  
  
	DECLARE @UID	VARCHAR(50)  
	DECLARE @COUPON_CODE VARCHAR(50)  
	DECLARE @CNT INT
    DECLARE @DELETE_CNT INT   	     
	   
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD  
 FOR  

  select uid, coupon_code, cnt , (cnt-1) delete_cnt from (
	select uid, coupon_code, count(*) cnt
	from (
	select uid, coupon_code  
	from s4_mycoupon where reg_date >= '2019-01-01'
	and uid <>'' and coupon_code <> '' 
	) a group by uid, coupon_code
	) b where cnt > 1
	ORDER BY CNT DESC

 
  
 OPEN cur_AutoInsert_For_Order  
  
 DECLARE @MMS_DATE VARCHAR(100)  
 DECLARE @PHONE_NUM VARCHAR(100)  
 DECLARE @U_ID VARCHAR(100)  
 DECLARE @SERVICE VARCHAR(4)  
  
 DECLARE @MMS_MSG VARCHAR(MAX)  
 DECLARE @MMS_SUBJECT VARCHAR(60)  
 DECLARE @CALLBACK VARCHAR(50)  
 DECLARE @ETC_INFO VARCHAR(50)  
 DECLARE @chkCnt INT;  
 DECLARE @CHK_SMS VARCHAR(1);   
 
 DECLARE @EVT_URL  VARCHAR(MAX)  --4.이벤트 주소  
 DECLARE @NO_REC_BRAND VARCHAR(50) --4.수신거부 브랜드  
 --DECLARE @NO_REC_TEL  VARCHAR(50) --4.수신거부 전화번호  

DECLARE @CONTENT_DATA   VARCHAR(250)	--(MMS)파일명^컨텐츠타입^컨텐츠서브타입 ex)http://www.test.com/test.jpg^1^0|http://www.test.com/test.jpg^1^0|~
DECLARE @MSG_TYPE       INT			--(MMS)메시지 구분(TEXT:0, HTML:1)

DECLARE @DEST_INFO	VARCHAR(100)

 FETCH NEXT FROM cur_AutoInsert_For_Order INTO @UID,  @COUPON_CODE, @CNT, @DELETE_CNT
  
 WHILE @@FETCH_STATUS = 0  
  
 BEGIN

	DELETE TOP (@DELETE_CNT) FROM S4_MYCOUPON WHERE UID =@UID AND COUPON_CODE = @COUPON_CODE 
  
  FETCH NEXT FROM cur_AutoInsert_For_Order INTO @UID,  @COUPON_CODE, @CNT, @DELETE_CNT
 END  
  
 CLOSE cur_AutoInsert_For_Order  
 DEALLOCATE cur_AutoInsert_For_Order  
END
GO
