/// This is our Dispatch class for all REST Services
Class REST.Dispatch Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.widgetsdirect.com/urlmap" ]
{
<Routes>
<Route Url="/:name" Method="GET" Call="HelloWorld" Cors="false" />
</Routes>
}

ClassMethod HelloWorld(Name As %String) As %Status
{
	Set %response.ContentType="application/json"
	
	SET retObj = {}
	SET retMessage = "Welcome to Widgets Direct "_Name
	SET retObj.Message = retMessage
	//
	SET widgetAry = []
	FOR i=1:1:10 {
		SET widgetObj = {}
		SET widgetObj.Id = i
		SET widgetObj.Name = "Widget "_i
		DO widgetAry.%Push(widgetObj)
	}
	SET retObj.Widgets = widgetAry
	//
	WRITE retObj.%ToJSON()
	QUIT $$$OK
}

}
