IF OBJECT_ID (N'dbo.up_front_vstat_epost', N'P') IS NOT NULL DROP PROCEDURE dbo.up_front_vstat_epost
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[up_front_vstat_epost]
	@vtype	char(1)
,	@vdate	varchar(10)
as
	
IF EXISTS (select pcnt from VSTAT_SITE_EPOST where vdate=@vdate)
-- 해당 상품열이 없을때 INSERT 처리
	if @vtype = 'P' 
		update VSTAT_SITE_EPOST set pcnt = pcnt + 1 where vdate = @vdate
	else
		update VSTAT_SITE_EPOST set ccnt = ccnt + 1 where vdate = @vdate
ELSE						-- 이미 해당상품 열이 입력되어 있을때 UPDATE 처리
	if @vtype = 'P' 
		insert into VSTAT_SITE_EPOST(vdate,pcnt) values(@vdate,1)
	else
		insert into VSTAT_SITE_EPOST(vdate,ccnt) values(@vdate,1)
GO
