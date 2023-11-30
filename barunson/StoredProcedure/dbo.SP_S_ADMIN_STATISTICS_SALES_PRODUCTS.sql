IF OBJECT_ID (N'dbo.SP_S_ADMIN_STATISTICS_SALES_PRODUCTS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_ADMIN_STATISTICS_SALES_PRODUCTS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_S_ADMIN_STATISTICS_SALES_PRODUCTS]
	@START_DT VARCHAR(10) = '2021-01-01',
	@END_DT VARCHAR(10)  = '9999-12-31',
	@SEARCH_KEYWORD NVARCHAR(50) = '',
	@BRAND VARCHAR(50) = '',
	@ORDERBY VARCHAR(20) = 'total_desc'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @delimiter NVARCHAR(1)
	SET @delimiter = ','

	DECLARE @item NVARCHAR(MAX)
	SET @item = NULL

	DECLARE @tmpBrand TABLE (
	    Item    NVARCHAR(MAX)
	)

	WHILE LEN(@BRAND) > 0
	BEGIN
		DECLARE @index    INT
		SET @index = PATINDEX('%' + @delimiter + '%', @BRAND)
		IF @index > 0
		BEGIN
			SET @item = SUBSTRING(@BRAND, 0, @index)
			SET @BRAND = SUBSTRING(@BRAND, LEN(@item + @delimiter) + 1, LEN(@BRAND))

			INSERT INTO @tmpBrand ( Item ) VALUES ( @item )
		END
		ELSE
		BEGIN
			SET @item = @BRAND
			SET @BRAND = NULL

			INSERT INTO @tmpBrand ( Item ) VALUES ( @item )
		END
	END

	create table #tmpTable (
		Product_Brand_Code varchar(50),
		Product_Code varchar(20),
		pay_count int,
		free_count int,
		total_count int
	);

	insert into #tmpTable
	select
		CD.Code_Name AS Product_Brand_Code,
		Product_Code,
		pay_count,
		free_count,
		total_count
	from (
			select 
				P.Product_Brand_Code,
				P.Product_Code,
				sum(case when O.Payment_Price > 0 then 1 else 0 end) pay_count,
				sum(case when O.Payment_Price is null or O.Payment_Price = 0 then 1 else 0 end) free_count,
				count(1) total_count
			from TB_Order AS O
				inner join TB_Order_Product AS OP
					on O.Order_ID = OP.Order_ID
				inner join TB_Product AS P
					on op.Product_ID = P.Product_ID
			where O.Order_DateTime is not null
				and P.Product_Brand_Code in (select item from @tmpBrand)
				and (P.Product_Code like '%'+@SEARCH_KEYWORD + '%' OR P.Product_Name like '%'+@SEARCH_KEYWORD+'%')
				and o.Order_DateTime > @START_DT + ' 00:00:00'
				and o.Order_DateTime <= @END_DT + ' 23:59:59'
				and O.Payment_Status_Code = 'PSC02'
			group by P.Product_Brand_Code, 
				P.Product_Code
		) AS R
		inner join TB_Common_Code as CD
			on CD.Code_Group = 'Product_Brand_Code'
				AND CD.Code = R.Product_Brand_Code

	if @ORDERBY = 'brand_asc' BEGIN
		select * from #tmpTable order by Product_Brand_Code asc
	END 
	else if @ORDERBY = 'brand_desc' BEGIN
		select * from #tmpTable order by Product_Brand_Code desc
	END
	else if @ORDERBY = 'code_asc' BEGIN
		select * from #tmpTable order by Product_Code asc
	END 
	else if @ORDERBY = 'code_desc' BEGIN
		select * from #tmpTable order by Product_Code desc
	END
	else if @ORDERBY = 'free_asc' BEGIN
		select * from #tmpTable order by free_count asc
	END 
	else if @ORDERBY = 'free_desc' BEGIN
		select * from #tmpTable order by free_count desc
	END 
	else if @ORDERBY = 'pay_asc' BEGIN
		select * from #tmpTable order by pay_count asc
	END 
	else if @ORDERBY = 'pay_desc' BEGIN
		select * from #tmpTable order by pay_count desc
	END 
	else if @ORDERBY = 'total_asc' BEGIN
		select * from #tmpTable order by total_count asc
	END 
	else if @ORDERBY = 'total_desc' BEGIN
		select * from #tmpTable order by total_count desc
	END 



END
GO
