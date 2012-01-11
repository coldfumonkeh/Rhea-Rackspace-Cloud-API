<!---
Filename: servers.cfc
Creation Date: 15/February/2010
Original Author: Matt Gifford
Revision: $Rev$
$LastChangedBy$
$LastChangedDate$
Description:
--->
<cfcomponent displayname="servers" output="false" hint="I am the servers cfc for the cloud servers api" extends="cloudUtils">

	<cfset variables.instance = structNew() />

	<cffunction name="init" access="public" output="false" hint="I am the constructor method" returntype="com.fuzzyorange.servers">
		<cfargument name="username" 	required="true" 	type="string" 								hint="The cloud files account username" />
		<cfargument name="apiKey" 		required="true" 	type="string" 								hint="The cloud files account API key" />
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="format"		required="true"		type="string"								hint="The return format of responses from the cloud server API. XML or JSON." />
			<cfscript>
				variables.instance.userName 	= arguments.userName;
				variables.instance.apiKey 		= arguments.apiKey;
				variables.instance.format		= arguments.format;
				variables.instance.xmlNS		= 'http://docs.rackspacecloud.com/servers/api/v1.0';
				super.init();
			</cfscript>
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getxmlNS" access="public" output="false" returntype="String" hint="I return the xml namespace attribute used in the POST Server calls">
		<cfreturn variables.instance.xmlNS />
	</cffunction>
	
	<!--- SERVER RELATED METHODS --->
	<cffunction name="listServers" access="public" output="false" returntype="Any" hint="">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 					hint="The authResponse bean" />
		<cfargument name="showDetail" 	required="false" 	type="boolean" 								default="false" hint="A boolean value. If TRUE, will return all details for the servers, not just IDs and names" />
		<cfargument name="format"		required="true"		type="string" 												hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/servers';
					if(arguments.showDetail) {
						strURL = strURL & '/detail.' & arguments.format;
					} else {
						strURL = strURL & '.' & arguments.format;
					}
					response	= makeAPICall(remoteURL=strURL,
									remoteMethod='GET',
									authToken=arguments.authResponse.getAuthToken());			
					response	= handleResponseOutput(response.response,arguments.format);              
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="createServer" access="public" output="false" returntype="Any" hint="This operation asynchronously provisions a new server. The progress of this operation depends on several factors including location of the requested image, network i/o, host load, and the selected flavor.">
		<cfargument name="authResponse"	required="true" type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="name"			required="true"	type="string" 								hint="I am the name for the new server" />
		<cfargument name="flavorID" 	required="true" type="string" 								hint="I am the ID of a specific flavor you wish to use to create the server." />
		<cfargument name="imageID"		required="true" type="string" 								hint="I am the ID of a specific image you wish to use to create the server." />
		<cfargument name="format"		required="true"	type="string" 								hint="The return format of responses from the cloud server API. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<!--- run a switch on the format to generate the required body content --->
				<cfswitch expression="#arguments.format#">
				<cfcase value="xml">
					<cfoutput>
					<cfsavecontent variable="strRequest">
					<server xmlns="#getxmlNS()#" 
						name="#arguments.name#" 
						imageId="#arguments.imageID#" 
						flavorId="#arguments.flavorID#" />
					</cfsavecontent>
					</cfoutput>
				</cfcase>
				<cfcase value="json">
					<cfset strRequest = '{"server" : {
							"name" 		: 	"#arguments.name#",
							"imageId"	:	#arguments.imageID#,
							"flavorId"	:	#arguments.flavorID#
							}}' />
				</cfcase>
				</cfswitch>		
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/servers';
					strURL 		= strURL & '.' & arguments.format;			
					response	= makeAPICallWithBody(remoteURL=strURL,
											remoteMethod='POST',
											postBody=strRequest,
											authToken=arguments.authResponse.getAuthToken(),
											format=arguments.format);
					response	= handleResponseOutput(response.response,arguments.format);           	                
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="getServerDetails" access="public" output="false" returntype="Any" hint="I will return the details of a specific server.">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="serverID" 	required="true" 	type="string" 								hint="I am the ID of a specific server you wish to obtain details for." />
		<cfargument name="format"		required="true"		type="string" 								hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/servers/' 
										& arguments.serverID & '.' & arguments.format;
					response	= makeAPICall(remoteURL=strURL,
									remoteMethod='GET',
									authToken=arguments.authResponse.getAuthToken());	
					response	= handleResponseOutput(response.response,arguments.format);             
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="updateServerNamePassword" access="public" output="false" returntype="Any" hint="This operation allows you to update the name of the server and/or change the administrative password. This operation changes the name of the server in the Cloud Servers system and does not change the server host name itself.">
		<cfargument name="authResponse"		required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="serverID" 		required="true" 	type="string" 								hint="I am the ID of a specific server you wish to obtain details for." />
		<cfargument name="serverName" 		required="false" 	type="string" 								hint="I am the new name for the server image." />
		<cfargument name="adminPassword" 	required="false" 	type="string" 								hint="I am the new admin password." />
		<cfargument name="format"			required="false"	type="string" 								hint="The return format of the response. XML or JSON." />
			<cfset var response 	= '' />
			<cfset var strURL 		= '' />
				<!--- run a switch on the format to generate the required body content --->
				<cfswitch expression="#arguments.format#">
				<cfcase value="xml">
					<cfoutput>
					<cfsavecontent variable="strRequest">
					<server xmlns="#getxmlNS()#" 
						<cfif len(arguments.serverName)>name="#arguments.serverName#"</cfif> 
						<cfif len(arguments.adminPassword)>adminPass="#arguments.adminPassword#"</cfif> />
					</cfsavecontent>
					</cfoutput>
				</cfcase>
				<cfcase value="json">
					<cfset strRequest = '{"server" : {' />
					<cfif len(arguments.serverName)>
						<cfset strRequest = strRequest & '"name" : "' & arguments.serverName & '"' />
						<cfif len(arguments.adminPassword)>
							<cfset strRequest = strRequest & ',' />
						</cfif>
					</cfif>
					<cfif len(arguments.adminPassword)>
						<cfset strRequest = strRequest & '"adminPass" : "' & arguments.adminPassword & '"' />
					</cfif>	
					<cfset strRequest = strRequest & '}}' />
				</cfcase>
				</cfswitch>	
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/servers/' & arguments.serverID;
					strURL 		= strURL & '.' & arguments.format;
					response	= makeAPICallWithBody(remoteURL=strURL,
											remoteMethod='PUT',
											postBody=strRequest,
											authToken=arguments.authResponse.getAuthToken(),
											format=arguments.format);
					response	= handleResponseOutput(response.response,arguments.format);           	                
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="deleteServer" access="public" output="false" returntype="Any" hint="This operation deletes a cloud server instance from the system.">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="serverID" 	required="true" 	type="string" 								hint="I am the ID of a specific server you wish to obtain delete." />
		<cfargument name="format"		required="true"		type="string" 								hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/servers/' 
										& arguments.serverID & '.' & arguments.format;
					response	= makeAPICall(remoteURL=strURL,
									remoteMethod='DELETE',
									authToken=arguments.authResponse.getAuthToken());	
					response	= handleResponseOutput(response.response,arguments.format);             
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<!--- SERVER ACTIONS --->
	<cffunction name="rebootServer" access="public" output="false" returntype="Any" hint="The reboot function allows for either a soft or hard reboot of a server. With a soft reboot (SOFT), the operating system is signaled to restart, which allows for a graceful shutdown of all processes. A hard reboot (HARD) is the equivalent of power cycling the server.">
		<cfargument name="authResponse"	required="true" type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="serverID" 	required="true" type="string" 								hint="I am the ID of a specific server you wish to reboot." />
		<cfargument name="rebootType"	required="true"	type="string" 								hint="The type of reboot to perform on the server. SOFT or HARD." />
		<cfargument name="format"		required="true"	type="string" 								hint="The return format of the response. XML or JSON." />		
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<!--- run a switch on the format to generate the required body content --->
				<cfswitch expression="#arguments.format#">
				<cfcase value="xml">
					<cfoutput>
					<cfsavecontent variable="strRequest">
					<reboot xmlns="#getxmlNS()#" type="#uCase(arguments.rebootType)#"/>
					</cfsavecontent>
					</cfoutput>
				</cfcase>
				<cfcase value="json">
					<cfset strRequest = '{
								"reboot" : {
								"type" : "#uCase(arguments.rebootType)#"
								}}' />
				</cfcase>
				</cfswitch>		
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/servers/' 
										& arguments.serverID & '/action';
					strURL 		= strURL & '.' & arguments.format;
					response	= makeAPICallWithBody(remoteURL=strURL,
											remoteMethod='POST',
											postBody=strRequest,
											authToken=arguments.authResponse.getAuthToken(),
											format=arguments.format);
					response	= handleResponseOutput(response.response,arguments.format);           	                
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="rebuildServer" access="public" output="false" returntype="Any" hint="The rebuild function removes all data on the server and replaces it with the specified image. serverId and IP addresses will remain the same.">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 		hint="The authResponse bean" />
		<cfargument name="serverID" 	required="true" 	type="string" 									hint="I am the ID of a specific server you wish to rebuild." />
		<cfargument name="imageID"		required="true"		type="string" 									hint="The ID of the specific image you wish to use to rebuild the server." />
		<cfargument name="format"		required="false"	type="string"									hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<!--- run a switch on the format to generate the required body content --->
				<cfswitch expression="#arguments.format#">
				<cfcase value="xml">
					<cfoutput>
					<cfsavecontent variable="strRequest">
					<reboot xmlns="#getxmlNS()#" imageId="#arguments.imageID#" />
					</cfsavecontent>
					</cfoutput>
				</cfcase>
				<cfcase value="json">
					<cfset strRequest = '{
								"rebuild" : {
								"imageId" : #arguments.imageID#
								}}' />
				</cfcase>
				</cfswitch>			
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/servers/' 
										& arguments.serverID & '/action';
					strURL 		= strURL & '.' & arguments.format;
					response	= makeAPICallWithBody(remoteURL=strURL,
											remoteMethod='POST',
											postBody=strRequest,
											authToken=arguments.authResponse.getAuthToken(),
											format=arguments.format);
					response	= handleResponseOutput(response.response,arguments.format);           	                
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="resizeServer" access="public" output="false" returntype="Any" hint="The resize function converts an existing server to a different flavor, in essence, scaling the server up or down. The original server is saved for a period of time to allow rollback if there is a problem. All resizes should be tested and explicitly confirmed, at which time the original server is removed. All resizes are automatically confirmed after 24 hours if they are not explicitly confirmed or reverted.">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="serverID" 	required="true" 	type="string" 								hint="I am the ID of a specific server you wish to resize." />
		<cfargument name="flavorID" 	required="true" 	type="string" 								hint="I am the ID of a specific flavour you wish to use." />
		<cfargument name="format"		required="false"	type="string"								hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<!--- run a switch on the format to generate the required body content --->
				<cfswitch expression="#arguments.format#">
				<cfcase value="xml">
					<cfoutput>
					<cfsavecontent variable="strRequest">
					<resize xmlns="#getxmlNS()#" flavorId=="#arguments.flavorID#" />
					</cfsavecontent>
					</cfoutput>
				</cfcase>
				<cfcase value="json">
					<cfset strRequest = '{
							"resize" 	: {
							"flavorId" 	: #arguments.flavorID#
							}}' />
				</cfcase>
				</cfswitch>
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/servers/' 
										& arguments.serverID & '/action';
					strURL 		= strURL & '.' & arguments.format;
					response	= makeAPICallWithBody(remoteURL=strURL,
											remoteMethod='POST',
											postBody=strRequest,
											authToken=arguments.authResponse.getAuthToken(),
											format=arguments.format);
					response	= handleResponseOutput(response.response,arguments.format);           	                
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="confirmResize" access="public" output="false" returntype="Any" hint="During a resize operation, the original server is saved for a period of time to allow roll back if there is a problem. Once the newly resized server is tested and has been confirmed to be functioning properly, use this operation to confirm the resize. After confirmation, the original server is removed and cannot be rolled back to. All resizes are automatically confirmed after 24 hours if they are not explicitly confirmed or reverted.">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="serverID" 	required="true" 	type="string" 								hint="I am the ID of a specific server you wish to confirm." />
		<cfargument name="format"		required="false"	type="string" 								hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<!--- run a switch on the format to generate the required body content --->
				<cfswitch expression="#arguments.format#">
				<cfcase value="xml">
					<cfoutput>
					<cfsavecontent variable="strRequest">
					<confirmResize xmlns="#getxmlNS()#" />
					</cfsavecontent>
					</cfoutput>
				</cfcase>
				<cfcase value="json">
					<cfset strRequest = '{
							"confirmResize" 	: {
							}}' />
				</cfcase>
				</cfswitch>
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/servers/' 
										& arguments.serverID & '/action';
					strURL 		= strURL & '.' & arguments.format;
					response	= makeAPICallWithBody(remoteURL=strURL,
											remoteMethod='POST',
											postBody=strRequest,
											authToken=arguments.authResponse.getAuthToken(),
											format=arguments.format);
					response	= handleResponseOutput(response.response,arguments.format);           	                
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="revertResize" access="public" output="false" returntype="Any" hint="During a resize operation, the original server is saved for a period of time to allow for roll back if there is a problem. If you determine there is a problem with a newly resized server, use this operation to revert the resize and roll back to the original server. All resizes are automatically confirmed after 24 hours if they have not already been confirmed explicitly or reverted.">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="serverID" 	required="true" 	type="string" 								hint="I am the ID of a specific server you wish to confirm." />
		<cfargument name="format"		required="false"	type="string" 								hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<!--- run a switch on the format to generate the required body content --->
				<cfswitch expression="#arguments.format#">
				<cfcase value="xml">
					<cfoutput>
					<cfsavecontent variable="strRequest">
					<revertResize xmlns="#getxmlNS()#" />
					</cfsavecontent>
					</cfoutput>
				</cfcase>
				<cfcase value="json">
					<cfset strRequest = '{
							"revertResize" 	: {
							}}' />
				</cfcase>
				</cfswitch>
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/servers/' 
										& arguments.serverID & '/action';
					strURL 		= strURL & '.' & arguments.format;
					response	= makeAPICallWithBody(remoteURL=strURL,
											remoteMethod='POST',
											postBody=strRequest,
											authToken=arguments.authResponse.getAuthToken(),
											format=arguments.format);
					response	= handleResponseOutput(response.response,arguments.format);           	                
                </cfscript>
		<cfreturn response />
	</cffunction>

	<!--- FLAVOR RELATED METHODS --->
	<cffunction name="listFlavors" access="public" output="false" returntype="Any" hint="">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 					hint="The authResponse bean" />
		<cfargument name="showDetail" 	required="false" 	type="boolean" 								default="false" hint="A boolean value. If TRUE, will return all details for the servers, not just IDs and names" />
		<cfargument name="format"		required="true"		type="string" 												hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/flavors';
					if(arguments.showDetail) {
						strURL = strURL & '/detail.' & arguments.format;
					} else {
						strURL = strURL & '.' & arguments.format;
					}
					response	= makeAPICall(remoteURL=strURL,
									remoteMethod='GET',
									authToken=arguments.authResponse.getAuthToken());			
					response	= handleResponseOutput(response.response,arguments.format);              
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="getFlavorDetails" access="public" output="false" returntype="Any" hint="I will return the details of a specific flavor.">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="flavorID" 	required="true" 	type="string" 								hint="I am the ID of a specific flavor you wish to obtain details for." />
		<cfargument name="format"		required="true"		type="string" 								hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/flavors/' 
										& arguments.flavorID & '.' & arguments.format;
					response	= makeAPICall(remoteURL=strURL,
									remoteMethod='GET',
									authToken=arguments.authResponse.getAuthToken());	
					response	= handleResponseOutput(response.response,arguments.format);              
                </cfscript>
		<cfreturn response />
	</cffunction>

	
	<!--- IMAGE RELATED METHODS --->
	<cffunction name="listImages" access="public" output="false" returntype="Any" hint="An image is a collection of files you use to create or rebuild a server. Rackspace provides pre-built OS images by default. You may also create custom images.">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 					hint="The authResponse bean" />
		<cfargument name="showDetail" 	required="false" 	type="boolean" 								default="false" hint="If TRUE, will return all details for the images, not just IDs and names" />
		<cfargument name="format"		required="true"		type="string" 												hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/images';
					if(arguments.showDetail) {
						strURL 	= strURL & '/detail.' & arguments.format;
					} else {
						strURL 	= strURL & '.' & arguments.format;
					}
					response	= makeAPICall(remoteURL=strURL,
									remoteMethod='GET',
									authToken=arguments.authResponse.getAuthToken());			
					response	= handleResponseOutput(response.response,arguments.format);              
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="createImage" access="public" output="false" returntype="Any" hint="This operation creates a new image for the given server ID. Once complete, a new image will be available that can be used to rebuild or create servers.">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 		hint="The authResponse bean" />
		<cfargument name="serverID" 	required="true" 	type="string" 									hint="I am the ID of a specific server you wish to create an image of." />
		<cfargument name="imageName"	required="false"	type="string" 									hint="The name to provide for the created image." />
		<cfargument name="format"		required="true"		type="string"									hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
			<cfset var stuResponse	= structNew() />	
				<!--- run a switch on the format to generate the required body content --->
				<cfswitch expression="#arguments.format#">
				<cfcase value="xml">
					<cfoutput>
					<cfsavecontent variable="strRequest">
						<image xmlns="#getxmlNS()#" 
							name="#arguments.imageName#" 
							serverId="#arguments.serverID#" />
					</cfsavecontent>
					</cfoutput>
				</cfcase>
				<cfcase value="json">
					<cfset strRequest = '{
							"image" : {
							"serverId" : #arguments.serverID#,
							"name" : "#arguments.imageName#"
							}}' />
				</cfcase>
				</cfswitch>
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/images';
					response	= makeAPICallWithBody(remoteURL=strURL,
											remoteMethod='POST',
											postBody=strRequest,
											authToken=arguments.authResponse.getAuthToken(),
											format=arguments.format);
					response	= handleResponseOutput(response.response,arguments.format);           	                
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="getImageDetails" access="public" output="false" returntype="Any" hint="This operation returns details of the specified image.">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 		hint="The authResponse bean" />
		<cfargument name="imageID" 		required="true" 	type="string" 									hint="I am the ID of a specific image you wish to obtain details for." />
		<cfargument name="format"		required="true"		type="string" 									hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/images/' & arguments.imageID;	
					strURL 		= strURL & '.' & arguments.format;		
					response	= makeAPICall(remoteURL=strURL,
									remoteMethod='GET',
									authToken=arguments.authResponse.getAuthToken());	
					response	= handleResponseOutput(response.response,arguments.format);              
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="deleteImage" access="public" output="false" returntype="Any" hint="This operation deletes an image from the system.">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 		hint="The authResponse bean" />
		<cfargument name="imageID" 		required="true" 	type="string" 									hint="I am the ID of a specific image you wish to delete." />
		<cfargument name="format"		required="true"		type="string"									hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/images/' & arguments.imageID;	
					strURL 		= strURL & '.' & arguments.format;		
					response	= makeAPICall(remoteURL=strURL,
									remoteMethod='DELETE',
									authToken=arguments.authResponse.getAuthToken());	
					response	= handleResponseOutput(response.response,arguments.format);              
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<!--- ADDRESS RELATED METHODS --->
	<cffunction name="listServerAddresses" access="public" output="false" returntype="Any" hint="I will return details of all server addresses for a specific server.">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 					hint="The authResponse bean" />
		<cfargument name="serverID" 	required="true" 	type="string" 												hint="I am the ID of a specific server you wish to obtain addresses for." />
		<cfargument name="filterList"	required="false"	type="string"								default="ALL" 	hint="If set to ALL, will list all server addresses. Other options are PUBLIC or PRIVATE." />
		<cfargument name="format"		required="true"		type="string" 												hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<cfset strListFilter = 'ALL,PUBLIC,PRIVATE' />
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/servers/' 
										& arguments.serverID & '/ips';	
					if(ListContainsNoCase(strListFilter, arguments.filterList, ',') && arguments.filterList != 'ALL') {
						strURL = strURL & '/' & arguments.filterList & '.' &  arguments.format;
					} else {
						strURL = strURL & '.' & arguments.format;
					}			
					response	= makeAPICall(remoteURL=strURL,
									remoteMethod='GET',
									authToken=arguments.authResponse.getAuthToken());	
					response	= handleResponseOutput(response.response,arguments.format);              
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<!--- BACKUP RELATED METHODS --->
	<cffunction name="listSchedules" access="public" output="false" returntype="Any" hint="I will return a list of the backup schedules for the specified server">
		<cfargument name="authResponse"	required="true" type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="serverID" 	required="true" type="string" 								hint="I am the ID of a specific server you wish to obtain details for." />
		<cfargument name="format"		required="true"	type="string" 								hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/servers/' 
										& arguments.serverID & '/backup_schedule';	
					strURL 		= strURL & '.' & arguments.format;					
					response	= makeAPICall(remoteURL=strURL,
									remoteMethod='GET',
									authToken=arguments.authResponse.getAuthToken());	
					response	= handleResponseOutput(response.response,arguments.format);          
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="createUpdateSchedule" access="public" output="false" returntype="Any" hint="I enable/update the backup schedule for the specified server.">
		<cfargument name="authResponse"	required="true" type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="serverID" 	required="true" type="String" 								hint="I am the ID of a specific server you wish to obtain details for." />
		<cfargument name="enabled"		required="true"	type="boolean" 								hint="Boolean value to set if the backup schedule is enabled." />
		<cfargument name="weekly"		required="true"	type="String"								hint="The weekly backup schedule value; eg THURSDAY" />
		<cfargument name="daily"		required="true"	type="String"								hint="The daily backup schedule value; eg H_0200_0400" />
		<cfargument name="format"		required="true"	type="String" 								hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<!--- run a switch on the format to generate the required body content --->
				<cfswitch expression="#arguments.format#">
				<cfcase value="xml">
					<cfoutput>
					<cfsavecontent variable="strRequest">
					<backupSchedule xmlns="#getxmlNS()#" 
							enabled="#arguments.enabled#" 
							weekly="#uCase(arguments.weekly)#"
							daily="#arguments.daily#" />
					</cfsavecontent>
					</cfoutput>
				</cfcase>
				<cfcase value="json">
					<cfset strRequest = '{"backupSchedule" : {
							"enabled" : #arguments.enabled#,
							"weekly" : "#uCase(arguments.weekly)#",
							"daily" : "#arguments.daily#"}}' />
				</cfcase>
				</cfswitch>	
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/servers/' 
										& arguments.serverID & '/backup_schedule';	
					strURL 		= strURL & '.' & arguments.format;
					response	= makeAPICallWithBody(remoteURL=strURL,
											remoteMethod='POST',
											postBody=strRequest,
											authToken=arguments.authResponse.getAuthToken(),
											format=arguments.format);
					response	= handleResponseOutput(response.response,arguments.format);           	                
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="disableSchedule" access="public" output="false" returntype="Any" hint="This operation disables the backup schedule for the specified server.">
		<cfargument name="authResponse"	required="true" type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="serverID" 	required="true" type="string" 								hint="I am the ID of a specific server you wish to obtain details for." />
		<cfargument name="format"		required="true"	type="string" 								hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/servers/' 
										& arguments.serverID & '/backup_schedule';	
					strURL 		= strURL & '.' & arguments.format;					
					response	= makeAPICall(remoteURL=strURL,
									remoteMethod='DELETE',
									authToken=arguments.authResponse.getAuthToken());	
					response	= handleResponseOutput(response.response,arguments.format);          
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	
	<!--- SHARED IP GROUPS RELATED METHODS --->
	<cffunction name="listSharedIPGroups" access="public" output="false" returntype="Any" hint="This operation provides a list of shared IP groups associated with your account.">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 					hint="The authResponse bean" />
		<cfargument name="showDetail" 	required="true" 	type="boolean" 									 			hint="If TRUE, will return all details for the shared IP groups, not just IDs and names" />
		<cfargument name="format"		required="true"		type="string" 												hint="The return format of the response. XML or JSON." />
			<cfset var response 	= '' />
			<cfset var strURL 		= '' />
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/shared_ip_groups';
					if(arguments.showDetail) {
						strURL 	= strURL & '/detail.' & arguments.format;
					} else {
						strURL 	= strURL & '.' & arguments.format;
					}
					response	= makeAPICall(remoteURL=strURL,
									remoteMethod='GET',
									authToken=arguments.authResponse.getAuthToken());			
					response	= handleResponseOutput(response.response,arguments.format);              
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="createSharedIPGroup" access="public" output="false" returntype="Any" hint="This operation creates a new shared IP group. Please note, all responses to requests for shared_ip_groups return an array of servers. However, on a create request, the shared IP group can be created empty or can be initially populated with a single server. Submitting a create request with a sharedIpGroup that contains an array of servers will generate a badRequest (400) fault.">
		<cfargument name="authResponse"	required="true" type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="ipgroupName"	required="true"	type="string" 								hint="The name to apply to the new IP group." />
		<cfargument name="serverID" 	required="true" type="string" 								hint="I am the ID of a specific server you wish to obtain details for." />
		<cfargument name="format"		required="true"	type="string" 								hint="The return format of the response. XML or JSON." />
			<cfset var response = '' />
			<cfset var strURL	= '' />			
				<!--- run a switch on the format to generate the required body content --->
				<cfswitch expression="#arguments.format#">
				<cfcase value="xml">
					<cfoutput>
					<cfsavecontent variable="strRequest">
					<sharedIpGroup xmlns="#getxmlNS()#"
						name="#arguments.ipgroupName#">
						<cfif listLen(arguments.serverID) GT 1>
							<servers>
							<cfloop from="1" to="#listLen(arguments.serverID)#" index="i">
								<server id="#listGetAt(arguments.serverID, i)#" />
							</cfloop>
							</servers>
						<cfelse>
							<server id="#arguments.serverID#" />
						</cfif>
					</sharedIpGroup>
					</cfsavecontent>
					</cfoutput>
				</cfcase>
				<cfcase value="json">
					<cfset strRequest = '{
						"sharedIpGroup" : {
						"name" : "#arguments.ipgroupName#",
						"server" : #arguments.serverID#
						}}' />
				</cfcase>
				</cfswitch>
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/shared_ip_groups'; 
					strURL 		= strURL & '.' & arguments.format;
					response	= makeAPICallWithBody(remoteURL=strURL,
											remoteMethod='POST',
											postBody=strRequest,
											authToken=arguments.authResponse.getAuthToken(),
											format=arguments.format);
					response	= handleResponseOutput(response.response,arguments.format);           	                
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="getSharedIPGroupDetails" access="public" output="false" returntype="Any" hint="This operation returns details of the specified shared IP group.">
		<cfargument name="authResponse"	required="true" type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="groupID"		required="true"	type="string" 								hint="The ID of the specific IP group." />
		<cfargument name="format"		required="true"	type="string" 								hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/shared_ip_groups/';
					strURL 		= strURL & arguments.groupID & '.' & arguments.format;
					response	= makeAPICall(remoteURL=strURL,
									remoteMethod='GET',
									authToken=arguments.authResponse.getAuthToken());			
					response	= handleResponseOutput(response.response,arguments.format);              
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="deleteSharedIPGroup" access="public" output="false" returntype="Any" hint="This operation deletes the specified shared IP group. This operation will ONLY succeed if 1) there are no active servers in the group (i.e. they have all been terminated) or 2) no servers in the group are actively sharing IPs.">
		<cfargument name="authResponse"	required="true" type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="groupID"		required="true"	type="string" 								hint="The ID of the specific IP group." />
		<cfargument name="format"		required="true"	type="string" 								hint="The return format of the response. XML or JSON." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getServerManagementURL() & '/shared_ip_groups/' & arguments.groupID;	
					strURL 		= strURL & '.' & arguments.format;					
					response	= makeAPICall(remoteURL=strURL,
									remoteMethod='DELETE',
									authToken=arguments.authResponse.getAuthToken());	
					response	= handleResponseOutput(response.response,arguments.format);          
                </cfscript>
		<cfreturn response />
	</cffunction>
	
</cfcomponent>