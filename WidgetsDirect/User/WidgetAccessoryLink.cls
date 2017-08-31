Class User.WidgetAccessoryLink Extends %Persistent
{

Relationship Widget As User.Widget [ Cardinality = one, Inverse = Accessories ];

Relationship Accessory As User.WidgetAccessory [ Cardinality = one, Inverse = Widgets ];

Index WidgetIndex On Widget;

Index AccessoryIndex On Accessory;

Storage Default
{
<Data name="WidgetAccessoryLinkDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Widget</Value>
</Value>
<Value name="3">
<Value>Accessory</Value>
</Value>
</Data>
<DataLocation>^User.WidgetAccessoryLinkD</DataLocation>
<DefaultData>WidgetAccessoryLinkDefaultData</DefaultData>
<IdLocation>^User.WidgetAccessoryLinkD</IdLocation>
<IndexLocation>^User.WidgetAccessoryLinkI</IndexLocation>
<StreamLocation>^User.WidgetAccessoryLinkS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
