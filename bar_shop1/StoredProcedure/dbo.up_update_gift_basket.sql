IF OBJECT_ID (N'dbo.up_update_gift_basket', N'P') IS NOT NULL DROP PROCEDURE dbo.up_update_gift_basket
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2014-04-22
-- Description:	답례품 update/delete 프로세스
-- =============================================
CREATE PROCEDURE [dbo].[up_update_gift_basket]
	-- Add the parameters for the stored procedure here
	
	@seq		AS nvarchar(1000),
	@gift_chk		AS nvarchar(1000),
	@item_cnt		AS nvarchar(1000),
	@mode		AS nvarchar(10),
	@result_code		int = 0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	BEGIN TRAN
		
		if @mode = 'update'	--답례품 수량 업데이트일 경우
			begin
				update S2_UsrBasket set order_cnt=B.itemValue2
				from S2_UsrBasket AS A join dbo.fn_SplitIn3Rows(@seq, @item_cnt,',') B
				on A.seq = B.ItemValue
			end
		if @mode = 'delete'
			begin
				delete from S2_UsrBasket
				from S2_UsrBasket AS A
				join dbo.fn_SplitIn2Rows(@gift_chk,',') B
				on A.seq = B.ItemValue
				where A.seq = ItemValue
			end
			
		
		
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
