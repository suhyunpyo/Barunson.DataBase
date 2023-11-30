IF OBJECT_ID (N'dbo.up_insert_visit_reservation', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_visit_reservation
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-05
-- Description:	방문상담 예약
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_visit_reservation]
		
	@visit_name		NVARCHAR(16),
	@visit_date		VARCHAR(10),
	@visit_time		VARCHAR(4),	
	@tel_no1		VARCHAR(3),
	@tel_no2		VARCHAR(4),
	@tel_no3		VARCHAR(4),
	@visit_content	TEXT,
	@domain_info	NVARCHAR(50),
	@wedd_date		VARCHAR(10),
	@wedd_time		VARCHAR(4)
	
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;	
	
	
	INSERT INTO Visit_Reservation 
	(visit_name, visit_date, visit_time, tel_no1, tel_no2, tel_no3, visit_content, regDate, domain_info, wedd_date, wedd_time) 
	 VALUES
	(@visit_name, @visit_date, @visit_time, @tel_no1, @tel_no2, @tel_no3, @visit_content, getDate(), @domain_info , @wedd_date, @wedd_time)

END



--select * from Visit_Reservation
GO
