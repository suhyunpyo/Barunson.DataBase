IF OBJECT_ID (N'dbo.delete_MCard', N'P') IS NOT NULL DROP PROCEDURE dbo.delete_MCard
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김수경
-- Create date: 2012,11,13
-- Description:	m청첩장 삭제
-- =============================================
CREATE PROCEDURE [dbo].[delete_MCard]
	-- Add the parameters for the stored procedure here
	@order_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	delete from S4_mcardEditinfo where Order_Seq=@order_seq
	delete from S4_mcardimageinfo where Order_Seq=@order_seq
    delete from S2_mCardOrder where Order_Seq=@order_seq

END
GO
