<!---
Filename: rackspaceCloud.cfc
Creation Date: 15/February/2010
Original Author: Matt Gifford
Revision: $Rev$
$LastChangedBy$
$LastChangedDate$
Description:
--->
<cfcomponent displayname="rackspaceCloud" output="false" hint="">

	<cfproperty name="cloudFiles" 	type="com.fuzzyorange.cloudFiles" 			default=""/>
	<cfproperty name="cloudServers" type="com.fuzzyorange.cloudServers"			default="" />
	<cfproperty name="authresponse" type="com.fuzzyorange.beans.authResponse" />

	<cfset variables.instance = structNew() />
	
	<cffunction name="init" access="public" output="false" returntype="com.fuzzyorange.rackspaceCloud" hint="I am the constructor method for the rackspaceCloud component">
		<cfargument name="username" 	required="true" 	type="string" 				hint="The cloud files account username" />
		<cfargument name="apiKey" 		required="true" 	type="string" 				hint="The cloud files account API key" />
		<cfargument name="format"		required="false"	type="string" default="xml"	hint="The return format of responses from the cloud server API. XML or JSON." />
			<cfscript>
				setAccountDetails(arguments.username,arguments.apiKey);
				setAccount();
				setReturnFormat(arguments.format);
				// run authentication
				authenticate(getUserName(),getAPIKey());
			</cfscript>
		<cfreturn this />
	</cffunction>
	
	<!--- MUTATORS --->
	<cffunction name="setAccountDetails" access="private" output="false" hint="I set the Rackspace cloud API account details">
		<cfargument name="username" 	required="true" 	type="string" 	hint="The cloud files account username" />
		<cfargument name="apiKey" 		required="true" 	type="string" 	hint="The cloud files account API key" />
		<cfset variables.instance.cloudAccountDetails = createObject('component', 'com.fuzzyorange.cloudAccountDetails').init(arguments.userName,arguments.apiKey) />
	</cffunction>
	
	<cffunction name="setCloudFiles" access="private" output="false" hint="I set the cloud files component">
		<cfargument name="cloudAccountDetails" 	required="true" type="com.fuzzyorange.cloudAccountDetails" 	hint="The cloud files account object" />
		<cfargument name="authResponse"			required="true" type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfset variables.instance.cloudFiles = createObject('component', 'com.fuzzyorange.cloudFiles').init(arguments.cloudAccountDetails,arguments.authResponse,getReturnFormat()) />
	</cffunction>
	
	<cffunction name="setCloudServers" access="private" output="false" hint="I set the cloud servers component">
		<cfargument name="cloudAccountDetails" 	required="true" 	type="com.fuzzyorange.cloudAccountDetails" 	hint="The cloud files account object" />
		<cfargument name="authResponse"			required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfset variables.instance.cloudServers = createObject('component', 'com.fuzzyorange.cloudServers').init(arguments.cloudAccountDetails,arguments.authResponse,getReturnFormat()) />
	</cffunction>
		
	<cffunction name="setAccount" access="private" output="false" hint="I instantiate the account cfc and load it into the variables.instance struct">
		<cfset variables.instance.account = createObject('component', 'com.fuzzyorange.account').init(getUserName(),getAPIKey()) />
	</cffunction>
	
	<cffunction name="setReturnFormat" access="private" output="false" hint="I set the string value for the return response in the variables.instance struct">
		<cfargument name="format"		required="false"	type="string"	hint="The return format of responses from the cloud server API. XML or JSON." />
		<cfset variables.instance.returnformat = arguments.format />
	</cffunction>
	
	<cffunction name="setAuthResponse" access="private" output="false" hint="I instantiate the AuthResponse cfc and load it into the variables.instance struct">
		<cfargument name="CDNManagementURL" 	type="string" required="false" default="" />
		<cfargument name="ServerManagementURL" 	type="string" required="false" default="" />
		<cfargument name="StorageURL" 			type="string" required="false" default="" />
		<cfargument name="AuthToken" 			type="string" required="false" default="" />
		<cfargument name="StorageToken" 		type="string" required="false" default="" />		
		<cfscript>
			variables.instance.authresponse = createObject('component', 'com.fuzzyorange.beans.authResponse').init(argumentCollection=arguments);
			setCloudFiles(getAccountDetails(),getAuthResponse());
			setCloudServers(getAccountDetails(),getAuthResponse(),getReturnFormat());    
        </cfscript>
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
		
	<cffunction name="getAccount" access="public" output="false" returntype="com.fuzzyorange.account" hint="I get the cloud files account component">
		<cfreturn variables.instance.account />
	</cffunction>
		
	<cffunction name="getAuthResponse" access="public" output="false" returntype="com.fuzzyorange.beans.authResponse" hint="I get the cloud files AuthResponse component">
		<cfreturn variables.instance.authresponse />
	</cffunction>
	
	<cffunction name="getReturnFormat" access="public" output="false" hint="I return the string value for the return response from the variables.instance struct">
		<cfreturn variables.instance.returnformat />
	</cffunction>
	
	<!--- PUBLIC METHODS --->
	
	<!--- load 'interfaces' for interaction --->
	<cffunction name="fileInterface" access="public" output="false" hint="I return the cloud files component">
		<cfreturn variables.instance.cloudFiles />
	</cffunction>
	
	<cffunction name="serverInterface" access="public" output="false" hint="I return the cloud servers component">
		<cfreturn variables.instance.cloudServers />
	</cffunction>
	
	<!--- AUTHENTICATION --->
	<cffunction name="authenticate" access="public" output="false" hint="I run client authentication using the supplied user name and api key">
		<cfargument name="username" required="true" default="#getUserName()#" 	type="string" 	hint="The cloud files account username" />
		<cfargument name="apiKey" 	required="true" default="#getAPIKey()#" 	type="string" 	hint="The cloud files account API key" />
			<cfset var response		= '' />
			<cfscript>
            	response = getAccount().authenticate(arguments.username,arguments.apiKey);
            </cfscript>
			<cfif response.success>
				<cfset setAuthResponse(argumentCollection=response) />
			<cfelse>
				<cfdump var="Authentication failed. Please check the User and API Key details are correct." />
				<cfabort />
			</cfif>
		<cfreturn response />
	</cffunction>

</cfcomponent>