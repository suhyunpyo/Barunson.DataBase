IF OBJECT_ID (N'dbo.SP_S_SCHEDULE_BARUNN_CALCULATE_DATA', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_SCHEDULE_BARUNN_CALCULATE_DATA
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
CREATE PROCEDURE [dbo].[SP_S_SCHEDULE_BARUNN_CALCULATE_DATA]
	@yyyymm VARCHAR(6) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @yyyymm = ISNULL(@yyyymm, LEFT(REPLACE(CONVERT(varchar(10), DATEADD(M, -1, GETDATE()), 120), '-',''), 6))

	SELECT 
		SUM(Tax.Tax) Tax,
		Account.Kakao_Bank_Code,
		Account.Kakao_Account_Number,
		Account.Barunn_Bank_Code,
		Account.Barunn_Account_Number
	FROM TB_Remit AS Remit
		INNER JOIN TB_Invitation_Tax AS InvitationTax
			ON Remit.Invitation_ID = InvitationTax.Invitation_ID
		INNER JOIN TB_Tax AS Tax
			ON InvitationTax.Tax_ID = Tax.Tax_ID
		LEFT JOIN TB_Calculate AS Calculate
			ON Remit.Remit_ID = Calculate.Remit_ID
				AND Calculate.Calculate_Type_Code = 'CTC01'
				AND Calculate.Status_Code = '200'
		JOIN (
			SELECT TOP 1 
				Barunn_Bank_Code,
				Barunn_Account_Number,
				Kakao_Bank_Code,
				Kakao_Account_Number
				FROM TB_Account_Setting
			ORDER BY Account_Setting_ID DESC	
		) AS Account
			ON 1=1
	WHERE Calculate.Remit_ID IS NULL
		AND Remit.Result_Code = 'RC005'
		AND Remit.Complete_Date LIKE @yyyymm+'%'
	GROUP BY 	Account.Kakao_Bank_Code,
		Account.Kakao_Account_Number,
		Account.Barunn_Bank_Code,
		Account.Barunn_Account_Number

END
GO
