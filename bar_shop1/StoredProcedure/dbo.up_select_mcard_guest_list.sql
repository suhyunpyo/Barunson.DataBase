IF OBJECT_ID (N'dbo.up_select_mcard_guest_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_mcard_guest_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		강현주
-- Create date: 2015-01-14
-- Description:	모바일 청첩장 방명록 List
-- =============================================
create Procedure [dbo].[up_select_mcard_guest_list]
	-- Add the parameters for the stored procedure here
	@order_seq	AS int,		-- 주문코드
	@page		AS int,				-- 페이지넘버
	@pagesize	AS int				-- 페이지사이즈(페이지당 노출갯수)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
    -- Insert statements for procedure here
	-- total count
	SELECT COUNT(Board_Seq) AS TOT 
	FROM 
		S5_nmCardBoard
	WHERE 
		Order_Seq = @order_seq

		
	-- goods list
	SELECT * 
	FROM
	(
		SELECT  ROW_NUMBER() OVER (ORDER BY Board_Seq DESC ) AS RowNum, 				
			Board_Seq, Name, Contents, RegDate
		FROM 
			S5_nmCardBoard
		WHERE 
			Order_Seq = @order_seq
	) AS RESULT
	WHERE RowNum BETWEEN ( ( (@page - 1) * @pagesize ) + 1 ) AND ( @page * @pagesize )	
END
GO
