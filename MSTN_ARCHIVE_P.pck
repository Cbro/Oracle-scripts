CREATE OR REPLACE PACKAGE MSTN_ARCHIVE_P AS
 /*
 This package acts as an archiving utility for large tables such as the *_COUNT tables 
 whose volume changes dramatically with time. It keeps the *_COUNT_LIVE tables as skinny 
 as possible ensuring that data is aged and archived into *_COUNT_LIVE_ADAY tables based
 on the time interval passed in and keeps record of every archive run in the JOB_RUN_STATS
 table for auditing. 
 
 %author MKA
 %version V1.0.MKA.0.0
  
 */
 


 /*
    Archives all the 'DAY' records that are in the aging criteria in the TRACK_COUNT_LIVE table
    to the AGED counterpart i.e. TRACK_COUNT_LIVE_ADAY table.
    %param pDays_in  The number of days past current date to decide time interval past which we archive
                     (Ex: Sysdate - pNumDays_in)
    %param pJobDesc_in The description of the database job that runs this archiving job.
  */  
  PROCEDURE archiveTrackCount(pNumDays_in IN NUMBER := 30,
                              pJobDesc_in IN VARCHAR2 := 'Job xxx');

 /*
    Archives all the 'DAY' records that are in the aging criteria in the ARTIST_COUNT_LIVE table
    to the AGED counterpart i.e. ARTIST_COUNT_LIVE_ADAY table.
    %param pDays_in  The number of days past current date to decide time interval past which we archive
                     (Ex: Sysdate - pNumDays_in)
    %param pJobDesc_in The description of the database job that runs this archiving job.
  */ 
  PROCEDURE archiveArtistCount(pNumDays_in IN NUMBER := 30,
                               pJobDesc_in IN VARCHAR2 := 'Job xxx');
                              

 /*
    Archives all the 'DAY' records that are in the aging criteria in the RELEASE_COUNT_LIVE table
    to the AGED counterpart i.e. RELEASE_COUNT_LIVE_ADAY table.
    %param pDays_in  The number of days past current date to decide time interval past which we archive
                     (Ex: Sysdate - pNumDays_in)
    %param pJobDesc_in The description of the database job that runs this archiving job.
  */ 
  PROCEDURE archiveReleaseCount(pNumDays_in IN NUMBER := 30,
                                pJobDesc_in IN VARCHAR2 := 'Job xxx');
            
  
 /*
    Archives all the 'DAY' records that are in the aging criteria in the PLAYLIST_COUNT_LIVE table
    to the AGED counterpart i.e. PLAYLIST_COUNT_LIVE_ADAY table.
    %param pDays_in  The number of days past current date to decide time interval past which we archive
                     (Ex: Sysdate - pNumDays_in)
    %param pJobDesc_in The description of the database job that runs this archiving job.
  */ 
  PROCEDURE archivePlaylistCount(pNumDays_in IN NUMBER := 30,
                                 pJobDesc_in IN VARCHAR2 := 'Job xxx');  
  
  
  
 /*
    Archives all the 'DAY' records that are in the aging criteria in the CUSTOMER_COUNT_LIVE table
    to the AGED counterpart i.e. CUSTOMER_COUNT_LIVE_ADAY table.
    %param pDays_in  The number of days past current date to decide time interval past which we archive
                     (Ex: Sysdate - pNumDays_in)
    %param pJobDesc_in The description of the database job that runs this archiving job.
  */ 
  PROCEDURE archiveCustomerCount(pNumDays_in IN NUMBER := 30,
                                 pJobDesc_in IN VARCHAR2 := 'Job xxx');  
  
  
  
    
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

  --
END MSTN_ARCHIVE_P;
/
CREATE OR REPLACE PACKAGE BODY 
--
--  Module    : MSTN_ARCHIVE_P (Body)
--  Author    : Manu Kaul
--  Created   : 28/04/2008 13:36:06
--  Purpose   : Archival of data to keep LIVE tables smaller and manageable
--
--  Revision History
--
--  Date        Who              Version        Details
--  =========== =============== =============== =======================================
--  28/04/2008  Manu Kaul       V1.0.MKA.0.0    Initial Version
--
 MSTN_ARCHIVE_P AS

