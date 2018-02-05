select DISTINCT
sys.User_Name0 as 'Username*',
'' as 'Password',
vru.givenName0 as 'First Name*',
vru.sn0 as 'Last Name*',
'YourGroupID' as 'GroupID*', 						-- Your Group ID here
'Directory' as 'Security Type*',
vru.Mail0 as 'Email Address*',
'' as 'User Role',
'' as 'User Message Type',
'YourGroupID' as 'Device GroupID', 					-- Your Group ID here
'' as 'Device Friendly Name',
v_GS_PC_BIOS.SerialNumber0 as 'Device Serial Number',
'' as 'Device Platform'
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
and vru.Mail0 != 'Null' 							-- Remove Null Email Address
and vru.givenName0 != 'Null' 						-- Remove Null First Name
and vru.sn0 != 'Null' 								-- Remove Null Last Name
and v_GS_PC_BIOS.SerialNumber0 not like '%vmware%' 	-- Optional, Remove VMs, Remove VMs with serial numbers starting with VMware