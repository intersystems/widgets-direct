/// Utilities which may be helpful to users working with the %Studio.SourceControl.ISC server-side Perforce hooks
Class Util.Perforce Extends %RegisteredObject
{

/// Working branch in depot
Parameter BRANCH As COSEXPRESSION = "..#ROOT_""depot\WidgetsDirect\""";

/// connection string for Perforce server
Parameter P4PORT As %String = "ssl:192.168.56.101:1666";

/// root of Perforce workspace
Parameter ROOT As %String = "C:\MyPerforce\";

/// Perforce workspace name (must exist in Perforce)
Parameter WORKSPACE As %String = "SHARED_WidgetsProject";

/// Sets up the configuration settings to use %Studio.SourceControl.ISC for Perforce Source Control
ClassMethod ConfigureNamespaceForSourceControl() As %Status
{
	Do ##class(%Studio.SourceControl.Interface).SourceControlClassSet("%Studio.SourceControl.ISC")   // set the source control hooks class
	Set ^SYS("SourceControl","ChangeConfig","KeepHistory") = 1 // keep record of changes 
	Set ^%SYS("SourceRoot","APPS") = ..#ROOT // source root
	Set ^Sources = ..#BRANCH_"DEV\" // current branch for development
	Set ^SYS("SourceControl","Disconnected") = 0 // connect hooks to Perforce
	Set ^SYS("SourceControl","Misc","UseUDL")=1 //use the UDL export format 
	Set ^SYS("SourceControl","Misc","AutoSync") = 1 // sync latest code
	Do ##class(%Studio.SourceControl.ISC).SetSharedWorkspace(..#WORKSPACE) // set up Perforce workspace
	Set sc=..CreateP4CONFIGFile()
	If sc'=$$$OK Quit sc
	Do InitializeStandardSettings^%buildccr	// set up additional default settings
	///make sure that the UnitTest reports can be accessed
	Set oldNS=$namespace
	Set $namespace="%SYS"
	Set ^SYS("Security","CSP","AllowPrefix","/csp/widgetdirect/","%UnitTest.")=1
	Set $namespace=oldNS
	Quit $$$OK
}

/// Creates connection to Perforce server and initializes it
ClassMethod CreateP4CONFIGFile() As %Status
{
	Set file=##class(%Stream.FileCharacter).%New()
	Set file.Filename="p4Config"
	Set sc=file.WriteLine("P4PORT="_..#P4PORT)
	If sc'=$$$OK Quit sc
	Set sc=file.%Save()
	If sc'=$$$OK Quit sc
	Set sc=##class(%Studio.SourceControl.ISC).RunCmd("p4 set -s P4CONFIG=p4Config",,1)	// use this configuration for this namespace
	If sc'=$$$OK Quit sc
	Set sc=##class(%Studio.SourceControl.ISC).RunCmd("p4 trust -y",,1)	// trust the SSL fingerprint
	Quit sc
}

/// Synces and builds the code from the current branch and then kicks off the UnitTests
ClassMethod BuildAndTest(pSync As %String = 1) As %Status
{
	If '$data(^Sources) Write "^Sources is not set up - please run Configure^%buildccr",! Quit
	Set ans=""
	Write "This will refresh the contents of the namespace with the exported contents of",!
	Write "the local Perforce workspace on disk",!
	If '##class(%Studio.SourceControl.ISC).Disconnected() {
		Write "This namespace is 'Connected' to Perforce."
		Write "Current branch is stored in:",!
		Write "    "_^Sources,!
		If (pSync) {
			Set ret=##class(%Studio.SourceControl.ISC).GetCredentials(.pP4user, .pP4pass)
			If (ret)&&($get(pP4pass)="") {
				Write "Please enter password for Perforce user '"_$get(pP4user)_"': "
				Use $p:(:"+S")
				Read pP4pass 
				Use $p:(:"-S")
				Write !
				Set %stP=$System.Encryption.Base64Encode($G(pP4pass))
			} ElseIf ('ret) {
				Write "NOTICE: Source Control Credentials are not set for '"_$USERNAME_"'",!
			}
		}
		If (pSync) {
			Write "Syncing "_^Sources_" from Perforce",!
			Set cmd="p4 sync """_^Sources_"..."_""""
			Set sc=##class(%Studio.SourceControl.ISC).RunCmd(cmd,.outstream,1,1)
			Write !
			If $$$ISOK(sc) {
				Do outstream.Rewind()
				While 'outstream.AtEnd {
					Write outstream.Read(8000)
				}
			} ElseIf ($system.Status.GetErrorText(sc) [ "up-to-date") {
				Write "All files are up to date",!
			} Else  {
				Write "An error occurred while trying to sync:"
				Do $system.OBJ.DisplayError(sc)		
			}
		}
	} Else {
		Write "This namespace is 'Disconnected'; skipping sources sync",!	
	}

#DEFINE InitTotalTime Set bigtime=$zh
#DEFINE InitTime Set time1=$zh If $isobject($get(%response)) { Do %response.Flush() }
#DEFINE ElapsedTime Set time1=$zh-time1 Write ?5,"Elapsed time: "_$select(time1>60:(time1\60)_" minutes ",1:"")_(time1#60)_" seconds"
#DEFINE ElapsedTotalTime If $data(bigtime) Set bigtime=$zh-bigtime Write !!,"COMPLETE!",!,"Overall Elapsed Time: "_$select(bigtime>60:(bigtime\60)_" minutes ",1:"")_(bigtime#60)_" seconds"
 
	$$$InitTotalTime 
 
	$$$InitTime
	Set types=$listbuild(
							$listbuild("Include Files",$listbuild("inc"),"*.inc"),
							$listbuild("Classes",$listbuild("cls"),"*.cls"),
							$listbuild("Routines",$listbuild("rtn"),"*.mac"),
							$listbuild("Projects",$listbuild("prj"),"*.prj"),
							$listbuild("Unit Tests",$listbuild("internal"),"*.cls"),
							$listbuild("DeepSee Folder Items",$listbuild("ds"),"*.ds")
							)
	For typeIndex=1:1:$listlength(types) {
		Set typeDetails=$listget(types,typeIndex)
		Set label=$listget(typeDetails,1)
		Set subdirs=$listget(typeDetails,2)
		Set ext=$listget(typeDetails,3)
		Write !,"Importing all "_label_"...",!
		$$$InitTime 
		For dirIndex=1:1:$listlength(subdirs) {
			Set subdir=##class(%File).NormalizeDirectory(^Sources_$listget(subdirs,dirIndex))
			If ##class(%File).DirectoryExists(subdir) {
				Set sc=$system.OBJ.ImportDir(subdir,ext,"fck",.errorlog,1)
			} Else {
				Write subdir_" does not exist ... moving to next directory",! 	
			}
		}
		Write !,"...Import complete.",!
		Write ! $$$ElapsedTime
		Write !
	}
 
	Kill apps
	//fetch the list of CSP Applications defined for this namespace
	Do CSPAppList^%SYS.cspServer2(.apps)
	Set key=""
	Set root=""
	Set key=$order(apps(key))
	While (key'="") {
		If key["itemsetsourcelink" Set key=$order(apps(key)) Continue
		Set root=$listget(apps(key),17), path=key
 		If root="" {
			Write !,!,"CSP App: '"_path_"'",!
			Write "   No physical path defined in CSP Definition; skipping this csp application",!,! 
	 		Set key=$order(apps(key)) 
	 		Continue
 		}
 		Set root=##class(%File).NormalizeDirectory(root)	; normalize directory in case there is no trailing slash in the CSP App definition
		Set testFile="foo.txt"
		Set testFilePath=##class(%Studio.SourceControl.ISC).ExtName(path_"/"_testFile)
		Set srcPath=$extract(testFilePath,1,$length(testFilePath)-$length(testFile))
 		$$$InitTime
		Write !,!,"CSP App: '"_path_"'",!
		Write "   physical path: "_root,!
		Write "   perforce path: "_srcPath,!
		If ($$$isUNIX&&(root'=srcPath))||($$$isWINDOWS&&($zconvert(root,"l")'=$zconvert(srcPath,"l"))) {
			If ##class(%File).Exists(srcPath) {
				//CSP application does not point directly to a non-mapped location within ^Sources, see if there is a match and try to move the files over
				Write "Prior to refresh - the files must be moved",!
				Write "Changing physical path contents to ReadWrite..."
				Set cmd=$select($$$isWINDOWS:"attrib -r "_root_"* /S",1:"chmod -R gu+w "_root)
				Set sc=##class(%Studio.SourceControl.ISC).RunCmd(cmd,.out,1) 
				If $$$ISOK(sc) { 
					Write !,"Complete",!
				} Else {
					Do $System.OBJ.DisplayError(sc)
				}
				Write "Copying files from perforce path to physical path for "_path,!
				Set ret=##class(%File).CopyDir(srcPath,root,1,.created)
				If ('ret) {
					Write "Copy failed!!"
					Do $system.OBJ.DisplayError(%objlasterror)
				} Else {
					Write "Copy complete; "_created_" files copied"
				}
				Write !
			} Else {
				Write "     NOTE: paths differ but no files exist in perforce path",!
			}
		}
		Write !,"Loading CSR rules and CSP pages for ",path,"."
		Do $System.CSP.LoadRuleDir(path,"fck")
		Do $System.CSP.LoadPageDir(path,"fck")
		Write ! $$$ElapsedTime
		Set key=$order(apps(key))
	}
 
	Set subdir=##class(%File).NormalizeDirectory(^Sources_"dsi")
	If ((##class(%Dictionary.CompiledClass).%ExistsId("%DeepSee.UserLibrary.Utils"))&&(##class(%File).DirectoryExists(subdir))){
		//for 2010.2 + DeepSee kit or 2011.1, we should use this code for import/export with DeepSee specific APIs because before FolderItemDocument was added standard import/export APIs didn't recognize the items.   
		Write !,"Importing all DeepSee Folder Items exported using %DeepSee.UserLibrary.Utils...",!
		Set dirList=$listbuild(subdir)
		While $listlength(dirList)>0 {
			Set subdir=$listget(dirList)
			Write !,"Importing *.xml files from "_subdir,!
			Set tRS = ##class(%ResultSet).%New("%File:FileSet")
			Set tSC = tRS.Execute(subdir,"*.xml",,1)
			If $$$ISOK(tSC) {
				While(tRS.Next()) {
					Set tName=tRS.Data("Name")
					If tRS.Data("Type")="D" {
						Set dirList=dirList_$listbuild(tName)
					} Else {
						Set sc=##class(%DeepSee.UserLibrary.Utils).%Import(tName,1)
						Write !
					}
				}
			} Else {
				Do $system.OBJ.DisplayError(tSC)		
			}
			Set dirList=$list(dirList,2,$listlength(dirList))
		}
		Write !,"...Import complete.",!
	}
 	$$$ElapsedTime

 	$$$InitTime
	//kick off the unit tests
	Set ^%SYS("SourceRoot")=^Sources
	do ##class(UnitTest.Widget).RunRecursive()		
 	$$$ElapsedTime
	
	$$$ElapsedTotalTime
	Write !,"Build and Test finished on ",$zdatetime($H)
	Quit sc	; in the future we need to quit a list of errors encountered, not just the error from the post-refresh logic
}

/// Removes up the configuration settings for Source Control
ClassMethod RemoveSourceControlFromNamespace() As %Status
{
	Do ##class(%Studio.SourceControl.Interface).SourceControlClassSet("")    // clear out source control hooks class
	Write ##class(%File).RemoveDirectoryTree(..#BRANCH),!		// remove all Workspace files
	Kill ^SYS("SourceControl") 
	Kill ^%SYS("SourceRoot","APPS")
	Kill ^Sources 
	Set sc=##class(%Routine).Delete("ZWELCOME.mac",,,"%SYS")
	If ('sc=$$$OK) {
		Write "Error deleting ZWELCOME: "_$system.Status.GetErrorText(sc),!
	}
	Set oldNS=$namespace
	Set $namespace="%SYS"
	Set sc=##class(Security.Applications).Get("/widgetsdirect",.props)
	Set props("Path")="C:\widgets\web"
	Set sc=##class(Security.Applications).Modify("/widgetsdirect",.props)
	Set $namespace=oldNS
	If ('sc=$$$OK) {
		Write "Error resetting /widgetdirect: "_$system.Status.GetErrorText(sc),!
	}
	Quit $$$OK
}

}
