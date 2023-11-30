IF OBJECT_ID (N'dbo.SP_AddPrintTitle', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_AddPrintTitle
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].[SP_AddPrintTitle]
	@order_seq     INT
	, @id INT
as      
      
SET NOCOUNT ON      


-- EXEC SP_AddPrintTitle 2783747, 9365050



DECLARE @add_msg1 CHAR(1)
DECLARE @add_msg2 CHAR(1)
DECLARE @add_msg3 CHAR(1)

SET @add_msg1 = 'N'
SET @add_msg2 = 'N'
SET @add_msg3 = 'N'


IF EXISTS (
	SELECT A.order_seq 
	FROM custom_order_plist A 
	WHERE order_seq = @order_seq
		AND A.print_type IN ('C', 'I', 'P', 'G') 
		AND A.title LIKE '카드추가인쇄%' 
)
BEGIN 
	SELECT @add_msg1 = CASE WHEN MAX(ISNULL(A.env_addr,'')) <> '' THEN 'Y' ELSE 'N' END 	--전세버스
		, @add_msg2 = CASE WHEN MAX(ISNULL(A.env_addr_detail,'')) <> '' THEN 'Y' ELSE 'N' END  	--피로연
		, @add_msg3 = CASE WHEN MAX(ISNULL(A.etc_comment,'')) <> '' THEN 'Y' ELSE 'N' END  	--기타
	FROM custom_order_plist A 
	WHERE order_seq = @order_seq
		AND A.print_type IN ('C', 'I', 'P', 'G') 	
		
END 

--기타부분은 제외
--+ CASE WHEN ISNULL(LTRIM(RTRIM(A.etc_comment)),'') <> '' THEN ' /기타O' WHEN @add_msg3 = 'Y' THEN ' /기타X' ELSE '' END


SELECT A.id, A.order_seq
	, A.title
	, ISNULL(A.env_zip,'000000') as add_chk	--000110  :   4,5,6번째 자릿수가 1이면 전세버스/피로연/기타 정보가 있는것.
	
	, CASE WHEN ISNULL(LTRIM(RTRIM(A.env_addr)),'') <> '' AND @add_msg1 = 'Y'  THEN ' /전세버스O' WHEN @add_msg1 = 'Y' THEN ' /전세버스X' ELSE '' END
		+ CASE WHEN ISNULL(LTRIM(RTRIM(A.env_addr_detail)),'') <> '' AND @add_msg2 = 'Y' THEN ' /피로연O' WHEN @add_msg2 = 'Y' THEN ' /피로연X' ELSE '' END
		+ CASE WHEN ISNULL(G.pid, 0) <> 0 THEN ' /인사말O' ELSE '' END
		 --감사장은 이름을 직관적으로 기재하기때문에 제외요청(정일순)
		+ CASE WHEN ISNULL(N.pid, 0) <> 0 AND EXISTS ( SELECT order_seq FROM custom_order where order_seq = @order_seq AND order_type <> '2' ) THEN ' /이름O' ELSE '' END
		+ CASE WHEN ISNULL(D.pid, 0) <> 0 THEN ' /예식일O' ELSE '' END AS Addtitle

FROM custom_order_plist A
LEFT JOIN custom_order_plistAddG G ON G.pid = A.id 
LEFT JOIN custom_order_plistAddN N ON N.pid = A.id 
LEFT JOIN custom_order_plistAddD D ON D.pid = A.id
WHERE A.order_seq = @order_seq
	and A.id = @id





--, ISNULL(A.env_addr,'') as add_msg1		--전세버스
--, ISNULL(A.env_addr_detail,'') as add_msg2	--피로연
--, ISNULL(A.etc_comment,'') as add_msg3		--기타
--, ISNULL(G.pid, 0) AS Gpid		--인사말	 ISNULL(G.greeting_content, '')
--, ISNULL(N.pid, 0) AS Npid		--혼주이름
--, ISNULL(D.pid, 0) AS Dpid		--예식일시
GO
