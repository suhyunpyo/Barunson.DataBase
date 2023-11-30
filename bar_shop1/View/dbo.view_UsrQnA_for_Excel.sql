IF OBJECT_ID (N'dbo.view_UsrQnA_for_Excel', N'V') IS NOT NULL DROP View dbo.view_UsrQnA_for_Excel
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[view_UsrQnA_for_Excel]
AS

SELECT
    '0' AS isS2,
    qa_iid,
    A.sales_gubun,
    A.company_seq,
    B.company_name,
    A.order_seq,
    '' AS CARD_CODE,
    A.member_id,
    case
        when isnull(A.member_name, '') = '' then U.uname
        else A.member_name
    end member_name,
    A.e_mail,
    A.tel_no,
    Q_kind,
    Q_title,
    Q_content,
	A_CONTENT,
    A_stat,
    a_dt,
    reg_dt,
    ISNULL(a_research1, '0') AS a_research1,
    ISNULL(a_research2, '0') AS a_research2,
    a_research_date,
    a_id,
    user_upfile1,
	user_upfile2,
	'' AS admin_upfile1,
	'' AS categorym,
	'' AS categorys
FROM
    SQM_QA_TBL A
    INNER JOIN COMPANY B ON A.company_seq = B.company_seq
    LEFT JOIN S2_UserInfo_TheCard U on A.member_id = U.uid
UNION
ALL
SELECT
    '1' AS isS2,
    qa_iid,
    A.sales_gubun,
    A.company_seq,
    B.company_name,
    A.order_seq,
    ISNULL(A.CARD_CODE, '') AS CARD_CODE,
    A.member_id,
    case
        when isnull(A.member_name, '') = '' then U.uname
        else A.member_name
    end member_name,
    A.e_mail,
    A.tel_no,
    Q_kind,
    Q_title,
    Q_content,
	a_content,
    A_stat,
    a_dt,
    reg_dt,
    ISNULL(a_research1, '0') AS a_research1,
    ISNULL(a_research2, '0') AS a_research2,
    a_research_date,
    a_id,
    user_upfile1,
	user_upfile2,
	admin_upfile1,
	E.code_value AS categorym,
	D.code_value AS categorys
FROM
    S2_UserQnA A
    INNER JOIN COMPANY B ON A.company_seq = B.company_seq
    LEFT JOIN S2_UserInfo_TheCard U on A.member_id = U.uid
	LEFT OUTER JOIN manage_code D ON D.code_type = 'admin_ment_Category_S' AND A.q_kind = D.code
	LEFT OUTER JOIN manage_code E ON D.parent_id = E.code_id
GO