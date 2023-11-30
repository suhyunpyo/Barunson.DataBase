IF OBJECT_ID (N'invtmng.sp_getJaego', N'P') IS NOT NULL DROP PROCEDURE invtmng.sp_getJaego
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [invtmng].[sp_getJaego]
@card_code varchar(20)
AS
select jaego from card_jaego where card_code=@card_code
GO
