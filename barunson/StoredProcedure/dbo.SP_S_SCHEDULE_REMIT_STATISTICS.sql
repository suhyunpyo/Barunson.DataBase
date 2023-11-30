IF OBJECT_ID (N'dbo.SP_S_SCHEDULE_REMIT_STATISTICS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_SCHEDULE_REMIT_STATISTICS
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
CREATE PROCEDURE [dbo].[SP_S_SCHEDULE_REMIT_STATISTICS]
	@Date VARCHAR(8) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @NextDate VARCHAR(8)
	DECLARE @Month Varchar(8);
	DECLARE @Year Varchar(8);

	SET @Date = ISNULL(@Date, CONVERT(VARCHAR(10), GETDATE() - 1, 112))
	SET @NextDate = ISNULL(CONVERT(VARCHAR(10),DATEADD(DAY, 1, CONVERT(DATETIME, @Date)), 112), CONVERT(VARCHAR(10), GETDATE(), 112))
	SET @Month = LEFT(@Date, 6)
	SET @Year = LEFT(@Date, 4)

	/* 날짜 생성 */
	EXEC SP_S_SCHEDULE_STANDARD_DATE @Date

	/* 일 데이터 삭제 */
	DELETE FROM TB_Remit_Statistics_Daily WHERE Date = @Date
	
	/* 일 종합 데이터 삭제 */
	DELETE FROM TB_Remit_Statistics_Daily WHERE Date = @Month+'00'

	/* 월 데이터 삭제 */
	DELETE FROM TB_Remit_Statistics_Monthly WHERE Date = @Month

	/* 월 종합 데이터 삭제 */
	DELETE FROM TB_Remit_Statistics_Monthly WHERE Date = @Year + '00'

	/* 일 데이터 재등록 */
	INSERT INTO TB_Remit_Statistics_Daily (Date, Remit_Price, Tax, Remit_Tax, Calculate_Tax, Hits_Tax, User_Count, Account_Count, Remit_Count) 
	SELECT 
		SD.Standard_Date,
		ISNULL(RM2.Total_Price, 0) Total_Price,
		ISNULL(RM2.Tax, 0) Tax,
		(ISNULL(RM2.Remit_Count, 0) * ISNULL(CT.Remit_Tax, 0 )) Remit_Tax,
		(ISNULL(RM2.Remit_Count, 0) * ISNULL(CT.Calculate_Tax, 0 )) Calculate_Tax,
		(ISNULL(DH.Hit_Count, 0) * ISNULL(CT.Hits_Tax,0)) Hit_Price,
		ISNULL(RM3.User_Count, 0) User_Count,
		ISNULL(RM.Account_Cnt, 0) Account_Cnt,
		ISNULL(RM2.Remit_Count, 0) Remit_Count
	FROM TB_Standard_Date AS SD
		LEFT JOIN (
			select 
				Standard_Date,
				Remit_Tax,
				Calculate_Tax,
				Hits_Tax
			from TB_Company_Tax as companyTax
				inner join (
					select standard_date, max(company_tax_id) company_tax_id
					from tb_company_tax as companyTax,
						tb_standard_date as standardDate
					where apply_start_date <= standardDate.standard_date
					group by standard_date
				) as companyTax2
					on companyTax.Company_Tax_ID = companyTax2.company_tax_id
		) AS CT
			ON SD.Standard_Date = CT.Standard_Date
		LEFT JOIN (
			select
				depositorHits.Request_Date,
				count(1) Hit_Count
			from TB_Depositor_Hits as depositorHits
			where depositorHits.Status_Code is not null
			group by depositorHits.Request_Date
		) AS DH
			ON SD.Standard_Date = DH.Request_Date

		LEFT JOIN (
			select 
				convert(varchar, Regist_DateTime, 112) Regist_Date,
				count(1) as Account_Cnt
			from TB_Account
			group by convert(varchar, Regist_DateTime, 112)
		) AS RM
			ON SD.Standard_Date = RM.Regist_Date
		
		LEFT JOIN (
			select 
				remit.Complete_Date,
				sum(remit.Total_Price) as Total_Price,
				count(1) as Remit_Count,
				sum(tax.Tax) as  Tax
			from tb_remit as remit
				inner join TB_Invitation_Tax as invitationTax
					on remit.Invitation_ID = invitationTax.Invitation_ID
				inner join TB_Tax as tax
					on invitationTax.Tax_ID = tax.Tax_ID
			where remit.Result_Code = 'RC005'
			group by remit.Complete_Date,
				tax.Tax_ID
		) AS RM2
			ON SD.Standard_Date = RM2.Complete_Date
		LEFT JOIN (
			select 
				Complete_Date,
				count(1) User_Count
			from (
					select 
						remit.Complete_Date,
						account.user_id
					from tb_remit as remit
						inner join tb_account as account
							on remit.Account_ID = account.Account_ID
					where remit.Result_Code = 'RC005'
					group by remit.Complete_Date,
					account.User_ID
				) as a
			group by Complete_Date
		) AS RM3
			ON SD.Standard_Date = RM3.Complete_Date
	WHERE SD.Standard_Date = @Date
	;


	INSERT INTO TB_Remit_Statistics_Daily (Date, Remit_Price, Tax, Remit_Tax, Calculate_Tax, Hits_Tax, User_Count, Account_Count, Remit_Count)
	SELECT 
		ST.Standard_Month + '00' AS Standard_Month,
		ST.Total_Price,
		ST.Tax,
		ST.Remit_Tax,
		ST.Calculate_Tax,
		ST.Hit_Price,
		isnull(UC.User_Count,0) User_Count,
		isnull(RM.Account_Cnt,0) Account_Cnt,
		isnull(Remit_Count,0) Remit_Count
	FROM (
			SELECT 
				Standard_Month,
				isnull(SUM(Total_Price),0) Total_Price,
				isnull(SUM(Tax),0) Tax, 
				isnull(SUM(Remit_Tax),0) Remit_Tax,
				isnull(SUM(Calculate_Tax),0) Calculate_Tax,
				isnull(SUM(Hit_Price),0) Hit_Price,
				isnull(SUM(Remit_Count),0) Remit_Count
			FROM (
					SELECT 
						SD.Standard_Month,
						ISNULL(RM2.Total_Price, 0) Total_Price,
						ISNULL(RM2.Tax, 0) Tax,
						(ISNULL(RM2.Remit_Count, 0) * ISNULL(CT.Remit_Tax, 0)) Remit_Tax,
						(ISNULL(RM2.Remit_Count, 0) * ISNULL(CT.Calculate_Tax, 0)) Calculate_Tax,
						(ISNULL(DH.Hit_Count, 0) * ISNULL(CT.Hits_Tax, 0)) Hit_Price,
						ISNULL(RM2.Remit_Count, 0) Remit_Count
					FROM TB_Standard_Date AS SD
						LEFT JOIN (
							select 
								Standard_Date,
								Remit_Tax,
								Calculate_Tax,
								Hits_Tax
							from TB_Company_Tax as companyTax
								inner join (
									select standard_date, max(company_tax_id) company_tax_id
									from tb_company_tax as companyTax,
										tb_standard_date as standardDate
									where apply_start_date <= standardDate.standard_date
									group by standard_date
								) as companyTax2
									on companyTax.Company_Tax_ID = companyTax2.company_tax_id
						) AS CT
							ON SD.Standard_Date = CT.Standard_Date
						LEFT JOIN (
							select
								depositorHits.Request_Date,
								count(1) Hit_Count
							from TB_Depositor_Hits as depositorHits
							where depositorHits.Status_Code is not null
								and convert(varchar, depositorHits.Request_Date, 112) < @NextDate
							group by depositorHits.Request_Date
						) AS DH
							ON SD.Standard_Date = DH.Request_Date

						LEFT JOIN (
							select 
								remit.Complete_Date,
								sum(remit.Total_Price) as Total_Price,
								count(1) as Remit_Count,
								sum(tax.Tax) as  Tax
							from tb_remit as remit
								inner join TB_Invitation_Tax as invitationTax
									on remit.Invitation_ID = invitationTax.Invitation_ID
								inner join TB_Tax as tax
									on invitationTax.Tax_ID = tax.Tax_ID
							where remit.Result_Code = 'RC005'
								and convert(varchar, remit.Complete_Date, 112) < @NextDate
							group by remit.Complete_Date,
								tax.Tax_ID
						) AS RM2
							ON SD.Standard_Date = RM2.Complete_Date
					WHERE SD.Standard_Month = @Month
				) AS A
			GROUP BY Standard_Month

		) AS ST
		LEFT JOIN (
			select 
				Complete_Month,
				count(1) User_Count
			from (
					select 
						LEFT(Complete_Date, 6) Complete_Month,
						account.user_id
					from tb_remit as remit
						inner join tb_account as account
							on remit.Account_ID = account.Account_ID
					where remit.Result_Code = 'RC005'
						and Complete_Date < @NextDate
					group by LEFT(Complete_Date, 6),
						account.User_ID
				) as a
			group by Complete_Month
		) AS UC
			ON ST.Standard_Month = UC.Complete_Month
		LEFT JOIN (
			select 
				Left(convert(varchar, Regist_DateTime, 112), 6) Regist_Month,
				count(1) as Account_Cnt
			from TB_Account
			where convert(varchar, Regist_DateTime, 112) < @NextDate
			group by Left(convert(varchar, Regist_DateTime, 112), 6)
		) AS RM
			ON ST.Standard_Month = RM.Regist_Month

		WHERE ST.Standard_Month = @Month
	;

	/* 월간 통계 등록 */
	INSERT INTO TB_Remit_Statistics_Monthly (Date, Remit_Price, Tax, Remit_Tax, Calculate_Tax, Hits_Tax, User_Count, Account_Count, Remit_Count)
	SELECT LEFT(Date, 6), Remit_Price, Tax, Remit_Tax, Calculate_Tax, Hits_Tax, User_Count, Account_Count, Remit_Count
	FROM TB_Remit_Statistics_Daily 
	WHERE Date = @Month+'00'

	INSERT INTO TB_Remit_Statistics_Monthly (Date, Remit_Price, Tax, Remit_Tax, Calculate_Tax, Hits_Tax, User_Count, Account_Count, Remit_Count)
	SELECT 
		ST.Year+'00',
		ST.Remit_Price,
		ST.Tax,
		ST.Remit_Tax,
		ST.Calculate_Tax,
		ST.Hits_Tax,
		isnull(UC.User_Count,0) as User_Count,
		isnull(AC.Account_Count, 0) Account_Count,
		ST.Remit_Count
	FROM (
		SELECT 
			LEFT(Date, 4) Year, 
			isnull(SUM(Remit_Price),0) Remit_Price, 
			isnull(SUM(Tax),0) Tax, 
			isnull(SUM(Remit_Tax),0) Remit_Tax, 
			isnull(SUM(Calculate_Tax),0) Calculate_Tax, 
			isnull(SUM(Hits_Tax),0) Hits_Tax, 
			isnull(SUM(Remit_Count),0) Remit_Count
		FROM TB_Remit_Statistics_Monthly
		WHERE Date Like @Year+'%'
		GROUP BY LEFT(Date, 4)
		) AS ST
		LEFT JOIN (
			SELECT 
				Complete_Year,
				Count(1) User_Count
			FROM (
					SELECT
						LEFT(Remit.Complete_Date, 4) Complete_Year,
						Invitation.User_ID
					FROM TB_Remit AS Remit
						INNER JOIN TB_Invitation AS Invitation
							ON Remit.Invitation_ID = Invitation.Invitation_ID
					WHERE Remit.Complete_Date Like @Year + '%'
						and convert(varchar, remit.Complete_Date, 112) < @NextDate
					GROUP BY LEFT(Remit.Complete_Date, 4),
						Invitation.User_ID
				) AS UC
			GROUP BY Complete_Year
		) AS UC
			ON ST.Year = UC.Complete_Year
		LEFT JOIN (
			select 
				Left(convert(varchar, Regist_DateTime, 112), 4) Regist_Year,
				count(1) as Account_Count
			from TB_Account
				where convert(varchar, Regist_DateTime, 112) < @NextDate
			group by Left(convert(varchar, Regist_DateTime, 112), 4)
		) AS AC
			ON ST.Year = AC.Regist_Year
	;

END
GO
