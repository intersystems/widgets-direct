/// This is our Dispatch class for all REST Services
Class REST.Dispatch Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.widgetsdirect.com/urlmap" ]
{
<Routes>
<Map Prefix  ="/widget"  Forward="REST.Widget" />
<Route Url="/:name" Method="GET" Call="HelloWorld" Cors="false" />
</Routes>
}

ClassMethod HelloWorld(Name As %String) As %Status
{
	Set %response.ContentType="application/json"
	
	SET retObj = {}
	SET retMessage = "Welcome to Widgets Direct "_Name
	SET retObj.Message = retMessage

	
	WRITE retObj.%ToJSON()
	QUIT $$$OK
}

}
