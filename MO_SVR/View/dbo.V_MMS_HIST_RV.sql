IF OBJECT_ID (N'dbo.V_MMS_HIST_RV', N'V') IS NOT NULL DROP View dbo.V_MMS_HIST_RV
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[V_MMS_HIST_RV]
AS
SELECT MSG_KEY, IN_TIME, SERVICE_CODE, MSG_TYPE, 
       CALLER_NO, CALLEE_NO, CALLBACK_NO, SUBJECT, MMS_MSG,
       IMAGE1, IMAGE2, IMAGE3, AUDIO, VIDEO,
       RV_SECT, READ_FLAG, SUBMIT_TIME
  FROM T_MMS_HIST_RV_01(READPAST)
UNION ALL
SELECT MSG_KEY, IN_TIME, SERVICE_CODE, MSG_TYPE, 
       CALLER_NO, CALLEE_NO, CALLBACK_NO, SUBJECT, MMS_MSG,
       IMAGE1, IMAGE2, IMAGE3, AUDIO, VIDEO,
       RV_SECT, READ_FLAG, SUBMIT_TIME
  FROM T_MMS_HIST_RV_02(READPAST)
UNION ALL
SELECT MSG_KEY, IN_TIME, SERVICE_CODE, MSG_TYPE, 
       CALLER_NO, CALLEE_NO, CALLBACK_NO, SUBJECT, MMS_MSG,
       IMAGE1, IMAGE2, IMAGE3, AUDIO, VIDEO,
       RV_SECT, READ_FLAG, SUBMIT_TIME
  FROM T_MMS_HIST_RV_03(READPAST)
UNION ALL
SELECT MSG_KEY, IN_TIME, SERVICE_CODE, MSG_TYPE, 
       CALLER_NO, CALLEE_NO, CALLBACK_NO, SUBJECT, MMS_MSG,
       IMAGE1, IMAGE2, IMAGE3, AUDIO, VIDEO,
       RV_SECT, READ_FLAG, SUBMIT_TIME
  FROM T_MMS_HIST_RV_04(READPAST)
UNION ALL
SELECT MSG_KEY, IN_TIME, SERVICE_CODE, MSG_TYPE, 
       CALLER_NO, CALLEE_NO, CALLBACK_NO, SUBJECT, MMS_MSG,
       IMAGE1, IMAGE2, IMAGE3, AUDIO, VIDEO,
       RV_SECT, READ_FLAG, SUBMIT_TIME
  FROM T_MMS_HIST_RV_05(READPAST)
UNION ALL
SELECT MSG_KEY, IN_TIME, SERVICE_CODE, MSG_TYPE, 
       CALLER_NO, CALLEE_NO, CALLBACK_NO, SUBJECT, MMS_MSG,
       IMAGE1, IMAGE2, IMAGE3, AUDIO, VIDEO,
       RV_SECT, READ_FLAG, SUBMIT_TIME
  FROM T_MMS_HIST_RV_06(READPAST)
UNION ALL
SELECT MSG_KEY, IN_TIME, SERVICE_CODE, MSG_TYPE, 
       CALLER_NO, CALLEE_NO, CALLBACK_NO, SUBJECT, MMS_MSG,
       IMAGE1, IMAGE2, IMAGE3, AUDIO, VIDEO,
       RV_SECT, READ_FLAG, SUBMIT_TIME
  FROM T_MMS_HIST_RV_07(READPAST)
UNION ALL
SELECT MSG_KEY, IN_TIME, SERVICE_CODE, MSG_TYPE, 
       CALLER_NO, CALLEE_NO, CALLBACK_NO, SUBJECT, MMS_MSG,
       IMAGE1, IMAGE2, IMAGE3, AUDIO, VIDEO,
       RV_SECT, READ_FLAG, SUBMIT_TIME
  FROM T_MMS_HIST_RV_08(READPAST)
UNION ALL
SELECT MSG_KEY, IN_TIME, SERVICE_CODE, MSG_TYPE, 
       CALLER_NO, CALLEE_NO, CALLBACK_NO, SUBJECT, MMS_MSG,
       IMAGE1, IMAGE2, IMAGE3, AUDIO, VIDEO,
       RV_SECT, READ_FLAG, SUBMIT_TIME
  FROM T_MMS_HIST_RV_09(READPAST)
UNION ALL
SELECT MSG_KEY, IN_TIME, SERVICE_CODE, MSG_TYPE, 
       CALLER_NO, CALLEE_NO, CALLBACK_NO, SUBJECT, MMS_MSG,
       IMAGE1, IMAGE2, IMAGE3, AUDIO, VIDEO,
       RV_SECT, READ_FLAG, SUBMIT_TIME
  FROM T_MMS_HIST_RV_10(READPAST)
UNION ALL
SELECT MSG_KEY, IN_TIME, SERVICE_CODE, MSG_TYPE, 
       CALLER_NO, CALLEE_NO, CALLBACK_NO, SUBJECT, MMS_MSG,
       IMAGE1, IMAGE2, IMAGE3, AUDIO, VIDEO,
       RV_SECT, READ_FLAG, SUBMIT_TIME
  FROM T_MMS_HIST_RV_11(READPAST)
UNION ALL
SELECT MSG_KEY, IN_TIME, SERVICE_CODE, MSG_TYPE, 
       CALLER_NO, CALLEE_NO, CALLBACK_NO, SUBJECT, MMS_MSG,
       IMAGE1, IMAGE2, IMAGE3, AUDIO, VIDEO,
       RV_SECT, READ_FLAG, SUBMIT_TIME
  FROM T_MMS_HIST_RV_12(READPAST);
GO