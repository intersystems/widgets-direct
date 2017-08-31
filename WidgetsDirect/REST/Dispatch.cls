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
	&SQL(DECLARE WidgetCurs CURSOR FOR 
    					    	   SELECT 
								   %Id
								   INTO :Id
								   FROM SQLUser.Widget			
 					)	 
			
    		
    &SQL(OPEN WidgetCurs)
    
    For { &SQL(FETCH WidgetCurs)
    	  Quit:SQLCODE
    	  set widgetObj = ##class(User.Widget).%OpenId(Id)
    	  do widgetAry.%Push(widgetObj.toJSON())
	    }
    &SQL(CLOSE WidgetCurs)
	SET retObj.Widgets = widgetAry
	//
	
	
	WRITE retObj.%ToJSON()
	QUIT $$$OK
}

}
