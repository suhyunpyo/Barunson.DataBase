IF OBJECT_ID (N'dbo.SP_MCARD_INVITATION', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_MCARD_INVITATION
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================================================================================
-- Author:		엄예지
-- Create date: 2016.09.08
-- Description:	2016.09오픈 NEW모바일초대장 이벤트일 기준 2개월 지나면 만요여부 , 삭제여부 N값으로 업데이트 한다.
--				모바일초대장 제작완료일기준으로 있으면 이벤트일자, 없으면 이벤트일자와 생성일을 기준으로 한다.
--				이벤트일기준 3개월이 지나면 이미지 파일도 모두 삭제된다.--추후 예정
-- ====================================================================================================================================
CREATE PROCEDURE [dbo].[SP_MCARD_INVITATION] 
AS
BEGIN
	
	SET NOCOUNT ON;

    WITH DEL_INVITATION AS (SELECT INVITATIONID
							FROM (
									SELECT INVITATIONID
										, CASE WHEN COMPLETEDTIME IS NOT NULL THEN 
												CASE WHEN DATEADD(MONTH, 3, LEFT(EVENTDATE, 10)) < GETDATE() THEN 'Y' ELSE 'N' END
												ELSE 
													CASE WHEN (DATEADD(MONTH, 3, LEFT(EVENTDATE, 10)) < GETDATE()) AND (DATEADD(MONTH, 4, LEFT(REGISTERTIME, 10)) < GETDATE()) THEN 'Y' ELSE 'N' END
											END GB
									FROM MCARD_INVITATION
									WHERE DELETEYN = 'N'
								) AA
							WHERE GB = 'Y'
						)

	UPDATE A SET 
		A.DELETEYN = 'Y',
		A.EXPIREYN = 'Y'
	FROM MCARD_INVITATION A, DEL_INVITATION D
	WHERE A.INVITATIONID = D.INVITATIONID


END
GO
