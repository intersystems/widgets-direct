Include %occInclude

/// This is a Requirement Formatter. Given a requirement class name, it displays a nice page for it.
Class UnitTest.Formatter [ Abstract ]
{


/// This method is used to display a page.
ClassMethod Run(pClassName As %String) As %Status [ PublicList = Result ]
{
	&html<<html>
	<head>>
	do ..DisplayStyles()
	do ..DisplayJS()
	set title=..GetTitle(pClassName)
	&html<<title>#(title)#</title>
	</head>
	<body>>
	if $data(%request.Data("run")) {
		write "<div class=""hidden"" id=""output"">"
		write "<pre>"
		write "To run this class it terminal with debug mode on, type:",!
		write "do ##class("_pClassName_").Run(""/debug"")"
		set sc=$zobjclassmethod(pClassName,"Run")
		if $$$ISERR(sc) do $system.OBJ.DisplayError(sc)
		write "</pre>"
		write "</div>"
	}
	if $data(%request.Data("runRecursive")) {
		write "<div class=""hidden"" id=""output"">"
		write "<pre>"
		write "To run this test suite it terminal with debug mode on, type:",!
		write "do ##class("_pClassName_").RunRecursive(""/debug"")"
		set sc=$zobjclassmethod(pClassName,"RunRecursive")
		if $$$ISERR(sc) do $system.OBJ.DisplayError(sc)
		write "</pre>"
		write "</div>"
	}
	do ..DisplayMenuBar(pClassName)
	do ..DisplayPath(pClassName)
	&html<<h1>#(title)#>
	&html<</h1>>
	set showLast=0
	set isRequirement=##class(%Dictionary.XDataDefinition).%ExistsId(pClassName_"||RequirementDefinition")
	if $data(%request.Data("run")) || $data(%request.Data("runRecursive")) || $data(%request.Data("results")) {
		set showLast=1
	}
	if isRequirement {
		if showLast {
			do ..DisplayLastResult(pClassName)
		} else {
			set Def=##class(%Dictionary.XDataDefinition).%OpenId(pClassName_"||RequirementDefinition")
			if Def set Stream=Def.Data
			if $get(Stream) do Stream.OutputToDevice()
		}
	} else {
		do ..DisplayAsPage(pClassName,showLast)
	}
	
	do ..DisplayChildren(pClassName)
	&html<</body></html>>
	quit $$$OK
}

ClassMethod DisplayLastResult(pClassName) As %Status
{
	set result=$zobjclassmethod(pClassName,"GetLastResult",.dateTime,.status,.duration,.html)
	if result="" quit $$$OK
	write html,!
	quit $$$OK
}

ClassMethod DisplayAsPage(pClassName, pShowLast = 0) As %Status
{
	write ##class(%Dictionary.CompiledClass).%OpenId(pClassName).Description
	if pShowLast set instance=$zobjclassmethod(pClassName,"GetLastResult",.dateTime,.status,.duration,.html,.suite)
	set method=""
	for  {
		set method=$$$comMemberNext(pClassName,$$$cCLASSmethod,method)
		quit:method=""
		if $extract(method,1,4)'="Test" continue
		set result=""
		try {
			if pShowLast set result=##class(%UnitTest.Report).GetTestStatus($znspace, instance, suite, pClassName, method)
		} catch(e) {}
		set class=$select(result="":"Skipped",result=1:"Passed",1:"Failed")
		write "<div class=""status"_class_""">"
		write !,"<h2>",method,"</h2>"
		write ##class(%Dictionary.CompiledMethod).%OpenId(pClassName_"||"_method).Description
		if pShowLast && (instance'="") {
			write "<div>"
			set assert="",inDiv=0
			for {
				set assert=$order(^UnitTest.Result(instance,suite,pClassName,method,assert))
				quit:assert=""
				set result=$list(^UnitTest.Result(instance,suite,pClassName,method,assert),1)
				if result=1 {
					if 'inDiv {
						write "<div class=""assertPassed"">"
						set inDiv=1
					}
					write "* "
				}
				if result=0 {
					if inDiv {
						write "</div>"
						set inDiv=0
					}
					write "<div class=""assertFailed"">"
					write "FAILED: "_$zconvert($list(^UnitTest.Result(instance,suite,pClassName,method,assert),2),"O","HTML")
					write ": "_$zconvert($list(^UnitTest.Result(instance,suite,pClassName,method,assert),3),"O","HTML")
					write "</div>"
					
				}
			}
			if inDiv {
				write "</div>"
			}
			write "</div>"
		}
		write "</div>"
	}
}

ClassMethod DisplayMenuBar(pClassName) As %Status
{
	set result=$zobjclassmethod(pClassName,"GetLastResult",.dateTime,.status,.duration,.html)
	set class=$select(status="":"Skipped",status=1:"Passed",1:"Failed")
	write "<p class=""status"_class_""">"
	write "  Execution results:"
	write " <b>"_class_"</b>"
	if dateTime'="" {
		write "  at "_dateTime
		write "  duration "_duration_". "
	}
	if $data(%request.Data("run")) || $data(%request.Data("runRecursive")) {
		write " <a class=""abutton"" href=""#"" onclick=""return show('','output');"">CONSOLE</a>"
	}
	write " <a class=""abutton"" href=""?"">#</a>"
	write " <a class=""abutton"" href=""?run"">Run</a>"
	write " <a class=""abutton"" href=""?runRecursive"">Run Recursive</a>"
	write " <a class=""abutton"" target=""_blank"" href=""%25UnitTest.Report.cls?NS="_$znspace_"&INDEX="_result_""">Execution log</a>"
	write " <a class=""abutton"" href=""?results"">Show last result</a>"
	write "</p>",!
	quit $$$OK
}

ClassMethod DisplayPath(pClassName) As %Status
{
	set path=""
	for i=1:1:$length(pClassName,".")-1 {
		set parentName=$piece(pClassName,".",1,i)
		if ##class(%Dictionary.CompiledClass).%ExistsId(parentName) && $classmethod(parentName,"%IsA","UnitTest.Abstract") {
			set path=path_"| [<a href="""_parentName_".cls"">"_..GetTitle(parentName) _"</a>] "
		}
	}
	set $extract(path)=""
	write path
	quit $$$OK
}

