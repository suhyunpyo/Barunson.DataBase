IF OBJECT_ID (N'dbo.sp_S2GetOrderSeq', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2GetOrderSeq
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  proc [dbo].[sp_S2GetOrderSeq] 
	@order_seq as int OUTPUT
as     
	--DECLARE @order_seq as int
	--Set @order_seq = ''
	
	INSERT  S2_eCardOrder (uid) VALUES ('')
	
	SELECT @order_seq = @@identity 
	
	SELECT @order_seq
GO
