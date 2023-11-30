IF OBJECT_ID (N'dbo.up_delete_mcard_auto', N'P') IS NOT NULL DROP PROCEDURE dbo.up_delete_mcard_auto
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		강현주
-- Create date: 2015.01.14
-- Description:	6개월이 지난 m청첩장 자동삭제 (하루에 한번씩 실행)
-- =============================================
CREATE PROCEDURE [dbo].[up_delete_mcard_auto]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	  DELETE FROM S4_mCardBoard 
	  	WHERE Order_Seq IN (SELECT order_seq FROM S2_mCardOrder WHERE datediff(month,regdate,getdate()) > 6)
	  DELETE FROM S4_mcardEditinfo
	  	WHERE Order_Seq IN (SELECT order_seq FROM S2_mCardOrder WHERE datediff(month,regdate,getdate()) > 6)
      DELETE FROM S4_mcardimageinfo
	  	WHERE Order_Seq IN (SELECT order_seq FROM S2_mCardOrder WHERE datediff(month,regdate,getdate()) > 6)
	  DELETE FROM S2_mCardOrder where datediff(month,regdate,getdate()) > 6

	  DELETE FROM S5_nmCardBoard 
	  	WHERE Order_Seq IN (SELECT order_seq FROM S5_nmCardOrder WHERE datediff(month,regdate,getdate()) > 6)
	  DELETE FROM S5_nmCardImageInfo 
	  	WHERE Order_Seq IN (SELECT order_seq FROM S5_nmCardOrder WHERE datediff(month,regdate,getdate()) > 6)
      DELETE FROM S5_nmCardShowInfo
	  	WHERE Order_Seq IN (SELECT order_seq FROM S5_nmCardOrder WHERE datediff(month,regdate,getdate()) > 6)
	  DELETE FROM S5_nmCardOrder WHERE datediff(month,regdate,getdate()) > 6
END
GO
