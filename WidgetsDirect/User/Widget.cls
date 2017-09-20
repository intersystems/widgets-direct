/// Persistent class to hold Widgets
Class User.Widget Extends %Persistent
{

Property Name As %String;

Property Description As %String(MAXLEN = 500);

Property Price As %Currency;

Property Quantity As %Integer;

Property Deleted as %Boolean;

Relationship Accessories As User.WidgetAccessoryLink [ Cardinality = many, Inverse = Widget ];

Method toJSONObject(traverseRelationships As %Boolean = 0) As %Library.DynamicObject
{
	
	set jsonReturn = {}
	set jsonReturn.Id 				= ..%Id()
	set jsonReturn.Name 			= ..Name
	set jsonReturn.Description 		= ..Description
	set jsonReturn.Price			= ..Price
	set jsonReturn.Quantity 		= ..Quantity
	
	if traverseRelationships {
		set accessoryKey = ""
		set accessoryList = []
		do {
			set accLink = ..Accessories.GetNext(.accessoryKey)
			if $isobject(accLink) && $isobject(accLink.Accessory) {
				do accessoryList.%Push(accLink.Accessory.toJSONObject())
			}
		} while (accessoryKey '= "")
		set jsonReturn.Accessories = accessoryList
	}
	
	quit jsonReturn
}

Method fromJSON(json As %String) As %Status
{
	
	set jsonObj = ##class(%Library.DynamicObject).%FromJSON(json)
	
	set propsIterator = jsonObj.%GetIterator()
	while (propsIterator.%GetNext(.key,.value)) {
		if ((key="Name")||(key="Description")||(key="Price")||(key="Quantity")) {
			set $PROPERTY($this, key) = value
		}
	}
	
	quit ..%Save()
}

Storage Default
{
<Data name="WidgetDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Description</Value>
</Value>
<Value name="4">
<Value>Price</Value>
</Value>
<Value name="5">
<Value>Quantity</Value>
</Value>
<Value name="6">
<Value>Deleted</Value>
</Value>
</Data>
<DataLocation>^User.WidgetD</DataLocation>
<DefaultData>WidgetDefaultData</DefaultData>
<IdLocation>^User.WidgetD</IdLocation>
<IndexLocation>^User.WidgetI</IndexLocation>
<StreamLocation>^User.WidgetS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
