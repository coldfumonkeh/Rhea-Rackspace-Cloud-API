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
<cfcomponent displayname="storage" output="false" hint="I am the storage cfc for the cloud files api" extends="cloudUtils">

	<cfset variables.instance = structNew() />

	<cffunction name="init" access="public" output="false" hint="I am the constructor method" returntype="com.fuzzyorange.storage">
		<cfargument name="username" 	required="true" 	type="string" 	hint="The cloud files account username" />
		<cfargument name="apiKey" 		required="true" 	type="string" 	hint="The cloud files account API key" />
			<cfscript>
				variables.instance.userName 	= arguments.userName;
				variables.instance.apiKey 		= arguments.apiKey;
				super.init();
			</cfscript>
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getContainers" access="public" output="false" returntype="any" hint="I return a list of storage Containers applied to the account.">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 				hint="The authResponse bean" />
		<cfargument name="limit" 		required="false" 	type="string" 								default=""	hint="For an integer value N, limits the number of results to at most N values." />
		<cfargument name="marker" 		required="false" 	type="string" 								default=""	hint="Given a string value X, return Object names greater in value than the specified marker." />
		<cfargument name="format" 		required="true" 	type="string" 											hint="Specify either JSON or XML to return the respective serialized response." />
			<cfset var response 	= "" />
			<cfset var stuArgs 		= StructNew() />
			<cfset var strURL		= '' />
			<cfset var strURLParam	= '?' />		
				<cfscript>
					strURL			= arguments.authResponse.getStorageURL();
                	stuArgs.limit 	= arguments.limit; 
					stuArgs.marker 	= arguments.marker; 
					stuArgs.format 	= arguments.format;
					strURL			= strURL & strURLParam & buildParamString(stuArgs);
					response 		= makeAPICall(remoteURL=strURL,
										remoteMethod='GET',
										authToken=arguments.authResponse.getAuthToken());
					response = handleResponseOutput(response.response, arguments.format);     
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="getAllContainerDetails" access="public" output="false" returntype="Any" hint="I determine the number of containers within the account and the total bytes stored.">
		<cfargument name="authResponse"	required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="format" 		required="true" 	type="string" 								hint="Specify either JSON or XML to return the respective serialized response." />
			<cfset var response 	= "" />
			<cfset var strURL		= '' />
			<cfset var stuDetails	= StructNew() />	
				<cfscript>
					strURL			= arguments.authResponse.getStorageURL();
					response 		= makeAPICall(remoteURL=strURL,
										remoteMethod='HEAD',
										authToken=arguments.authResponse.getAuthToken());
					stuDetails.account_Bytes_Used 		= response.response.ResponseHeader['X-Account-Bytes-Used'];
					stuDetails.account_Container_Count 	= response.response.ResponseHeader['X-Account-Container-Count'];
                </cfscript>
		<cfreturn stuDetails />
	</cffunction>
	
	<cffunction name="getContainerDetails" access="public" output="false" returntype="Any" hint="I determine the number of Objects and total stored bytes within the Container">
		<cfargument name="authResponse"		required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="containerName" 	required="true" 	type="string" 								hint="Name of the container you wish to create" />
		<cfargument name="format" 			required="true" 	type="string" 								hint="Specify either JSON or XML to return the respective serialized response." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
			<cfset var stuDetails	= StructNew() />
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getStorageURL() &
							   		'/' & arguments.containerName;
					response	= makeAPICall(remoteURL=strURL,
									remoteMethod='HEAD',
									authToken=arguments.authResponse.getAuthToken());
					stuDetails.container_Name			= arguments.containerName;
					stuDetails.container_Bytes_Used 	= response.response.ResponseHeader['X-Container-Bytes-Used'];
					stuDetails.Container_Object_Count 	= response.response.ResponseHeader['X-Container-Object-Count'];     	                
                </cfscript>
		<cfreturn stuDetails />
	</cffunction>
	
	<cffunction name="createContainer" access="public" output="false" returntype="Any" hint="I create a Container.">
		<cfargument name="authResponse"		required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="containerName" 	required="true" 	type="string" 								hint="Name of the container you wish to create" />
		<cfargument name="format" 			required="true" 	type="string" 								hint="Specify either JSON or XML to return the respective serialized response." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<cfscript>
					if(!arrayLen(re_Match('[/]', arguments.containerName))) {
						strURL 		= strURL & arguments.authResponse.getStorageURL() &
							   		'/' & arguments.containerName;
						response	= makeAPICall(remoteURL=strURL,
										remoteMethod='PUT',
										authToken=arguments.authResponse.getAuthToken());
						response	= handleResponseOutput(response.response);
					} else {
						response = structNew();
						response.message = 'The Container name cannot contain "/"';
						response.success = false;
					}                
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="deleteContainer" access="public" output="false" returntype="Any" hint="This method permanently removes a Container">
		<cfargument name="authResponse"		required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="containerName" 	required="true" 	type="string" 								hint="Name of the container you wish to delete" />
		<cfargument name="format" 			required="true" 	type="string" 								hint="Specify either JSON or XML to return the respective serialized response." />
			<cfset var response 	= "" />
			<cfset var strURL 		= '' />
				<cfscript>
					strURL 		= strURL & arguments.authResponse.getStorageURL() &
							   		'/' & arguments.containerName;
					response	= makeAPICall(remoteURL=strURL,
									remoteMethod='DELETE',
									authToken=arguments.authResponse.getAuthToken());
					response = handleResponseOutput(response.response);
					if(response.message == '404 Not Found') {
						response.message = response.message & '. The selected container "' & 
								arguments.containerName & '" does not exist';
					} else if (response.message == '409 Conflict') {
						response.message = response.message & '. The selected container "' & 
								arguments.containerName & '" is not empty and cannot be deleted.';
					}  	                
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<!--- OBJECT RELATED METHODS --->
	<cffunction name="getObjectsInContainer" access="public" output="false" returntype="Any" hint="I retrieve a list of Objects stored in the selected Container">
		<cfargument name="authResponse"		required="true" 	type="com.fuzzyorange.beans.authResponse" 				hint="The authResponse bean" />
		<cfargument name="containerName" 	required="true" 	type="string" 											hint="Name of the container you wish to retrieve listings for." />
		<cfargument name="limit" 			required="false" 	type="string" 								default=""	hint="For an integer value N, limits the number of results to at most N values." />
		<cfargument name="marker" 			required="false" 	type="string" 								default=""	hint="Given a string value X, return Object names greater in value than the specified marker." />
		<cfargument name="prefix"			required="false"	type="string"								default=""	hint="For a string value X, causes the results to be limited to Object names beginning with the substring X." />
		<cfargument name="path"				required="false" 	type="string" 								default=""	hint="For a string value X, return the Object names nested in the pseudo path (assuming preconditions are met)" />		
		<cfargument name="format" 			required="true" 	type="string" 											hint="Specify either JSON or XML to return the respective serialized response." />
			<cfset var response 	= "" />
			<cfset var stuArgs 		= StructNew() />
			<cfset var strURL		= '' />
			<cfset var strURLParam	= '?' />	
				<cfscript>
					strURL			= arguments.authResponse.getStorageURL() & '/' & arguments.containerName;
                	stuArgs.limit 	= arguments.limit; 
					stuArgs.marker 	= arguments.marker; 
					stuArgs.format 	= arguments.format;
					strURL			= strURL & strURLParam & buildParamString(stuArgs);
					response 		= makeAPICall(remoteURL=strURL,
										remoteMethod='GET',
										authToken=arguments.authResponse.getAuthToken());
					response = handleResponseOutput(response.response, arguments.format);
					if(response.message == '404 Not Found') {
						response.message = response.message & '. The selected container "' & 
								arguments.containerName & '" does not exist';
					} else if (response.message == '204 No Content') {
						response.message = response.message & '. The selected container "' & 
								arguments.containerName & '" is empty.';
					}      
                </cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="getObjectMeta" access="public" output="false" returntype="Any" hint="I retrieve an Object's metadata">
		<cfargument name="authResponse"		required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="containerName" 	required="true" 	type="string" 								hint="Name of the Container that contains the Object you wish to retrieve." />
		<cfargument name="objectName"		required="true" 	type="string"								hint="The name of the Object" />
		<cfargument name="format" 			required="true" 	type="string" 								hint="Specify either JSON or XML to return the respective serialized response." />
			<cfset var response 	= "" />
			<cfset var strURL		= '' />
			<cfset var stuMeta		= structNew() />
				<cfscript>
					strURL			= arguments.authResponse.getStorageURL() & '/' 
										& arguments.containerName & '/' & arguments.objectName;
					response 		= makeAPICall(remoteURL=strURL,
										remoteMethod='GET',
										authToken=arguments.authResponse.getAuthToken());
					response 		= handleResponseOutput(response.response, 'objectMeta');
					if(response.message == '404 Not Found') {
						response.message = response.message & '. The requested object "' & 
								arguments.containerName & '" does not exist';
					}
				</cfscript>
		<cfreturn response />
	</cffunction>

	<cffunction name="getObject" access="public" output="true" returntype="Any" hint="I retrieve an Object's metadata">
		<cfargument name="authResponse"		required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="containerName" 	required="true" 	type="string" 								hint="Name of the Container that contains the Object you wish to retrieve." />
		<cfargument name="objectName"		required="true" 	type="string"								hint="The name of the Object" />
		<cfargument name="format" 			required="true" 	type="string" 								hint="Specify either JSON or XML to return the respective serialized response." />
			<cfset var response 	= "" />
			<cfset var strURL		= '' />
			<cfset var stuMeta		= structNew() />
				<cfscript>
					strURL			= arguments.authResponse.getStorageURL() & '/' 
										& arguments.containerName & '/' & arguments.objectName;
					response 		= makeAPICall(remoteURL=strURL,
										remoteMethod='GET',
										authToken=arguments.authResponse.getAuthToken());
					response 		= handleResponseOutput(response.response, 'Object');
					if(response.message == '404 Not Found') {
						response.message = response.message & '. The requested object "' & 
								arguments.containerName & '" does not exist';
					}
				</cfscript>
		<cfreturn response />
	</cffunction>
			
	<cffunction name="putObject" access="public" output="false" returntype="Any" hint="I am used to write, or overwrite, an Object's metadata and content">
		<cfargument name="authResponse"		required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="containerName" 	required="true" 	type="string" 								hint="Name of the Container you wish to put the Object into." />
		<cfargument name="object"			required="true" 	type="Any"									hint="The Object." />
		<cfargument name="format" 			required="true" 	type="string" 								hint="Specify either JSON or XML to return the respective serialized response." />
			<cfset var response = "" />
			<cfset var strURL	= '' />
				<cfscript>
					stuFileData = structNew();
					stuFileData['Content-Length'] 	= arguments.object.FileSize;
					stuFileData['Content-type'] 	= arguments.object.contentType & '/' & arguments.object.contentSubType;	
					stuFileData['file']				= arguments.object.serverDirectory & '\' & arguments.object.serverFile;	
					strURL		= arguments.authResponse.getStorageURL() & '/' & arguments.containerName & '/' & arguments.object.serverFile;
					response 	= makeAPICall(remoteURL=strURL,
										remoteMethod='PUT',
										authToken=arguments.authResponse.getAuthToken(),
										postArgs=stuFileData);
					response 	= handleResponseOutput(response.response, 'objectMeta');
				</cfscript>
		<cfreturn response />
	</cffunction>
	
	<cffunction name="deleteObject" access="public" output="false" returntype="Any" hint="I permanently remove the specified Object from the storage system (metadata and data)">
		<cfargument name="authResponse"		required="true" 	type="com.fuzzyorange.beans.authResponse" 	hint="The authResponse bean" />
		<cfargument name="containerName" 	required="true" 	type="string" 								hint="Name of the Container that contains the Object you wish to retrieve." />
		<cfargument name="objectName"		required="true" 	type="string"								hint="The name of the Object" />
		<cfargument name="format" 			required="true" 	type="string" 								hint="Specify either JSON or XML to return the respective serialized response." />
			<cfset var response = "" />
			<cfset var strURL	= '' />
				<cfscript>
					strURL		= arguments.authResponse.getStorageURL() & '/' & arguments.containerName & '/' & arguments.objectName;
					response 	= makeAPICall(remoteURL=strURL,
										remoteMethod='DELETE',
										authToken=arguments.authResponse.getAuthToken());
					response 	= handleResponseOutput(response.response, 'objectMeta');
				</cfscript>
		<cfreturn response />
	</cffunction>
	
</cfcomponent>