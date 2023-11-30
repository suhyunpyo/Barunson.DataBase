IF OBJECT_ID (N'dbo.up_delete_sample_basket', N'P') IS NOT NULL DROP PROCEDURE dbo.up_delete_sample_basket
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-15
-- Description:	MyPage 샘플장바구니 삭제
-- TEST : up_delete_sample_basket
-- =============================================
CREATE PROCEDURE [dbo].[up_delete_sample_basket]	

	@seq INT,
	@result_code	INT = 0 OUTPUT,
	@result_cnt		INT = 0 OUTPUT	

AS
BEGIN
	
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;

	
	DELETE FROM S2_SampleBasket WHERE seq = @seq
	
	SET @result_cnt = @@ROWCOUNT	--변경된 rowcount
	SET @result_code = @@Error		--에러발생 cnt
		
	RETURN @result_code
	RETURN @result_cnt	

				  
END



-- select * from S2_SampleBasket where seq = @seq


GO
