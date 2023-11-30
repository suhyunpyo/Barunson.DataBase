IF OBJECT_ID (N'dbo.V_BoardList', N'V') IS NOT NULL DROP View dbo.V_BoardList
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_BoardList]
AS
SELECT 'faq' AS boardid, seq, sales_gubun, company_seq, writer, title, contents,
       display_order, '' AS start_date, '' AS end_date, viewcnt, reg_date       
FROM S2_FAQ
UNION ALL
SELECT 'notice' AS boardid, seq, sales_gubun, company_seq, writer, title, contents,
       seq AS display_order, ISNULL(start_date, ''), ISNULL(end_date, ''), viewcnt, reg_date
FROM S2_Notice
UNION ALL
SELECT 'review' AS boardid, ER_idx AS seq, '' AS sales_gubun, er_company_seq AS company_seq, 
       er_userName AS writer, er_review_title AS title, er_review_content AS contents, ER_idx AS display_order, '' AS start_date, '' AS end_date, er_recom_cnt AS viewcnt, er_regdate AS reg_date
FROM S4_Event_Review
GO
