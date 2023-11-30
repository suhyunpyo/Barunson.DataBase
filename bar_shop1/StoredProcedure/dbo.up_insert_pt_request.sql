IF OBJECT_ID (N'dbo.up_insert_pt_request', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_pt_request
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-08
-- Description:	제휴 문의
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_pt_request]
	
	@sales_gubun	VARCHAR(2),
	@company_seq	INT,	
	@com_name		VARCHAR(50),
	@com_url		VARCHAR(100),
	@person_name	VARCHAR(50),
	@person_email   VARCHAR(50), 	
	@phone1			VARCHAR(3),
	@phone2			VARCHAR(4),
	@phone3			VARCHAR(4),
	@hand_phone1	VARCHAR(3),
	@hand_phone2	VARCHAR(4),
	@hand_phone3	VARCHAR(4),
	@zip1			VARCHAR(3),
	@zip2			VARCHAR(3),
	@address		VARCHAR(100),
	@addr_detail	VARCHAR(50),
	@zip1_R			VARCHAR(3),
	@zip2_R			VARCHAR(3),
	@address_R		VARCHAR(100),
	@addr_detail_R	VARCHAR(50),
	@com_contents	TEXT,
	@com_message	TEXT,
	@user_upfile	VARCHAR(50)
	
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;	


	INSERT INTO S2_PTRequest 
	(
		sales_gubun, company_seq, com_name, com_url, person_name, person_email, phone1, phone2, phone3, hand_phone1, hand_phone2, hand_phone3, 
		zip1, zip2, address, addr_detail, com_contents, com_message, user_upfile, reg_date, zip1_R, zip2_R, address_R, addr_detail_R
	) 
	VALUES 
	(
		@sales_gubun, @company_seq, @com_name, @com_url, @person_name, @person_email, @phone1, @phone2, @phone3, @hand_phone1, @hand_phone2, @hand_phone3, 
		@zip1, @zip2, @address, @addr_detail, @com_contents, @com_message, @user_upfile, GETDATE(), @zip1_R, @zip2_R, @address_R, @addr_detail_R
	)

END





-- select * from S2_PTRequest

GO
