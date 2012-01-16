<cfset cloud = application.objFiles>
<cfset testContainer = "TestRhea">
<cfset testFileName = "free hug coupon.pdf">
<cfset filePath = expandPath(testFileName)>
<cfset fileFolder = replaceNoCase(filePath, testFileName, "")>

<!--- Get All Container Details --->
<cfset containerDetails = cloud.getAllContainerDetails()>
<br>Get All Container Details...
<cfdump var="#containerDetails#" label="containerDetails">

<!--- Create Container --->
<cfset newContainer = cloud.createContainer(testContainer)>
<br>Create Container Called TestRhea...
<cfdump var="#newContainer#" label="newContainer">

<!--- Get Container --->
<br>List all containers...
<cfset allContainers = cloud.getContainers(format="JSON")>
<cfdump var="#allContainers#" label="get containers">
<cfdump var="#deserializeJSON(allContainers.data)#" label="deserialized data">

<!--- Upload file to the new container --->
<br>Upload file to the new container. . .
<cfset fileStruct = fileInfo(filePath)>
<cfset putFile = cloud.putObject(testContainer,filePath)>
<cfdump var="#putFile#" label="response for uploading a new object">

<!--- List object in the new container --->
<br>List object in the new container . . . 
<cfset objectList = cloud.getObjectsInContainer(containerName=testContainer, format="json")>
<cfdump var="#objectList#" label="Objects in new container">
<cfdump var="#deserializeJSON(objectList.data)#" label="deserialized data Objects in new container">

<br>Set Object MetaData ...
<cfset meta = structNew()>
<cfset meta.Fname = "Tim">
<cfset meta.Lname = "Cunningham">
<cfset meta.attribute = "Sharply dressed">
<cfset setMeta = cloud.setObjectMeta(containerName=testContainer, object=testFileName, metaData=meta)>
<cfdump var="#setMeta#" label="extended metadata response">


<!--- Get Object Meta Data --->
<br>Get Object Meta Data . . . 
<cfset objMeta = cloud.getObjectMeta(testContainer, testFileName)>
<cfdump var="#objMeta#" label="object meta data">

<!--- Get the object from the container --->
<br>Get the object from the container . . .
<cfset newFile = cloud.getObject(testContainer, testFileName)>
<cfdump var="#newFile#" label="Get Object Response">
<cfset newFileData = newfile.data>
<cfset newfileName = createUUID() & ".pdf">
<cfset newFilePath = fileFolder & newfileName >
<cfpdf action="write" destination="#newFilePath#" source="newFileData" overwrite="yes" > 
<cfoutput><br>Link to newly downloaded file: <a href="#newfileName#" target="_">#newfileName#</a></cfoutput>

<!--- Copy object --->
<br>Copy Object. . . 
<cfset copyObj = cloud.copyObject(testContainer, testFileName, testContainer, "1-" & testFileName)>
<cfset copyObj = cloud.copyObject(testContainer, testFileName, testContainer, "2-" & testFileName)>
<cfset copyObj = cloud.copyObject(testContainer, testFileName, testContainer, "3-" & testFileName)>
<cfdump var="#copyObj#">


<!--- Rename Object --->
<br>Rename object. . . 
<cfset renameObj = cloud.renameObject(testContainer, "1-" & testFileName, testContainer, "rename-of-1-" & testFileName)>
<cfdump var="#renameObj#">

<!--- Move Object --->
<br>Move object. . . 
<cfset newContainer = cloud.createContainer(testContainer & "-2")>
<cfset renameObj = cloud.moveObject(testContainer, "2-" & testFileName, testContainer & "-2")>
<cfdump var="#renameObj#">

<!--- Delete object from the container --->
<br><br>Delete object from the container . . . 
<cfset deleteObj = cloud.deleteObject(testContainer, testFileName)>
<cfdump var="#deleteObj#" label="delete object">

<!--- Rename Container  --->
<br>Rename Container . . .
<cfset renameCont = cloud.renameContainer(testContainer, "Renamed-" & testContainer)>
<cfdump var="#renameCont#" label="renamed Container">

<!--- Delete container(s) from cloud --->
<br>Recursively delete container(s) from cloud . . . 
<cfset deleteCont = cloud.deleteContainer(testContainer,true)>
<cfdump var="#deleteCont#" label="delete container #testContainer#">
<cfset deleteCont = cloud.deleteContainer("Renamed-" & testContainer,true)>
<cfdump var="#deleteCont#" label="delete container Renamed-#testContainer#">
<cfset deleteCont = cloud.deleteContainer(testContainer & "-2",true)>
<cfdump var="#deleteCont#" label="delete container #testContainer#-2">

<cffunction name="fileInfo">
	<cfargument name="path" type="string" required="true">
	<cfset var myFileInfo = getFileInfo(filePath)>
	<cfset var fileStruct = structNew()>
	<cfset fileStruct.FileSize = myFileInfo.size>
	<cfset fileStruct.fullcontentType = getPageContext().getServletContext().getMimeType(myFileInfo.path)>
	<cfset fileStruct.contentType = listFirst(fileStruct.fullcontentType, "/")>
	<cfset fileStruct.contentSubType = listLast(fileStruct.fullcontentType, "/")>
	<cfset fileStruct.serverDirectory = myFileInfo.parent>
	<cfset filestruct.serverFile = myFileInfo.name>
	<cfreturn  fileStruct>
</cffunction>