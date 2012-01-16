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

<cfcomponent displayname="cloudUtils" output="false" hint="I am the cloudUtils class containing core variables, util methods and common functions">
	<cfset variables.META_HEADER_PREFIX = "X-Object-Meta-">
	<cfset variables.instance = StructNew() />
	
	<cffunction name="init" access="public" output="false" returntype="com.fuzzyorange.cloudUtils" hint="I am the constructor method for the cloudUtils class">
			<cfscript>
				variables.instance.version	= 'v1.0';
				variables.instance.authURL	= 'https://auth.api.rackspacecloud.com/';
			</cfscript>
		<cfreturn this />
	</cffunction>	
	
	<!--- ACCESSORS --->
	<cffunction name="getVersion" access="public" output="false" returntype="string" hint="I return the version value for use in the method calls.">
		<cfreturn variables.instance.version />
	</cffunction>
	
	<cffunction name="getauthURL" access="public" output="false" returntype="string" hint="I return the authorisation url for use in the method calls.">
		<cfreturn variables.instance.authURL />
	</cffunction>
	
	<!--- METHODS --->
	<cffunction name="buildParamString" access="public" output="false" returntype="String" hint="I loop through a struct to convert to query params for the URL.">
		<cfargument name="argScope" required="true" type="struct" hint="I am the struct containing the method params" />
			<cfset var strURLParam 	= '' />
			<cfloop collection="#arguments.argScope#" item="key">
				<cfif len(arguments.argScope[key])>
					<cfif listLen(strURLParam)>
						<cfset strURLParam = strURLParam & '&' />
					</cfif>	
					<cfset strURLParam = strURLParam & lcase(key) & '=' & arguments.argScope[key] />
				</cfif>
			</cfloop>
		<cfreturn strURLParam />
	</cffunction>
	
	<cffunction name="makeAPICall" access="package" output="false" returntype="Any" hint="I am the function that makes the cfhttp GET requests.">
		<cfargument name="remoteURL" 		required="true" 	type="string" 	hint="The URL string to make the call to." />
		<cfargument name="remoteMethod" 	required="true" 	type="string" 	hint="The method of the remote call." />
		<cfargument name="authToken" 		required="true" 	type="string" 	hint="The authorisation token for use in the remote call." />
		<cfargument name="postArgs"			required="false" 	type="struct" 	hint="A structure containing information relating to file uploads." />
			<cfset var cfhttp	 	= '' />
			<cfset var statusCheck	= '' />
			<cfset var stuResponse 	= StructNew() />	
			
				<cfhttp url="#arguments.remoteURL#"
					 method="#arguments.remoteMethod#"
					 useragent="cloudFiles">
					<cfhttpparam name="X-Auth-Token" type="header" value="#arguments.authToken#" />
					<!--- check for additional parameters to send (in this case for the file upload) --->
					<cfif structKeyExists(arguments, 'postArgs')>
						<cfif structKeyExists(arguments.postArgs, 'Content-Length')>
							<cfhttpparam name="Content-Length" type="header" value="#arguments.postArgs['Content-Length']#" />
						</cfif>
						<cfif structKeyExists(arguments.postArgs, 'Content-type')>
							<cfhttpparam name="Content-type" type="header" value="#arguments.postArgs['Content-type']#" />
						</cfif>
						<cfif structKeyExists(arguments.postArgs, 'file')>
							<cfhttpparam name="file" type="file" file="#arguments.postArgs['file']#" />
						</cfif>
						<cfif structKeyExists(arguments.postArgs, 'X-Copy-From')>
							<cfhttpparam name="X-Copy-From" type="header" value="#arguments.postArgs['X-Copy-From']#" />
						</cfif>
						<cfif structKeyExists(arguments.postArgs, 'metaData')>
							<cfloop list="#StructKeyList(arguments.postArgs.metaData)#" index="i">
								<cfhttpparam type="header" name="#variables.META_HEADER_PREFIX##i#" value="#StructFind(arguments.postArgs.metaData, i)#" />
							</cfloop>
						</cfif>
					</cfif>
				</cfhttp>
								
				<cfscript>
					statusCheck 			= checkStatusCode(cfhttp.StatusCode);
	            	stuResponse.response 	= cfhttp;
					stuResponse.success		= statusCheck.success; 
					stuResponse.message		= statusCheck.message;   
					stuResponse.fileContent = cfhttp.fileContent;         
	            </cfscript>
		<cfreturn stuResponse />
	</cffunction>
	
	<cffunction name="makeAPICallWithBody" access="package" output="false" returntype="Any" hint="I am the function that makes the cfhttp POST and PUT requests with body content.">
		<cfargument name="remoteURL" 		required="true" 	type="string" 	hint="The URL string to make the call to." />
		<cfargument name="remoteMethod" 	required="true" 	type="string" 	hint="The method of the remote call." />
		<cfargument name="postBody"			required="true"		type="string" 	hint="The body content to send in the post." />
		<cfargument name="authToken" 		required="true" 	type="string" 	hint="The authorisation token for use in the remote call." />
		<cfargument name="format"			required="true"		type="string" 	hint="The return format of responses from the cloud server API. XML or JSON." />
			<cfset var cfhttp	 	= '' />
			<cfset var statusCheck	= '' />
			<cfset var stuResponse 	= StructNew() />
			
				<cfhttp url="#arguments.remoteURL#" method="POST">
					<cfhttpparam name="X-Auth-Token" 		type="header" 	value="#arguments.authToken#" />
					<cfhttpparam name="Content-Type" 		type="header" 	value="application/#arguments.format#" />
					<cfhttpparam name="Accept" 				type="header" 	value="application/#arguments.format#" />
					<cfhttpparam name="#arguments.format#"	type="url"  	value="#strRequest#" />
					<cfhttpparam name="#arguments.format#"	type="body" 	value="#strRequest#" />
				</cfhttp>
								
				<cfscript>
					statusCheck 			= checkStatusCode(cfhttp.StatusCode);
            		stuResponse.response 	= cfhttp;
					stuResponse.success		= statusCheck.success; 
					stuResponse.message		= statusCheck.message;  
					stuResponse.fileContent = cfhttp.fileContent;       	                
                </cfscript>
		<cfreturn stuResponse />
	</cffunction> 
	
	<cffunction name="handleResponseOutput" access="public" output="false" hint="I handle the output format for the returned data.">
		<cfargument name="data" 	required="true" 	type="Any" 					hint="The returned fileContent data from the cfhttp call." />
		<cfargument name="format"	required="false" 	type="string" default="" 	hint="The chosen format for the returned data. XML, JSON or blank for HEADER information." />
			
			<cfset var stuResponse = StructNew() />
			<cfset stuResponse = checkStatusCode(arguments.data.statusCode) />			
			<cfswitch expression="#arguments.format#">
				<cfcase value="xml">
					<cfif len(arguments.data.filecontent)>
						<cfset stuResponse.data = arguments.data.FileContent />
					</cfif>
				</cfcase>
				<cfcase value="json">
					<cfif len(arguments.data.filecontent) and isJSON(arguments.data.filecontent)>
						<cfset stuResponse.data = serializeJSON(deserializeJSON(arguments.data.filecontent)) />
					</cfif>
					<cfif len(arguments.data.filecontent) and isJSON(arguments.data.filecontent) IS false>
						<cfset stuResponse.data = serializeJSON(arguments.data.filecontent) />
					</cfif>
				</cfcase>
				<cfcase value="objectMeta">
					<cfset stuResponse.data = arguments.data.ResponseHeader />
				</cfcase>
				<cfcase value="object">
					<cfset stuResponse.data = arguments.data.fileContent/>
					<cfif  isObject(arguments.data.fileContent)>
						<cfset stuResponse.data = arguments.data.fileContent.toByteArray()/>
					<cfelse>
						<cfset stuResponse.data = ToBinary(Tobase64(arguments.data.fileContent))/>
					</cfif>
				</cfcase>
				<cfdefaultcase>
					<cfset stuResponse.data = arguments.data.FileContent />
				</cfdefaultcase>
			</cfswitch>
		<cfreturn stuResponse />
	</cffunction>
	
	<cffunction name="checkStatusCode" access="public" output="false" hint="I check the status code from any CFHTTP request.">
		<cfargument name="status" required="true" type="string" hint="The status code from the cfhttp call." />
			<cfset var boolReturn = false />
			<cfset var stuStatusResponse = StructNew() />
				<cfswitch expression="#arguments.status#">
					<cfcase value="200 OK">
						<cfset boolReturn = true />
					</cfcase>
					<cfcase value="201 Created">
						<cfset boolReturn = true />
					</cfcase>
					<cfcase value="202 Accepted">
						<cfset boolReturn = true />
					</cfcase>
					<cfcase value="204 No Content">
						<cfset boolReturn = true />
					</cfcase>
					<cfcase value="400 Bad Request">
						<cfset boolReturn = false />
					</cfcase>
					<cfcase value="404 Not Found">
						<cfset boolReturn = false />
					</cfcase>
					<cfcase value="412 Precondition Failed">
						<cfset boolReturn = false />
					</cfcase>
				</cfswitch>
			<cfset stuStatusResponse.message = arguments.status />
			<cfset stuStatusResponse.success = boolReturn />
		<cfreturn stuStatusResponse />
	</cffunction>
	
	<cffunction name="re_Match" access="public" output="false" returntype="Any" hint="I am used to run regular expression validation tests.">
		<cfargument name="substring"	required="true" type="string" 				hint="The substring / expression to search for." />
		<cfargument name="string"		required="true" type="string" 				hint="The string / data within which to search for the substring." />
		<cfreturn reMatch(arguments.substring,arguments.string) />
	</cffunction>
	
</cfcomponent>