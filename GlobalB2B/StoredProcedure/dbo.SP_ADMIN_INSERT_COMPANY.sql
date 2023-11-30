IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_COMPANY', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_COMPANY
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_COMPANY]
	-- Add the parameters for the stored procedure here
	@p_company_name nvarchar(255),
	@p_company_tel_1 nvarchar(255),
	@p_company_tel_2 nvarchar(255),
	@p_company_tel_3 nvarchar(255),
	@p_company_tel_4 nvarchar(255),
	@p_company_fax_1 nvarchar(255),
	@p_company_fax_2 nvarchar(255),
	@p_company_fax_3 nvarchar(255),
	@p_company_fax_4 nvarchar(255),
	@p_company_addr_1 nvarchar(255),
	@p_company_addr_2 nvarchar(255),
	@p_company_city nvarchar(255),
	@p_company_state nvarchar(255),
	@p_company_country nvarchar(255),
	@p_company_zipcode nvarchar(255),
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

    -- Insert statements for procedure here
	INSERT INTO [GlobalB2B].[dbo].[COMPANY_MST]
           ([COMPANY_NAME]
           ,[COMPANY_TEL_1]
           ,[COMPANY_TEL_2]
           ,[COMPANY_TEL_3]
           ,[COMPANY_TEL_4]
           ,[COMPANY_FAX_1]
           ,[COMPANY_FAX_2]
           ,[COMPANY_FAX_3]
           ,[COMPANY_FAX_4]
           ,[COMPANY_ADDR_1]
           ,[COMPANY_ADDR_2]
           ,[COMPANY_CITY]
           ,[COMPANY_STATE]
           ,[COMPANY_COUNTRY]
           ,[COMPANY_ZIPCODE]
           ,[COMPANY_CONTACT_NAME]
           ,[COMPANY_CONTACT_JOB]
           ,[COMPANY_CONTACT_EMAIL]
           ,[COMPANY_WEBSITE_URL]
           ,[COMPANY_ESTABLISH_YEAR]
           ,[COMPANY_TYPE_OF_BUSINESS]
           ,[COMPANY_NUMBER_OF_EMPLOYEES]
           ,[MEMO]
           ,[REG_DATE]
           ,[COMPANY_RATE]
           )
     VALUES
           (@p_company_name
           ,@p_company_tel_1
           ,@p_company_tel_2
           ,@p_company_tel_3
           ,@p_company_tel_4
           ,@p_company_fax_1
           ,@p_company_fax_2
           ,@p_company_fax_3
           ,@p_company_fax_4
           ,@p_company_addr_1
           ,@p_company_addr_2
           ,@p_company_city
           ,@p_company_state
           ,@p_company_country
           ,@p_company_zipcode
           ,@p_company_contact_name
           ,@p_company_contact_job
           ,@p_company_contact_email
           ,@p_company_website_url
           ,@p_company_establish_year
           ,@p_company_type_of_business
           ,@p_company_number_of_employees
           ,@p_memo
           ,GETDATE()
           ,@p_company_rate
           );
END


GO
