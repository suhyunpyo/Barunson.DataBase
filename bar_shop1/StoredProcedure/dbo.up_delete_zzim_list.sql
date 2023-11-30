IF OBJECT_ID (N'dbo.up_delete_zzim_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_delete_zzim_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-14
-- Description:	MyPage 최근 본 상품 삭제
-- TEST : up_delete_today_view_list
-- =============================================
CREATE PROCEDURE [dbo].[up_delete_zzim_list]	

	@seq INT,
	@result_code	INT = 0 OUTPUT,
	@result_cnt		INT = 0 OUTPUT	

AS
BEGIN
	
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;

	DELETE FROM S2_WishCard WHERE seq = @seq
	
	SET @result_cnt = @@ROWCOUNT	--변경된 rowcount
	SET @result_code = @@Error		--에러발생 cnt
		
	RETURN @result_code
	RETURN @result_cnt	

				  
END



-- select * FROM S2_WishCard order by seq desc
GO
