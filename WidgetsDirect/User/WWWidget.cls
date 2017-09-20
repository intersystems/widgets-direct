/// Import of WWWidget database
Class User.WWWidget Extends %Persistent
{

Property WidgetName As %String;

Property Summary As %String;

Property StockLevel As %Integer;

Property Cost As %Currency;

Property Barcode As %String;

Property Location As %String;

Method toJSONObject(traverseRelationships As %Boolean = 0) As %Library.DynamicObject
{
	
	set jsonReturn				= {}
	set jsonReturn.Id			= "W"_..%Id()
	set jsonReturn.Name			= ..WidgetName
	set jsonReturn.Description	= ..Summary
	set jsonReturn.Price		= ..Cost
	set jsonReturn.Quantity		= ..StockLevel
	set jsonReturn.Barcode		= ..Barcode
	set jsonReturn.Location		= ..Location
	
	quit jsonReturn
}

Method fromJSON(json As %String) As %Status
{
	
	set jsonObj = ##class(%Library.DynamicObject).%FromJSON(json)
	
	set propsIterator = jsonObj.%GetIterator()
	while (propsIterator.%GetNext(.key,.value)) {
		if (key = "Name") {
			set ..WidgetName = value
		} elseif (key = "Description") {
			set ..Summary = value
		} elseif (key = "Price") {
			set ..Cost = value
		} elseif (key = "Quantity") {
			set ..StockLevel = value
		} elseif ((key = "Barcode") || (key = "Location")) {
			set $PROPERTY($this, key) = value
		}
	}
	
	quit ..%Save()
}

Storage Default
{
<Data name="WWWidgetDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>WidgetName</Value>
</Value>
<Value name="3">
<Value>Summary</Value>
</Value>
<Value name="4">
<Value>StockLevel</Value>
</Value>
<Value name="5">
<Value>Cost</Value>
</Value>
<Value name="6">
<Value>Barcode</Value>
</Value>
<Value name="7">
<Value>Location</Value>
</Value>
</Data>
<DataLocation>^User.WWWidgetD</DataLocation>
<DefaultData>WWWidgetDefaultData</DefaultData>
<IdLocation>^User.WWWidgetD</IdLocation>
<IndexLocation>^User.WWWidgetI</IndexLocation>
<StreamLocation>^User.WWWidgetS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
