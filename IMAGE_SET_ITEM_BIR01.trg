CREATE OR REPLACE TRIGGER IMAGE_SET_ITEM_BIR01
--
--  Module      : Trigger (Spec)
--  Author      : Manu K
--  Created     : 28-Jul-2008
--  Purpose     : To push values onto the stacks initialized in the Before statement level trigger.
--
--  Revision History
--
--  Date        Who             Version         Details
--  =========== =============== =============== =======================================
--  28-Jul-2008 M. Kaul         V1.0.MKA.0.0    Initial Version
--
    BEFORE INSERT ON IMAGE_SET_ITEM
        FOR EACH ROW
BEGIN
  --
  MS_TYPE_P.pushStack('STK_ITEM_ROLE', :new.image_set_item_role);
  MS_TYPE_P.pushStack('STK_IMAGE_SET_ID', :new.image_set_item_image_set_id);
  --
END IMAGE_SET_ITEM_BIR01;
/