-------------------------------------
-- Procedure archiveTrackCount
-------------------------------------
  PROCEDURE archiveTrackCount(pNumDays_in IN NUMBER := 30,
                              pJobDesc_in IN VARCHAR2 := 'Job xxx') AS
    -- Variables
    vRowsProcessed NUMBER := 0;
    vRunID         job_run_stats.id%type := 0;
  
  BEGIN
    -- 1. Insert a record into job runs to indicate start of the archival process.
    INSERT INTO job_run_stats
      (id,
       run_desc,
       job_desc,
       run_count,
       start_ts,
       end_ts,
       data_classification,
       created,
       inserted,
       modified)
    VALUES
      (job_run_stats_id_seq.nextval,
       'Archive Track Counts',
       pJobDesc_in,
       0,
       sysdate,
       null,
       400000,
       sysdate,
       sysdate,
       sysdate)
    RETURNING id INTO vRunID;
  
    -- 2. Copy records from the TRACK_COUNT_LIVE table into the AGING table
    INSERT INTO track_count_live_aday 
                         (id,
                          track_id,
                          service_id,
                          period_kind,
                          period,
                          period_start,
                          platform_group_kind,
                          platform_kind,
                          play_count,
                          nq_play_count,
                          rate_count,
                          share_count,
                          nq_play_time_secs,
                          play_time_secs,
                          first_play_date,
                          first_nq_play_date,
                          first_rate_date,
                          first_share_date,
                          last_play_date,
                          last_nq_play_date,
                          last_rate_date,
                          last_share_date,
                          run_id,
                          guid,
                          data_classification,
                          created,
                          inserted,
                          modified)
      SELECT TRACK_COUNT_LIVE_A_ID_SEQ.NEXTVAL,
             t.TRACK_ID,
             t.SERVICE_ID,
             t.PERIOD_KIND,
             t.PERIOD,
             t.PERIOD_START,
             t.PLATFORM_GROUP_KIND,
             t.PLATFORM_KIND,
             t.PLAY_COUNT,
             t.NQ_PLAY_COUNT,
             t.RATE_COUNT,
             t.SHARE_COUNT,
             t.NQ_PLAY_TIME_SECS,
             t.PLAY_TIME_SECS,
             t.FIRST_PLAY_DATE,
             t.FIRST_NQ_PLAY_DATE,
             t.FIRST_RATE_DATE,
             t.FIRST_SHARE_DATE,
             t.LAST_PLAY_DATE,
             t.LAST_NQ_PLAY_DATE,
             t.LAST_RATE_DATE,
             t.LAST_SHARE_DATE,
             vRunID,
             t.GUID,
             t.DATA_CLASSIFICATION,
             t.CREATED,
             t.INSERTED,
             t.MODIFIED
        FROM track_count_live t
       WHERE t.period_start < sysdate - pNumDays_in
         AND t.period_kind = 'DAY';
  
    -- 3. Record affected rows
    vRowsProcessed := SQL%ROWCOUNT;
    dbms_output.put_line('Rows processed = ' || vRowsProcessed);
  
    -- 4. Delete the records from TRACK_COUNT_LIVE table as they have been archived.
    DELETE FROM track_count_live t
     WHERE t.period_start < sysdate - pNumDays_in
       AND t.period_kind = 'DAY';
  
    -- 5. Update job_run_stats table to reflect affected rows and the end_ts to
    --    show when process of archiving was completed.
    UPDATE job_run_stats t
       SET t.run_count = vRowsProcessed, t.end_ts = sysdate
     WHERE t.id = vRunID;
  
  END archiveTrackCount;



