/// This is an abstract Requirement class.
/// Requirement implement classic Cache's %UnitTest functionality.
/// Also it may be runned through web browser.
/// Each requirement may also be represented as a CSP page.
/// After execution, requirement results are stored in ^UnitTest.Result global.
Class UnitTest.Abstract Extends (%UnitTest.TestCase, %CSP.Page)
{

/// Your test title
Parameter TITLE As %String;

/// default maximum global accesses for a single row based method call
/// can override per class or put explicitly in each method call
Parameter GlobalsMaxMethod = 100;

/// default maximum global accesses for a query
/// can override per class or put explicitly in each method call
Parameter GlobalsMaxQuery = 1000;

/// Use evaluation methods to test performance 
Property PerformanceTest As %Boolean [ InitialExpression = {..UsePerformanceTest()} ];

/// This method is used to display a test page.
ClassMethod OnPage() As %Status [ ServerOnly = 1 ]
{
	lock
	do ##class(UnitTest.Formatter).Run($classname($this))
	quit $$$OK
}

/// Run this specific test (in debug mode)
ClassMethod Run(qualifiers As %String = "") As %Status [ ProcedureBlock = 1 ]
{
	set sc=##class(UnitTest.Manager).RunTest($classname($this),"/recursive=0"_qualifiers)
	quit sc
}

/// Run this test and all its children
ClassMethod RunRecursive(qualifiers As %String = "") As %Status [ ProcedureBlock = 1 ]
{
	set sc=##class(UnitTest.Manager).RunTest($classname($this),"/recursive=1"_qualifiers)
	quit sc
}

/// Execute expression using current object's context
Method Execute(expr) As %String
{
	new %result
	xecute "s %result="_expr
	quit %result
}

/// Log execution HTML result. Now it is stored as a log message.
Method LogResult(result)
{
	set oldDisplay=..Manager.Display
	set ..Manager.Display=""
	do ..LogMessage($get(result))
	set ..Manager.Display=oldDisplay
	quit
}

/// Get last test result instance id, dateTime, status, duration and HTML
/// All this information is stored in ^UnitTest.Result
ClassMethod GetLastResult(ByRef dateTime, ByRef status, ByRef duration, ByRef html, ByRef suite) As %String [ ProcedureBlock = 1 ]
{
	set (dateTime,status,duration,html,suite)=""
	set name=$classname($this)
	&SQL(SELECT Duration, TestSuite->TestInstance, TestSuite->Name, TestSuite->TestInstance->DateTime
		INTO :qDuration, :qInstance, :qSuite, :qDateTime
		FROM %IGNOREINDICES %UnitTest_Result.TestCase.idxName %UnitTest_Result.TestCase
		WHERE Name=:name
		ORDER BY TestSuite->TestInstance DESC)
	if SQLCODE quit ""
	set dateTime=qDateTime
	set duration=qDuration
	set status=##class(%UnitTest.Report).GetTestStatus($znspace, qInstance, qSuite, name)
	set htmlIndex=$order(^UnitTest.Result(qInstance, qSuite, name, "TestRequirement",""),-1)-1
	set html=$listget($get(^UnitTest.Result(qInstance, qSuite, name, "TestRequirement",htmlIndex)),3)
	set suite=qSuite
	quit qInstance
}

Method AssertEqualsViaMacro(autoquoted = "", value1 = "", value2 = "", description = "") As %Boolean
{
	set manager=r%Manager
	set description=$get(description)_": "_value1_"=="_value2_" in "_..ParseAutoQuoted(autoquoted,"equals")
	set success=value1=value2
	do manager.LogAssert(success,"AssertEquals",description)
	if 'success&&'..Debug quit $$$ERROR(5001,description)
	if 'success break
	quit $$$OK
}

Method AssertNotEqualsViaMacro(autoquoted = "", value1 = "", value2 = "", description = "") As %Boolean
{
	set success=##super(autoquoted, value1, value2, description)
	if 'success quit $$$ERROR(5001,description_": "_value1_"=="_value2_" in "_autoquoted)
	quit $$$OK
}

Method AssertTrueViaMacro(autoquoted = "", value = "", description = "") As %Boolean
{
	set success=##super(autoquoted, value, description)
	if 'success quit $$$ERROR(5001,description_": "_value_"!=TRUE in "_autoquoted)
	quit $$$OK
}

Method AssertNotTrueViaMacro(autoquoted = "", value = "", description = "") As %Boolean
{
	set success=##super(autoquoted, value, description)
	if 'success quit $$$ERROR(5001,description_": "_value_"== TRUE in "_autoquoted)
	quit $$$OK
}

Method AssertStatusOKViaMacro(autoquoted = "", status = "", description = "") As %Boolean
{
	set success=##super(autoquoted, status, .description)
	if 'success quit $$$ERROR(5001,description_" in "_autoquoted)
	quit $$$OK
}

Method AssertStatusNotOKViaMacro(autoquoted = "", status = "", description = "") As %Boolean
{
	set success=##super(autoquoted, status, description)
	if 'success quit $$$ERROR(5001,description_" IS OK in "_autoquoted)
	quit $$$OK
}

Method AssertStatusEqualsViaMacro(autoquoted = "", value1 = "", value2 = "", description = "") As %Boolean
{
	set success=##super(autoquoted, value1, value2, description)
	if 'success quit $$$ERROR(5001,description_": STATUS NOT EQUAL in "_autoquoted)
	quit $$$OK
}

Method AssertFilesSameViaMacro(autoquoted, file1, file2, description) As %Boolean
{
	set success=##super(autoquoted, file1, file2, description)
	if 'success quit $$$ERROR(5001,description_": "_file1_"!="_file2_" in "_autoquoted)
	quit $$$OK
}
/// Run a class method and:
/// 1. compare the result against an expected value, this can be a single value "A" or a list $lb("A","B","C")
/// 2. compare the global count against an expected maximum
/// itmid can uniquely identify a specific test in list within a test method e.g. #1.1,   #1.2  etc
/// output informative information about the code that was run, the actual value and the expected value

Method StringEquals(itmid, expectedvalue, globalsmax, classname, methodname, args...) As %Status [ Final ]
{
	if +$get(globalsmax)=0 set globalsmax=..#GlobalsMaxMethod
	set tResult="-99999"
	
	try {
		set pTime=$zhorolog
		set pLines=$zutil(67,8,$job)
		set pGlobals=$zutil(67,9,$job)
		
		if $get(args)="" set tResult=$classmethod(classname,methodname)
		if $get(args)=1 set tResult=$classmethod(classname,methodname,args(1))
		if $get(args)=2 set tResult=$classmethod(classname,methodname,args(1),args(2))
		if $get(args)=3 set tResult=$classmethod(classname,methodname,args(1),args(2),args(3))
		if $get(args)=4 set tResult=$classmethod(classname,methodname,args(1),args(2),args(3),args(4))
		if $get(args)=5 set tResult=$classmethod(classname,methodname,args(1),args(2),args(3),args(4),args(5))
		if $get(args)=6 set tResult=$classmethod(classname,methodname,args(1),args(2),args(3),args(4),args(5),args(6))
		if $get(args)=7 set tResult=$classmethod(classname,methodname,args(1),args(2),args(3),args(4),args(5),args(6),args(7))
		if $get(args)=8 set tResult=$classmethod(classname,methodname,args(1),args(2),args(3),args(4),args(5),args(6),args(7),args(8))
		//no reason this is limited to 8 - at the tme of writing this was more than enough for the ct classes
		set pTime=$zhorolog-pTime
		set pLines=$zutil(67,8,$job)-pLines
		set pGlobals=$zutil(67,9,$job)-pGlobals
	} catch(e) {
		//try and void the pain of hidden errors and put them
		set tResult=e.Name_" "_e.Location
		set pTime=""
		set pLines=""
		set pGlobals=""
	}
	
	//if both are lists should use $listsame... but for now format as strings
	if $listvalid(expectedvalue)&&(expectedvalue'="") set expectedvalue="["_$listtostring(expectedvalue,",")_"]"
	if $listvalid(tResult)&&(tResult'="") set tResult="["_$listtostring(tResult,",")_"]"
	set argsdisplay=""
	for j=1:1:$get(args) set argsdisplay=argsdisplay_$select(argsdisplay'="":",",1:"")_""""_args(j)_""""
	do $$$AssertEquals(tResult,expectedvalue,"##Class("_classname_")."_methodname_"("_argsdisplay_") ["_itmid_"] Return Value: '"_tResult_"' Expected: '"_expectedvalue_"'")
	//less than or equals
	if ..PerformanceTest do $$$AssertTrue(pGlobals'>globalsmax,"##Class("_classname_")."_methodname_"("_argsdisplay_") ["_itmid_"] Global Count: '"_pGlobals_"' Expected: '<="_globalsmax_"'")
}
/// Run a class query and:
/// 1. compare the result against an expected value, this is a list of lists (one list per expected row)
///   the comaprison will only check up to the first five rows returned
/// 2. compare the global count against an expected maximum
/// itmid can uniquely identify a specific test in list within a test method e.g. #1.1,   #1.2  etc
/// output informative information about the code that was run, the actual value and the expected value

Method QueryEquals(itmid, expectedvalue, globalsmax, classname, queryname, args...) As %Status [ Final ]
{
	if +$get(globalsmax)=0 set globalsmax=..#GlobalsMaxQuery
	set tResult=$listbuild("-99999")
	try {
		set pTime=$zhorolog
		set pLines=$zutil(67,8,$job)
		set pGlobals=$zutil(67,9,$job)
		
		set rs=##class(%ResultSet).%New()
		set rs.ClassName=classname
		set rs.QueryName=queryname
		if $get(args)="" set sc=rs.Execute()
		if $get(args)=1 set sc=rs.Execute(args(1))
		if $get(args)=2 set sc=rs.Execute(args(1),args(2))
		if $get(args)=3 set sc=rs.Execute(args(1),args(2),args(3))
		if $get(args)=4 set sc=rs.Execute(args(1),args(2),args(3),args(4))
		if $get(args)=5 set sc=rs.Execute(args(1),args(2),args(3),args(4),args(5))
		if $get(args)=6 set sc=rs.Execute(args(1),args(2),args(3),args(4),args(5),args(6))
		if $get(args)=7 set sc=rs.Execute(args(1),args(2),args(3),args(4),args(5),args(6),args(7))
		if $get(args)=8 set sc=rs.Execute(args(1),args(2),args(3),args(4),args(5),args(6),args(7),args(8))
		//no reason this is limited to 8 - at the tme of writing this was more than enough for the ct classes
		if $$$ISERR(sc) do $system.OBJ.DisplayError(sc)
		set colcount=rs.GetColumnCount()
		set tResult=""
		//test only first 5 rows
		for j=1:1:5 {
			if 'rs.Next() quit
			
			set valx=""
			for jj=1:1:colcount set valx=valx_$listbuild(rs.GetData(jj))
			set tResult=tResult_$listbuild(valx)
		}
		do rs.Close()
		set pTime=$zhorolog-pTime
		set pLines=$zutil(67,8,$job)-pLines
		set pGlobals=$zutil(67,9,$job)-pGlobals
	} catch(e) {
		//try and void the pain of hidden errors and put them
		set tResult=e.Name_" "_e.Location
		set pTime=""
		set pLines=""
		set pGlobals=""
	}
	
	set argsdisplay=""
	for j=1:1:$get(args) set argsdisplay=argsdisplay_$select(argsdisplay'="":",",1:"")_$select($data(args(j)):""""_args(j)_"""",1:"")
	do $$$AssertTrue($listsame(tResult,expectedvalue),"##Class("_classname_")."_queryname_"("_argsdisplay_") ["_itmid_"] Return Value: '"_..ListOfListToDisplay(tResult)_"' Expected: '"_..ListOfListToDisplay(expectedvalue)_"'")
	//less than or equals
	if ..PerformanceTest do $$$AssertTrue(pGlobals'>globalsmax,"##Class("_classname_")."_queryname_"("_argsdisplay_") ["_itmid_"] Global Count: '"_pGlobals_"' Expected: '<="_globalsmax_"'")
}
/// output formatter to display a List of lists

ClassMethod ListOfListToDisplay(listoflist) As %String [ Final ]
{
	if '$listvalid(listoflist) quit listoflist
	set tResult=""
	for j=1:1:$listlength(listoflist) {
		set tResult=tResult_$select(tResult'="":",",1:"")_"$lb("""_$listtostring($listget(listoflist,j),""",""")_""")"
	}
	quit $select(tResult'="":"$lb("_tResult_")",1:tResult)
}

/// Decides whether or not to test performance as part of the unit test.
ClassMethod UsePerformanceTest() As %Boolean
{
	quit $$$YES
}

}