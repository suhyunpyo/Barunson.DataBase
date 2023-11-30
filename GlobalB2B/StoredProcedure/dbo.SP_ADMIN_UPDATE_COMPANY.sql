IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_COMPANY', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_COMPANY
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_COMPANY]
	@p_seq int,
	@p_company_name nvarchar(255),
	@p_company_tel_1 nvarchar(20),
	@p_company_tel_2 nvarchar(20),
	@p_company_tel_3 nvarchar(20),
	@p_company_tel_4 nvarchar(100),
	@p_company_fax_1 nvarchar(20),
	@p_company_fax_2 nvarchar(20),
	@p_company_fax_3 nvarchar(20),
	@p_company_fax_4 nvarchar(100),
	@p_company_addr_1 nvarchar(255),
	@p_company_addr_2 nvarchar(255),
	@p_company_city nvarchar(255),
	@p_company_state nvarchar(255),
	@p_company_country nvarchar(150),
	@p_company_zipcode nvarchar(60),
	@p_company_contact_name nvarchar(255),
	@p_company_contact_job nvarchar(255),
	@p_company_contact_email nvarchar(255),
	@p_company_website_url nvarchar(255),
	@p_company_establish_year char(4),
	@p_company_type_of_business nvarchar(255),
	@p_company_number_of_employees int,
	@p_memo ntext,
	@p_company_rate int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE [GlobalB2B].[dbo].[COMPANY_MST]
	SET [COMPANY_NAME] = @p_company_name
	  ,[COMPANY_TEL_1] = @p_company_tel_1
	  ,[COMPANY_TEL_2] = @p_company_tel_2
	  ,[COMPANY_TEL_3] = @p_company_tel_3
	  ,[COMPANY_TEL_4] = @p_company_tel_4
	  ,[COMPANY_FAX_1] = @p_company_fax_1
	  ,[COMPANY_FAX_2] = @p_company_fax_2
	  ,[COMPANY_FAX_3] = @p_company_fax_3
	  ,[COMPANY_FAX_4] = @p_company_fax_4
	  ,[COMPANY_ADDR_1] = @p_company_addr_1
	  ,[COMPANY_ADDR_2] = @p_company_addr_2
	  ,[COMPANY_CITY] = @p_company_city
	  ,[COMPANY_STATE] = @p_company_state
	  ,[COMPANY_COUNTRY] = @p_company_country
	  ,[COMPANY_ZIPCODE] = @p_company_zipcode
	  ,[COMPANY_CONTACT_NAME] = @p_company_contact_name
	  ,[COMPANY_CONTACT_JOB] = @p_company_contact_job
	  ,[COMPANY_CONTACT_EMAIL] = @p_company_contact_email
	  ,[COMPANY_WEBSITE_URL] = @p_company_website_url
	  ,[COMPANY_ESTABLISH_YEAR] = @p_company_establish_year
	  ,[COMPANY_TYPE_OF_BUSINESS] = @p_company_type_of_business
	  ,[COMPANY_NUMBER_OF_EMPLOYEES] = @p_company_number_of_employees
	  ,[MEMO] = @p_memo
	  ,[COMPANY_RATE] = @p_company_rate
	 WHERE COMPANY_SEQ = @p_seq;

END
GO
