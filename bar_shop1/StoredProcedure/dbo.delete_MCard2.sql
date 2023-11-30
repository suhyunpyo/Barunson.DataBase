IF OBJECT_ID (N'dbo.delete_MCard2', N'P') IS NOT NULL DROP PROCEDURE dbo.delete_MCard2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		김수경
-- Create date: 2012,11,13
-- Modify date: 2014, 7,23
-- Description:	m청첩장 삭제
-- =============================================
CREATE PROCEDURE [dbo].[delete_MCard2]
	-- Add the parameters for the stored procedure here
	@order_seq int,
    @new_or_old varchar(5)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @new_or_old = 'old'
	BEGIN
	  delete from S4_mcardEditinfo where Order_Seq=@order_seq
	  delete from S4_mcardimageinfo where Order_Seq=@order_seq
      delete from S2_mCardOrder where Order_Seq=@order_seq
    END
	ELSE IF @new_or_old = 'new'
	BEGIN  
	  delete from S5_nmCardOrder where Order_Seq=@order_seq
	  delete from S5_nmCardImageInfo where Order_Seq=@order_seq
      delete from S5_nmCardShowInfo where Order_Seq=@order_seq
    END
END


GO
