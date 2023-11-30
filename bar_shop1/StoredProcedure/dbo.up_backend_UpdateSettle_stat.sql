IF OBJECT_ID (N'dbo.up_backend_UpdateSettle_stat', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_UpdateSettle_stat
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   :  [2003:08:01    1:53]  JJH: 
	관련페이지 : shopadm/custom/settle/coop_settle_info.asp
	내용	   : 결제 상태 변경
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_backend_UpdateSettle_stat]
	@IID			int
,	@COMM_STAT		varchar(10)
,	@KIND			varchar(10) = 'B'		-- 바른손: B   업체:C 에서 반영할떄
as
	
	DECLARE	@NEXT_COMM_STAT	VARCHAR(10)
	-- 바른손어드민에서 S2->S3    S4->S5 로 의 상태변경은 못하게 한다(업체에서만 변경하는것이므로)
	IF @KIND='B' AND ( @COMM_STAT = 'S2' OR @COMM_STAT = 'S4'  OR  @COMM_STAT = 'S5') 
	BEGIN
		SELECT -1 AS ERROR_CODE
		RETURN
	END
	-- 업체에서 S1->S2   S3->S4 로 의 상태변경은 못하게 한다(바른손에서만 변경하는것이므로)
	IF @KIND='C' AND ( @COMM_STAT = 'S1' OR @COMM_STAT = 'S3' )
	BEGIN
		SELECT -2 AS ERROR_CODE
		RETURN
	END
	IF @COMM_STAT = 'S1'	SET @NEXT_COMM_STAT ='S2'
	IF @COMM_STAT = 'S2'	SET @NEXT_COMM_STAT ='S3'
	IF @COMM_STAT = 'S3'	SET @NEXT_COMM_STAT ='S4'
	IF @COMM_STAT = 'S4'	SET @NEXT_COMM_STAT ='S5'
-- 거부를 처리할려고 할때에는  바른손에서 처리할때와.. 
-- 대금을 받는쪽에서 처리할때 두가지 다르게 한다
	IF @KIND ='B'  AND @COMM_STAT = 'S10'	SET @NEXT_COMM_STAT ='S2'		-- 바른손에서 s10에서 다른상태로 변경은 다시 결제대기 처리로 하는것
	IF @KIND ='C'  AND @COMM_STAT = 'S10'	SET @NEXT_COMM_STAT ='S10'		-- 업체에서는 결제거부로 오면 결제거부로 처리한다
-- 결제 상태수정
IF @NEXT_COMM_STAT = 'S2'
	BEGIN
	UPDATE dbo.coop_settle_tbl  SET 
				COMM_STAT = @NEXT_COMM_STAT
				,COMM_STAT_S2_DT = GETDATE()
				 WHERE IID = @IID
	END
ELSE IF @NEXT_COMM_STAT = 'S3'
	BEGIN
	UPDATE dbo.coop_settle_tbl  SET 
				COMM_STAT = @NEXT_COMM_STAT
				,COMM_STAT_S3_DT = GETDATE()
				 WHERE IID = @IID
	END
ELSE IF @NEXT_COMM_STAT = 'S4'
	BEGIN
	UPDATE dbo.coop_settle_tbl  SET 
				COMM_STAT = @NEXT_COMM_STAT
				,COMM_STAT_S4_DT = GETDATE()
				 WHERE IID = @IID
	END
ELSE
	BEGIN
	UPDATE dbo.coop_settle_tbl  SET 
				COMM_STAT = @NEXT_COMM_STAT
				 WHERE IID = @IID
	END
SELECT 1 AS ERROR_CODE

GO
