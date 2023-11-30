IF OBJECT_ID (N'dbo.up_front_vstat_site', N'P') IS NOT NULL DROP PROCEDURE dbo.up_front_vstat_site
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
 작성정보   :   [2005:01:25    13:28] 김수경:   
 내용    :       접속 카운트
   
 수정정보   :   
*/  
CREATE Procedure [dbo].[up_front_vstat_site]
	@vdomain		varchar(50)
,	@vdate	varchar(10)
,	@company_seq smallint
as

IF EXISTS (select vcnt from VSTAT_SITE where vdate=@vdate and vdomain=@vdomain and company_seq=@company_seq)
-- 해당 상품열이 없을때 INSERT 처리

	update VSTAT_SITE set vcnt = vcnt + 1 where vdate = @vdate and vdomain=@vdomain and company_Seq=@company_seq
ELSE						-- 이미 해당상품 열이 입력되어 있을때 UPDATE 처리
	insert into VSTAT_SITE(vdomain,vdate,company_seq) values(@vdomain,@vdate,@company_seq)
GO