ClassMethod GetTitle(pClassName) As %String
{
	set title=##class(%Dictionary.CompiledParameter).%OpenId(pClassName_"||TITLE")
	if title set title=title.Default
	if title="" set title=pClassName
	quit title
}
/// Display children

ClassMethod DisplayChildren(pClassName) As %Status
{
	set pointCount=$length(pClassName,".")
	set child=pClassName_"."
	set childStr=""
	for {
		set child=$order(^oddDEF(child))
		if child'[(pClassName_".") quit
		if $length(child,".")'=(pointCount+1) continue
		set childStr=childStr_"<p><a href="""_child_".cls"">"_..GetTitle(child) _"</a></p> "
	}
	if childStr'="" write "<h2>More details: </h2>"_childStr
	quit $$$OK
}
/// Output CSS stules for page

ClassMethod DisplayStyles() As %Status
{
	&html<
		<style type="text/css">
		body {
			padding: 32px;
		}
		pre {
			padding: 6px 28px 6px 28px;
			background-color: #E8EEF7;
		}
		pre, pre *, code, code *, kbd {
			font-family: Courier New, Courier;
			font-siz1e: 10pt;
		}
		h1, h1 * {
			font-siz1e: 24pt;
		}
		p, td, th, li, .breadcrumbs {
			font-siz1e: 10pt;
		}
		p, li {
			line-height: 140%;
		}
		table {
			border-collapse: collapse;
			empty-cells: show;
			margin: 8px 0px 8px 0px;
		}
		th, td {
			border: 1px solid black;
			padding: 3px;
		}
		td {
			background-color: white;
			vertical-align: top;
		}
		th {
			background-color: #C3D9FF;
		}
		li {
			margin-top: 6px;
			margin-bottom: 6px;
		}
		.example {
			padding: 2px 12px 6px 12px;
			border: 1px solid #C3D9FF;
			margin: 6px 0px 28px 0px;
			background-color: #F5F9FD;
		}
		.example h3 {
			margin-top: 8px;
			margin-bottom: 8px;
			font-siz1e: 12pt;
		}
		.special {
			font-style: italic;
		}
		.idea {
			font-siz1e: 9pt;
			color: #888;
			font-style: italic;
		}
		.tight li {
			margin-top: 1px;
			margin-bottom: 1px;
		}
		.commentary {
			float: right;
			width: 200px;
			background-color: #ffffd0;
			padding:8px;
			border: 3px solid #eeeeb0;
			margin: 10px 0px 10px 10px;
		}
		.commentary, .commentary * {
			font-siz1e: 8pt;
		}
		.ok {
			background-color: #d0ffd0;
		}
		.error {
			background-color: #ffd0d0;
		}
		
		.statusPassed {
			padding: 2px 12px;
			border: 1px solid #B3FFB3;
			margin: 0px 0px 18px 0px;
			background-color: #EEFFEE;
		}
		.statusFailed {
			padding: 2px 12px;
			border: 1px solid #FFD9C3;
			margin: 0px 0px 18px 0px;
			background-color: #FFF3F0;
		}
		.statusSkipped {
			padding: 2px 12px;
			border: 1px solid #DDDDDD;
			margin: 0px 0px 18px 0px;
			background-color: #F3F3F3;
		}
		
		.assertPassed {
			color:green;
			font-family: Courier New, Courier;
		}
		.assertFailed {
			color:red;
			font-family: Courier New, Courier;
		}
		
		.hidden {
			display:none;
		}
		.abutton {
			padding: 0 0.2em;
			border: 1px solid #C0C0C0;
			margin: 0 0.2em;
			background-color: #E0E0E0;
		}
		</style>>
}
/// Output CSS stules for page

