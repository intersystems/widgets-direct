/// This is our Dispatch class for all REST Services
Class REST.Dispatch Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
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
	set %response.ContentType = "application/json"
	
	set retObj = {}
	set tSC = $$$OK
	set widgetAry = []

	&SQL(DECLARE WidgetCursor CURSOR FOR 
								SELECT 
								%Id
								INTO :WidgetId
								FROM SQLUser.Widget	
								WHERE Deleted <> 1 OR Deleted is null		
 	)	 
			
	&SQL(OPEN WidgetCursor)
	
	for {
		&SQL(FETCH WidgetCursor)
		quit:SQLCODE
		set widgetObj = ##class(User.Widget).%OpenId(WidgetId,,.tSC)
		if $$$ISERR(tSC) {
			quit
		}
		do widgetAry.%Push(widgetObj.toDynamicObject(1))
	}
	if (SQLCODE && (SQLCODE '= 100)) {
		set tSC = $$$ERROR($$$SQLCode,SQLCODE,%msg)
		// delay quit until after we close the cursor
	}
	&SQL(CLOSE WidgetCursor)
	if $$$ISERR(tSC) {
		quit tSC
	}
	
	// let's get the WWWidgets	
	&SQL(DECLARE WWWidgetCursor CURSOR FOR 
								SELECT 
								%Id
								INTO :WWWidgetId
								FROM SQLUser.WWWidget	
	)	 
	
	&SQL(OPEN WWWidgetCursor)
	
	for {
		&SQL(FETCH WWWidgetCursor)
		quit:SQLCODE
		set widgetObj = ##class(User.WWWidget).%OpenId(WWWidgetId,,.tSC)
		if $$$ISERR(tSC) {
			quit
		}
		do widgetAry.%Push(widgetObj.toDynamicObject(1))
	}
	if (SQLCODE && (SQLCODE '= 100)) {
		set tSC = $$$ERROR($$$SQLCode,SQLCODE,%msg)
		// delay quit until after we close the cursor
	}
	&SQL(CLOSE WWWidgetCursor)
	if $$$ISERR(tSC) {
		quit tSC
	}
	
	set retObj.Widgets = widgetAry
	
	write retObj.%ToJSON()
	
	quit $$$OK
}

ClassMethod GetWidgetById(WidgetId As %Integer) As %Status
{
	set %response.ContentType = "application/json"
	
	set tSC = $$$OK
	set retObj = {}
	
	if '##class(User.Widget).%ExistsId(WidgetId) {
		set %response.Status = ..#HTTP404NOTFOUND
	}
	else {
		set widgetObj = ##class(User.Widget).%OpenId(WidgetId,,.tSC)
		if $$$ISERR(tSC) {
			quit tSC
		}
		// Set output to JSON representation of object		  
		set retObj.Widget = widgetObj.toDynamicObject(1)
	}
	
	write retObj.%ToJSON()
	
	quit tSC
}

ClassMethod AddNewWidget() As %Status
{
	set %response.ContentType = "application/json"
	
	set widgetObj = ##class(User.Widget).%New()
	set updateJSON = %request.Content.Read($$$MaxLocalLength)
	
	set tSC = widgetObj.fromJSON(updateJSON)
	if $$$ISERR(tSC) {
		quit tSC
	}
	
	write widgetObj.toDynamicObject().%ToJSON()
	
	quit tSC
}

ClassMethod UpdateWidgetById(WidgetId As %String) As %Status
{
	set %response.ContentType = "application/json"
	
	set retObj = {}
	
	set widgetClass = "User.Widget"
	set internalWidgetId = WidgetId
	if ($extract(WidgetId,1) = "W") {
		set widgetClass = "User.WWWidget"
		set internalWidgetId = $extract(WidgetId,2,*)
	}
	
	if '$classmethod(widgetClass,"%ExistsId",internalWidgetId) {
		set %response.Status = ..#HTTP404NOTFOUND
	}
	else {
		set widgetObj = $classmethod(widgetClass,"%OpenId",internalWidgetId,,.tSC)
		if $$$ISERR(tSC) {
			quit tSC
		}
		
		set updateJSON = %request.Content.Read($$$MaxLocalLength)
	
		set tSC = widgetObj.fromJSON(updateJSON)
		if $$$ISERR(tSC) {
			quit tSC
		}
		
		set retObj = widgetObj.toDynamicObject()
	}
	
	write retObj.%ToJSON()

	quit $$$OK
}

ClassMethod DeleteWidgetById(WidgetId As %Integer) As %Status
{
	set %response.ContentType = "application/json"
	
	set retObj = {}
	set tSC = $$$OK
	
	if '##class(User.Widget).%ExistsId(WidgetId) {
		set %response.Status = ..#HTTP404NOTFOUND
	}
	else {
		set widgetObj = ##class(User.Widget).%OpenId(WidgetId,,.tSC)
		if $$$ISERR(tSC) {
			quit tSC
		}
		
		set widgetObj.Deleted = 1
		set tSC = widgetObj.%Save()
		if $$$ISERR(tSC) {
			quit tSC
		}
		
		set retObj = widgetObj.toDynamicObject()
	}
	
	write retObj.%ToJSON()
	
	quit tSC
}

}
