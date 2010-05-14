CREATE OR REPLACE TRIGGER CUSTOMER_CLIENT_BIU01
--
--	Author		: Manu Kaul
--	Created		: 22/04/2008 11:34:34
--
--	Revision History
--
--	Date		    Who				      Version			    Details
--	===========	===============	===============	=======================================
--	22/04/2008	Manu Kaul		    V1.0.MKA.0.0	  Initial Version (JIRA : #MS-423)
--

/*
 * The Trigger gets the DEVICE_IMEI field from the CUSTOMER_CLIENT table 
 * and updates the value of NORMALIZED_IMEI automatically stripping off 
 * all non-digit characters from DEVICE_IMEI and packing the digits only.
 */
	BEFORE INSERT OR UPDATE ON CUSTOMER_CLIENT
		FOR EACH ROW
BEGIN
       -- If a new row is inserted, get the device_imei and calculate the new normalized imei
       -- The subster(regex... expression below evaluates to NULL for NULL device_imei as well.
       if INSERTING then
          dbms_output.put_line('Calculating the normalized imei on insert');
          :new.normalized_imei := substr(regexp_replace(:new.device_imei, '([^[:digit:]]*)',''), 1, 15);
       else -- Updating
            -- If Device_imei gets changed then go ahead and recalculate the normalized_imei
            -- This will ensure that we re-calculate the normalized imei only when the device_imei 
            -- has changed!
            if( :new.device_imei <> :old.device_imei or   -- Value got changed from a non-null value xxx to yyy
                :new.device_imei is null             or   -- Device_imei is being Nulled out   
                :old.device_imei is null                  -- Device_imei was null and is being stamped
               ) then
            
          dbms_output.put_line('Calculating the normalized imei on update');
                :new.normalized_imei := substr(regexp_replace(:new.device_imei, '([^[:digit:]]*)',''), 1, 15);
            end if;
       end if;
END;
/
