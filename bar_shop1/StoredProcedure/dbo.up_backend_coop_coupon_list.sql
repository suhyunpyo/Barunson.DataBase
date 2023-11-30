IF OBJECT_ID (N'dbo.up_backend_coop_coupon_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_coop_coupon_list
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*  
 작성정보   :   [2003:08:20    13:28]  JJH:   
 관련페이지 :A_Info/coop_info.asp
 내용    :       업체 쿠폰정보
   
 수정정보   :   
*/  
CREATE procedure [dbo].[up_backend_coop_coupon_list]
	 @COMPANY_SEQ  int  
as
	select  IID
		,COMPANY_SEQ
		,S_NUM
		,E_NUM
		,CONVERT(VARCHAR(8),S_DAY,112) as S_DAY
		,CONVERT(VARCHAR(8),E_DAY,112) as E_DAY
		,REG_ID
		,REG_DT
		,CHG_ID
		,CHG_DT
		,ONOFF
	from dbo.COOP_COUPON where COMPANY_SEQ = @COMPANY_SEQ 
					and	 ONOFF ='Y'
					order by S_NUM

GO
