IF OBJECT_ID (N'dbo.OB_REF_CODE_SP', N'P') IS NOT NULL DROP PROCEDURE dbo.OB_REF_CODE_SP
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OB_REF_CODE_SP]
@field_name     varchar(20)  
AS    
/********************************************************************/
/*                 아웃바운드 리뉴얼          */
/********************************************************************/
/*  1. 시 스 템 명 : 아웃바운드
 *  2. 단위 업무명 : 
 *  3. 파  일  JOB : 기존 코드테이블 조회.
 *  4. 파  일   ID : OB_REF_CODE_SP
 *  5. 구       분 : Stored Procedure
 *  6. 관련TABLE명 : Ref_Code
 *  7. 작  성  자  : 진나영
 *  8. 작  성  일  : 2006.07.18
 *  9. 주의  사항  :
 * 10. Parameter   :
 *      @field_name: 검색 타입명
 * 11. 수정  사항(일자,수정자,수정이유 기술)
 *     1)
 *     2)
 ********************************************************************/

SELECT 
	Code_No, Field_Name, Field_Value, Disp_Order, Disp_Name, Remark 
FROM 
	Ref_Code 
WHERE 
	Field_Name = @field_name 
AND 
	Disp_Order > 0 	
ORDER BY Disp_Order ASC
GO
