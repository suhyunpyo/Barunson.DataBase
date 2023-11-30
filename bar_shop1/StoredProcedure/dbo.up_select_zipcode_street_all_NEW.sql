IF OBJECT_ID (N'dbo.up_select_zipcode_street_all_NEW', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_zipcode_street_all_NEW
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  daniel,kim  
-- Create date: 2014-03-05  
-- Description: 신도로 우편번호 검색  
  
--지번검색  
 --건물명  
 -- up_select_zipcode_street_all_NEW '대치동','대치동','1','1'  
 --번지수  
 -- up_select_zipcode_street_all_NEW '면목동','88','1','2'   

--도로명검색  
 --건물명  
 -- up_select_zipcode_street_all_NEW '영동대로','현대아파트','2','1'  
 --건물번호  
 -- up_select_zipcode_street_all_NEW '영동대로','28','2','2'  
-- =============================================  
CREATE PROCEDURE [dbo].[up_select_zipcode_street_all_NEW] (  
 -- Add the parameters for the stored procedure here  
 @street_name nvarchar(50),  
 @build_name nvarchar(50),  
 @search_convert nvarchar(1),  
 @search_Flag nvarchar(1)  
 )  
AS  
BEGIN  
 SET NOCOUNT ON;  
 --지번검색=>건물명  
 -- up_select_zipcode_street_all_NEW '대치동','대치동','1','1'  
 IF @search_convert = '1' AND @search_Flag = '1'  
  BEGIN  
   SELECT   
    TOP 1001 zipcode, sido, gungu, isnull(myoun, ''), street_name, build_no, build_sub_no, sigungu_build_name, isnull(b_name,b_ri) AS b_name, b_ri, jibun_no, jibun_sub_no   
   FROM   
    dbo.zipcode_street_N WITH(NOLOCK)  
   WHERE    
    b_name LIKE '%'+@street_name+'%' AND sigungu_build_name LIKE '%'+@build_name+'%'   
   ORDER BY   
    sido, gungu, jibun_no, jibun_sub_no  
  END  
  
 --지번검색 => 번지수  
 -- up_select_zipcode_street_all_NEW '송산동','4','1','2'   
 IF @search_convert = '1' AND @search_Flag = '2'  
  if  CHARINDEX('-', @build_name) <> 0  
   BEGIN  
    SELECT   
     TOP 1001 zipcode, sido, gungu, isnull(myoun, ''), street_name, build_no, build_sub_no, sigungu_build_name, isnull(b_name,b_ri) AS b_name, b_ri, jibun_no, jibun_sub_no   
    FROM   
     dbo.zipcode_street_N WITH(NOLOCK)  
    WHERE   
    -- b_name LIKE '%'+@street_name+'%' AND jibun_no LIKE '%'+@build_name+'%'   
     (b_name LIKE '%'+@street_name+'%') and jibun_no=SUBSTRING(@build_name,0, CHARINDEX('-', @build_name)) and jibun_sub_no=right(@build_name, CHARINDEX('-',reverse(@build_name))-1)  
   ORDER BY   
    sido, gungu, jibun_no, jibun_sub_no       
   END  
  else  
   BEGIN  
    SELECT   
     TOP 1001 zipcode, sido, gungu, isnull(myoun, ''), street_name, build_no, build_sub_no, sigungu_build_name, isnull(b_name,b_ri) AS b_name, b_ri, jibun_no, jibun_sub_no   
    FROM   
     dbo.zipcode_street_N WITH(NOLOCK)  
    WHERE   
     b_name LIKE '%'+@street_name+'%' AND jibun_no LIKE ''+@build_name+'%'   
    -- b_name = @street_name AND jibun_no = @build_name   
    -- (b_name=@street_name or b_name=@street_name) and jibun_no=SUBSTRING(@build_name,0, CHARINDEX('-', @build_name)) and jibun_sub_no=right(@build_name, CHARINDEX('-',reverse(@build_name))-1)  
   ORDER BY   
    sido, gungu, jibun_no, jibun_sub_no      
   END  
  
 --도로명검색 => 건물명  
 -- up_select_zipcode_street_all_NEW '영동대로','현대아파트','2','1'  
 IF @search_convert = '2' AND @search_Flag = '1'  
  BEGIN  
   SELECT   
    TOP 1001 zipcode, sido, gungu, isnull(myoun, ''), street_name, build_no, build_sub_no, sigungu_build_name, isnull(b_name,b_ri) AS b_name, b_ri, jibun_no, jibun_sub_no   
   FROM   
    dbo.zipcode_street_N WITH(NOLOCK)  
   WHERE   
   --street_name LIKE '%'+@street_name+'%' AND sigungu_build_name LIKE '%'+@build_name+'%'   
    street_name LIKE ''+@street_name+'%' AND sigungu_build_name LIKE '%'+@build_name+'%'   
   ORDER BY   
    sido, gungu, build_no, build_sub_no      
  END  
  
 --도로명검색 => 건물번호  
 -- up_select_zipcode_street_all_NEW '영동대로','28','2','2'  
  IF @search_convert = '2' AND @search_Flag = '2'  
  BEGIN  
   SELECT   
    TOP 1001 zipcode, sido, gungu, isnull(myoun, ''), street_name, build_no, build_sub_no, sigungu_build_name, isnull(b_name,b_ri) AS b_name, b_ri, jibun_no, jibun_sub_no   
   FROM   
    dbo.zipcode_street_N WITH(NOLOCK)  
   WHERE   
    street_name LIKE '%'+@street_name+'%' AND build_no LIKE '%'+@build_name+'%'
   ORDER BY   
    sido, gungu, build_no, build_sub_no      
  END  
END
GO
