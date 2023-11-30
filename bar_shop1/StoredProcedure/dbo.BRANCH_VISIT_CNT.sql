IF OBJECT_ID (N'dbo.BRANCH_VISIT_CNT', N'P') IS NOT NULL DROP PROCEDURE dbo.BRANCH_VISIT_CNT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
 작성자   :  2005.12.05  진나영
 내용    :   접속 카운트   
 수정정보   :   
*/  
CREATE Procedure [dbo].[BRANCH_VISIT_CNT]
	@vdomain		varchar(50)
,	@vdate	varchar(10)
,	@company_seq smallint
as

IF EXISTS (select vcnt from BRANCH_VISIT_SITE where vdate=@vdate and vdomain=@vdomain and company_seq=@company_seq)
	-- 해당 상품열이 없을때 INSERT 처리
	update BRANCH_VISIT_SITE set vcnt = vcnt + 1 where vdate = @vdate and vdomain=@vdomain and company_Seq=@company_seq
ELSE	
	-- 이미 해당상품 열이 입력되어 있을때 UPDATE 처리
	insert into BRANCH_VISIT_SITE(vdomain,vdate,company_seq) values(@vdomain,@vdate,@company_seq)
GO
