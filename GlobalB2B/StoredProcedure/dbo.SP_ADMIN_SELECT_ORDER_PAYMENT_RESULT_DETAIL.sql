IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_ORDER_PAYMENT_RESULT_DETAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_ORDER_PAYMENT_RESULT_DETAIL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_ORDER_PAYMENT_RESULT_DETAIL]
	@p_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT
    *
    FROM
    ORDER_PAYMENT_RESULT_MST OPRM
    WHERE OPRM.PAYMENT_RESULT_SEQ = @p_seq;
END

GO
