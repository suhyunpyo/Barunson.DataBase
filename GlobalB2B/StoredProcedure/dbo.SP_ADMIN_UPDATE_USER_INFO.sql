IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_USER_INFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_USER_INFO
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_USER_INFO]
	-- Add the parameters for the stored procedure here
	@p_seq int,
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
	@p_shipping_country nvarchar(255),
	@p_active_yorn nchar(1),
	@p_admin_verfied_yorn nchar(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE [GlobalB2B].[dbo].[USER_MST]
   SET 
      [FIRST_NAME] = @p_first_name
      ,[LAST_NAME] = @p_last_name
      ,[COMPANY_NAME] = @p_company_name
      ,[COMPANY_LOCATION] = @p_company_location
      ,[COMPANY_OFFIC_ADDR] = @p_company_offic_addr
      ,[COMPANY_TEL_1] = @p_company_tel1
      ,[COMPANY_TEL_2] = @p_company_tel2
      ,[COMPANY_TEL_3] = @p_company_tel3
      ,[COMPANY_TEL_4] = @p_company_tel4
      ,[COMPANY_FAX_1] = @p_company_fax1
      ,[COMPANY_FAX_2] = @p_company_fax2
      ,[COMPANY_FAX_3] = @p_company_fax3
      ,[COMPANY_FAX_4] = @p_company_fax4
      ,[COMPANY_CONTACT_NAME] = @p_company_contact_name
      ,[COMPANY_CONTACT_JOB] = @p_company_contact_job
      ,[COMPANY_CONTACT_EMAIL] = @p_company_contact_email
      ,[COMPANY_WEBSITE_URL] = @p_company_website_url
      ,[COMPANY_ESTABLISH_YEAR] = @p_company_establish_year
      ,[COMPANY_TYPE_OF_BUSINESS] = @p_company_type_of_business
      ,[COMPANY_CONTURY] = @p_company_contury
      ,[COMPANY_ZIPCODE] = @p_company_zipcode
      ,[COMPANY_NUMBER_OF_EMPLOYEES] = @p_company_number_of_employees
      ,[BILLING_ADDR_1] = @p_billing_addr_1
      ,[BILLING_ADDR_2] = @p_billing_addr_2
      ,[BILLING_CITY] = @p_billing_city
      ,[BILLING_STATE] = @p_billing_state
      ,[BILLING_ZIPCODE] = @p_billing_zipcode
      ,[BILLING_COUNTRY] = @p_billing_country
      ,[SHIPPING_ADDR_1] = @p_shipping_addr_1
      ,[SHIPPING_ADDR_2] = @p_shipping_addr_2
      ,[SHIPPING_CITY] = @p_shipping_city
      ,[SHIPPING_STATE] = @p_shipping_state
      ,[SHIPPING_ZIPCODE] = @p_shipping_zipcode
      ,[SHIPPING_COUNTRY] = @p_shipping_country
      ,[MAILING_YORN] = @p_mailing_check
      ,[ACTIVATE_YORN] = @p_active_yorn
      ,[ADMIN_VERFIED_YORN] = @p_admin_verfied_yorn
	WHERE
		USER_SEQ = @p_seq;		

END

GO
