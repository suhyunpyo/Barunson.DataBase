IF OBJECT_ID (N'dbo.up_select_order_wed_seq_cardinfo_plist', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_order_wed_seq_cardinfo_plist
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2014-04-30
-- Description:	청첩장 주문 봉투정보 
-- =============================================
CREATE PROCEDURE [dbo].[up_select_order_wed_seq_cardinfo_plist]
	-- Add the parameters for the stored procedure here
	@order_seq AS int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
			select COUNT(id) FROM custom_order_plist with(nolock)
			WHERE order_seq=@order_seq and (title like '%카드%' or print_type='E') and isFPrint<>'1' and order_seq <> 0
		
			SELECT 
			id,sid,print_type,title,print_count,	--5
			isNotPrint,env_zip,etc_comment,env_addr,env_addr_detail,	--10
			env_phone,env_hphone,env_hphone2,env_person1,env_person2,	--15
			env_person_tail,isenv_person_tail,env_person1_tail,env_person2_tail,isPostMark,		--20
			PostName,PostName_Tail,isZipBox,recv_tail,order_filename, isnull(isNotPrint_Addr,0)	--26
			FROM custom_order_plist with(nolock)
			WHERE order_seq=@order_seq and (title like '%카드%' or print_type='E') and isFPrint<>'1' and order_seq <> 0 order by id


	
END
GO
