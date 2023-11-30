IF OBJECT_ID (N'dbo.sp_DacomMMS', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_DacomMMS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC sp_DacomMMS '010-4934-9760', '010-4934-9760', '테스트', '/Inetpub/MobileInvitation/Photos/201611/B2402584/mmscard.jpg'

*/

CREATE Procedure [dbo].[sp_DacomMMS]
	@recv_pnum 	varchar(20),
	@send_pnum 	varchar(20),
	@msg 		varchar(160),
	@IMG_URL	VARCHAR(MAX)
as
begin



	--insert into invtmng.MMS_MSG(subject,phone,callback,status,reqdate,msg,file_cnt, file_path1,TYPE) 
	--values('모바일초대장 ', @recv_pnum, @send_pnum ,'0',getdate(), @msg   , '1' , @IMG_URL,'0')


	EXEC SP_EXEC_SMS_OR_MMS_SEND @SEND_PNUM, @RECV_PNUM, '바른컴퍼니', @MSG, '', '고객 사용', '모바일초대장 핸드폰으로 주소 보내기 - SP_DACOMMMS', '', 1, @IMG_URL


end
GO