ClassMethod DisplayJS() As %Status
{
	&html<
		<script language="JavaScript">
		function show(element,id) {
			if(element) element.className="hidden";
			document.getElementById(id).className="";
			return false;
		}
		</script>>
}

ClassMethod WriteXmlReport(pFileName As %String, pResultIndex As %String) As %Status
{
	if $get(pResultIndex)="" set pResultIndex=$order(^UnitTest.Result(""),-1)
	set File=##class(%File).%New(pFileName)
	do File.Open("WSN")
	do File.WriteLine("<testsuites>")
	set suite=""
	for  {
		set suite=$order(^UnitTest.Result(pResultIndex,suite))
		quit:suite=""
		//do File.WriteLine("<testsuite name="""_suite_""" time="""_$fn($lg(^UnitTest.Result(pResultIndex,suite),2),"-")_""">")
		set case=""
		for  {
			set case=$order(^UnitTest.Result(pResultIndex,suite,case))
			quit:case=""
			set status=##class(%UnitTest.Report).GetTestStatus($znspace, pResultIndex,suite,case)
			do File.WriteLine("<testsuite name="""_case_""" time="""_$fnumber($listget(^UnitTest.Result(pResultIndex,suite,case),2),"-")_""">")
			do File.WriteLine("<testcase name=""TestRequirement"" time="""_$fnumber($listget($get(^UnitTest.Result(pResultIndex,suite,case,"TestRequirement")),2),"-")_""">")
			set method="TestRequirement"
			set index="",systemOut="",failure="",failureType=""
			for {
				set index=$order(^UnitTest.Result(pResultIndex,suite,case,method,index))
				quit:index=""
				if $listget(^UnitTest.Result(pResultIndex,suite,case,method,index),1)=0 {
					set failureType=$listget(^UnitTest.Result(pResultIndex,suite,case,method,index),2)
					set failure=failure_$listget(^UnitTest.Result(pResultIndex,suite,case,method,index),3)_$char(13,10)
				}
				if $listget(^UnitTest.Result(pResultIndex,suite,case,method,index),2)="LogMessage" {
					set systemOut=systemOut_$listget(^UnitTest.Result(pResultIndex,suite,case,method,index),3)
				}
			}
			if failure'="" {
				do File.WriteLine("<failure type="""_failureType_""">")
				do File.WriteLine(##class(%CSP.Page).EscapeHTML(failure))
				do File.WriteLine("</failure>")
				do File.WriteLine("<system-err>"_##class(%CSP.Page).EscapeHTML(failure)_"</system-err>")
			}
			do File.WriteLine("<system-out>"_##class(%CSP.Page).EscapeHTML(systemOut)_"</system-out>")
			do File.WriteLine("</testcase>")
			do File.WriteLine("</testsuite>")
		}
		//do File.WriteLine("</testsuite>")
	}
	do File.WriteLine("</testsuites>")
	quit $$$OK
}

}