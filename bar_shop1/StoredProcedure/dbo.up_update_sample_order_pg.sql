IF OBJECT_ID (N'dbo.up_update_sample_order_pg', N'P') IS NOT NULL DROP PROCEDURE dbo.up_update_sample_order_pg
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2014-04-22
-- Description:	샘플오더 프로세스 (pg통한 결제)
-- =============================================
CREATE PROCEDURE [dbo].[up_update_sample_order_pg]
	-- Add the parameters for the stored procedure here
	@company_seq	AS int,
	@uid			AS nvarchar(16),
	@order_seq		AS int,
	@settle_method	AS int,
	@settle_price	AS int,
	@pg_mertid		AS nvarchar(15),
	@pg_resultinfo	AS nvarchar(50),
	@pg_resultinfo2	AS nvarchar(50),
	@card_installmonth	AS nvarchar(10),
	@card_nointyn		AS nvarchar(1),
	@dacom_tid		AS nvarchar(20),
	@result_code		int = 0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	BEGIN TRAN
		
		if @settle_method = '3'	--계좌이체의 경우
			begin
				Update custom_sample_order set 
				status_seq = 1, settle_method=@settle_method, settle_price=@settle_price,
				pg_resultinfo=@pg_resultinfo, PG_RESULTINFO2=@pg_resultinfo2, PG_MERTID=@pg_mertid,
				DACOM_TID=@dacom_tid 
				where sample_order_seq=@order_seq
			end
		else
			begin
				Update custom_sample_order set
				status_seq = 4, settle_method=@settle_method, settle_price=@settle_price,
				SETTLE_DATE=GETDATE(), REQUEST_DATE=GETDATE(), 
				pg_resultinfo=@pg_resultinfo, PG_RESULTINFO2=@pg_resultinfo2, 
				card_installmonth=@card_installmonth, card_nointyn=@card_nointyn,
				PG_MERTID=@pg_mertid, DACOM_TID=@dacom_tid 
				where sample_order_seq=@order_seq
			end
		
		delete from S2_SampleBasket where uid=@uid and company_seq=@company_seq and card_seq in (select card_seq from custom_sample_order_item where sample_order_seq=@order_seq)
		
		set @result_code = @@Error		--에러발생 cnt
		
		IF (@result_code <> 0) GOTO PROBLEM
			COMMIT TRAN

		PROBLEM:
		IF (@result_code <> 0) BEGIN
			ROLLBACK TRAN
		END
	
	return @result_code
	
END

GO
