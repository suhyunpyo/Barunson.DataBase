IF OBJECT_ID (N'dbo.SP_T_USER_ORDER_DELETE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_T_USER_ORDER_DELETE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_T_USER_ORDER_DELETE]
/***************************************************************
작성자	:	표수현
작성일	:	2020-02-15
DESCRIPTION	:	회원 주문건 삭제 및 환불 처리  
SPECIAL LOGIC	:
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @Order_ID INT = NULL
AS

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

     --// 1. TB_Refund_Info 테이블에 Insert
     --       Entity_db.Add(model);
     --       Entity_db.SaveChanges();

    -- --       // 2. TB_Order 테이블에 해당 예약건 결제상태코드 / 취소날짜 / 취소시간 업데이트 
	   --Update_Order_Item.Payment_Status_Code = "PSC03";
    --        Update_Order_Item.Cancel_DateTime = DateTime.Now;
    --        Update_Order_Item.Cancel_Time = DateTime.Now.ToString("hh");



 select * from tb_Order

 

 --DECLARE @Order_ID int = 458

-- DECLARE @Invitation_ID INt
-- declare @Coupon_Publish_ID int
--  declare @Resource_ID int

-- select @Invitation_ID = Invitation_ID 
-- from	TB_Invitation
-- where Order_ID = @Order_ID

-- select @Coupon_Publish_ID = Coupon_Publish_ID 
-- from	TB_Order_Coupon_Use
-- where Order_ID = @Order_ID

-- select @Resource_ID = Resource_ID 
-- from TB_Invitation_Item
-- where Invitation_ID = @Invitation_ID


-- select @Invitation_ID
 
-- select @Coupon_Publish_ID

 
-- select @Resource_ID


-- begin tran 

 
--	--2. 초대장 관련 데이터 삭제 
	

--	delete from  TB_Account where Invitation_ID = @Invitation_ID
--delete from  TB_Gallery   where Invitation_ID = @Invitation_ID
--delete from  TB_GuestBook  where Invitation_ID = @Invitation_ID
--delete from  TB_Invitation_Area  where Invitation_ID = @Invitation_ID
--delete from  TB_Invitation_Detail  where Invitation_ID = @Invitation_ID
--delete from  TB_Invitation_Detail_Etc  where Invitation_ID = @Invitation_ID


--delete from  TB_Invitation  where Invitation_ID = @Invitation_ID


--delete from  TB_Invitation_Item  where Resource_ID = @Resource_ID

----delete from  TB_Item_Resource  where Resource_ID = @Resource_ID















--	--3. 쿠폰 관련 데이터 삭제 
--	delete from TB_Coupon_Publish where Coupon_Publish_ID  = @Coupon_Publish_ID
--	delete from  TB_Order_Coupon_Use  where Coupon_Publish_ID  = @Coupon_Publish_ID



--	--1. 주문 관련 데이터 삭제 
	

--delete from TB_Order_Product where Order_ID = @Order_ID
--delete from TB_Refund_Info where Order_ID = @Order_ID
--delete from TB_Order  where Order_ID = @Order_ID


--	rollback
	
GO
