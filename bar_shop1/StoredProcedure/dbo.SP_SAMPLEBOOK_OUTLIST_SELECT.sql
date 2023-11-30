IF OBJECT_ID (N'dbo.SP_SAMPLEBOOK_OUTLIST_SELECT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SAMPLEBOOK_OUTLIST_SELECT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_SAMPLEBOOK_OUTLIST_SELECT]
	@iGUBUN INT

AS
BEGIN


DECLARE @SAMPLEBOOK_GUBUN VARCHAR(3)
SELECT @SAMPLEBOOK_GUBUN = CASE @iGUBUN WHEN 0 THEN 'SSW' WHEN 1 THEN 'SSA' WHEN 2 THEN 'SSB' WHEN 3 THEN 'SSC' ELSE 'XX' END

SELECT A.seq 
    , A.SampleBook_ID 
	, A.Delivery_Count 
    , CASE WHEN A.Delivery_YN = 'Y' THEN '출고가능' ELSE '출고불가' END AS Delivery_YN_NM 
     
	 --, A.Delivery_Status 
  --   , B.code_value AS Delivery_Status_NM      
  --   , A.SampleBook_Condition 
  --   , C.DTL_NAME AS SampleBook_Condition_NM 
  --   , ISNULL(A.Admin_Memo, '') AS Admin_Memo 
FROM SampleBook AS A 
--JOIN manage_code AS B ON A.Delivery_Status = B.code AND B.code_type = 'etc_status_seq' 
JOIN common_code AS C ON A.SampleBook_Condition = C.CMMN_CODE AND C.CLSS_CODE = 142 
 WHERE A.Delivery_YN = 'Y' 
         AND A.SampleBook_Condition = '142001' 
		 AND A.SampleBook_ID LIKE LTRIM(RTRIM(@SAMPLEBOOK_GUBUN))+'%'
 ORDER BY A.SampleBook_ID 



END
GO
