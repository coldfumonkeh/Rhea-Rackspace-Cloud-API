<!---
Filename: $${CURRENTFILE}
Creation Date: $${DAYOFMONTH}/$${MONTH}/$${YEAR}
Original Author: $${author}
Revision: $Rev: 10 $
$LastChangedBy: matt.gifford $
$LastChangedDate: 2010-03-09 14:47:07 +0000 (Tue, 09 Mar 2010) $
Description:
$${description}
--->
<cfcomponent displayname="cdnaccount" output="false" hint="I am the cdnaccount cfc for the cloud files api" extends="cloudUtils">

	<cfset variables.instance = structNew() />

	<cffunction name="init" access="public" output="false" hint="I am the constructor method" returntype="com.fuzzyorange.cdnaccount">
		<cfargument name="username" 	required="true" 	type="string" 	hint="The cloud files account username" />
		<cfargument name="apiKey" 		required="true" 	type="string" 	hint="The cloud files account API key" />
			<cfscript>
				variables.instance.userName 	= arguments.userName;
				variables.instance.apiKey 		= arguments.apiKey;
				super.init();
			</cfscript>
		<cfreturn this />
	</cffunction>
	
	
	<cffunction name="getContainers" access="public" output="false" returntype="any" hint="I return a list of CDN-enabled Containers.">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 					hint="The authResponse bean" />
		<cfargument name="limit" 		required="false" 	type="string" 								default=""		hint="For an integer value N, limits the number of results to at most N values." />
		<cfargument name="marker" 		required="false" 	type="string" 								default=""		hint="Given a string value X, return Object names greater in value than the specified marker." />
		<cfargument name="enabled_only"	required="false"	type="boolean"								default="true"  hint="Set to 'true' to return only the CDN-enabled Containers" />
		<cfargument name="format" 		required="true" 	type="string" 												hint="Specify either JSON or XML to return the respective serialized response." />
			<cfset var response 	= "" />
			<cfset var stuArgs 		= StructNew() />
			<cfset var strURL		= '' />
			<cfset var strURLParam	= '?' />		
				<cfscript>
					strURL					= arguments.authResponse.getCDNManagementURL();
                	stuArgs.limit 			= arguments.limit;
					stuArgs.marker 			= arguments.marker; 
					stuArgs.format 			= arguments.format;
					stuArgs.enabled_only 	= arguments.enabled_only;
					strURL			= strURL & strURLParam & buildParamString(stuArgs);
					response 		= makeAPICall(remoteURL=strURL,
										remoteMethod='GET',
										authToken=arguments.authResponse.getAuthToken());
					response = handleResponseOutput(response.response, arguments.format);     
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="getContainerAttributes" access="public" output="false" returntype="any" hint="I return the CDN attributes of the supplied CDN-enabled Container.">
		<cfargument name="authResponse"		required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="containerName" 	required="true" 	type="string" 								hint="Name of the container you wish to query" />
		<cfargument name="format" 			required="true" 	type="string" 								hint="Specify either JSON or XML to return the respective serialized response." />
			<cfset var response 	= "" />
			<cfset var strURL		= '' />
				<cfscript>
                	strURL		= arguments.authResponse.getCDNManagementURL() & '/' & arguments.containerName;
					response 		= makeAPICall(remoteURL=strURL,
										remoteMethod='HEAD',
										authToken=arguments.authResponse.getAuthToken());
					response = handleResponseOutput(response.response , 'objectMeta');
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="setCDNContainer" access="public" output="false" returntype="any" hint="I CDN-enable a Container and set it's attributes.">
		<cfargument name="authResponse"		required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="containerName" 	required="true" 	type="string" 								hint="Name of the container you wish to enable" />
		<cfargument name="format" 			required="true" 	type="string" 								hint="Specify either JSON or XML to return the respective serialized response." />
			<cfset var response 	= "" />
			<cfset var strURL		= '' />
				<cfscript>
                	strURL		= arguments.authResponse.getCDNManagementURL() & '/' & arguments.containerName;
					response 		= makeAPICall(remoteURL=strURL,
										remoteMethod='PUT',
										authToken=arguments.authResponse.getAuthToken());
					response = handleResponseOutput(response.response , 'objectMeta');
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="setCDNContainerAttributes" access="public" output="false" returntype="any" hint="I am used to adjust the CDN attributes of the supplied CDN-enabled Container. This operation can be used to set a new TTL cache expiration or to enable/disable public sharing over the CDN. Keep in mind that if you have content currently cached in the CDN, setting your Container back to private will NOT purge the CDN cache; you will have to wait for the TTL to expire.">
		<cfargument name="authResponse"		required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="containerName" 	required="true" 	type="string" 								hint="Name of the container you wish to edit the attributes of." />
		<cfargument name="format" 			required="true" 	type="string" 								hint="Specify either JSON or XML to return the respective serialized response." />
			<cfset var response 	= "" />
			<cfset var strURL		= '' />
				<cfscript>
                	strURL		= arguments.authResponse.getCDNManagementURL() & '/' & arguments.containerName;
					response 		= makeAPICall(remoteURL=strURL,
										remoteMethod='POST',
										authToken=arguments.authResponse.getAuthToken());          
                	response = handleResponseOutput(response.response , 'objectMeta');
                </cfscript>
		<cfreturn response />
	</cffunction>

</cfcomponent>