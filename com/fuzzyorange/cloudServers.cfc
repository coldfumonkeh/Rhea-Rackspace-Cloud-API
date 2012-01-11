<!---
Filename: cloudServers.cfc
Creation Date: 15/February/2010
Original Author: Matt Gifford
Revision: $Rev$
$LastChangedBy$
$LastChangedDate$
Description:
--->
<cfcomponent displayname="cloudServers" output="false">

	<cfset variables.instance = structNew() />

	<cffunction name="init" access="public" output="false" returntype="com.fuzzyorange.cloudServers">
		<cfargument name="cloudAccountDetails" 	required="true" 	type="com.fuzzyorange.cloudAccountDetails" 	hint="The cloud files account object" />
		<cfargument name="authResponse"			required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="format"				required="true"		type="string" 								hint="The return format of responses from the cloud server API. XML or JSON." />
			<cfscript>
				setAccountDetails(arguments.cloudAccountDetails);
				setAuthResponse(arguments.authResponse);
				setReturnFormat(arguments.format);
				setServers();
			</cfscript>
		<cfreturn this />
	</cffunction>
	
	<!--- MUTATORS --->
	<cffunction name="setAccountDetails" access="private" output="false" hint="I set the cloud files API account details">
		<cfargument name="cloudAccountDetails" required="true" type="com.fuzzyorange.cloudAccountDetails" hint="The cloud files account object" />
		<cfset variables.instance.cloudAccountDetails = arguments.cloudAccountDetails />
	</cffunction>
	
	<cffunction name="setServers" access="private" output="false" hint="I instantiate the servers cfc and load it into the variables.instance struct">
		<cfset variables.instance.servers = createObject('component', 'com.fuzzyorange.servers').init(getUserName(),getAPIKey(),getAuthResponse(),getReturnFormat()) />
	</cffunction>
	
	<cffunction name="setAuthResponse" access="private" output="false" hint="I instantiate the AuthResponse cfc and load it into the variables.instance struct">
		<cfargument name="authResponse"	required="true" type="com.fuzzyorange.beans.authResponse" hint="The authResponse bean" />
		<cfset variables.instance.authresponse = arguments.authResponse />
	</cffunction>
	
	<cffunction name="setReturnFormat" access="private" output="false" hint="I set the string value for the return response in the variables.instance struct">
		<cfargument name="format" required="false" type="string" hint="The return format of responses from the cloud server API. XML or JSON." />
		<cfset variables.instance.returnformat = arguments.format />
	</cffunction>
	
	<!--- ACCESSORS --->
	<cffunction name="getAccountDetails" access="public" output="false" hint="I get the cloud files API account details">
		<cfreturn variables.instance.cloudAccountDetails />
	</cffunction>
	
	<cffunction name="getUserName" access="public" output="false" returntype="string" hint="I get the cloud files account username">
		<cfreturn getAccountDetails().getuserName() />
	</cffunction>
	
	<cffunction name="getAPIKey" access="public" output="false" returntype="string" hint="I get the cloud files account API key">
		<cfreturn getAccountDetails().getapiKey() />
	</cffunction>
	
	<cffunction name="getServers" access="public" output="false" returntype="com.fuzzyorange.servers" hint="I get the cloud server servers component">
		<cfreturn variables.instance.servers />
	</cffunction>
	
	<cffunction name="getAuthResponse" access="public" output="false" returntype="com.fuzzyorange.beans.authResponse" hint="I get the cloud files AuthResponse component">
		<cfreturn variables.instance.authresponse />
	</cffunction>
		
	<cffunction name="getReturnFormat" access="public" output="false" hint="I return the string value for the return response from the variables.instance struct">
		<cfreturn variables.instance.returnformat />
	</cffunction>
	
	<!--- PUBLIC METHODS --->
	
	<!--- SERVER RELATED METHODS --->
	<cffunction name="listServers" access="public" output="false" returntype="Any" hint="I will return details of all servers currently associated with the authenticated account.">
		<cfargument name="showDetail" 	required="false" 	type="boolean" 	default="false" 				hint="If TRUE, will return all details for the servers, not just IDs and names" />
		<cfargument name="format"		required="false"	type="string" 	default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().listServers(getAuthResponse(),arguments.showDetail,arguments.format) />
	</cffunction>
	
	<cffunction name="createServer" access="public" output="false" returntype="Any" hint="This operation asynchronously provisions a new server. The progress of this operation depends on several factors including location of the requested image, network i/o, host load, and the selected flavor.">
		<cfargument name="name"		required="true"		type="string" 								hint="I am the name for the new server" />
		<cfargument name="flavorID" required="true" 	type="string" 								hint="I am the ID of a specific flavor you wish to use to create the server." />
		<cfargument name="imageID"	required="true" 	type="string" 								hint="I am the ID of a specific image you wish to use to create the server." />
		<cfargument name="format"	required="false"	type="string" default="#getReturnFormat()#" hint="The return format of responses from the cloud server API. XML or JSON." />
		<cfreturn getServers().createServer(getAuthResponse(),arguments.name,arguments.flavorID,arguments.imageID,arguments.format) />
	</cffunction>
	
	<cffunction name="getServerDetails" access="public" output="false" returntype="Any" hint="I will return the details of a specific server.">
		<cfargument name="serverID" required="true" 	type="string" 								hint="I am the ID of a specific server you wish to obtain details for." />
		<cfargument name="format"	required="false"	type="string" default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().getServerDetails(getAuthResponse(),arguments.serverID,arguments.format) />
	</cffunction>
	
	<cffunction name="updateServerNamePassword" access="public" output="false" returntype="Any" hint="This operation allows you to update the name of the server and/or change the administrative password. This operation changes the name of the server in the Cloud Servers system and does not change the server host name itself.">
		<cfargument name="serverID" 		required="true" 	type="string" 								hint="I am the ID of a specific server you wish to obtain details for." />
		<cfargument name="serverName" 		required="false" 	type="string" default=""					hint="I am the new name for the server image." />
		<cfargument name="adminPassword" 	required="false" 	type="string" default=""					hint="I am the new admin password." />
		<cfargument name="format"			required="false"	type="string" default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().updateServerNamePassword(getAuthResponse(),arguments.serverID,arguments.serverName,arguments.adminPassword,arguments.format) />
	</cffunction>
	
	<cffunction name="deleteServer" access="public" output="false" returntype="Any" hint="This operation deletes a cloud server instance from the system.">
		<cfargument name="serverID" required="true" 	type="string" 								hint="I am the ID of a specific server you wish to delete." />
		<cfargument name="format"	required="false"	type="string" default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().deleteServer(getAuthResponse(),arguments.serverID,arguments.format) />
	</cffunction>
	
	<!--- SERVER ACTIONS --->
	<cffunction name="rebootServer" access="public" output="false" returntype="Any" hint="The reboot function allows for either a soft or hard reboot of a server. With a soft reboot (SOFT), the operating system is signaled to restart, which allows for a graceful shutdown of all processes. A hard reboot (HARD) is the equivalent of power cycling the server.">
		<cfargument name="serverID" 	required="true" 	type="string" 									hint="I am the ID of a specific server you wish to reboot." />
		<cfargument name="rebootType"	required="false"	type="string" 	default="SOFT"					hint="The type of reboot to perform on the server. SOFT or HARD." />
		<cfargument name="format"		required="false"	type="string" 	default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().rebootServer(getAuthResponse(),arguments.serverID,arguments.rebootType,arguments.format) />
	</cffunction>
	
	<cffunction name="rebuildServer" access="public" output="false" returntype="Any" hint="The rebuild function removes all data on the server and replaces it with the specified image. serverId and IP addresses will remain the same.">
		<cfargument name="serverID" required="true" 	type="string" 									hint="I am the ID of a specific server you wish to rebuild." />
		<cfargument name="imageID"	required="true" 	type="string" 									hint="I am the ID of a specific image you wish to use to rebuild the server." />
		<cfargument name="format"	required="false"	type="string" 	default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().rebuildServer(getAuthResponse(),arguments.serverID,arguments.imageID,arguments.format) />
	</cffunction>
	
	<cffunction name="resizeServer" access="public" output="false" returntype="Any" hint="The resize function converts an existing server to a different flavor, in essence, scaling the server up or down. The original server is saved for a period of time to allow rollback if there is a problem. All resizes should be tested and explicitly confirmed, at which time the original server is removed. All resizes are automatically confirmed after 24 hours if they are not explicitly confirmed or reverted.">
		<cfargument name="serverID" 	required="true" 	type="string" 									hint="I am the ID of a specific server you wish to resize." />
		<cfargument name="flavorID" 	required="true" 	type="string" 									hint="I am the ID of a specific flavour you wish to use." />
		<cfargument name="format"		required="false"	type="string" 	default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().resizeServer(getAuthResponse(),arguments.serverID,arguments.flavorID,arguments.format) />
	</cffunction>
	
	<cffunction name="confirmResize" access="public" output="false" returntype="Any" hint="During a resize operation, the original server is saved for a period of time to allow roll back if there is a problem. Once the newly resized server is tested and has been confirmed to be functioning properly, use this operation to confirm the resize. After confirmation, the original server is removed and cannot be rolled back to. All resizes are automatically confirmed after 24 hours if they are not explicitly confirmed or reverted.">
		<cfargument name="serverID" 	required="true" 	type="string" 									hint="I am the ID of a specific server you wish to confirm." />
		<cfargument name="format"		required="false"	type="string" 	default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().confirmResize(getAuthResponse(),arguments.serverID,arguments.format) />
	</cffunction>
	
	<cffunction name="revertResize" access="public" output="false" returntype="Any" hint="During a resize operation, the original server is saved for a period of time to allow for roll back if there is a problem. If you determine there is a problem with a newly resized server, use this operation to revert the resize and roll back to the original server. All resizes are automatically confirmed after 24 hours if they have not already been confirmed explicitly or reverted.">
		<cfargument name="serverID" 	required="true" 	type="string" 									hint="I am the ID of a specific server you wish to confirm." />
		<cfargument name="format"		required="false"	type="string" 	default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().revertResize(getAuthResponse(),arguments.serverID,arguments.format) />
	</cffunction>
	
	<!--- ADDRESS RELATED METHODS --->
	<cffunction name="listServerAddresses" access="public" output="false" returntype="Any" hint="I will return details of all server addresses for a specific server.">
		<cfargument name="serverID" 	required="true" 	type="string" 									hint="I am the ID of a specific server you wish to obtain details for." />
		<cfargument name="filterList"	required="false"	type="string"	default="ALL" 					hint="If set to ALL by default, will return all server addresses. Other options are PUBLIC or PRIVATE, which will return only details for the public or private addresses." />
		<cfargument name="format"		required="false"	type="string" 	default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().listServerAddresses(getAuthResponse(),arguments.serverID,arguments.filterList,arguments.format) />
	</cffunction>		
		
	<!--- FLAVOR RELATED METHODS --->
	<!---
	A flavor is an available hardware configuration for a server. 
	Each flavor has a unique combination of disk space and memory capacity.
	--->
	<cffunction name="listFlavors" access="public" output="false" returntype="Any" hint="This operation will list all available flavors with details.">
		<cfargument name="showDetail" 	required="false" 	type="boolean" 	default="true" 					hint="If TRUE, will return all details for the flavors, not just IDs and names" />
		<cfargument name="format"		required="false"	type="string" 	default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().listFlavors(getAuthResponse(),arguments.showDetail,arguments.format) />
	</cffunction>
	
	<cffunction name="getFlavorDetails" access="public" output="false" returntype="Any" hint="This operation returns details of the specified flavor.">
		<cfargument name="flavorID" required="true" 	type="string" 								hint="I am the ID of a specific flavor you wish to obtain details for." />
		<cfargument name="format"	required="false"	type="string" default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().getFlavorDetails(getAuthResponse(),arguments.flavorID,arguments.format) />
	</cffunction>
	
	<!--- IMAGE RELATED METHODS --->
	<!---
	An image is a collection of files you use to create or rebuild a server. 
	Rackspace provides pre-built OS images by default. You may also create custom images.
	--->
	<cffunction name="listImages" access="public" output="false" returntype="Any" hint="This operation will list all images visible by the account.">
		<cfargument name="showDetail" 	required="false" 	type="boolean" 	default="true" 					hint="If TRUE, will return all details for the images, not just IDs and names" />
		<cfargument name="format"		required="false"	type="string" 	default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().listImages(getAuthResponse(),arguments.showDetail,arguments.format) />
	</cffunction>
	
	<cffunction name="createImage" access="public" output="false" returntype="Any" hint="This operation creates a new image for the given server ID. Once complete, a new image will be available that can be used to rebuild or create servers.">
		<cfargument name="serverID" 	required="true" 	type="string" 									hint="I am the ID of a specific server you wish to create an image of." />
		<cfargument name="imageName"	required="true"		type="string" 									hint="The name to provide for the created image." />
		<cfargument name="format"		required="false"	type="string" 	default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().createImage(getAuthResponse(),arguments.serverID,arguments.imageName,arguments.format) />
	</cffunction>
	
	<cffunction name="getImageDetails" access="public" output="false" returntype="Any" hint="This operation returns details of the specified image.">
		<cfargument name="imageID" 		required="true" 	type="string" 									hint="I am the ID of a specific image you wish to obtain details for." />
		<cfargument name="format"		required="false"	type="string" 	default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().getImageDetails(getAuthResponse(),arguments.imageID,arguments.format) />
	</cffunction>
	
	<cffunction name="deleteImage" access="public" output="false" returntype="Any" hint="This operation deletes an image from the system.">
		<cfargument name="imageID" 		required="true" 	type="string" 									hint="I am the ID of a specific image you wish to delete." />
		<cfargument name="format"		required="false"	type="string" 	default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().deleteImage(getAuthResponse(),arguments.imageID,arguments.format) />
	</cffunction>
	
	<!--- BACKUP RELATED METHODS --->
	<!---
	In addition to creating images on-demand, you may also schedule periodic (daily and weekly) images via a backup schedule. 
	The daily and weekly images are triggered automatically based on the backup schedule established. 
	The days/times specified for the backup schedule are targets and actual start and completion times may vary based on other activity in the system. 
	All backup times are in GMT.
	
	Weekly Backup Options:
	----------------------
	
	DISABLED 	= Weekly backup disabled
	SUNDAY 	 	= Sunday
	MONDAY	 	= Monday
	TUESDAY  	= Tuesday
	WEDNESDAY	= Wednesday
	THURSDAY	= Thursday
	FRIDAY		= Friday
	SATURDAY	= Saturday
	
	DAILY Backup Options:
	---------------------
	
	DISABLED	= Daily backups disabled
	H_0000_0200	= 0000-0200
	H_0200_0400	= 0200-0400
	H_0400_0600	= 0400-0600
	H_0600_0800	= 0600-0800
	H_0800_1000	= 0800-1000
	H_1000_1200	= 1000-1200
	H_1200_1400	= 1200-1400
	H_1400_1600	= 1400-1600
	H_1600_1800	= 1600-1800
	H_1800_2000	= 1800-2000
	H_2000_2200	= 2000-2200
	H_2200_0000	= 2200-0000
	
	--->
	<cffunction name="listSchedules" access="public" output="false" returntype="Any" hint="I will return a list of the backup schedules for the specified server">
		<cfargument name="serverID" required="true" 	type="string" 								hint="I am the ID of a specific server you wish to obtain details for." />
		<cfargument name="format"	required="false"	type="string" default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().listSchedules(getAuthResponse(),arguments.serverID,arguments.format) />
	</cffunction>
		
	<cffunction name="createUpdateSchedule" access="public" output="false" returntype="Any" hint="This operation creates a new backup schedule or updates an existing backup schedule for the specified server. Backup schedules will occur only when the enabled attribute is set to true. The weekly and daily attributes can be used to set or to disable individual backup schedules.">
		<cfargument name="serverID" required="true" 	type="String" 									hint="I am the ID of a specific server you wish to obtain details for." />
		<cfargument name="enabled"	required="false"	type="boolean" 	default="true"					hint="Boolean value to set if the backup schedule is enabled." />
		<cfargument name="weekly"	required="true"		type="String"									hint="The weekly backup schedule value; eg THURSDAY" />
		<cfargument name="daily"	required="true"		type="String"									hint="The daily backup schedule value; eg H_0200_0400" />
		<cfargument name="format"	required="false"	type="string" 	default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().createUpdateSchedule(getAuthResponse(),arguments.serverID,arguments.enabled,arguments.weekly,arguments.daily,arguments.format) />
	</cffunction>
	
	<cffunction name="disableSchedule" access="public" output="false" returntype="Any" hint="This operation disables the backup schedule for the specified server.">
		<cfargument name="serverID" required="true" 	type="string" 								hint="I am the ID of a specific server you wish to obtain details for." />
		<cfargument name="format"	required="false"	type="string" default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().disableSchedule(getAuthResponse(),arguments.serverID,arguments.format) />
	</cffunction>
	
	<!--- SHARED IP GROUPS RELATED METHODS --->
	<!---
	A shared IP group is a collection of servers that can share IPs with other members of the group. 
	Any server in a group can share one or more public IPs with any other server in the group. 
	With the exception of the first server in a shared IP group, servers must be launched into shared IP groups. 
	A server may only be a member of one shared IP group.
	--->
	<cffunction name="listSharedIPGroups" access="public" output="false" returntype="Any" hint="This operation provides a list of shared IP groups associated with your account.">
		<cfargument name="showDetail" 	required="false" 	type="boolean" 	default="true" 					hint="If TRUE, will return all details for the IP groups, not just IDs and names" />
		<cfargument name="format"		required="false"	type="string" 	default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().listSharedIPGroups(getAuthResponse(),arguments.showDetail,arguments.format) />
	</cffunction>
	
	<cffunction name="createSharedIPGroup" access="public" output="false" returntype="Any" hint="This operation creates a new shared IP group. Please note, all responses to requests for shared_ip_groups return an array of servers. However, on a create request, the shared IP group can be created empty or can be initially populated with a single server. Submitting a create request with a sharedIpGroup that contains an array of servers will generate a badRequest (400) fault.">
		<cfargument name="ipgroupName"	required="true"		type="string" 								hint="The name to apply to the new IP group." />
		<cfargument name="serverID" 	required="true" 	type="string" 								hint="I am the ID of a specific server you wish to obtain details for." />
		<cfargument name="format"		required="false"	type="string" default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().createSharedIPGroup(getAuthResponse(),arguments.ipgroupName,arguments.serverID,arguments.format) />
	</cffunction>
	
	<cffunction name="getSharedIPGroupDetails" access="public" output="false" returntype="Any" hint="This operation returns details of the specified shared IP group.">
		<cfargument name="groupID"	required="true"		type="string" 								hint="The ID of the specific IP group." />
		<cfargument name="format"	required="false"	type="string" default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().getSharedIPGroupDetails(getAuthResponse(),arguments.groupID,arguments.format) />
	</cffunction>
	
	<cffunction name="deleteSharedIPGroup" access="public" output="false" returntype="Any" hint="This operation deletes the specified shared IP group. This operation will ONLY succeed if 1) there are no active servers in the group (i.e. they have all been terminated) or 2) no servers in the group are actively sharing IPs.">
		<cfargument name="groupID"	required="true"		type="string" 								hint="The ID of the specific IP group." />
		<cfargument name="format"	required="false"	type="string" default="#getReturnFormat()#"	hint="The return format of the response. XML or JSON." />
		<cfreturn getServers().deleteSharedIPGroup(getAuthResponse(),arguments.groupID,arguments.format) />
	</cffunction>
	
</cfcomponent>