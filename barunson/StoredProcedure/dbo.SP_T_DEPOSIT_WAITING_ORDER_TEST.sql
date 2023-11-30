IF OBJECT_ID (N'dbo.SP_T_DEPOSIT_WAITING_ORDER_TEST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_DEPOSIT_WAITING_ORDER_TEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_DEPOSIT_WAITING_ORDER_TEST]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	ADMIN - 메뉴 저장
SPECIAL LOGIC	: 무통장 결제 대기 상태에서 3일 이상 경과한 주문건을 일괄 입금대기 취소 처리 
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED



 select * from test
GO