-------------------------------------
-- Procedure archiveArtistCount
-------------------------------------
  PROCEDURE archiveArtistCount(pNumDays_in IN NUMBER := 30,
                               pJobDesc_in IN VARCHAR2 := 'Job xxx') AS
    -- Variables
    vRowsProcessed NUMBER := 0;
    vRunID         job_run_stats.id%type := 0;

  BEGIN
    -- 1. Insert a record into job runs to indicate start of the archival process.
    INSERT INTO job_run_stats
      (id,
       run_desc,
       job_desc,
       run_count,
       start_ts,
       end_ts,
       data_classification,
       created,
       inserted,
       modified)
    VALUES
      (job_run_stats_id_seq.nextval,
       'Archive Artist Counts',
       pJobDesc_in,
       0,
       sysdate,
       null,
       400000,
       sysdate,
       sysdate,
       sysdate)
    RETURNING id INTO vRunID;

    -- 2. Copy records from the ARTIST_COUNT_LIVE table into the AGING table
    INSERT INTO
    artist_count_live_aday (id,
                          artist_id,
                          service_id,
                          period_kind,
                          period,
                          period_start,
                          platform_group_kind,
                          platform_kind,
                          play_count,
                          nq_play_count,
                          rate_count,
                          share_count,
                          nq_play_time_secs,
                          play_time_secs,
                          first_play_date,
                          first_nq_play_date,
                          first_rate_date,
                          first_share_date,
                          last_play_date,
                          last_nq_play_date,
                          last_rate_date,
                          last_share_date,
                          run_id,
                          guid,
                          data_classification,
                          created,
                          inserted,
                          modified)
      SELECT ARTIST_COUNT_LIVE_A_ID_SEQ.NEXTVAL,
             a.ARTIST_ID,                   
             a.SERVICE_ID,                 
             a.PERIOD_KIND,                
             a.PERIOD,                     
             a.PERIOD_START,  
	           a.PLATFORM_GROUP_KIND,
	           a.PLATFORM_KIND,
             a.PLAY_COUNT,                 
             a.NQ_PLAY_COUNT,              
             a.RATE_COUNT, 
             a.SHARE_COUNT,                
             a.NQ_PLAY_TIME_SECS,          
             a.PLAY_TIME_SECS,             
             a.FIRST_PLAY_DATE,            
             a.FIRST_NQ_PLAY_DATE,         
             a.FIRST_RATE_DATE,            
             a.FIRST_SHARE_DATE,           
             a.LAST_PLAY_DATE,             
             a.LAST_NQ_PLAY_DATE,          
             a.LAST_RATE_DATE,             
             a.LAST_SHARE_DATE,            
             vRunID,                     
             a.GUID,                       
             a.DATA_CLASSIFICATION,        
             a.CREATED,                    
             a.INSERTED,                   
             a.MODIFIED                   
       FROM artist_count_live a
       WHERE a.period_start < sysdate - pNumDays_in
       AND   a.period_kind = 'DAY';

    -- 3. Record affected rows
    vRowsProcessed := SQL%ROWCOUNT;
    dbms_output.put_line('Rows processed = ' || vRowsProcessed);

    -- 4. Delete the records from ARTIST_COUNT_LIVE table as they have been archived.
    DELETE FROM artist_count_live t
    WHERE  t.period_start < sysdate - pNumDays_in
    AND    t.period_kind = 'DAY';

    -- 5. Update job_run_stats table to reflect affected rows and the end_ts to
    --    show when process of archiving was completed.
    UPDATE job_run_stats t
       SET t.run_count = vRowsProcessed,
           t.end_ts    = sysdate
     WHERE t.id    = vRunID;

  END archiveArtistCount;




