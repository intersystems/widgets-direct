Class UnitTest.Widget.ToJson Extends UnitTest.Transaction 
{

Method TestSingleWidget() As %Status { 
	set widgetId=##class(UnitTest.Factory).Add("User.Widget",$lb($lb("Name","Widget1")))
	set Widget=##class(User.Widget).%OpenId(widgetId)
	set WidgetJson=Widget.toJSON().%ToJSON()
	do $$$AssertTrue(WidgetJson["""Name"":""Widget1""","Widget JSON contains widget name")
	quit $$$OK 
}

}