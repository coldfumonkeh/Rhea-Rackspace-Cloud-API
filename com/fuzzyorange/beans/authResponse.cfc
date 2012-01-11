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
<cfcomponent displayname="authResponse" output="false" hint="A bean which models the authResponse form.">

	<cfproperty name="CDNManagementURL" 	default="" />
	<cfproperty name="ServerManagementURL" 	default="" />
	<cfproperty name="StorageURL" 			default="" />
	<cfproperty name="AuthToken" 			default="" />
	<cfproperty name="StorageToken" 		default="" />

	<cfset variables.instance = StructNew() />

	<cffunction name="init" access="public" returntype="com.fuzzyorange.beans.authResponse" output="false">
		<cfargument name="CDNManagementURL" 	type="string" required="false" default="" />
		<cfargument name="ServerManagementURL" 	type="string" required="false" default="" />
		<cfargument name="StorageURL" 			type="string" required="false" default="" />
		<cfargument name="AuthToken" 			type="string" required="false" default="" />
		<cfargument name="StorageToken" 		type="string" required="false" default="" />
			<cfset setCDNManagementURL(arguments.CDNManagementURL) />
			<cfset setServerManagementURL(arguments.ServerManagementURL) />
			<cfset setStorageURL(arguments.StorageURL) />
			<cfset setAuthToken(arguments.AuthToken) />
			<cfset setStorageToken(arguments.StorageToken) />
		<cfreturn this />
 	</cffunction>

	<!--- ACCESSORS / MUTATORS --->
	<cffunction name="setCDNManagementURL" access="public" returntype="void" output="false">
		<cfargument name="CDNManagementURL" type="string" required="true" />
		<cfset variables.instance.CDNManagementURL = arguments.CDNManagementURL />
	</cffunction>
	<cffunction name="getCDNManagementURL" access="public" returntype="string" output="false">
		<cfreturn variables.instance.CDNManagementURL />
	</cffunction>

	<cffunction name="setServerManagementURL" access="public" returntype="void" output="false">
		<cfargument name="ServerManagementURL" type="string" required="true" />
		<cfset variables.instance.ServerManagementURL = arguments.ServerManagementURL />
	</cffunction>
	<cffunction name="getServerManagementURL" access="public" returntype="string" output="false">
		<cfreturn variables.instance.ServerManagementURL />
	</cffunction>

	<cffunction name="setStorageURL" access="public" returntype="void" output="false">
		<cfargument name="StorageURL" type="string" required="true" />
		<cfset variables.instance.StorageURL = arguments.StorageURL />
	</cffunction>
	<cffunction name="getStorageURL" access="public" returntype="string" output="false">
		<cfreturn variables.instance.StorageURL />
	</cffunction>

	<cffunction name="setAuthToken" access="public" returntype="void" output="false">
		<cfargument name="AuthToken" type="string" required="true" />
		<cfset variables.instance.AuthToken = arguments.AuthToken />
	</cffunction>
	<cffunction name="getAuthToken" access="public" returntype="string" output="false">
		<cfreturn variables.instance.AuthToken />
	</cffunction>

	<cffunction name="setStorageToken" access="public" returntype="void" output="false">
		<cfargument name="StorageToken" type="string" required="true" />
		<cfset variables.instance.StorageToken = arguments.StorageToken />
	</cffunction>
	<cffunction name="getStorageToken" access="public" returntype="string" output="false">
		<cfreturn variables.instance.StorageToken />
	</cffunction>
	
	<!--- PUBLIC FUNCTIONS --->
	<cffunction name="getMemento" access="public"returntype="struct" output="false" >
		<cfreturn variables.instance />
	</cffunction>

</cfcomponent>