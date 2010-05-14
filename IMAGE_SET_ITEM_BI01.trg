CREATE OR REPLACE TRIGGER IMAGE_SET_ITEM_BI01
--
--  Module      : Trigger (Spec)
--  Author      : Manu K
--  Created     : 28-Jul-2008
--  Purpose     : To create a new stack to insert values before insert only
--
--  Revision History
--
--  Date        Who             Version         Details
--  =========== =============== =============== =======================================
--  28-Jul-2008 M. Kaul         V1.0.MKA.0.0    Initial Version
--
    BEFORE INSERT ON IMAGE_SET_ITEM
BEGIN
  --
  -- Store these values on a new stack each. A string for ROLE and 
  -- a integer for Image_set_id
  MS_TYPE_P.newStringStack('STK_ITEM_ROLE');
  MS_TYPE_P.newIntStack('STK_IMAGE_SET_ID');
  --
END IMAGE_SET_ITEM_BI01;
/
