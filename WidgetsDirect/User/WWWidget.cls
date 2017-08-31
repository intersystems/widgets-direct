/// Import of WWWidget database
Class User.WWWidget Extends %Persistent
{

Property WidgetName As %String;

Property Summary As %String;

Property StockLevel As %Integer;

Property Cost As %Currency;

Property Barcode As %String;

Property Location As %String;

Method toJSON(traverseRelationships As %Boolean = 0) As %String
{
	
	set jsonReturn = {}
	set jsonReturn.Id 				= "W"_..%Id()
	set jsonReturn.Name 			= ..WidgetName
	set jsonReturn.Description 		= ..Summary
	set jsonReturn.Price			= ..Cost
	set jsonReturn.Quantity 		= ..StockLevel
	set jsonReturn.Barcode 			= ..Barcode
	set jsonReturn.Location			= ..Location
	
	quit jsonReturn
}

Method fromJSON(json As %String) As %String
{
	
	set jsonObj = {}.%FromJSON(json)
	 
    set propsIterator = jsonObj.%GetIterator()
    While (propsIterator.%GetNext(.key,.value)) {
          if (key="Name"){
	            set ..WidgetName=value
	       } elseif (key="Description"){
		       set ..Summary=value
		   } elseif (key="Price"){
		       set ..Cost=value
		   } elseif (key="Quantity"){
		       set ..StockLevel=value
		   } elseif ((key="Barcode")||(key="Location")){
		      Set $PROPERTY($this, key) = value
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
