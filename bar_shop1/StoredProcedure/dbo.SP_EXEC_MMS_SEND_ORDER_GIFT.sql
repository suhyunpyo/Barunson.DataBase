IF OBJECT_ID (N'dbo.SP_EXEC_MMS_SEND_ORDER_GIFT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_MMS_SEND_ORDER_GIFT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************  
  
2020-08-27 정혜련  
2020-11-30 (KT로 변경)

- 답례품 주문건 관련 LMS 발송 요청
- 조건 :
- 전일(00:00~24:00) 답례품 업체별 발생한 주문건/취소건 익일 AM08:00발송
- 전일(00:00~24:00) 답례품 업체별 주문건/취소건 미발생시 발송x

 service  
 SB(바른손카드)/ SA(비핸즈)/ SS(프리미어페이퍼)/ ST(더카드)/ B(바른손몰)  
 exec SP_EXEC_MMS_SEND_ORDER_GIFT
 -- 010-8929-6592 나요셉님
 
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_MMS_SEND_ORDER_GIFT]  
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
	 

CREATE   Table #gift_order  (      
	today_Dt		nvarchar(8)			NOT NULL,
	order_type		nvarchar(4)			NOT NULL,
	OrderGb			nvarchar(1)			NOT NULL,
	order_Cnt	int			NOT NULL, 
) 
			
--기준정보 셋팅
INSERT INTO #gift_order 

SELECT convert(char(10), GETDATE(), 112) , order_type , 'Y' OrderGb ,  count(order_seq) cnt
from custom_Etc_order
where order_type IN ( SELECT code from manage_code where code_type ='etcprod' ) 
and settle_date >= CONVERT(CHAR(10), GETDATE() -1, 23)
and settle_date < CONVERT(CHAR(10), GETDATE()  , 23)
and status_seq not in ('3','5')  	
group by order_type 
UNION ALL
SELECT convert(char(10), GETDATE(), 112), order_type , 'N' OrderGb ,  count(order_seq) cnt
from custom_Etc_order
where order_type IN ( SELECT code from manage_code where code_type ='etcprod' ) 
and settle_date < CONVERT(CHAR(10), GETDATE() -1, 23)
and settle_cancel_Date  >= CONVERT(CHAR(10), GETDATE() -1, 23)
and settle_cancel_Date  < CONVERT(CHAR(10), GETDATE()  , 23)
and status_seq in ('3','5')  	
group by order_type 

 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_order CURSOR FAST_FORWARD  
 FOR  
	select order_type 
		, ISNULL((select CONVERT(char(2), order_Cnt) from  #gift_order where ordergb = 'Y' AND today_Dt = convert(char(10), GETDATE(), 112) and order_type = a.order_type),0) orderY
		, ISNULL((select CONVERT(char(2), order_Cnt) from  #gift_order where ordergb = 'N' AND today_Dt = convert(char(10), GETDATE(), 112) and order_type = a.order_type),0) orderN
	from #gift_order a
	where today_Dt = convert(char(10), GETDATE(), 112)


 OPEN cur_AutoInsert_For_order  
  
 DECLARE @MMS_DATE VARCHAR(100)  
 DECLARE @PHONE_NUM VARCHAR(100)  
 DECLARE @U_ID VARCHAR(100)  
 DECLARE @SERVICE VARCHAR(4)  
  
 DECLARE @MMS_MSG VARCHAR(MAX)  
 DECLARE @MMS_SUBJECT VARCHAR(60)  
 DECLARE @CALLBACK VARCHAR(50)  
 DECLARE @UID VARCHAR(50)  
 
 DECLARE @company_tel VARCHAR(15)   
 DECLARE @order_type VARCHAR(5) 
 DECLARE @orderY  VARCHAR(2)  
 DECLARE @orderN  VARCHAR(2) 
  
 DECLARE @NO_REC_BRAND VARCHAR(50) --4.수신거부 브랜드  
 --DECLARE @NO_REC_TEL  VARCHAR(50) --4.수신거부 전화번호 

 DECLARE @DEST_INFO	VARCHAR(100)  
 DECLARE @RESERVED4      VARCHAR(50)

 DECLARE @ORDER_CNT AS INT = 0

 FETCH NEXT FROM cur_AutoInsert_For_order INTO @order_type,  @orderY, @orderN
  
 WHILE @@FETCH_STATUS = 0  
  
 BEGIN  
        
	SET @NO_REC_BRAND = '바른손카드'      
	SET @CALLBACK  = '1644-0708'  
	SET @RESERVED4 = '2'
	SET @MMS_MSG = '[바른손답례품] 전일주문건> 주문 ' + @orderY + ' /  취소 ' + @orderN
	SET @SERVICE = 'SB' 

	SELECT @PHONE_NUM = company_tel  
	FROM gift_company_tel 
	WHERE CODE = @ORDER_TYPE 
	and isYN ='Y'
	and company_tel <> '' 
		 
 	SET @DEST_INFO = 'AA^'+@PHONE_NUM
		
	EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @MMS_MSG, '', @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SERVICE, '', '', @RESERVED4, '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT
	   
  FETCH NEXT FROM cur_AutoInsert_For_order INTO  @order_type,  @orderY, @orderN
 END  
  
 CLOSE cur_AutoInsert_For_order  
 DEALLOCATE cur_AutoInsert_For_order  
END
GO
