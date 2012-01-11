<cfcomponent output="false">

	<cfscript>
		this.name = hash(getCurrentTemplatePath());
		this.applicationtimeout = createTimeSpan(0,2,0,0);
	</cfscript>

	<cffunction name="onApplicationStart" output="false">
		<cfscript>
			this.cloudUser 	= '<enter your cloud api username>';
	 		this.cloudKey	= '<enter your cloud api key>';
			
			Application.objRackspace = createObject('component', 
										'com.fuzzyorange.rackspaceCloud').
										init(username=this.cloudUser,apiKey=this.cloudKey);
										
			Application.objFiles 	= Application.objRackspace.fileInterface();
			Application.objServer 	= Application.objRackspace.serverInterface();
		</cfscript>
	</cffunction>
	
	<cffunction name="onRequestStart">
		<cfif structKeyExists(URL, "reinit")>
			<cfscript>
				onApplicationStart();
			</cfscript>
		</cfif>
	</cffunction>

</cfcomponent>