-------------------------------------
-- Procedure archiveReleaseCount
-------------------------------------
  PROCEDURE archiveReleaseCount(pNumDays_in IN NUMBER := 30,
                               pJobDesc_in IN VARCHAR2 := 'Job xxx') AS
    -- Variables
    vRowsProcessed NUMBER := 0;
    vRunID         job_run_stats.id%type := 0;

  BEGIN
    -- 1. Insert a record into job runs to indicate start of the archival process.
    INSERT INTO job_run_stats
      (id,
       run_desc,
       job_desc,
       run_count,
       start_ts,
       end_ts,
       data_classification,
       created,
       inserted,
       modified)
    VALUES
      (job_run_stats_id_seq.nextval,
       'Archive Release Counts',
       pJobDesc_in,
       0,
       sysdate,
       null,
       400000,
       sysdate,
       sysdate,
       sysdate)
    RETURNING id INTO vRunID;

    -- 2. Copy records from the RELEASE_COUNT_LIVE table into the AGING table
    INSERT INTO
    release_count_live_aday (
                              ID               ,   
                              RELEASE_ID       ,   
                              SERVICE_ID       ,   
                              PERIOD_KIND      ,   
                              PERIOD           ,   
                              PERIOD_START     ,   
                              PLATFORM_GROUP_KIND, 
                              PLATFORM_KIND      , 
                              PLAY_COUNT         , 
                              NQ_PLAY_COUNT      , 
                              RATE_COUNT         , 
                              SHARE_COUNT        , 
                              NQ_PLAY_TIME_SECS  , 
                              PLAY_TIME_SECS     , 
                              FIRST_PLAY_DATE    , 
                              FIRST_NQ_PLAY_DATE , 
                              FIRST_RATE_DATE    ,                       
                              LAST_PLAY_DATE     ,                       
                              LAST_NQ_PLAY_DATE  ,                       
                              LAST_RATE_DATE     ,                       
                              run_id             ,
                              GUID               ,                       
                              DATA_CLASSIFICATION,                       
                              CREATED            ,                       
                              INSERTED           ,                       
                              MODIFIED            )                     
      SELECT  RELEASE_COUNT_LIVE_A_ID_SEQ.NEXTVAL,
              RELEASE_ID          ,       
              SERVICE_ID          ,
              PERIOD_KIND         ,
              PERIOD              ,
              PERIOD_START        ,
              PLATFORM_GROUP_KIND ,
              PLATFORM_KIND       ,
              PLAY_COUNT          ,
              NQ_PLAY_COUNT       ,
              RATE_COUNT          ,
              SHARE_COUNT         ,
              NQ_PLAY_TIME_SECS   ,
              PLAY_TIME_SECS      ,
              FIRST_PLAY_DATE     ,
              FIRST_NQ_PLAY_DATE  ,
              FIRST_RATE_DATE     ,
              LAST_PLAY_DATE      ,
              LAST_NQ_PLAY_DATE   ,
              LAST_RATE_DATE      ,
              vRunID              ,
              GUID                ,
              DATA_CLASSIFICATION ,
              CREATED             ,
              INSERTED            ,
              MODIFIED            
       FROM release_count_live a
       WHERE a.period_start < sysdate - pNumDays_in
       AND   a.period_kind = 'DAY';

    -- 3. Record affected rows
    vRowsProcessed := SQL%ROWCOUNT;
    dbms_output.put_line('Rows processed = ' || vRowsProcessed);

    -- 4. Delete the records from RELEASE_COUNT_LIVE table as they have been archived.
    DELETE FROM release_count_live t
    WHERE  t.period_start < sysdate - pNumDays_in
    AND    t.period_kind = 'DAY';

    -- 5. Update job_run_stats table to reflect affected rows and the end_ts to
    --    show when process of archiving was completed.
    UPDATE job_run_stats t
       SET t.run_count = vRowsProcessed,
           t.end_ts    = sysdate
     WHERE t.id    = vRunID;

  END archiveReleaseCount;



