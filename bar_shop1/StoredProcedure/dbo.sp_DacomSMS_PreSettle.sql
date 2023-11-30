IF OBJECT_ID (N'dbo.sp_DacomSMS_PreSettle', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_DacomSMS_PreSettle
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[sp_DacomSMS_PreSettle]
AS
BEGIN
	DECLARE CUR_PreSettle CURSOR FAST_FORWARD  
	FOR 

	SELECT DISTINCT 'AA^'+ REPLACE(A.order_hphone,'-','') TR_PHONE,
	REPLACE(B.mng_tel_no,'-','') TR_CALLBACK,'[' + B.company_name + ']초안확인!/체크사항확인후 초안확정및인쇄요청 클릭해야 인쇄진행됩니다.' TR_MSG, A.SALES_GUBUN
	FROM custom_order A INNER JOIN COMPANY B ON A.company_seq = B.company_Seq
	WHERE status_seq IN (7,8) AND settle_status=2 AND order_date>='2021-01-01'
	AND A.company_seq IN (5001,5006,5007,5003) AND a.member_id <> 's4guest'
	
	OPEN CUR_PreSettle  

	DECLARE @TR_PHONE VARCHAR(50)
	DECLARE @TR_CALLBACK VARCHAR(20)
	DECLARE @TR_MSG VARCHAR(100)
	DECLARE @SALES_GUBUN VARCHAR(2)
 
	FETCH NEXT FROM CUR_PreSettle INTO @TR_PHONE, @TR_CALLBACK, @TR_MSG, @SALES_GUBUN
  
	WHILE @@FETCH_STATUS = 0  
  
	BEGIN  

	EXEC PROC_SMS_MMS_SEND '', 0, '', @TR_MSG, '', @TR_CALLBACK, 1, @TR_PHONE, 0, '', 0, @SALES_GUBUN, '', '', '', '', '', '', '', '', '', ''
 
	FETCH NEXT FROM CUR_PreSettle INTO  @TR_PHONE, @TR_CALLBACK, @TR_MSG, @SALES_GUBUN
	END

	CLOSE CUR_PreSettle  
	DEALLOCATE CUR_PreSettle  

	/* 관리자 메모에 히스토리 저장 */
	INSERT INTO CUSTOM_ORDER_ADMIN_MENT (ISWOrder,MENT,ORDER_SEQ,PCHECK,STATUS,ADMIN_ID,REG_DATE,isJumun,intype,sgubun,stype)
	SELECT  1, '[' + B.company_name + ']초안확인!/체크사항확인후 초안확정및인쇄요청 클릭해야 인쇄진행됩니다.', ORDER_SEQ, NULL, 0, 'admin', GETDATE(), 1, 4, '', '기타'
	from    custom_order A inner join COMPANY B on A.company_seq = B.company_Seq
	where   status_seq in (7,8) and settle_status=2  and order_date>='2021-01-01'
	and     A.company_seq in (5001,5006,5007,5003) and a.member_id <> 's4guest' 
END


/*
INSERT  INTO  invtmng.SC_TRAN (TR_SENDSTAT, TR_RSLTSTAT,TR_PHONE, TR_CALLBACK, TR_MSG) 
select distinct '0','00',replace(A.order_hphone,'-','') as TR_PHONE,
replace(B.mng_tel_no,'-','') as TR_CALLBACK,'[' + B.company_name + ']초안확인!/체크사항확인후 초안확정및인쇄요청 클릭해야 인쇄진행됩니다.'
from custom_order A inner join COMPANY B on A.company_seq = B.company_Seq
where status_seq in (7,8) and settle_status=2 and order_date>='2019-01-01'
and A.company_seq in (5001,5006,5007,5003) and a.member_id <> 's4guest'
*/
/* 관리자 메모에 히스토리 저장 */
/*
INSERT INTO CUSTOM_ORDER_ADMIN_MENT (ISWOrder,MENT,ORDER_SEQ,PCHECK,STATUS,ADMIN_ID,REG_DATE,isJumun,intype,sgubun,stype)
SELECT  1, '[' + B.company_name + ']초안확인!/체크사항확인후 초안확정및인쇄요청 클릭해야 인쇄진행됩니다.', ORDER_SEQ, NULL, 0, 'admin', GETDATE(), 1, 4, '', '기타'
from    custom_order A inner join COMPANY B on A.company_seq = B.company_Seq
where   status_seq in (7,8) and settle_status=2  and order_date>='2019-01-01'
and     A.company_seq in (5001,5006,5007,5003) and a.member_id <> 's4guest' 
*/


GO
