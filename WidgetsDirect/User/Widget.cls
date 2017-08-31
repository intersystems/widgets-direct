/// Persistent class to hold Widgets
Class User.Widget Extends %Persistent
{

Property Name As %String;

Property Description As %String(MAXLEN = 500);

Property Price As %Currency;

Property Quantity As %Integer;

Method toJSON() As %String
{
	
	set jsonReturn = {}
	set jsonReturn.Id 				= ..%Id()
	set jsonReturn.Name 			= ..Name
	set jsonReturn.Description 		= ..Description
	set jsonReturn.Price			= ..Price
	set jsonReturn.Quantity 		= ..Quantity
	quit jsonReturn
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
</Data>
<DataLocation>^User.WidgetD</DataLocation>
<DefaultData>WidgetDefaultData</DefaultData>
<IdLocation>^User.WidgetD</IdLocation>
<IndexLocation>^User.WidgetI</IndexLocation>
<StreamLocation>^User.WidgetS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