-------------------------------------
-- Procedure archivePlaylistCount
-------------------------------------
  PROCEDURE archivePlaylistCount(pNumDays_in IN NUMBER := 30,
                                 pJobDesc_in IN VARCHAR2 := 'Job xxx') AS
    -- Variables
    vRowsProcessed NUMBER := 0;
    vRunID         job_run_stats.id%type := 0;

  BEGIN
    -- 1. Insert a record into job runs to indicate start of the archival process.
    INSERT INTO job_run_stats
      (id,
       run_desc,
       job_desc,
       run_count,
       start_ts,
       end_ts,
       data_classification,
       created,
       inserted,
       modified)
    VALUES
      (job_run_stats_id_seq.nextval,
       'Archive Playlist Counts',
       pJobDesc_in,
       0,
       sysdate,
       null,
       400000,
       sysdate,
       sysdate,
       sysdate)
    RETURNING id INTO vRunID;

    -- 2. Copy records from the PLAYLIST_COUNT_LIVE table into the AGING table
    INSERT INTO
    playlist_count_live_aday (
                              ID                  ,                         
                              PLAYLIST_ID         ,
                              PERIOD_KIND         ,
                              PERIOD              ,
                              PERIOD_START        ,
                              PLATFORM_GROUP_KIND ,
                              PLATFORM_KIND       ,
                              PLAY_COUNT          ,
                              NQ_PLAY_COUNT       ,
                              RATE_COUNT          ,
                              SHARE_COUNT         ,
                              FIRST_PLAY_DATE     ,
                              FIRST_NQ_PLAY_DATE  ,
                              FIRST_RATE_DATE     ,
                              LAST_PLAY_DATE      ,
                              LAST_NQ_PLAY_DATE   ,
                              LAST_RATE_DATE      ,
                              run_id              ,
                              GUID                ,
                              DATA_CLASSIFICATION ,
                              CREATED             ,
                              INSERTED            ,
                              MODIFIED            
     )                     
      SELECT  PLAYLIST_COUNT_LIVE_A_ID_SEQ.NEXTVAL,
              PLAYLIST_ID         ,
              PERIOD_KIND         ,
              PERIOD              ,
              PERIOD_START        ,
              PLATFORM_GROUP_KIND ,
              PLATFORM_KIND       ,
              PLAY_COUNT          ,
              NQ_PLAY_COUNT       ,
              RATE_COUNT          ,
              SHARE_COUNT         ,
              FIRST_PLAY_DATE     ,
              FIRST_NQ_PLAY_DATE  ,
              FIRST_RATE_DATE     ,
              LAST_PLAY_DATE      ,
              LAST_NQ_PLAY_DATE   ,
              LAST_RATE_DATE      ,
              vRunID              ,
              GUID                ,
              DATA_CLASSIFICATION ,
              CREATED             ,
              INSERTED            ,
              MODIFIED            
       FROM  playlist_count_live a
       WHERE a.period_start < sysdate - pNumDays_in
       AND   a.period_kind = 'DAY';

    -- 3. Record affected rows
    vRowsProcessed := SQL%ROWCOUNT;
    dbms_output.put_line('Rows processed = ' || vRowsProcessed);

    -- 4. Delete the records from PLAYLIST_COUNT_LIVE table as they have been archived.
    DELETE FROM playlist_count_live t
    WHERE  t.period_start < sysdate - pNumDays_in
    AND    t.period_kind = 'DAY';

    -- 5. Update job_run_stats table to reflect affected rows and the end_ts to
    --    show when process of archiving was completed.
    UPDATE job_run_stats t
       SET t.run_count = vRowsProcessed,
           t.end_ts    = sysdate
     WHERE t.id    = vRunID;

  END archivePlaylistCount;



