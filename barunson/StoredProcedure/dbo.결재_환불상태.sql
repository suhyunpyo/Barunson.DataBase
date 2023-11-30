IF OBJECT_ID (N'dbo.결재_환불상태', N'P') IS NOT NULL DROP PROCEDURE dbo.결재_환불상태
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[결재_환불상태]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	 
SPECIAL LOGIC	:  결재_환불상태 'M2108250007'
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @ORDER_CODE		VARCHAR(20) = 'M2108240053'
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


 select B.Code, B.Code_Name, C.Code, C.Code_Name, A.Payment_Price, A.Coupon_Price, A.Order_Price
 from tB_order A inner join TB_Common_Code B on A.Payment_Method_Code = B.Code
 inner join TB_Common_Code C on A.Payment_Status_Code = C.Code
 where B.Code_Group = 'Payment_Method_Code' and C.Code_Group = 'Payment_Status_Code' and
  A.Order_Code = @ORDER_CODE


  
 select E.Code, E.Code_Name, F.Code, F.Code_Name
 from tB_order A inner join TB_Common_Code B on A.Payment_Method_Code = B.Code
 inner join TB_Common_Code C on A.Payment_Status_Code = C.Code
 left join TB_Refund_Info D on A.Order_ID = D.Order_ID
  inner  join TB_Common_Code E on D.Refund_Status_Code = E.Code 
  inner  join TB_Common_Code F on D.Refund_Type_Code = F.Code 

 where B.Code_Group = 'Payment_Method_Code' and C.Code_Group = 'Payment_Status_Code' and
 E.Code_Group = 'Refund_Status_Code'  and
  F.Code_Group = 'Refund_Type_Code' and
  A.Order_Code = @ORDER_CODE

  select B.*, C.* from TB_ORder A inner join 
				TB_Order_Coupon_Use B on A.Order_ID = B.Order_ID INNER JOIN 
				TB_Coupon_Publish c ON B.Coupon_Publish_ID = C.Coupon_Publish_ID 
	where A.Order_Code = @ORDER_CODE
				

  select * from  TB_Common_Code where Code_Group = 'Payment_Method_Code'
  
  select * from  TB_Common_Code where Code_Group = 'Payment_Status_Code'
  
  select * from  TB_Common_Code where Code_Group = 'Refund_Status_Code'
  
  select * from  TB_Common_Code where Code_Group = 'Refund_Type_Code'

  --update TB_ORder 
  -- set Payment_Status_Code = 'PSC03'
  -- where Order_Code = 'M2108240053'

  
  --select * from TB_Order where Order_Code = 'M2108240055'

  -- select * from TB_Refund_Info where Order_ID = 69



  -- select * from TB_Coupon

   
  -- select * from TB_Coupon_Publish


  -- select * from TB_Order_Coupon_Use
GO
