IF OBJECT_ID (N'dbo.VW_Statics_Produce', N'V') IS NOT NULL DROP View dbo.VW_Statics_Produce
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[VW_Statics_Produce]    
AS  

	SELECT LEFT(A.DATE,4) YEAR, A.DATE, ISNULL(A.CNT,0) CNT_1, ISNULL(B.CNT,0) CNT_2, (ISNULL(C.CNT,0) - ISNULL(B.CNT,0)) CNT_3
	,ISNULL(C.CNT,0) CNT_4, ISNULL(D.CNT,0) CNT_5, ISNULL(E.CNT,0) CNT_6, ISNULL(F.CNT,0) CNT_7, ISNULL(G.CNT,0) CNT_8, 
	(ISNULL(D.CNT,0) - ISNULL(E.CNT,0) + ISNULL(F.CNT,0) - ISNULL(G.CNT, 0)) CNT_9,  ISNULL(H.CNT,0) CNT_10
	FROM 
	(
		SELECT CONVERT(CHAR(7),src_packing_date,121) DATE, ISNULL(COUNT(order_seq),0)  CNT 
		FROM bar_shop1.dbo.custom_order 
		WHERE up_order_seq is null and status_seq = 15 and src_packing_date is not null
		AND  year(src_packing_date) > 2021
		GROUP BY CONVERT(CHAR(7),src_packing_date,121)
	) A
	LEFT JOIN 
	(
		SELECT CONVERT(CHAR(7),A.Payment_DateTime,121) DATE, ISNULL(COUNT(A.Order_ID),0) CNT
		FROM TB_Order A
		JOIN bar_shop1.dbo.custom_order B on A.User_ID = B.member_id and a.Email = b.order_email
		WHERE A.Payment_Status_Code = 'PSC02' and A.Payment_DateTime is not null
		AND B.up_order_seq is null and B.status_seq = 15 and B.src_packing_date is not null
		AND B.order_type in (1,6,7)
		AND YEAR(A.Payment_DateTime) > 2021
		GROUP BY CONVERT(CHAR(7),A.Payment_DateTime,121)
	) B ON A.DATE = B.DATE
	LEFT JOIN
	(
		SELECT CONVERT(CHAR(7),A.Payment_DateTime,121) DATE, ISNULL(COUNT(A.Order_ID),0) CNT
		FROM TB_Order A
		WHERE A.Payment_Status_Code = 'PSC02' AND A.Payment_DateTime IS NOT NULL
		AND YEAR(A.Payment_DateTime) > 2021
		GROUP BY CONVERT(CHAR(7),A.Payment_DateTime,121)
	) C ON A.DATE = C.DATE
	LEFT JOIN
	(
		SELECT CONVERT(CHAR(7),A.Payment_DateTime,121) DATE, ISNULL(COUNT(A.Order_ID),0) CNT
		FROM TB_Order A
		JOIN TB_Invitation B ON A.Order_ID = B.Order_ID
		JOIN TB_Invitation_Detail C ON B.Invitation_ID = C.Invitation_ID
		WHERE A.Payment_Status_Code = 'PSC02' and A.Payment_DateTime is not null
		AND CONVERT(CHAR(6),A.Payment_DateTime,112) > 202203
		AND C.Conf_KaKaoPay_YN = 'Y'
		AND C.MoneyGift_Remit_Use_YN = 'Y'
		GROUP BY CONVERT(CHAR(7),A.Payment_DateTime,121)
	) D ON A.DATE = D.DATE
	LEFT JOIN
	(
		SELECT CONVERT(CHAR(7),A.Payment_DateTime,121) DATE, ISNULL(COUNT(A.Order_ID),0) CNT
		FROM TB_Order A
		JOIN TB_Invitation B ON A.Order_ID = B.Order_ID
		JOIN TB_Invitation_Detail C ON B.Invitation_ID = C.Invitation_ID
		WHERE A.Payment_Status_Code = 'PSC02' and A.Payment_DateTime is not null
		AND CONVERT(CHAR(6),A.Payment_DateTime,112) > 202203
		AND C.Conf_KaKaoPay_YN = 'Y'
		AND C.MoneyGift_Remit_Use_YN = 'N'
		GROUP BY CONVERT(CHAR(7),A.Payment_DateTime,121)
	) E ON A.DATE = E.DATE
	LEFT JOIN
	(
		SELECT CONVERT(CHAR(7),A.Payment_DateTime,121) DATE, ISNULL(COUNT(A.Order_ID),0) CNT
		FROM TB_Order A
		JOIN TB_Invitation B ON A.Order_ID = B.Order_ID
		JOIN TB_Invitation_Detail C ON B.Invitation_ID = C.Invitation_ID
		WHERE A.Payment_Status_Code = 'PSC02' and A.Payment_DateTime is not null
		AND CONVERT(CHAR(6),A.Payment_DateTime,112) > 202203
		AND C.Conf_Remit_YN = 'Y'
		AND (C.MoneyAccount_Div_Use_YN = 'Y' OR C.MoneyAccount_Remit_Use_YN = 'Y')
		GROUP BY CONVERT(CHAR(7),A.Payment_DateTime,121)
	) F ON A.DATE = F.DATE
	LEFT JOIN 
	(
		SELECT CONVERT(CHAR(7),A.Payment_DateTime,121) DATE, ISNULL(COUNT(A.Order_ID),0) CNT
		FROM TB_Order A
		JOIN TB_Invitation B ON A.Order_ID = B.Order_ID
		JOIN TB_Invitation_Detail C ON B.Invitation_ID = C.Invitation_ID
		WHERE A.Payment_Status_Code = 'PSC02' and A.Payment_DateTime is not null
		AND CONVERT(CHAR(6),A.Payment_DateTime,112) > 202203
		AND C.Conf_Remit_YN = 'Y'
		AND (C.MoneyAccount_Div_Use_YN = 'N' AND C.MoneyAccount_Remit_Use_YN = 'N')
		GROUP BY CONVERT(CHAR(7),A.Payment_DateTime,121)
	) G ON A.DATE = G.DATE
	LEFT JOIN 
	(
		SELECT LEFT(DATE,4) + '-' + RIGHT(DATE,2) DATE, Remit_Price CNT FROM TB_Remit_Statistics_Monthly
	) H ON A.DATE = H.DATE
GO
