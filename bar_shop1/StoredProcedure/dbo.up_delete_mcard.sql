IF OBJECT_ID (N'dbo.up_delete_mcard', N'P') IS NOT NULL DROP PROCEDURE dbo.up_delete_mcard
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		강현주
-- Create date: 2015.01.14
-- Description:	m청첩장 삭제
-- =============================================
CREATE PROCEDURE [dbo].[up_delete_mcard]
	-- Add the parameters for the stored procedure here
	@order_seq int = 0,
    @type Char(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @type = 'O'
	BEGIN
		DELETE FROM S4_mCardBoard WHERE Order_Seq=@order_seq
		DELETE FROM S4_mcardEditinfo WHERE Order_Seq=@order_seq
		DELETE FROM S4_mcardimageinfo WHERE Order_Seq=@order_seq
		DELETE FROM S2_mCardOrder WHERE Order_Seq=@order_seq
    END
	ELSE IF @type = 'N'
	BEGIN  
		DELETE FROM S5_nmCardBoard WHERE Order_Seq=@order_seq
		DELETE FROM S5_nmCardOrder WHERE Order_Seq=@order_seq
		DELETE FROM S5_nmCardImageInfo WHERE Order_Seq=@order_seq
		DELETE FROM S5_nmCardShowInfo WHERE Order_Seq=@order_seq
    END
END
GO
