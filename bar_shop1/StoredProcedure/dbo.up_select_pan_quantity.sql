IF OBJECT_ID (N'dbo.up_select_pan_quantity', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_pan_quantity
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-24
-- Description:	마이페이지 주문상세내역 - 판 수량정보 가져오기
-- TEST : up_select_pan_quantity 2173575
-- =============================================
CREATE PROCEDURE [dbo].[up_select_pan_quantity]
	
	@order_seq		int	

AS
BEGIN

	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
	
	-- 카드 --
	SELECT   id						--0
			,sid					--1
			,print_type				--2
			,title					--3
			,print_count			--4
			,isNotPrint				--5
			,env_zip				--6
			,etc_comment			--7
			,env_addr				--8
			,env_addr_detail		--9
			,env_phone				--10
			,env_hphone				--11
			,ISNULL(env_person1, '') AS env_person1			--12	
			,ISNULL(env_person2, '') AS env_person2			--13
			,env_person_tail		--14 (배상)	
			,isenv_person_tail		--15
			,ISNULL(env_person1_tail, '') AS env_person1_tail		--16 (세례명/아명)
			,ISNULL(env_person2_tail, '') AS env_person2_tail		--17 (세례명/아명)
			,isPostMark				--18
			,PostName				--19
			,PostName_Tail			--20
			,isZipBox				--21
			,ISNULL(recv_tail, '') AS recv_tail				--22 (귀하)
			,order_filename			--23
			,imgFolder				--24
			,imgname				--25
			,ISNULL(pstatus, 0) AS pstatus	--26
			,isNotSet				--27
	FROM Custom_Order_Plist 
	WHERE order_seq = @order_seq 
	  AND print_type IN ('C', 'G', 'I')	  
	  AND isFPrint <> '1'
	  AND print_count > 0  
	ORDER BY print_type, id



	-- 봉투 --
	SELECT   A.id					--0
			,A.sid					--1
			,A.print_type			--2
			,A.card_seq				--3
			,A.title				--4
			,A.print_count			--5
			,A.isNotPrint			--6
			,A.env_zip				--7
			,A.etc_comment			--8
			,A.env_addr				--9
			,A.env_addr_detail		--10
			,A.env_phone			--11
			,A.env_hphone			--12
			,A.env_hphone2			--13	
			,ISNULL(A.env_person1, '') AS env_person1			--14
			,ISNULL(A.env_person2, '') AS env_person2			--15
			,A.env_person_tail		--16 (배상)
			,A.isenv_person_tail	--17	
			,ISNULL(A.env_person1_tail, '') AS env_person1_tail		--18 (세례명/아명)
			,ISNULL(A.env_person2_tail, '') AS env_person2_tail		--19 (세례명/아명)
			,A.isPostMark			--20
			,A.PostName				--21
			,A.PostName_Tail		--22
			,A.isZipBox				--23
			,ISNULL(A.recv_tail, '') AS recv_tail			--24 (귀하)
			,A.isqrcode				--25
			,A.etc_info_s			--26
			,B.card_name			--27
			,A.isNotPrint_Addr		--28
			,A.order_filename		--29
			,A.imgFolder			--30
			,A.imgname				--31
			,ISNULL(A.pstatus, 0) AS pstatus	--32	
	FROM Custom_Order_Plist A 
	INNER JOIN S2_Card B ON A.card_seq = B.card_seq	
	WHERE A.order_seq = @order_seq 
	  AND A.print_type = 'E' 
	  AND A.isFPrint <> '1' 
	  AND A.print_count > 0 
	ORDER BY A.id
	
	
END


/*
update Custom_Order_Plist set title = '추가인쇄봉투'
where title = '인쇄봉투추가'

update Custom_Order_Plist set title = '추가인쇄봉투'
where title = '추가봉투'

select * from Custom_Order_Plist where title = '봉투인쇄안함'


select print_type, card_seq, title, print_count
from custom_order_plist
where order_seq = 1970723

*/


--update Custom_Order_Plist set env_zip = '456123', env_addr = '서울 테스트구 테스트시 123-24'
--where id = 5930419


/*
select postname, PostName_tail
from Custom_Order_Plist
where isPostMark = 1
*/


/*
select distinct title from Custom_Order_Plist

select * from S2_Card where Card_Name like '%레이저%'
select * from S2_Card where Card_Name like '%컬러%'
*/
GO
