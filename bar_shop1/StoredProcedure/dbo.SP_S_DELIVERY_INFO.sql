IF OBJECT_ID (N'dbo.SP_S_DELIVERY_INFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_DELIVERY_INFO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_DELIVERY_INFO]
/***************************************************************
작성자	:	표수현
작성일	:	2023-03-04
DESCRIPTION	:	청첩장 배송비 조회
SPECIAL LOGIC	:  
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @GUBUN					INT = 1,		--  1 : 메인대분류 / 2 : 카테고리대분류  / 3 : 카테고리중분류 
 @DETAILVIEW_YN			CHAR(1) = 'N', 	--  카테고리 상세 리스트 디스플레이 Y/N
 @PARENT_CATEGORY_ID	INT = NULL,		-- 상위 대분류 카테고리번호 
 @CATEGORY_ID			INT = NULL		-- 선택한 카테고리의 번호 
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 SELECT AddDeliveryPrice1, AddDeliveryPrice2
 FROM DeliveryPriceInfo
GO
