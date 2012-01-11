<!---
Filename: $${CURRENTFILE}
Creation Date: $${DAYOFMONTH}/$${MONTH}/$${YEAR}
Original Author: $${author}
Revision: $Rev: 8 $
$LastChangedBy: matt.gifford $
$LastChangedDate: 2010-02-24 23:32:03 +0000 (Wed, 24 Feb 2010) $
Description:
$${description}
--->
<cfcomponent displayname="account" output="false" hint="I am the account cfc for the cloud files api" extends="cloudUtils">

	<cfset variables.instance = structNew() />

	<cffunction name="init" access="public" output="false" hint="I am the constructor method" returntype="com.fuzzyorange.account">
		<cfargument name="username" 	required="true" 	type="string" 	hint="The cloud files account username" />
		<cfargument name="apiKey" 		required="true" 	type="string" 	hint="The cloud files account API key" />
			<cfscript>
				variables.instance.userName 	= arguments.userName;
				variables.instance.apiKey 		= arguments.apiKey;
				super.init();
			</cfscript>
		<cfreturn this />
	</cffunction>
	
	<cffunction name="authenticate" access="public" output="false" returntype="any" hint="Use this method to test if supplied user credentials are valid.">
		<cfargument name="username" 	required="true" 	type="string" 	hint="The cloud files account username" />
		<cfargument name="apiKey" 		required="true" 	type="string" 	hint="The cloud files account API key" />
			<cfset var cfhttp 			= "" />
			<cfset var boolReturn 		= false />
			<cfset var stuResponse		= StructNew() />
			<cfset var stuStatusCheck 	= StructNew() />
				<cfhttp url="#getauthURL()##getVersion()#" method="get" useragent="cloudFiles">
					<cfhttpparam name="X-Auth-User" type="header" value="#username#" />
					<cfhttpparam name="X-Auth-Key" 	type="header" value="#apiKey#" />
				</cfhttp>
				<cfscript>
					stuStatusCheck = checkStatusCode(cfhttp.Statuscode);
					boolReturn = stuStatusCheck.success;
					if(boolReturn) {
						stuResponse.CDNManagementURL 	= cfhttp.ResponseHeader['X-CDN-Management-Url'];
						stuResponse.ServerManagementURL = cfhttp.ResponseHeader['X-Server-Management-Url'];
						stuResponse.StorageURL 			= cfhttp.ResponseHeader['X-Storage-Url'];
						stuResponse.AuthToken 			= cfhttp.ResponseHeader['X-Auth-Token'];
						stuResponse.StorageToken 		= cfhttp.ResponseHeader['X-Storage-Token'];
						stuResponse.success				= stuStatusCheck.success;
					} else {
						stuResponse = stuStatusCheck; 
					}
                </cfscript>
		<cfreturn stuResponse />	
	</cffunction>

</cfcomponent>