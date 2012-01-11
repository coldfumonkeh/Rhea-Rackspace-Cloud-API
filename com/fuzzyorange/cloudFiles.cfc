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
<cfcomponent displayname="cloudFiles" output="false">

	<cfset variables.instance = structNew() />

	<cffunction name="init" access="public" output="false" returntype="com.fuzzyorange.cloudFiles">
		<cfargument name="cloudAccountDetails" 	required="false" 	type="com.fuzzyorange.cloudAccountDetails" 	hint="The cloud files account object" />
		<cfargument name="authResponse"			required="false" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="format"				required="true"		type="string" 								hint="The return format of responses from the cloud server API. XML or JSON." />
			<cfscript>
				setAccountDetails(arguments.cloudAccountDetails);
				setAuthResponse(arguments.authResponse);
				setReturnFormat(arguments.format);
				setStorage();
				setCDNAccount();
			</cfscript>	
		<cfreturn this />
	</cffunction>
	
	<!--- MUTATORS --->
	<cffunction name="setAccountDetails" access="private" output="false" hint="I set the cloud files API account details">
		<cfargument name="cloudAccountDetails" required="true" type="com.fuzzyorange.cloudAccountDetails" hint="The cloud files account object" />
		<cfset variables.instance.cloudAccountDetails = arguments.cloudAccountDetails />
	</cffunction>
		
	<cffunction name="setStorage" access="private" output="false" hint="I instantiate the storage cfc and load it into the variables.instance struct">
		<cfset variables.instance.storage = createObject('component', 'com.fuzzyorange.storage').init(getUserName(),getAPIKey()) />
	</cffunction>
	
	<cffunction name="setCDNAccount" access="private" output="false" hint="I instantiate the cdnaccount cfc and load it into the variables.instance struct">
		<cfset variables.instance.cdnaccount = createObject('component', 'com.fuzzyorange.cdnaccount').init(getUserName(),getAPIKey()) />
	</cffunction>
	
	<cffunction name="setAuthResponse" access="private" output="false" hint="I instantiate the AuthResponse cfc and load it into the variables.instance struct">
		<cfargument name="authResponse"			required="true" type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
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
	
	<cffunction name="getStorage" access="public" output="false" returntype="com.fuzzyorange.storage" hint="I get the cloud files storage component">
		<cfreturn variables.instance.storage />
	</cffunction>
	
	<cffunction name="getCDNAccount" access="public" output="false" returntype="com.fuzzyorange.cdnaccount" hint="I get the cloud files cdnaccount component">
		<cfreturn variables.instance.cdnaccount />
	</cffunction>
	
	<cffunction name="getAuthResponse" access="public" output="false" returntype="com.fuzzyorange.beans.authResponse" hint="I get the cloud files AuthResponse component">
		<cfreturn variables.instance.authresponse />
	</cffunction>
	
	<cffunction name="getReturnFormat" access="public" output="false" hint="I return the string value for the return response from the variables.instance struct">
		<cfreturn variables.instance.returnformat />
	</cffunction>
	
	<!--- PUBLIC METHODS --->
	
	<!--- STORAGE RELATED METHODS --->
	<cffunction name="getContainers" access="public" output="false" returntype="Any" hint="I return a list of storage Containers applied to the account.">
		<cfargument name="limit" 		required="false" 	type="string" 	default=""						hint="For an integer value N, limits the number of results to at most N values." />
		<cfargument name="marker" 		required="false" 	type="string" 	default=""						hint="Given a string value X, return Object names greater in value than the specified marker." />
		<cfargument name="format" 		required="false" 	type="string" 	default="#getReturnFormat()#"	hint="Specify either JSON or XML to return the respective serialized response." />
		<cfreturn getStorage().getContainers(getAuthResponse(),arguments.limit,arguments.marker,arguments.format) />
	</cffunction>
	
	<cffunction name="getAllContainerDetails" access="public" output="false" returntype="Any" hint="I determine the number of Containers within the account and the total bytes stored.">
		<cfargument name="format" 		required="false" 	type="string" 	default="#getReturnFormat()#"	hint="Specify either JSON or XML to return the respective serialized response." />
		<cfreturn getStorage().getAllContainerDetails(getAuthResponse(),arguments.format) />
	</cffunction>
	
	<!--- STORAGE CONTAINER SERVICES --->
	<cffunction name="getContainerDetails" access="public" output="false" returntype="Any" hint="I determine the number of Objects and total stored bytes within the Container">
		<cfargument name="containerName" 	required="true" 	type="string" 									hint="Name of the container you wish to create" />
		<cfargument name="format" 			required="false" 	type="string" 	default="#getReturnFormat()#"	hint="Specify either JSON or XML to return the respective serialized response." />
		<cfreturn getStorage().getContainerDetails(getAuthResponse(),arguments.containerName,arguments.format) />
	</cffunction>
	
	<cffunction name="createContainer" access="public" output="false" returntype="Any" hint="I create a Container.">
		<cfargument name="containerName" 	required="true" 	type="string" 									hint="Name of the container you wish to create" />
		<cfargument name="format" 			required="false" 	type="string" 	default="#getReturnFormat()#"	hint="Specify either JSON or XML to return the respective serialized response." />
		<cfreturn getStorage().createContainer(getAuthResponse(),arguments.containerName,arguments.format) />
	</cffunction>
	
	<cffunction name="deleteContainer" access="public" output="false" returntype="Any" hint="This method permanently removes a Container">
		<cfargument name="containerName" 	required="true" 	type="string" 									hint="Name of the container you wish to delete" />
		<cfargument name="format" 			required="false" 	type="string" 	default="#getReturnFormat()#"	hint="Specify either JSON or XML to return the respective serialized response." />
		<cfreturn getStorage().deleteContainer(getAuthResponse(),arguments.containerName,arguments.format) />
	</cffunction>
	
	<!--- STORAGE OBJECT SERVICES --->
	<cffunction name="getObjectsInContainer" access="public" output="false" returntype="Any" hint="I retrieve a list of Objects stored in the selected Container">
		<cfargument name="containerName" 	required="true" 	type="string" 									hint="Name of the container you wish to retrieve listings for." />
		<cfargument name="limit" 			required="false" 	type="string" 	default=""						hint="For an integer value N, limits the number of results to at most N values." />
		<cfargument name="marker" 			required="false" 	type="string" 	default=""						hint="Given a string value X, return Object names greater in value than the specified marker." />
		<cfargument name="prefix"			required="false"	type="string"	default=""						hint="For a string value X, causes the results to be limited to Object names beginning with the substring X." />
		<cfargument name="path"				required="false" 	type="string" 	default=""						hint="For a string value X, return the Object names nested in the pseudo path (assuming preconditions are met)" />		
		<cfargument name="format" 			required="false" 	type="string" 	default="#getReturnFormat()#"	hint="Specify either JSON or XML to return the respective serialized response." />
		<cfreturn getStorage().getObjectsInContainer(getAuthResponse(),arguments.containerName,arguments.limit,arguments.marker,arguments.prefix,arguments.path,arguments.format) />
	</cffunction>
	
	<cffunction name="getObjectMeta" access="public" output="false" returntype="Any" hint="I retrieve an Object's metadata">
		<cfargument name="containerName" 	required="true" 	type="string" 									hint="Name of the Container that contains the Object you wish to retrieve." />
		<cfargument name="objectName"		required="true" 	type="string"									hint="The name of the Object" />
		<cfargument name="format" 			required="false" 	type="string" 	default="#getReturnFormat()#"	hint="Specify either JSON or XML to return the respective serialized response." />
		<cfreturn getStorage().getObjectMeta(getAuthResponse(),arguments.containerName,arguments.objectName,arguments.format) />
	</cffunction>
	
	<cffunction name="putObject" access="public" output="false" returntype="Any" hint="I am used to write, or overwrite, an Object's metadata and content">
		<cfargument name="containerName" 	required="true" 	type="string"									hint="Name of the container you wish to place the object into." />
		<cfargument name="object"			required="true" 	type="Any"										hint="The Object data" />
		<cfargument name="format" 			required="false" 	type="string"	default="#getReturnFormat()#"	hint="Specify either JSON or XML to return the respective serialized response." />
		<cfreturn getStorage().putObject(getAuthResponse(),arguments.containerName,arguments.object,arguments.format) />
	</cffunction>
	
	<cffunction name="deleteObject" access="public" output="false" returntype="Any" hint="I permanently remove the specified Object from the storage system (metadata and data)">
		<cfargument name="containerName" 	required="true" 	type="string" 									hint="Name of the Container that contains the Object you wish to retrieve." />
		<cfargument name="objectName"		required="true" 	type="string"									hint="The name of the Object" />
		<cfargument name="format" 			required="false" 	type="string" 	default="#getReturnFormat()#"	hint="Specify either JSON or XML to return the respective serialized response." />
		<cfreturn getStorage().deleteObject(getAuthResponse(),arguments.containerName,arguments.objectName,arguments.format) />
	</cffunction>
	
	<!--- CDN RELATED METHODS --->
	<cffunction name="getCDNContainers" access="public" output="false" returntype="any" hint="I return a list of CDN-enabled Containers.">
		<cfargument name="limit" 		required="false" 	type="string" 	default=""						hint="For an integer value N, limits the number of results to at most N values." />
		<cfargument name="marker" 		required="false" 	type="string" 	default=""						hint="Given a string value X, return Object names greater in value than the specified marker." />
		<cfargument name="enabled_only"	required="false"	type="boolean"	default="true"  				hint="Set to 'true' to return only the CDN-enabled Containers" />
		<cfargument name="format" 		required="false" 	type="string" 	default="#getReturnFormat()#"	hint="Specify either JSON or XML to return the respective serialized response." />
		<cfreturn getCDNAccount().getContainers(getAuthResponse(),arguments.limit,arguments.marker,arguments.enabled_only,arguments.format) />
	</cffunction>
	
	<cffunction name="getCDNContainerAttributes" access="public" output="false" returntype="any" hint="I return the CDN attributes of the supplied CDN-enabled Container.">
		<cfargument name="containerName" 	required="true" 	type="string" 								hint="Name of the container you wish to retrieve data for." />
		<cfargument name="format" 			required="false" 	type="string" default="#getReturnFormat()#"	hint="Specify either JSON or XML to return the respective serialized response." />
		<cfreturn getCDNAccount().getContainerAttributes(getAuthResponse(),arguments.containerName,arguments.format) />
	</cffunction>
	
	<cffunction name="setCDNContainer" access="public" output="false" returntype="any" hint="I CDN-enable a Container and set it's attributes.">
		<cfargument name="containerName" 	required="true" 	type="string" 									hint="Name of the container you wish to enable" />
		<cfargument name="format" 			required="false" 	type="string" 	default="#getReturnFormat()#"	hint="Specify either JSON or XML to return the respective serialized response." />
		<cfreturn getCDNAccount().setCDNContainer(getAuthResponse(),arguments.containerName,arguments.format) />
	</cffunction>
	
	<cffunction name="setCDNContainerAttributes" access="public" output="false" returntype="any" hint="I am used to adjust the CDN attributes of the supplied CDN-enabled Container.">
		<cfargument name="containerName" 	required="true" 	type="string" 									hint="Name of the container you wish to edit the attributes of." />
		<cfargument name="format" 			required="false" 	type="string" 	default="#getReturnFormat()#"	hint="Specify either JSON or XML to return the respective serialized response." />
		<cfreturn getCDNAccount().setCDNContainerAttributes(getAuthResponse(),arguments.containerName,arguments.format) />
	</cffunction>
	
</cfcomponent>