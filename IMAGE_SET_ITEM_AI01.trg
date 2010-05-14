CREATE OR REPLACE TRIGGER IMAGE_SET_ITEM_AI01
--
--  Module      : Trigger (Spec)
--  Author      : Manu K
--  Created     : 28-Jul-2008
--  Purpose     : To check if the incoming role is NOT = AVATAR or NOT PLAYLIST then
--                Checks to see if there are multiple occurences of the same 
--                (IMAGE_SET_ITEM_IMAGE_SET_ID, IMAGE_SET_ITEM_ROLE) to 
--                raise an exception and disallow the INSERT. 
--
--  Revision History
--
--  Date        Who             Version         Details
--  =========== =============== =============== =======================================
--  28-Jul-2008 M. Kaul         V1.0.MKA.0.0    Initial Version
--
  AFTER INSERT ON IMAGE_SET_ITEM
DECLARE
  -- Local Variables into which the stack values will be placed
  vImageSetID IMAGE_SET_ITEM.IMAGE_SET_ITEM_IMAGE_SET_ID%TYPE;
  vRole       IMAGE_SET_ITEM.IMAGE_SET_ITEM_ROLE%TYPE;
  vCount      INTEGER := 0;

  -- Exception Declaration
  xDUPLICATE_RECORD_FOUND EXCEPTION;

BEGIN

  -- Start looping and popping out the values on both
  -- stacks one by one and validating business logic
  LOOP
    -- Exception Handling Block  
    BEGIN
      MS_TYPE_P.popStack('STK_ITEM_ROLE', vRole);
      MS_TYPE_P.popStack('STK_IMAGE_SET_ID', vImageSetID);
    
      insert into mka_logger values ('vRole = ' || vRole);
      insert into mka_logger values ('vImageSetID = ' || vImageSetID);
    
      IF (upper(vRole) <> 'AVATAR' AND upper(vRole) <> 'PLAYLIST' and
         vRole is not null) THEN
      
        -- Check if there is a record in the table with the incoming (vImageSetID, vRole) combination
        -- If yes, then raise an error
        select count(*)
          into vCount
          from image_set_item x
         where x.image_set_item_image_set_id = vImageSetID
           and x.image_set_item_role = vRole;
      
        insert into mka_logger values ('vCount = ' || vCount);
      
        -- There exists a record in the table with that combination
        -- Note: We check for vCount > 1 because at this point the record
        -- we are trying to insert is also counted as one of the records in the table!
        IF (vCount > 1) THEN
          raise xDUPLICATE_RECORD_FOUND;
        END IF;
      END IF;
    EXCEPTION
      WHEN MS_TYPE_P.xARRAY_OUT_OF_BOUNDS THEN
        EXIT;
    END;
  END LOOP;
  -- Return memory held by stack
  MS_TYPE_P.destroyStack('STK_ITEM_ROLE');
  MS_TYPE_P.destroyStack('STK_IMAGE_SET_ID');
EXCEPTION
  WHEN OTHERS THEN
    -- Return memory held by stack
    MS_TYPE_P.destroyStack('STK_ITEM_ROLE');
    MS_TYPE_P.destroyStack('STK_IMAGE_SET_ID');
    RAISE;
    NULL;
END IMAGE_SET_ITEM_AI01;
/
