IF OBJECT_ID (N'dbo.SP_SELECT_WISH_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_WISH_LIST
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
CREATE PROCEDURE [dbo].[SP_SELECT_WISH_LIST]
	@p_user_id nvarchar(255)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @t_user_seq int
	
	SET @t_user_seq = (SELECT USER_SEQ FROM USER_MST WHERE USER_ID  = @p_user_id);
	
	SELECT 
	CM.CART_SEQ
	,CM.CART_STATE_CODE
	,CM.QUANTITY
	,CM.REG_DATE
	,PM.PROD_SEQ
	,PM.PROD_CODE
	,PM.PROD_TITLE
	,PM.MIN_ORDER
	FROM CART_MST CM
	LEFT JOIN PROD_MST PM ON CM.PROD_SEQ = PM.PROD_SEQ
	WHERE CM.USER_SEQ = @t_user_seq 
	AND
	CM.CART_TYPE_CODE = '111001'
	AND
	CM.CART_STATE_CODE = '118001'
END

GO
