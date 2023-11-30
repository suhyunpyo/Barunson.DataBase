IF OBJECT_ID (N'dbo.FN_ORDER_COUPON_LIST', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_ORDER_COUPON_LIST', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_ORDER_COUPON_LIST', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_ORDER_COUPON_LIST', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.FN_ORDER_COUPON_LIST', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.FN_ORDER_COUPON_LIST
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--select dbo.FN_ORDER_COUPON_LIST(2847805)

CREATE  function [dbo].[FN_ORDER_COUPON_LIST]
(
	@nORDER_SEQ		int
	,@sCOUPON_TYPE  varchar(6) = ''
)
    returns varchar(1000)
as

begin
	declare @sReturn    as varchar(1000)
	-- declare @sTmp as varchar(100)
	-- declare curTemp cursor read_only for
	/*
	SELECT CASE CM.COUPON_TYPE_CODE WHEN '131001' THEN '쿠폰:'+CM.COUPON_NAME 
	WHEN '131002' THEN '중복쿠폰:'+CM.COUPON_NAME 
	WHEN '131003' THEN 'AD쿠폰:'+CM.COUPON_NAME 
	WHEN '131004' THEN '추가쿠폰:'+CM.COUPON_NAME 
	ELSE CM.COUPON_NAME END
	*/
	/*
	SELECT CM.COUPON_NAME 
	FROM Custom_Order_Coupon AS COC
	INNER JOIN    Coupon_Issue AS CI ON COC.Coupon_Issue_Seq = CI.Coupon_Issue_Seq
	INNER JOIN    Coupon_Detail AS CD ON CI.Coupon_Detail_Seq = CD.Coupon_Detail_Seq
	INNER JOIN    Coupon_MST AS CM ON CD.Coupon_MST_Seq = CM.Coupon_MST_Seq
	where COC.order_seq = @nORDER_SEQ
	AND CASE WHEN @sCOUPON_TYPE<>'' THEN CM.COUPON_TYPE_CODE ELSE '1' END = CASE WHEN @sCOUPON_TYPE<>'' THEN @sCOUPON_TYPE ELSE '1' END
	order by CM.Coupon_Type_Code


	open curTemp
	
	fetch next from curTemp into @sTmp
	set @sReturn = ''
	
	while (@@fetch_status <> -1)
	begin
	    if @sReturn = ''
	        set @sReturn = @sTmp
	    else
	        set @sReturn = @sReturn + '/' +@sTmp
	
	    fetch next from curTemp into @sTmp
	end
	
	close curTemp
	deallocate curTemp
	*/

	SELECT @sReturn = STUFF((SELECT
			'/' + CM.COUPON_NAME
		FROM
			Custom_Order_Coupon AS COC
			INNER JOIN Coupon_Issue AS CI ON COC.Coupon_Issue_Seq = CI.Coupon_Issue_Seq
			INNER JOIN Coupon_Detail AS CD ON CI.Coupon_Detail_Seq = CD.Coupon_Detail_Seq
			INNER JOIN Coupon_MST AS CM ON CD.Coupon_MST_Seq = CM.Coupon_MST_Seq
		where
			COC.order_seq = @nORDER_SEQ AND
			(@sCOUPON_TYPE = '' OR CM.COUPON_TYPE_CODE = @sCOUPON_TYPE)
		
		order by
			CM.Coupon_Type_Code FOR XML PATH ('')), 1, 1, '')
	
	Return @sReturn
end
GO