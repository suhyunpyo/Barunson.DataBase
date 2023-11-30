IF OBJECT_ID (N'dbo.up_select_sampleorder', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_sampleorder
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE proc [dbo].[up_select_sampleorder]
   @seq int 
   as

   select A.card_seq,B.card_image,B.card_code,B.Card_Seq ,B.card_div,1 as order_count 
   from custom_sample_order_item A inner join s2_card B on A.card_seq=B.card_seq 
	where A.sample_order_seq  = @seq
GO
