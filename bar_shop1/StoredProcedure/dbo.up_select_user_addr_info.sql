IF OBJECT_ID (N'dbo.up_select_user_addr_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_user_addr_info
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-22
-- Description:	주문상세내역 - 배송정보 - 회원가입 시의 주소 
-- TEST : up_select_delivery_info 회원ID
-- =============================================
CREATE PROCEDURE [dbo].[up_select_user_addr_info]
	
	@uid		varchar(16)		--회원 ID

AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;


	SELECT   uname
			,zip1
			,zip2
			,address
			,addr_detail
			,hand_phone1
			,hand_phone2
			,hand_phone3
			,phone1
			,phone2
			,phone3			
	FROM S2_UserInfo_TheCard
	WHERE uid = @uid


END
GO
