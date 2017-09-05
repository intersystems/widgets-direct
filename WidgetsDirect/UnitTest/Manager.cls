/// Sightly changed %UnitTest manager.
/// The main goal is not to use filesystem for testing and use class definitions instead
Class UnitTest.Manager Extends %UnitTest.Manager
{
/// Same as <b>RunTest</b>, but requires three arguments.  These arguments can be null, as ("","","").
ClassMethod RunTestSuites(testspec As %String = "", qspec As %String = "", userparam As %String = "") As %Status
{
	set manager=..%New()
	if manager=$$$NULLOREF quit %objlasterror
	
	set sc=$$$qualifierParse("UnitTest",.qspec,.qstruct) quit:$$$ISERR(sc) sc
	
	set manager.Debug=$$$qualifierGetValue(qstruct,"debug")
	set manager.Display=$select($$$qualifierGetValue(qstruct,"displaylog"):"log",1:"")_","_$select($$$qualifierGetValue(qstruct,"displayerror"):"error",1:"")
	set manager.UserParam=userparam
	
	set suite=$piece(testspec,":",1)
	// tests variable is divided by suites
	if $$$qualifierGetValue(qstruct,"recursive")=0 {
		set tests(suite)=$listbuild(suite)
	} else {
		set tests(suite)=$listbuild(suite)
		set child=suite_"."
		set pointCount=$length(child,".")
		for {
			set child=$order(^oddDEF(child))
			if child'[(suite_".") quit
			if '$$issubclassof^%occCompile(child,"%UnitTest.TestCase") continue
			set tests($piece(child,".",1,pointCount))=$get(tests($piece(child,".",1,pointCount)))_$listbuild(child)
		}
	}
	
	set zhBegin=$zhorolog
	
	set suite="" for  set suite=$order(tests(suite)) quit:suite=""  do
	. do manager.RunOneTestSuite(suite,tests(suite),testspec,.qstruct)
	
	do manager.SaveResult($zhorolog-zhBegin)
	
	set manager.Display="log,error"
	if $$$qualifierGetValue(qstruct,"run") do manager.PrintURL()
	
	quit $$$OK
}

Method RunOneTestSuite(suite As %String, tests As %String, testspec As %String, qstruct)
{
	set testcase=$piece(testspec,":",2)
	set testmethod=$piece(testspec,":",3)
	do ..PrintLine("===============================================================================",0)
	do ..PrintLine("Suite: "_suite,0)
	do ..PrintLine("===============================================================================",0)
	
	do ..LogStateBegin(suite) do  do ..LogStateEnd($zhorolog-zhsBegin)
	. //
	. set zhsBegin=$zhorolog
	. if tests="" do ..PrintLine("No classes found for testsuite "_suite,1) quit
	. //
	. if $$$qualifierGetValue(qstruct,"run")=0 do ..PrintLine("Skipping running testsuite "_suite,1)
	. else  do
	. . for i=1:1:$listlength(tests) do
	. . . set class=$listget(tests,i)
	. . . if testcase'="",class'=testcase quit
	. . . if '$$issubclassof^%occCompile(class,"%UnitTest.TestCase") quit
	. . . do ..RunOneTestCase(suite,class,testmethod)
	. //
	. set sc=$$$OK
	do ..PrintLine("",0)
	
	quit
}

Method PrintURL()
{
	set s = ##class(%RoutineMgr).GetWebServerPort(.p, .h, .up, .url)
	set url = "http://"_##class(%SYSTEM.INetInfo).LocalHostName()_":"_57772_"/"
	do ..PrintLine("Use the following URL to view the result:")
	do ..PrintLine("<a href="""_url_"csp/samples/%25UnitTest.Report.cls?NS="_##class(%CSP.Page).EscapeURL($znspace)_"&INDEX="_i%LogIndex_""">")
	do ..PrintLine(url_"csp/samples/%25UnitTest.Report.cls?NS="_##class(%CSP.Page).EscapeURL($znspace)_"&INDEX="_i%LogIndex_"</a>")
	quit
}

ClassMethod OutputResultsXml(pFileName As %String) As %Status
{
	set File=##class(%File).%New(pFileName)
	set i=$order(^UnitTest.Result(""),-1)
	if i="" quit $$$OK // no results
	
	kill ^||TMP // results global
	set suite="" for {
		set suite=$order(^UnitTest.Result(i,suite))
		quit:suite=""
		set ^||TMP("S",suite,"time")=$listget(^UnitTest.Result(i,suite),2)
		
		set case="" for {
			set case=$order(^UnitTest.Result(i,suite,case))
			quit:case=""
			
			if $increment(^||TMP("S",suite,"tests"))
			set ^||TMP("S",suite,"C",case,"time")=$listget(^UnitTest.Result(i,suite),2)
			set method="" for {
				set method=$order(^UnitTest.Result(i,suite,case,method))
				quit:method=""
				set ^||TMP("S",suite,"C",case,"M",method,"time")=$listget(^UnitTest.Result(i,suite,case,method),2)
				set assert="" for {
					set assert=$order(^UnitTest.Result(i,suite,case,method,assert))
					quit:assert=""
					if $increment(^||TMP("S",suite,"assertions"))
					if $increment(^||TMP("S",suite,"C",case,"assertions"))
					if $increment(^||TMP("S",suite,"C",case,"M",method,"assertions"))
					if $listget(^UnitTest.Result(i,suite,case,method,assert))=0 {
						if $increment(^||TMP("S",suite,"failures"))
						if $increment(^||TMP("S",suite,"C",case,"failures"))
						if $increment(^||TMP("S",suite,"C",case,"M",method,"failures"))
						set ^||TMP("S",suite,"C",case,"M",method,"failure")=$get(^||TMP("S",suite,"C",case,"M",method,"failure"))
							_$listget(^UnitTest.Result(i,suite,case,method,assert),2)
							_": "_$listget(^UnitTest.Result(i,suite,case,method,assert),3)
							_$char(13,10)
					}
				}
				if ($listget(^UnitTest.Result(i,suite,case,method))=0)
				&& ('$data(^||TMP("S",suite,"C",case,"M",method,"failures"))) {
					if $increment(^||TMP("S",suite,"failures"))
					if $increment(^||TMP("S",suite,"C",case,"failures"))
					if $increment(^||TMP("S",suite,"C",case,"M",method,"failures"))
					set ^||TMP("S",suite,"C",case,"M",method,"failure")=$get(^||TMP("S",suite,"C",case,"M",method,"failure"))
						_$listget(^UnitTest.Result(i,suite,case,method),3)
						_": "_$listget(^UnitTest.Result(i,suite,case,method),4)
						_$char(13,10)
				}
			}
			
			if $listget(^UnitTest.Result(i,suite,case))=0
			&& ('$data(^||TMP("S",suite,"C",case,"failures"))) {
				if $increment(^||TMP("S",suite,"failures"))
				if $increment(^||TMP("S",suite,"C",case,"failures"))
				if $increment(^||TMP("S",suite,"C",case,"M",case,"failures"))
				set ^||TMP("S",suite,"C",case,"M",case,"failure")=$get(^||TMP("S",suite,"C",case,"M",case,"failure"))
					_$listget(^UnitTest.Result(i,suite,case),3)
					_": "_$listget(^UnitTest.Result(i,suite,case),4)
					_$char(13,10)
			}
		}
	}
	
	do File.Open("WSN")
	do File.WriteLine("<?xml version=""1.0"" encoding=""UTF-8"" ?>")
	do File.WriteLine("<testsuites>")
	set suite="" for {
		set suite=$order(^||TMP("S",suite))
		quit:suite=""
		do File.Write("<testsuite")
		do File.Write(" name="""_$zconvert(suite,"O","XML")_"""")
		do File.Write(" assertions="""_$get(^||TMP("S",suite,"assertions"))_"""")
		do File.Write(" time="""_$get(^||TMP("S",suite,"time"))_"""")
		do File.Write(" tests="""_$get(^||TMP("S",suite,"tests"))_"""")
		do File.WriteLine(">")
		set case="" for {
			set case=$order(^||TMP("S",suite,"C",case))
			quit:case=""
			do File.Write("<testsuite")
			do File.Write(" name="""_$zconvert(case,"O","XML")_"""")
			do File.Write(" assertions="""_$get(^||TMP("S",suite,"C",case,"assertions"))_"""")
			do File.Write(" time="""_$get(^||TMP("S",suite,"C",case,"time"))_"""")
			do File.Write(" tests="""_$get(^||TMP("S",suite,"C",case,"tests"))_"""")
			do File.WriteLine(">")
			
			set method="" for {
				set method=$order(^||TMP("S",suite,"C",case,"M",method))
				quit:method=""
				do File.Write("<testcase")
				do File.Write(" name="""_$zconvert(method,"O","XML")_"""")
				do File.Write(" assertions="""_$get(^||TMP("S",suite,"C",case,"M",method,"assertions"))_"""")
				do File.Write(" time="""_$get(^||TMP("S",suite,"C",case,"M",method,"time"))_"""")
				do File.WriteLine(">")
				if $data(^||TMP("S",suite,"C",case,"M",method,"failure")) {
					do File.Write("<failure type=""cache-error"" message=""Cache Error"">")
					do File.Write($zconvert(^||TMP("S",suite,"C",case,"M",method,"failure"),"O","XML"))
					do File.WriteLine("</failure>")
				}
				do File.WriteLine("</testcase>")
			}
			do File.WriteLine("</testsuite>")
		}
		do File.WriteLine("</testsuite>")
	}
	do File.WriteLine("</testsuites>")
	do File.Close()
	kill ^||TMP
	quit $$$OK
}

Method LogStateStatus(status, action)
{
	if $$$ISOK(status) quit
	do $system.Status.DecomposeStatus(status,.errorarray,"-d") set errortext=$get(errorarray(1))
	set testsuite=i%TheStack(i%TheStack,"suite")
	set testcase=i%TheStack(i%TheStack,"case")
	set testmethod=i%TheStack(i%TheStack,"method")
	set message="0:"_action_":"_errortext
	if $data(^||FactoryError) set message=message_" Factory Error:"_$system.Status.GetErrorText(^||FactoryError)
	for i=$stack:-1:10 { //10 is a stack level of test manager
		set message=message_$char(13,10)_"Stack "_i_": "_$stack(i)_" "_$stack(i,"place")_" "_$text(@$piece($stack(i,"place")," ",1))
	}
	if testmethod'="" {
		set ^||TempLog(i%TempLogIndex,testsuite,testcase,testmethod)=$listbuild(0,0,action,errortext)
	} elseif testcase'="" {
		set ^||TempLog(i%TempLogIndex,testsuite,testcase)=$listbuild(0,0,action,errortext)
	} else {
		set ^||TempLog(i%TempLogIndex,testsuite)=$listbuild(0,0,action,errortext)
	}
	do ..PrintLine("LogStateStatus:"_message)
	do ..PrintErrorLine("LogStateStatus:"_message)
	if '..Debug quit
	break  quit
}

}