/// Class to hold our widget accessories
Class User.WidgetAccessory Extends %Persistent
{

Property Name As %String;

Property Description As %String(MAXLEN = 500);

Property Price As %Currency;

Property Quantity As %Integer;

Property FirstManufactured As %Date;

Property InProduction As %Boolean;

Property Import As %Boolean;

Property SKU As %String;

Relationship Widgets As User.WidgetAccessoryLink [ Cardinality = many, Inverse = Accessory ];

Method toJSONObject(traverseRelationships As %Boolean = 0) As %Library.DynamicObject
{
	
	set jsonReturn = {}
	set jsonReturn.Id 				 = ..%Id()
	set jsonReturn.Name 			 = ..Name
	set jsonReturn.Description 		 = ..Description
	set jsonReturn.Price			 = ..Price
	set jsonReturn.Quantity 		 = ..Quantity
	set jsonReturn.FirstManufactured = $zdate(..FirstManufactured,4)
	set jsonReturn.InProduction		 = ..InProduction
	set jsonReturn.Import			 = ..Import
	set jsonReturn.SKU				 = ..SKU
	
	if traverseRelationships {
		set widgetKey = ""
	    set widgetList = []
		do {
			set widgetLink = ..Widgets.GetNext(.widgetKey)
			if $isobject(widgetLink) && $isobject(widgetLink.Widget) {
				do widgetList.%Push(widgetLink.Widget.toJSONObject())
			}
		} while (widgetKey '= "")
		set jsonReturn.Widgets = widgetList
	}
	
	quit jsonReturn
}

Storage Default
{
<Data name="WidgetAccessoryDefaultData">
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
<Value>FirstManufactured</Value>
</Value>
<Value name="7">
<Value>InProduction</Value>
</Value>
<Value name="8">
<Value>Import</Value>
</Value>
<Value name="9">
<Value>SKU</Value>
</Value>
</Data>
<DataLocation>^User.WidgetAccessoryD</DataLocation>
<DefaultData>WidgetAccessoryDefaultData</DefaultData>
<IdLocation>^User.WidgetAccessoryD</IdLocation>
<IndexLocation>^User.WidgetAccessoryI</IndexLocation>
<StreamLocation>^User.WidgetAccessoryS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
