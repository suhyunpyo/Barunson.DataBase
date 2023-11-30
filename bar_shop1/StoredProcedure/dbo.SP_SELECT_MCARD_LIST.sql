IF OBJECT_ID (N'dbo.SP_SELECT_MCARD_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_MCARD_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
/*    
EXEC SP_SELECT_MCARD_LIST '', '2018-01-18', '2018-01-26', 'SB|SA|ST|SS|B|C|H|CE|BE', '', '','REG_DATE'
*/    
    
CREATE PROCEDURE [dbo].[SP_SELECT_MCARD_LIST]    
   @P_SEARCH_VALUE AS VARCHAR(100) = ''    
 , @P_START_DATE AS VARCHAR(10) = ''    
 , @P_END_DATE AS VARCHAR(10) = ''    
 , @P_SALES_GUBUN AS VARCHAR(5) = ''    
 , @P_INVITATION_TYPE AS VARCHAR(20) = ''    
 , @P_SKIN_CODE AS VARCHAR(20) = ''    
-- , @P_PAGE_SIZE AS INT  
-- , @P_PAGE_NUMBER AS INT
 , @P_ORDER_BY_NAME AS VARCHAR(10) = 'REG_DATE'
AS    
BEGIN    
    
 SET NOCOUNT ON    
    
    
 SELECT *    
 FROM (    
    SELECT ROW_NUMBER() OVER (    
            ORDER BY     
             CASE WHEN @P_ORDER_BY_NAME = 'REG_DATE'     THEN C.RegisterTime      ELSE 0 END ASC    
            , C.RegisterTime ASC    
                 
           ) AS ROW_NUM    
     , ROW_NUMBER() OVER (    
            ORDER BY     
             CASE WHEN @P_ORDER_BY_NAME = 'REG_DATE'     THEN C.RegisterTime      ELSE 0 END DESC    
            , C.RegisterTime DESC    
                 
           ) AS ROW_NUM_DESC    
     , *    
    FROM (    
                   SELECT      
                        MI.AuthCode
                        , MI.AuthYN
                        , MI.CommentYN
                        , MI.CompletedTime
                        , MI.DeleteYN
                        , MI.EtcAfter
                        , MI.EtcBus
                        , MI.EtcCar
                        , MI.EtcGuide
                        , MI.EtcInfo
                        , MI.EtcParking
                        , MI.EtcSubway
                        , MI.EventDate
                        , MI.EventEndTime
                        , MI.EventTime
                        , MI.ExpireYN
                        , MI.GalleryType
                        , MI.GalleryYN
                        , MI.GiftYN
                        , MI.Greeting
                        , MI.GuideYN
                        , MI.HostYN
                        , MI.InvitationCode
                        , MI.InvitationID
                        , MI.InvitationTitle
                        , MI.InvitationType
                        , MI.LastModifiedTime
                        , MI.LocationAddr
                        , MI.LocationDetail
                        , MI.LocationMapImage
                        , MI.LocationMapImageHeight
                        , MI.LocationMapImageSize
                        , MI.LocationMapImageWidth
                        , MI.LocationMapLat
                        , MI.LocationMapLng
                        , MI.LocationMapType
                        , MI.LocationName
                        , MI.LocationTel
                        , MI.MainImage
                        , MI.MainImageHeight
                        , MI.MainImageSize
                        , MI.MainImageWidth
                        , CASE WHEN MI.MoneyGiftYN = 'Y' THEN '사용'
                          ELSE '미사용' END AS MoneyGiftYN
                        , MI.OnlineYN
                        , MI.OrdererEmail
                        , MI.OrdererMobile
                        , MI.OrdererName
                        , MI.OrderSeq
                        , MI.PublishYN
                        , MI.RegisterIP
                        , MI.RegisterTime
                        , CASE WHEN MI.SiteCode = 'SB' THEN '바른손' 
                               WHEN MI.SiteCode = 'SA' THEN '비핸즈' 
                               WHEN MI.SiteCode = 'ST' THEN '더카드' 
                               WHEN MI.SiteCode = 'SS' THEN '프리미어' 
                               WHEN MI.SiteCode = 'BE' THEN '비웨딩' 
                               WHEN MI.SiteCode IN ('B','H','C') THEN '바른손몰' 
                               END SiteCode
                        , MI.SkinCode
                        , MI.SkinID
                        , MI.SmsInvitationYN
                        , MI.SmsMypageYN
                        , MI.VideoType
                        , MI.VideoURL
                        , MI.VideoYN
                        , (select TOP 1 Return_Updated_Tmstmp from Mcard_MoneyGift where DisableYN = 'N' AND InvitationID = MI.InvitationID ) ReturnUpdatedTmstmp
						, ISNULL(MI.AdDisplayYN, 'N') as AdDisplayYN
           FROM     MCARD_INVITATION MI    
           WHERE    1 = 1    
           AND      MI.PublishYN = 'Y' 
		   AND  (  
					(
                    ISNULL(@P_SEARCH_VALUE,'') = '' 
						OR  MI.InvitationCode LIKE '%' + @P_SEARCH_VALUE + '%' 
						OR  MI.OrderSeq LIKE '%' + @P_SEARCH_VALUE + '%' 
						OR  MI.AuthCode LIKE '%' + @P_SEARCH_VALUE + '%' 
						OR  MI.OrdererName LIKE '%' + @P_SEARCH_VALUE + '%' 
						OR  MI.OrdererMobile LIKE '%' + @P_SEARCH_VALUE + '%' 
						OR  MI.SkinCode LIKE '%' + @P_SEARCH_VALUE + '%' 
					)									
					AND 
					(
					ISNULL(@P_SEARCH_VALUE,'') <> '' 	
							OR MI.RegisterTime >= @P_START_DATE AND MI.RegisterTime < @P_END_DATE   
                            AND MI.DeleteYN = 'N'

					)
                )    

           AND  (     
                   ISNULL(@P_SALES_GUBUN,'') = '' OR MI.SiteCode IN ( SELECT * FROM [dbo].[ufn_SplitTable] (@P_SALES_GUBUN, '|') )    
                )      
           AND  (     
                   ISNULL(@P_INVITATION_TYPE,'') = '' OR MI.InvitationType LIKE '%' + @P_INVITATION_TYPE + '%'
                )      
           AND  (     
                   ISNULL(@P_SKIN_CODE,'') = '' OR MI.SkinCode LIKE '%' + @P_SKIN_CODE + '%'
                )      
      ) C    
    
   ) A    
    
 WHERE 1 = 1    
 ORDER BY A.ROW_NUM DESC    
     
END    
    
    
GO
