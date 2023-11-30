IF OBJECT_ID (N'dbo.up_select_pan_print', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_pan_print
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		강현주
-- Create date: 2015-01-21
-- Description:	초안확인 - 판정보 조회
-- TEST : up_select_pan_print 1970473
-- =============================================
CREATE PROCEDURE [dbo].[up_select_pan_print]
	
	@order_seq		int	

AS
BEGIN

	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
	
	-- 카드 --
	SELECT   A.id					--0
			,A.print_type			--1
			,A.card_seq				--2
			,A.title				--3
			,A.print_count			--4
			,A.isFPrint				--5
			,A.isNotPrint			--6
			,A.isNotSet				--7
			,A.isPostMark			--8
			,A.imgFolder			--9
			,A.imgname				--10
			,ISNULL(A.pstatus, 0) AS pstatus	--11
	FROM 
		Custom_Order_Plist A 
	WHERE A.order_seq = @order_seq
		AND A.print_type IN ('C', 'I', 'G')  
		AND A.print_count > 0  
	ORDER BY A.print_type, A.id

	-- 봉투 --
	SELECT   A.id					--0
			,A.print_type			--1
			,A.card_seq				--2
			,A.title				--3
			,A.print_count			--4
			,A.isFPrint				--5
			,A.isNotPrint			--6
			,A.isNotSet				--7
			,A.isPostMark			--8
			,A.imgFolder			--9
			,A.imgname				--10
			,ISNULL(A.pstatus, 0) AS pstatus	--11
	FROM 
		Custom_Order_Plist A 
	WHERE A.order_seq = @order_seq
		AND A.print_type= 'E'
		AND A.print_count > 0 
	ORDER BY A.id
	
	-- 약도카드 --
	SELECT   A.id					--0
			,A.print_type			--1
			,A.card_seq				--2
			,A.title				--3
			,A.print_count			--4
			,A.isFPrint				--5
			,A.isNotPrint			--6
			,A.isNotSet				--7
			,A.isPostMark			--8
			,A.imgFolder			--9
			,A.imgname				--10
			,ISNULL(A.pstatus, 0) AS pstatus	--11
	FROM 
		Custom_Order_Plist A 
	WHERE A.order_seq = @order_seq
		AND A.print_type= 'P'
		AND A.print_count > 0 
	ORDER BY A.id	
END
GO
