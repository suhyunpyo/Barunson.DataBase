IF OBJECT_ID (N'dbo.sp_DacomSMS_PreSettle_JEHU', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_DacomSMS_PreSettle_JEHU
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- Exec sp_DacomSMS_PreSettle_JEHU

CREATE  PROC [dbo].[sp_DacomSMS_PreSettle_JEHU]
AS

BEGIN
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD  
 FOR  
	select distinct replace(A.order_hphone,'-','') as TR_PHONE
	from custom_order A inner join COMPANY B on A.company_seq = B.company_Seq
	where status_seq in (7,8) and settle_status=2 and order_date>='2019-01-01'
	and A.company_seq not in (5001,5006,5007,5003) and A.sales_Gubun IN ('B','H','C') and a.member_id <> 's4guest'
 	 
 OPEN cur_AutoInsert_For_Order  

 DECLARE @MSG VARCHAR(100)  
 DECLARE @MSG2 VARCHAR(100) 
 DECLARE @DEST_INFO VARCHAR(100) 
 DECLARE @TR_PHONE VARCHAR(20) 
 
 FETCH NEXT FROM cur_AutoInsert_For_Order INTO @TR_PHONE
  
 WHILE @@FETCH_STATUS = 0  
  
 BEGIN  

	SET @MSG = '[바른손몰]초안확인!/체크사항확인후 초안확정및인쇄요청 클릭해야 인쇄진행됩니다.';
	SET @DEST_INFO = 'AA^'+@TR_PHONE


	EXEC PROC_SMS_MMS_SEND '', 0, '', @MSG, '', '1644-7413', 1, @DEST_INFO, 0, '', 0, 'B', '', '', '', '', '', '', '', '', '', ''
 
 FETCH NEXT FROM cur_AutoInsert_For_Order INTO  @TR_PHONE
 END

 CLOSE cur_AutoInsert_For_Order  
 DEALLOCATE cur_AutoInsert_For_Order  


    /* 관리자 메모에 히스토리 저장 */
    INSERT INTO CUSTOM_ORDER_ADMIN_MENT (ISWOrder,MENT,ORDER_SEQ,PCHECK,STATUS,ADMIN_ID,REG_DATE,isJumun,intype,sgubun,stype)
    SELECT  1, '[바른손몰]초안확인!/체크사항확인후 초안확정및인쇄요청 클릭해야 인쇄진행됩니다.', ORDER_SEQ, NULL, 0, 'admin', GETDATE(), 1, 4, '', '기타'
    from    custom_order A inner join COMPANY B on A.company_seq = B.company_Seq
    where   status_seq in (7,8) and settle_status=2  and order_date>='2019-01-01'
    and     A.company_seq not in (5001,5006,5007,5003) and A.sales_Gubun IN ('B','H','C') and a.member_id <> 's4guest'

END
GO
