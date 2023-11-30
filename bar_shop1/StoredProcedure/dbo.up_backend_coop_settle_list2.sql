IF OBJECT_ID (N'dbo.up_backend_coop_settle_list2', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_coop_settle_list2
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   : [2003:08:02    13:13]  JJH: 
	관련페이지 : coop_admin/D_SETTLE/settle_list.asp
	내용	   : 제휴사 정산관리 (제휴사쪽에서 보는것)
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_backend_coop_settle_list2]
	@COMPANY_SEQ		varchar(10)
,	@SRCH_KIND		varchar(10)
as
-- S2:바른손에서 결제확인요청 건들보기
IF @SRCH_KIND = 1
	BEGIN
		SELECT  CPY. COMPANY_NAME
			,CST.SETTLE_DT
			,CST.TOTAL_SELL_PRICE
			,CST.COMM_PRICE
			,CST.SETTLE_PRICE
			,convert(varchar(8),CST.COMM_STAT_S2_DT,112) as COMM_STAT_S2_DT 
			,convert(varchar(8),CST.COMM_STAT_S4_DT,112) as COMM_STAT_S4_DT 
			,CST.KIND
			,CST.IID
			FROM dbo.coop_settle_tbl CST  , dbo.company CPY
			WHERE 	CST.COMPANY_SEQ = @COMPANY_SEQ
			AND	CPY.COMPANY_SEQ = CST.COMPANY_SEQ
			AND	CST.COMM_STAT='S2'
	END
-- S2:바른손에서 입금확인 건들보기
IF @SRCH_KIND = 2
	BEGIN
		SELECT  CPY. COMPANY_NAME
			,CST.SETTLE_DT
			,CST.TOTAL_SELL_PRICE
			,CST.COMM_PRICE
			,CST.SETTLE_PRICE
			,convert(varchar(8),CST.COMM_STAT_S2_DT,112) as COMM_STAT_S2_DT 
			,convert(varchar(8),CST.COMM_STAT_S4_DT,112) as COMM_STAT_S4_DT 
			,CST.KIND
			,CST.IID
			FROM dbo.coop_settle_tbl CST  , dbo.company CPY
			WHERE 	CST.COMPANY_SEQ = @COMPANY_SEQ
			AND	CPY.COMPANY_SEQ = CST.COMPANY_SEQ
			AND	CST.COMM_STAT='S4'
	END
-- 모든입금처리가 완료된 건들보기
IF @SRCH_KIND = 3
	BEGIN
		SELECT  CPY. COMPANY_NAME
			,CST.SETTLE_DT
			,CST.TOTAL_SELL_PRICE
			,CST.COMM_PRICE
			,CST.SETTLE_PRICE
			,convert(varchar(8),CST.COMM_STAT_S2_DT,112) as COMM_STAT_S2_DT 
			,convert(varchar(8),CST.COMM_STAT_S4_DT,112) as COMM_STAT_S4_DT 
			,CST.KIND
			,CST.IID
			FROM dbo.coop_settle_tbl CST  , dbo.company CPY
			WHERE 	CST.COMPANY_SEQ = @COMPANY_SEQ
			AND	CPY.COMPANY_SEQ = CST.COMPANY_SEQ
			AND	CST.COMM_STAT='S5'
	END

GO
