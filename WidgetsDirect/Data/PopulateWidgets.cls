/// This is a class to populate some example data
Class Data.PopulateWidgets Extends %RegisteredObject
{

/// Run all population methods
ClassMethod Populate() As %Status
{
	set sc = $$$OK
	set sc = $$$ADDSC(sc,##class(Data.PopulateWidgets).CreateWidgets())
	set sc = $$$ADDSC(sc,##class(Data.PopulateWidgets).PopulateAccessories())
	set sc = $$$ADDSC(sc,##class(Data.PopulateWidgets).PopulateLinks())
	set sc = $$$ADDSC(sc,##class(Data.PopulateWidgets).CreateWWWidgets())
	quit sc
}

ClassMethod CreateWidgets() As %Status
{
	set tSC = $$$OK
	
	set tSC = $$$ADDSC(tSC,..CreateWidget("Waterproof Widget", 10.99, 10, "This widget is waterproof to a depth of 100m for up to 7 hours"))
	set tSC = $$$ADDSC(tSC,..CreateWidget("Motorbike Widget", 110.99, 7, "This widget attaches to all Japanese motorbikes"))
	set tSC = $$$ADDSC(tSC,..CreateWidget("Woodland Widget", 7.99, 17, "This widget can identify plant and tree species"))
	set tSC = $$$ADDSC(tSC,..CreateWidget("Racing Widget", 1000.98, 100, "This widget records lap time and average speed"))
	set tSC = $$$ADDSC(tSC,..CreateWidget("Music Widget", 1.99, 107, "This widget can autotune all brass and string instruments"))
	set tSC = $$$ADDSC(tSC,..CreateWidget("Microscope Widget", 8.99, 84, "This widget can magnify to 1000x"))
	
	quit tSC
}

ClassMethod PopulateAccessories()
{
	set tSC = $$$OK
	
	set tSC = $$$ADDSC(tSC,..CreateAccessory("Flotation Aid", 18.54, 10, $horolog-1235, 1, 1, "AE235B6FB", "This accessory helps the widget to float"))
	set tSC = $$$ADDSC(tSC,..CreateAccessory("Flight Aid", 180.54, 87, $horolog-300, 1, 1, "AE2388DBB", "This accessory helps the widget to fly"))
	set tSC = $$$ADDSC(tSC,..CreateAccessory("Slip Cover", 7.24, 100, $horolog-10, 1, 1, "AE2377800", "This accessory protects the widget from scratches"))
	
	quit tSC
}

ClassMethod PopulateLinks() As %Status
{
	set tSC = $$$OK
	
	set tSC = $$$ADDSC(tSC,..PopulateLink(1,1))
	set tSC = $$$ADDSC(tSC,..PopulateLink(1,2))
	set tSC = $$$ADDSC(tSC,..PopulateLink(1,3))
	set tSC = $$$ADDSC(tSC,..PopulateLink(2,2))
	set tSC = $$$ADDSC(tSC,..PopulateLink(3,1))
	set tSC = $$$ADDSC(tSC,..PopulateLink(5,3))

	quit tSC
}

ClassMethod CreateWWWidgets() As %Status
{
	set tSC = $$$OK
	
	set tSC = $$$ADDSC(tSC,..CreateWWWidget("Widget of Power", 40.99, 40, "50011001104", "HQ", "This widget provides 110V60 or 230V50"))
	set tSC = $$$ADDSC(tSC,..CreateWWWidget("Widget of Speed", 140.99, 87, "50011001105", "HQ", "This widget can travel at 143mph"))
	set tSC = $$$ADDSC(tSC,..CreateWWWidget("Widget of Light", 50.99, 54, "50011001106", "HQ", "This widget can provide 10000 Candlepower"))
	
	quit tSC
}

ClassMethod CreateWidget(
	Name As %String,
	Price As %Currency,
	Quantity As %Integer,
	Description As %String
) As %Status
{
	set widgetObj				= ##class(User.Widget).%New()
	set widgetObj.Name			= Name
	set widgetObj.Price			= Price
	set widgetObj.Quantity		= Quantity
	set widgetObj.Description	= Description
	
	quit widgetObj.%Save()
}

ClassMethod CreateAccessory(
	Name As %String,
	Price As %Currency,
	Quantity As %Integer,
	FirstManufactured As %Date,
	InProduction As %Boolean,
	Import As %Boolean,
	SKU As %String,
	Description As %String
) As %Status
{
	set accessory					= ##class(User.WidgetAccessory).%New()
	set accessory.Name				= Name 
	set accessory.Price				= Price
	set accessory.Quantity			= Quantity
	set accessory.FirstManufactured	= FirstManufactured 
	set accessory.InProduction		= InProduction
	set accessory.Import			= Import
	set accessory.SKU				= SKU
	set accessory.Description		= Description
	
	quit accessory.%Save()
}

ClassMethod PopulateLink(
	WidgetId As %Integer,
	AccessoryId As %Integer
) As %Status
{
	set accessoryLink = ##class(User.WidgetAccessoryLink).%New()
	if '##class(User.Widget).%ExistsId(WidgetId) {
		quit $$$ERROR($$$LoadObjectNotFound,"User.Widget",WidgetId)
	}
	if '##class(User.WidgetAccessory).%ExistsId(AccessoryId) {
		quit $$$ERROR($$$LoadObjectNotFound,"User.WidgetAccessory",AccessoryId)
	}
	set tSC = accessoryLink.WidgetSetObjectId(WidgetId)
	if $$$ISERR(tSC) {
		quit tSC
	}
	set tSC = accessoryLink.AccessorySetObjectId(AccessoryId)
	if $$$ISERR(tSC) {
		quit tSC
	}
	
	quit accessoryLink.%Save()
}


ClassMethod CreateWWWidget(
	Name As %String,
	Cost As %Currency,
	StockLevel As %Integer,
	Barcode As %String,
	Location As %String,
	Summary As %String
) As %Status
{
	set widgetObj				= ##class(User.WWWidget).%New()
	set widgetObj.WidgetName	= Name 
	set widgetObj.Cost			= Cost
	set widgetObj.StockLevel	= StockLevel
	set widgetObj.Barcode		= Barcode
	set widgetObj.Location		= Location
	set widgetObj.Summary		= Summary
	
	quit widgetObj.%Save()
}

}
