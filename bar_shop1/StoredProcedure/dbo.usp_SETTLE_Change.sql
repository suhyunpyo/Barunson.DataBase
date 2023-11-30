IF OBJECT_ID (N'dbo.usp_SETTLE_Change', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_SETTLE_Change
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*********************************************************
	관리자 인증 프로시져
	   주문완료 :  buy_STATUS = 1  /  ResultCode = '01'
	   결제완료 :  buy_STATUS = 2  /  ResultCode = '00'  /  
		      ResultMsg = '입금확인되었습니다' /  PGAuthDate =날짜  /  PGAugthTime=시간
	   주문취소 :  buy_STATUS = 3  /  ResultCode = '01'
	   관리자취소 :  buy_STATUS = 4  /  ResultCode = '01'
**********************************************************/
			
CREATE PROC [dbo].[usp_SETTLE_Change]
(
	@b_c_seq		[int],	--카드구매번호
	@status			[int],	--진행상태
	@authdate		[varchar]  (8),	--진행상태
	@authtime		[varchar]  (6)	--진행상태
)
AS 
SET XACT_ABORT ON
SET NOCOUNT ON
Begin Tran
	IF @status = 2  --결제완료를 변경했을시..
	      BEGIN
		UPDATE ewed_BUY_CARD set buy_STATUS=@status
		WHERE buy_card_SEQ=@b_c_seq
		UPDATE ewed_BUY_SETTLE_INFO SET ResultCode='00',
		 ResultMsg='은행입금 확인되었습니다.', PGAuthDate=@authdate, PGAuthTime=@authtime 
		WHERE buy_card_SEQ=@b_c_seq
	      END
	ELSE
	      BEGIN
		UPDATE ewed_BUY_CARD set buy_STATUS=@status
		WHERE buy_card_SEQ=@b_c_seq
		UPDATE ewed_BUY_SETTLE_INFO SET ResultCode='01'
		WHERE buy_card_SEQ=@b_c_seq
	      END
	
Commit Tran
GO
