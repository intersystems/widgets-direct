/// This is our Dispatch class for all REST Services
Class REST.Dispatch Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<!-- September 2017
	There is currently a that prevents the Map below from working 
	in some versions of InterSystems Cache/IRIS, so we use local Routes
	that wrap the API implementations in REST.Widget -->
<!--<Map Prefix  ="/widget"  Forward="REST.Widget" />-->
<Route Url="/version" 	Method="GET" 	Call="version" 			Cors="false" />
<Route Url="/:name" 	Method="GET" 	Call="HelloWorld" 		Cors="false" />
<Route Url="/" 			Method="GET" 	Call="GetAllWidgets" 	Cors="false" />
<Route Url="/" 			Method="POST" 	Call="AddNewWidget" 	Cors="false" />	
<Route Url="/:widgetid" Method="GET" 	Call="GetWidgetById" 	Cors="false" />
<Route Url="/:widgetid" Method="PUT" 	Call="UpdateWidgetById" Cors="false" />
<Route Url="/:widgetid"	Method="DELETE" Call="DeleteWidgetById" Cors="false" />
</Routes>
}

ClassMethod HelloWorld(Name As %String = "") As %Status
{
	set %response.ContentType = "application/json"
	
	set retObj = {}
	set retMessage = "Welcome to Widgets Direct "_Name
	set retObj.Message = retMessage

	write retObj.%ToJSON()
	
	quit $$$OK
}

ClassMethod version() As %Status
{
	set %response.ContentType = "application/json"
	
	set retObj = {}
	set retMessage = $zversion_":"_$zdatetime($horolog,3)_##class(%PopulateUtils).City()
	set retObj.Message = retMessage

	write retObj.%ToJSON()

	quit $$$OK
}

ClassMethod GetAllWidgets() As %Status
{
	quit ##class(REST.Widget).GetAllWidgets()
}

ClassMethod GetWidgetById(WidgetId As %Integer) As %Status
{
	quit ##class(REST.Widget).GetWidgetById(WidgetId)
}

ClassMethod AddNewWidget() As %Status
{
	quit ##class(REST.Widget).AddNewWidget()
}

ClassMethod UpdateWidgetById(WidgetId As %String) As %Status
{
	quit ##class(REST.Widget).UpdateWidgetById(WidgetId)
}

ClassMethod DeleteWidgetById(WidgetId As %Integer) As %Status
{
	quit ##class(REST.Widget).DeleteWidgetById(WidgetId)
}

}
