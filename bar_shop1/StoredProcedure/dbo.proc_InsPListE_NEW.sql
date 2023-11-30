IF OBJECT_ID (N'dbo.proc_InsPListE_NEW', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_InsPListE_NEW
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    Procedure [dbo].[proc_InsPListE_NEW]   
 @order_seq int,   
 @title varchar(50),   
 @card_seq int,   
 @ptype char(1),   
 @pcount int,   
 @isFPrint char(1),   
 @isNotPrint char(1),   
 @env_person1 varchar(50),  
 @env_person2 varchar(50),  
 @env_person_tail varchar(10),  
 @env_person1_tail varchar(50),  
 @env_person2_tail varchar(50),  
 @isenv_person_tail varchar(1),  
 @env_phone varchar(30),  
 @env_hphone varchar(30),  
 @env_hphone2 varchar(30),  
 @env_zip varchar(6),  
 @env_addr varchar(300),  
 @env_addr_detail varchar(100),  
 @isPostMark varchar(1),  
 @PostName varchar(50),  
 @PostTail varchar(15),  
 @isZipBox varchar(1),  
 @recv_tail varchar(10),   
 @isNotPrint_Addr char(1),  
 @pid int output   
 as   
 begin   
    
  insert into CUSTOM_ORDER_PLIST(order_seq,print_type,card_seq,title,print_count,isNotPrint  
  ,env_person1,env_person2,env_person_tail,env_person1_tail,env_person2_tail,isenv_person_tail  
  ,env_phone,env_hphone,env_hphone2,env_zip,env_addr,env_addr_detail,isPostMark,PostName,PostName_tail  
  ,isZipBox,recv_tail, isNotPrint_Addr) values(@order_seq,@ptype,@card_seq,@title,@pcount,@isNotPrint  
  ,@env_person1,@env_person2,@env_person_tail,@env_person1_tail,@env_person2_tail,@isenv_person_tail  
  ,@env_phone,@env_hphone,@env_hphone2,@env_zip,@env_addr,@env_addr_detail,@isPostMark,@PostName,@PostTail  
  ,@isZipBox,@recv_tail, @isNotPrint_Addr)  
  set @pid = @@identity  
 END   
  
GO