-------------------------------------
-- Procedure archiveCustomerCount
-------------------------------------
  PROCEDURE archiveCustomerCount(pNumDays_in IN NUMBER := 30,
                                 pJobDesc_in IN VARCHAR2 := 'Job xxx') AS
    -- Variables
    vRowsProcessed NUMBER := 0;
    vRunID         job_run_stats.id%type := 0;

  BEGIN
    -- 1. Insert a record into job runs to indicate start of the archival process.
    INSERT INTO job_run_stats
      (id,
       run_desc,
       job_desc,
       run_count,
       start_ts,
       end_ts,
       data_classification,
       created,
       inserted,
       modified)
    VALUES
      (job_run_stats_id_seq.nextval,
       'Archive Customer Counts',
       pJobDesc_in,
       0,
       sysdate,
       null,
       400000,
       sysdate,
       sysdate,
       sysdate)
    RETURNING id INTO vRunID;

    -- 2. Copy records from the CUSTOMER_COUNT_LIVE table into the AGING table
    INSERT INTO
    customer_count_live_aday (
                            ID                               ,                           
                            CUSTOMER_ID                      ,  
                            PERIOD_KIND                      ,  
                            PERIOD                           ,  
                            PERIOD_START                     ,  
                            PLATFORM_GROUP_KIND              ,  
                            PLATFORM_KIND                    ,  
                            DEVICE_ID                        ,  
                            PLAY_COUNT                       , 
                            PLAY_COUNT_TRACK                 , 
                            PLAY_COUNT_RELEASE               ,
                            PLAY_COUNT_SYSTEM_PLAYLIST       ,
                            PLAY_COUNT_MYPLAYLIST            ,  
                            PLAY_COUNT_MYPLAYLIST_OWNER      ,  
                            PLAY_COUNT_MYPLAYLIST_OTHER      ,  
                            PLAY_COUNT_OTHERPLAYLIST         ,  
                            NQ_PLAY_COUNT                    ,  
                            NQ_PLAY_COUNT_TRACK              ,  
                            NQ_PLAY_COUNT_RELEASE            ,  
                            NQ_PLAY_COUNT_MYPLAYLIST         ,  
                            NQ_PLAY_COUNT_MYPLAYLIST_OWNER   ,  
                            NQ_PLAY_COUNT_MYPLAYLIST_OTHER   ,  
                            NQ_PLAY_COUNT_OTHERPLAYLIST      ,  
                            NQ_PLAY_COUNT_SYSTEM_PLAYLIST    ,  
                            RATE_COUNT                       ,  
                            SHARE_COUNT                      ,  
                            FRIEND_COUNT                     ,  
                            FIRST_PLAY_DATE                  ,  
                            FIRST_PLAY_TRACK_DATE            ,  
                            FIRST_PLAY_RELEASE_DATE          ,  
                            FIRST_PLAY_MYPLAYLIST_OWNER_DA   ,  
                            FIRST_PLAY_MYPLAYLIST_OTHER_DA   ,  
                            FIRST_PLAY_MYPLAYLIST_DATE       ,  
                            FIRST_PLAY_OTHERPLAYLIST_DATE    ,  
                            FIRST_PLAY_SYSTEM_PLAYLIST_DAT   ,  
                            FIRST_NQ_PLAY_DATE               ,  
                            FIRST_NQ_PLAY_TRACK_DATE         ,  
                            FIRST_NQ_PLAY_RELEASE_DATE       ,  
                            FIRST_NQ_PLAY_MYPLAYLIST_DATE    ,  
                            FIRST_NQ_PLAY_MYPLAYLIST_OWNER   ,  
                            FIRST_NQ_PLAY_MYPLAYLIST_OTHER   ,  
                            FIRST_NQ_PLAY_OTHERPLAYLIST_DA   ,  
                            FIRST_NQ_PLAY_SYSTEM_PLAYLIST_   ,  
                            FIRST_SHARE_DATE                 ,  
                            FIRST_RATE_DATE                  ,  
                            LAST_PLAY_DATE                   ,  
                            LAST_PLAY_TRACK_DATE             ,  
                            LAST_PLAY_RELEASE_DATE           ,  
                            LAST_PLAY_MYPLAYLIST_DATE        ,  
                            LAST_PLAY_MYPLAYLIST_OWNER_DAT   ,  
                            LAST_PLAY_MYPLAYLIST_OTHER_DAT   ,  
                            LAST_PLAY_OTHERPLAYLIST_DATE     ,  
                            LAST_PLAY_SYSTEM_PLAYLIST_DATE   ,  
                            LAST_NQ_PLAY_DATE                ,  
                            LAST_NQ_PLAY_TRACK_DATE          ,  
                            LAST_NQ_PLAY_RELEASE_DATE        ,  
                            LAST_NQ_PLAY_MYPLAYLIST_DATE     ,  
                            LAST_NQ_PLAY_MYPLAYLIST_OWNER_   ,  
                            LAST_NQ_PLAY_MYPLAYLIST_OTHER_   ,  
                            LAST_NQ_PLAY_OTHERPLAYLIST_DAT   , 
                            LAST_NQ_PLAY_SYSTEM_PLAYLIST_D   ,  
                            LAST_SHARE_DATE                  , 
                            LAST_RATE_DATE                   ,  
                            run_id                           , 
                            GUID                             ,  
                            DATA_CLASSIFICATION              ,  
                            CREATED                          ,  
                            INSERTED                         ,  
                            MODIFIED                          
     )                     
      SELECT    
                            CUSTOMER_COUNT_LIVE_A_ID_SEQ.NEXTVAL,
                            CUSTOMER_ID                      ,              
                            PERIOD_KIND                      ,      
                            PERIOD                           ,      
                            PERIOD_START                     ,      
                            PLATFORM_GROUP_KIND              ,      
                            PLATFORM_KIND                    ,      
                            DEVICE_ID                        ,      
                            PLAY_COUNT                       ,      
                            PLAY_COUNT_TRACK                 ,      
                            PLAY_COUNT_RELEASE               ,      
                            PLAY_COUNT_SYSTEM_PLAYLIST       ,      
                            PLAY_COUNT_MYPLAYLIST            ,      
                            PLAY_COUNT_MYPLAYLIST_OWNER      ,      
                            PLAY_COUNT_MYPLAYLIST_OTHER      ,      
                            PLAY_COUNT_OTHERPLAYLIST         ,      
                            NQ_PLAY_COUNT                    ,      
                            NQ_PLAY_COUNT_TRACK              ,      
                            NQ_PLAY_COUNT_RELEASE            ,      
                            NQ_PLAY_COUNT_MYPLAYLIST         ,      
                            NQ_PLAY_COUNT_MYPLAYLIST_OWNER   ,      
                            NQ_PLAY_COUNT_MYPLAYLIST_OTHER   ,      
                            NQ_PLAY_COUNT_OTHERPLAYLIST      ,      
                            NQ_PLAY_COUNT_SYSTEM_PLAYLIST    ,      
                            RATE_COUNT                       ,      
                            SHARE_COUNT                      ,      
                            FRIEND_COUNT                     ,      
                            FIRST_PLAY_DATE                  ,      
                            FIRST_PLAY_TRACK_DATE            ,      
                            FIRST_PLAY_RELEASE_DATE          ,      
                            FIRST_PLAY_MYPLAYLIST_OWNER_DA   ,      
                            FIRST_PLAY_MYPLAYLIST_OTHER_DA   ,      
                            FIRST_PLAY_MYPLAYLIST_DATE       ,      
                            FIRST_PLAY_OTHERPLAYLIST_DATE    ,      
                            FIRST_PLAY_SYSTEM_PLAYLIST_DAT   ,      
                            FIRST_NQ_PLAY_DATE               ,      
                            FIRST_NQ_PLAY_TRACK_DATE         ,      
                            FIRST_NQ_PLAY_RELEASE_DATE       ,      
                            FIRST_NQ_PLAY_MYPLAYLIST_DATE    ,      
                            FIRST_NQ_PLAY_MYPLAYLIST_OWNER   ,      
                            FIRST_NQ_PLAY_MYPLAYLIST_OTHER   ,      
                            FIRST_NQ_PLAY_OTHERPLAYLIST_DA   ,      
                            FIRST_NQ_PLAY_SYSTEM_PLAYLIST_   ,      
                            FIRST_SHARE_DATE                 ,      
                            FIRST_RATE_DATE                  ,      
                            LAST_PLAY_DATE                   ,      
                            LAST_PLAY_TRACK_DATE             ,      
                            LAST_PLAY_RELEASE_DATE           ,      
                            LAST_PLAY_MYPLAYLIST_DATE        ,      
                            LAST_PLAY_MYPLAYLIST_OWNER_DAT   ,      
                            LAST_PLAY_MYPLAYLIST_OTHER_DAT   ,      
                            LAST_PLAY_OTHERPLAYLIST_DATE     ,      
                            LAST_PLAY_SYSTEM_PLAYLIST_DATE   ,      
                            LAST_NQ_PLAY_DATE                ,      
                            LAST_NQ_PLAY_TRACK_DATE          ,      
                            LAST_NQ_PLAY_RELEASE_DATE        ,      
                            LAST_NQ_PLAY_MYPLAYLIST_DATE     ,      
                            LAST_NQ_PLAY_MYPLAYLIST_OWNER_   ,      
                            LAST_NQ_PLAY_MYPLAYLIST_OTHER_   ,      
                            LAST_NQ_PLAY_OTHERPLAYLIST_DAT   ,      
                            LAST_NQ_PLAY_SYSTEM_PLAYLIST_D   ,      
                            LAST_SHARE_DATE                  ,      
                            LAST_RATE_DATE                   ,      
                            vRunID                           ,      
                            GUID                             ,      
                            DATA_CLASSIFICATION              ,      
                            CREATED                          ,      
                            INSERTED                         ,      
                            MODIFIED                                
       FROM  customer_count_live a
       WHERE a.period_start < sysdate - pNumDays_in
       AND   a.period_kind = 'DAY';

    -- 3. Record affected rows
    vRowsProcessed := SQL%ROWCOUNT;
    dbms_output.put_line('Rows processed = ' || vRowsProcessed);

    -- 4. Delete the records from PLAYLIST_COUNT_LIVE table as they have been archived.
    DELETE FROM customer_count_live t
    WHERE  t.period_start < sysdate - pNumDays_in
    AND    t.period_kind = 'DAY';

    -- 5. Update job_run_stats table to reflect affected rows and the end_ts to
    --    show when process of archiving was completed.
    UPDATE job_run_stats t
       SET t.run_count = vRowsProcessed,
           t.end_ts    = sysdate
     WHERE t.id    = vRunID;

  END archiveCustomerCount;
  
END MSTN_ARCHIVE_P;
/
