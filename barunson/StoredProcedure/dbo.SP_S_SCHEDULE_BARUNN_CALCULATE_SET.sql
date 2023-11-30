IF OBJECT_ID (N'dbo.SP_S_SCHEDULE_BARUNN_CALCULATE_SET', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_SCHEDULE_BARUNN_CALCULATE_SET
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
CREATE PROCEDURE [dbo].[SP_S_SCHEDULE_BARUNN_CALCULATE_SET]
	@yyyymm VARCHAR(6) = NULL,
	@BarunnBankCode VARCHAR(3),
	@BarunnAccountNumber VARCHAR(50),
	@TradingNumber VARCHAR(20),
	@UniqueNumber INT,
	@RequestDateTime varchar(14),
	@RequestDate varchar(8),
	@StatusCode varchar(50),
	@CalculateDateTime varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @yyyymm = ISNULL(@yyyymm, LEFT(REPLACE(CONVERT(varchar(10), DATEADD(M, -1, GETDATE()), 120), '-',''), 6))

    -- Insert statements for procedure here
	INSERT INTO TB_Calculate (
		Remit_ID, 
		Calculate_Type_Code,
		Remit_Price,
		Remit_Bank_Code,
		Remit_Account_Number,
		Remit_Content,
		Trading_Number,
		Unique_Number,
		Request_DateTime,
		Request_Date,
		Status_Code,
		Calculate_DateTime
	)
	SELECT 
		Remit.Remit_ID,
		'CTC01' AS Calculate_Type_Code,
		Tax.Tax AS Remit_Price,
		@BarunnBankCode AS Remit_Bank_Code,
		@BarunnAccountNumber AS Remit_Account_Number,
		'수수료정산' AS Remit_Content,
		@TradingNumber AS Trading_Number,
		@UniqueNumber AS Unique_Number,
		@RequestDateTime AS Request_DateTime,
		@RequestDate AS Request_Date,
		@StatusCode AS Status_Code,
		@CalculateDateTime AS Calculate_DateTime
	FROM TB_Remit AS Remit
		INNER JOIN TB_Invitation_Tax AS InvitationTax
			ON Remit.Invitation_ID = InvitationTax.Invitation_ID
		INNER JOIN TB_Tax AS Tax
			ON InvitationTax.Tax_ID = Tax.Tax_ID
		LEFT JOIN TB_Calculate AS Calculate
			ON Remit.Remit_ID = Calculate.Remit_ID
				AND Calculate.Calculate_Type_Code = 'CTC01'
				AND Calculate.Status_Code = '200'
	WHERE Calculate.Remit_ID IS NULL
		AND Remit.Result_Code = 'RC005'
		AND Remit.Complete_Date LIKE @yyyymm+'%'
	ORDER BY Remit.Remit_ID

END
GO
