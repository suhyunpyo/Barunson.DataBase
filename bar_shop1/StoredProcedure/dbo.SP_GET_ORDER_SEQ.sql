IF OBJECT_ID (N'dbo.SP_GET_ORDER_SEQ', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_GET_ORDER_SEQ
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
CREATE PROCEDURE [dbo].[SP_GET_ORDER_SEQ]
	@P_Type char(1) = 'C'
AS
BEGIN
	SET NOCOUNT ON;
	
	
	-- @RunType = 0 => max(order_seq) + 1 (deprecated)
	-- @RunType > 0 => Sequence Next Value
	DECLARE @RunType INT = 1;

	DECLARE @SEQ INT;

	IF @RunType = 0
		BEGIN

		-- 청첩장 주문
		IF @P_Type = 'C'
			SELECT @SEQ = MAX(order_seq) + 1 FROM custom_order
		-- 부가상품 주문
		ELSE IF @P_Type = 'E'
			SELECT @SEQ = MAX(order_seq) + 1 FROM custom_etc_order
		-- 샘플 주문
		ELSE IF @P_Type = 'S'
			SELECT @SEQ = MAX(sample_order_seq) + 1 FROM custom_sample_order

		END
	ELSE
		BEGIN

		-- 청첩장 주문
		IF @P_Type = 'C'
			SET @SEQ = NEXT VALUE FOR OrderSeq
		-- 부가상품 주문
		ELSE IF @P_Type = 'E'
			SET @SEQ = NEXT VALUE FOR EtcOrderSeq
		-- 샘플 주문
		ELSE IF @P_Type = 'S'
			SET @SEQ = NEXT VALUE FOR SampleOrderSeq

		END

	SELECT @SEQ AS Seq
END
GO
