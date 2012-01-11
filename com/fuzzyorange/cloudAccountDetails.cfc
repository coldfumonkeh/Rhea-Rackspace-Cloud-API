<!---
Filename: $${CURRENTFILE}
Creation Date: $${DAYOFMONTH}/$${MONTH}/$${YEAR}
Original Author: $${author}
Revision: $Rev: 7 $
$LastChangedBy: matt.gifford $
$LastChangedDate: 2010-02-11 18:27:41 +0000 (Thu, 11 Feb 2010) $
Description:
$${description}
--->
<cfcomponent displayname="cloudAccountDetails" output="false" hint="I am the cloudAccountDetails component, and I contain the account username and API key">

	<cfset variables.instance = structNew() />
	
	<cffunction name="init" access="public" output="false" returntype="com.fuzzyorange.cloudAccountDetails" hint="I am the constructor method for the cloudAccountDetails class">
		<cfargument name="username" 	required="true" 	type="string" 	hint="The cloud files account username" />
		<cfargument name="apiKey" 		required="true" 	type="string" 	hint="The cloud files account API key" />
			<cfscript>
				setuserName(arguments.username);
				setapiKey(arguments.apiKey);
			</cfscript>
		<cfreturn this />
	</cffunction>
	
	<!--- MUTATORS --->
	<cffunction name="setuserName" access="private" output="false" hint="I set the cloud files account username">
		<cfargument name="username" 	required="true" 	type="string" 	hint="The cloud files account username" />
		<cfset variables.instance.username = arguments.username />
	</cffunction>
	
	<cffunction name="setapiKey" access="private" output="false" hint="I set the cloud files account API key">
		<cfargument name="apiKey" 		required="true" 	type="string" 	hint="The cloud files account API key" />
		<cfset variables.instance.apiKey = arguments.apiKey />
	</cffunction>
	
	<!--- ACCESSORS --->
	<cffunction name="getuserName" access="public" output="false" hint="I get the twitter account username">
		<cfreturn variables.instance.username />
	</cffunction>
	
	<cffunction name="getapiKey" access="public" output="false" hint="I get the twitter account password">
		<cfreturn variables.instance.apiKey />
	</cffunction>

</cfcomponent>