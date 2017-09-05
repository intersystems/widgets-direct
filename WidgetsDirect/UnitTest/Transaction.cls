/// This is a class for tests that change transactional data.
/// It's run within a transaction which is rolled back at the end.
Class UnitTest.Transaction Extends UnitTest.Abstract
{

Method OnBeforeAllTests() As %Status
{
	tstart
	if ..Manager.Debug set %debug=1
	quit $$$OK
}

Method OnAfterAllTests() As %Status
{
	set Status=$$$OK

	trollback
	
	// Kill newly created ID counter globals
	// ^||FactoryKill is populated by UnitTest.Factory
	set i=""
	for  {
		set i=$order(^||FactoryKill(i))
		quit:i=""
		set %d(0)=$list(^||FactoryKill(i),2)
		try{
			xecute "kill "_$list(^||FactoryKill(i),1)
		} catch ex {
			set Status = $$$ADDSC(Status, ex.AsStatus())
		}
	}
	kill ^||FactoryKill
	
	quit Status
}

}