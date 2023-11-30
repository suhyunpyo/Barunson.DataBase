IF OBJECT_ID (N'dbo.SP_S_USER_CALCULATE_TEST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_USER_CALCULATE_TEST
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
CREATE PROCEDURE [dbo].[SP_S_USER_CALCULATE_TEST]
	@UserId Varchar(50),
	@Page int = 1,
	@PageSize int = 10,
	@Type varchar(50) = 'paging',
	@Total int = 0 output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		SELECT 
			@Total = count(1)
		FROM TB_Remit AS Remit
			INNER JOIN TB_Account AS Account
				ON Remit.Account_ID = Account.Account_ID
			LEFT JOIN TB_Calculate AS Calculate1
				ON Remit.Remit_ID = Calculate1.Remit_ID
					AND Calculate1.Calculate_Type_Code = 'CTC01'
					AND Calculate1.Status_Code = '200'
			LEFT JOIN TB_Calculate AS Calculate2
				ON Remit.Remit_ID = Calculate2.Remit_ID
					AND Calculate2.Calculate_Type_Code = 'CTC02'
					AND Calculate2.Status_Code = '200'
		WHERE Remit.Result_Code = 'RC005'
			AND Account.User_ID = @UserId


	 BEGIN
		SELECT 
			convert(varchar, Remit.Complete_DateTime, 120) Complete_DateTime,
			Account.Depositor_Name,
			Remit.Remitter_Name,
			Remit.Total_Price AS Total_Amount,
			Calculate1.Remit_Price AS Tax,
			Calculate2.Remit_Price AS Amount,
			Remit.Total_Price - isnull(Calculate1.Remit_Price, 0) - isnull(Calculate2.Remit_Price, 0) AS Left_Amount,
			convert(varchar, Calculate2.Calculate_DateTime, 120) Calculate_DateTime
		FROM TB_Remit AS Remit
			INNER JOIN TB_Account AS Account
				ON Remit.Account_ID = Account.Account_ID
			LEFT JOIN TB_Calculate AS Calculate1
				ON Remit.Remit_ID = Calculate1.Remit_ID
					AND Calculate1.Calculate_Type_Code = 'CTC01'
					AND Calculate1.Status_Code = '200'
			LEFT JOIN TB_Calculate AS Calculate2
				ON Remit.Remit_ID = Calculate2.Remit_ID
					AND Calculate2.Calculate_Type_Code = 'CTC02'
					AND Calculate2.Status_Code = '200'
		WHERE Remit.Result_Code = 'RC005'
			AND Account.User_ID = @UserId
		order by Remit.Complete_DateTime ASC

	
END
END
GO
