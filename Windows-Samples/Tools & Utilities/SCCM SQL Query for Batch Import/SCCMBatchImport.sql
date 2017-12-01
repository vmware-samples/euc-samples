select DISTINCT
sys.User_Name0 as 'Username*',
'' as 'Password',
'1' as 'Active',
'Directory' as 'Security Type*',
'' as 'Security Type*',
'' as 'Enable Device Staging',
'' as 'Pre Register for Vpp',
'' as 'Email Username',
vru.User_Principal_Name0 as 'Email Address*',
'' as 'Email Password',
'' as 'User Principal Name',
vru.givenName0 as 'First Name*',
'' as 'Middle Name',
vru.sn0 as 'Last Name*',
'YourGroupID' as 'GroupID*', 						-- Your Group ID here
'' as 'Authorized GroupIDs',
'' as 'Enrollment Organization Group',
'' as 'Domain',
'' as 'Phone Number',
'' as 'Mobile Phone',
'' as 'Department',
'' as 'User Category',
'' as 'User Role',
'' as 'User Message Type',
'' as 'User Message Subject',
'' as 'User Message Body',
'' as 'Employee Identifier',
'' as 'Cost Center',
'' as 'Manager DN',
'YourDeviceGroupID' as 'Device GroupID', 			-- Your Group ID here
'' as 'Device Friendly Name',
'c' as 'Device Ownership(C/E/S/None)',
'' as 'Device Message Type',
'' as 'Device UDID(No special Characters)',
'' as 'Device IMEI',
'' as 'Device SIM',
'' as 'Device Asset Number',
v_GS_PC_BIOS.SerialNumber0 as 'Device Serial Number',
'' as 'Device Platform',
'' as 'Device Model',
'' as 'Device OS',
'' as 'Device Oem',
'' as 'Tags',
'' as 'Custom Attribute Name 1',
'' as 'Custom Attribute Name 2',
'' as 'Custom Attribute Name 3'
FROM v_R_System sys JOIN v_GS_PC_BIOS on  sys.ResourceID =  v_GS_PC_BIOS.ResourceID JOIN v_GS_COMPUTER_SYSTEM on sys.ResourceID = v_GS_COMPUTER_SYSTEM.ResourceID
join v_FullCollectionMembership FCM on FCM.ResourceID = v_GS_COMPUTER_SYSTEM.ResourceID
INNER JOIN
     v_GS_COMPUTER_SYSTEM cs on sys.resourceID = cs.resourceID
LEFT JOIN
     V_GS_Operating_system os on sys.resourceID = os.resourceID
LEFT JOIN
     v_R_User vru ON sys.User_Name0 = vru.User_Name0
Where FCM.CollectionID = 'YourCollectionID' 		-- Your Collection ID 
and sys.User_Name0 != 'Null'  						-- Remove Null Usernames
and sys.User_Name0 != 'Administrator' 				-- Remove Administrators
and vru.User_Principal_Name0 != 'Null' 				-- Remove Null UPN
and vru.givenName0 != 'Null' 						-- Remove Null First Name
and vru.sn0 != 'Null' 								-- Remove Null Last Name
and v_GS_PC_BIOS.SerialNumber0 not like '%vmware%' 	-- Optional, Remove VMs, Remove VMs with serial numbers starting with VMware