IF OBJECT_ID (N'dbo.view_Comment', N'V') IS NOT NULL DROP View dbo.view_Comment
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_Comment]
AS
Select A.CMT_SEQ,A.MEMBER_NAME,ISNULL(A.COMMENT,'') as comment,A.REGDATE,A.CARD_SEQ,A.score,A.TITLE
,B.card_cate,B.card_code,B.card_img_xs,'W' as comm_div From CARD_USER_COMMNET A inner join CARD B on A.card_seq=B.card_seq
Where A.sales_gubun='W'
--UNION

--Select A.CMT_SEQ,A.MEMBER_NAME,ISNULL(A.COMMENT,'') as comment,A.REGDATE,A.CARD_SEQ,A.score,A.TITLE
--,B.cate_l_code as card_cate,B.card_title as card_code,B.card_img2 as card_img_xs,'E' as comm_div From ewed_CARD_USER_COMMNET A inner join ewed_CARD_INFO B on A.card_seq=B.card_seq
--Where A.site_div is null and B.isview_yn='Y'



GO
