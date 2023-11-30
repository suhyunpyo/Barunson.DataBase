IF OBJECT_ID (N'dbo.SP_INSERT_USER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_USER
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
CREATE PROCEDURE [dbo].[SP_INSERT_USER]
	@p_id nvarchar(255),
	@p_pwd nvarchar(255),
	@p_first_name nvarchar(255),
	@p_last_name nvarchar(255),
	@p_mailing_check nchar(1),
	@p_company_name nvarchar(255),
	@p_company_location nvarchar(255),
	@p_company_offic_addr nvarchar(255),
	@p_company_tel1 nvarchar(255),
	@p_company_tel2 nvarchar(255),
	@p_company_tel3 nvarchar(255),
	@p_company_tel4 nvarchar(255),
	@p_company_fax1 nvarchar(255),
	@p_company_fax2 nvarchar(255),
	@p_company_fax3 nvarchar(255),
	@p_company_fax4 nvarchar(255),
	@p_company_contact_name nvarchar(255),
	@p_company_contact_job nvarchar(255),
	@p_company_contact_email nvarchar(255),
	@p_company_website_url nvarchar(255),
	@p_company_establish_year char(4),
	@p_company_type_of_business nvarchar(255),
	@p_company_contury nvarchar(255),
	@p_company_zipcode nvarchar(255),
	@p_company_number_of_employees int,
	@p_billing_addr_1 nvarchar(255),
	@p_billing_addr_2 nvarchar(255),
	@p_billing_city nvarchar(255),
	@p_billing_state nvarchar(255),
	@p_billing_zipcode nvarchar(255),
	@p_billing_country nvarchar(255),
	@p_shipping_addr_1 nvarchar(255),
	@p_shipping_addr_2 nvarchar(255),
	@p_shipping_city nvarchar(255),
	@p_shipping_state nvarchar(255),
	@p_shipping_zipcode nvarchar(255),
	@p_shipping_country nvarchar(255)

	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO [GlobalB2B].[dbo].[USER_MST]
           ([USER_ID]
           ,[USER_PWD]
           ,[FIRST_NAME]
           ,[LAST_NAME]
           ,[COMPANY_NAME]
           ,[COMPANY_LOCATION]
           ,[COMPANY_OFFIC_ADDR]
           ,[COMPANY_TEL_1]
           ,[COMPANY_TEL_2]
           ,[COMPANY_TEL_3]
           ,[COMPANY_TEL_4]
           ,[COMPANY_FAX_1]
           ,[COMPANY_FAX_2]
           ,[COMPANY_FAX_3]
           ,[COMPANY_FAX_4]
           ,[COMPANY_CONTACT_NAME]
           ,[COMPANY_CONTACT_JOB]
           ,[COMPANY_CONTACT_EMAIL]
           ,[COMPANY_WEBSITE_URL]
           ,[COMPANY_ESTABLISH_YEAR]
           ,[COMPANY_TYPE_OF_BUSINESS]
           ,[COMPANY_CONTURY]
           ,[COMPANY_ZIPCODE]
           ,[COMPANY_NUMBER_OF_EMPLOYEES]
           ,[BILLING_ADDR_1]
           ,[BILLING_ADDR_2]
           ,[BILLING_CITY]
           ,[BILLING_STATE]
           ,[BILLING_ZIPCODE]
           ,[BILLING_COUNTRY]
           ,[SHIPPING_ADDR_1]
           ,[SHIPPING_ADDR_2]
           ,[SHIPPING_CITY]
           ,[SHIPPING_STATE]
           ,[SHIPPING_ZIPCODE]
           ,[SHIPPING_COUNTRY]
           ,[MAILING_YORN]
           ,[REG_DATE])
     VALUES
           (@p_id
           ,@p_pwd
           ,@p_first_name
           ,@p_last_name
           ,@p_company_name
           ,@p_company_location
           ,@p_company_offic_addr
           ,@p_company_tel1
           ,@p_company_tel2
           ,@p_company_tel3
           ,@p_company_tel4
           ,@p_company_fax1
           ,@p_company_fax2
           ,@p_company_fax3
           ,@p_company_fax4
           ,@p_company_contact_name
           ,@p_company_contact_job
           ,@p_company_contact_email
           ,@p_company_website_url
           ,@p_company_establish_year
           ,@p_company_type_of_business
           ,@p_company_contury
           ,@p_company_zipcode
           ,@p_company_number_of_employees
           ,@p_billing_addr_1
           ,@p_billing_addr_2
           ,@p_billing_city
           ,@p_billing_state
           ,@p_billing_zipcode
           ,@p_billing_country
           ,@p_shipping_addr_1
           ,@p_shipping_addr_2
           ,@p_shipping_city
           ,@p_shipping_state
           ,@p_shipping_zipcode
           ,@p_shipping_country
           ,@p_mailing_check
           ,GETDATE());

END
GO
