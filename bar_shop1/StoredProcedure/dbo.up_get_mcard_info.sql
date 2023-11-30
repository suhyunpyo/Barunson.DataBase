IF OBJECT_ID (N'dbo.up_get_mcard_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_get_mcard_info
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		강현주
-- Create date: 2015-01-08
-- Description:	Mobile 청첩장 1단계 정보
-- TEST : up_get_mcard_info 51945, 'algodulce', 'algodulce', 5007 
-- =============================================
CREATE PROCEDURE [dbo].[up_get_mcard_info]
	@order_seq		AS int,	
	@addr			AS varchar(50),
	@uid			AS varchar(20),
	@company_seq	AS int	
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON;

	SELECT TOP 1 
		 ISNULL(order_name, '') AS order_name 
		,ISNULL(order_email, '') AS order_email 
		,ISNULL(order_phone, '') AS order_phone 
		,ISNULL(order_hphone, '') AS order_hphone 
		,ISNULL(Addr, '') AS Addr 
		,ISNULL(groom_name_kor, '') AS groom_name_kor 
		,ISNULL(groom_name_eng, '') AS groom_name_eng 
		,ISNULL(groom_hphone, '') AS groom_hphone 
		,ISNULL(bride_name_kor, '') AS bride_name_kor 
		,ISNULL(bride_name_eng, '') AS bride_name_eng 
		,ISNULL(bride_hphone, '') AS bride_hphone 
		,ISNULL(greeting_content, '') AS greeting_content 
		,ISNULL(event_year, '') AS event_year 
		,ISNULL(event_month, '') AS event_month 
		,ISNULL(event_Day, '') AS event_day 
		,ISNULL(event_weekname, '') AS event_weekname 
		,ISNULL(event_ampm, '낮') AS event_ampm 
		,ISNULL(event_hour, '12') AS event_hour 
		,ISNULL(event_minute, '00') AS event_minute 
		,ISNULL(lunar_yorn, 'N') AS lunar_yorn 
		,ISNULL(weddinghall, '') AS weddinghall 
		,ISNULL(wedd_phone, '') AS wedd_phone
		,ISNULL(wedd_place, '') AS wedd_place
		,ISNULL(weddingaddr, '') AS weddingaddr
		,ISNULL(latitude, '') AS latitude
		,ISNULL(longitude, '') AS longitude
		,ISNULL(Qrcode, '') AS Qrcode
		,ISNULL(show_hash, '') AS show_hash
 		,worder_seq
		,status_seq
		,mobile_skin_seq
		,order_seq
		,(select skin_img from S5_nmCardShowInfo where ShowHash=A.show_hash) as skin_img
		,ISNULL(map_type, 'NaverMap') AS map_type
	FROM 
		S5_nmCardOrder AS A
	WHERE 
		order_seq = ISNULL(@order_seq, order_seq)
		AND addr = ISNULL(@addr, addr)
		AND uid = ISNULL(@uid, uid)
		AND company_seq = @company_seq

END
GO
