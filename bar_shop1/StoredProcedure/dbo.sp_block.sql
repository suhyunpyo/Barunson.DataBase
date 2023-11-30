IF OBJECT_ID (N'dbo.sp_block', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_block
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[sp_block] (@spid bigint=NULL)
as
select
    t1.resource_type,
    'database'=db_name(resource_database_id),
    'blk object' = t1.resource_associated_entity_id,
    t1.request_mode,
    t1.request_session_id,
    t2.blocking_session_id    
from
    sys.dm_tran_locks as t1, 
    sys.dm_os_waiting_tasks as t2
where
    t1.lock_owner_address = t2.resource_address and
    t1.request_session_id = isnull(@spid,t1.request_session_id)
GO
