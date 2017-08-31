/// This is a class to populate some example data
Class Data.PopulateWidgets Extends %RegisteredObject
{

ClassMethod CreateWidgets() As %Status
{
	
	
	set widgetObj 				= ##class(User.Widget).%New()
	set widgetObj.Name 			= "Waterproof Widget" 
	set widgetObj.Description 	= "This widget is waterproof to a depth of 100m for up to 7 hours" 
	set widgetObj.Price			= 10.99
	set widgetObj.Quantity		= 10
	do widgetObj.%Save()
	
	set widgetObj 				= ##class(User.Widget).%New()
	set widgetObj.Name 			= "Motorbike Widget" 
	set widgetObj.Description 	= "This widget attaches to all Japanese motorbikes" 
	set widgetObj.Price			= 110.99
	set widgetObj.Quantity		= 7
	do widgetObj.%Save()
	
	set widgetObj 				= ##class(User.Widget).%New()
	set widgetObj.Name 			= "Woodland Widget" 
	set widgetObj.Description 	= "This widget can identify plant and tree species" 
	set widgetObj.Price			= 7.99
	set widgetObj.Quantity		= 17
	do widgetObj.%Save()
	
	set widgetObj 				= ##class(User.Widget).%New()
	set widgetObj.Name 			= "Racing Widget" 
	set widgetObj.Description 	= "This widget record lap time and average speed" 
	set widgetObj.Price			= 1000.98
	set widgetObj.Quantity		= 100
	do widgetObj.%Save()
	
	set widgetObj 				= ##class(User.Widget).%New()
	set widgetObj.Name 			= "Music Widget" 
	set widgetObj.Description 	= "This widget can autotune all brass and string instruments" 
	set widgetObj.Price			= 1.99
	set widgetObj.Quantity		= 107
	do widgetObj.%Save()
		set widgetObj 				= ##class(User.Widget).%New()
	set widgetObj.Name 			= "Microscope Widget" 
	set widgetObj.Description 	= "This widget can magnify to 1000x" 
	set widgetObj.Price			= 8.99
	set widgetObj.Quantity		= 84
	do widgetObj.%Save()
	
	QUIT $$$OK
}

ClassMethod PopulateAccessories()
{

	s acc = ##class(User.WidgetAccessory).%New()
	s acc.Name = "Flotation Aid" 
	s acc.Description = "This accessory helps the widget to float"
	s acc.Price = 18.54
	s acc.Quantity = 10
	s acc.FirstManufactured = $H-1235 
	s acc.InProduction =1
	s acc.Import =1
	s acc.SKU ="AE235B6FB"
	w acc.%Save()

	s acc = ##class(User.WidgetAccessory).%New()
	s acc.Name = "Flight Aid" 
	s acc.Description = "This accessory helps the widget to fly"
	s acc.Price = 180.54
	s acc.Quantity = 87
	s acc.FirstManufactured = $H-300 
	s acc.InProduction =1
	s acc.Import =1
	s acc.SKU ="AE2388DBB"
	w acc.%Save()

	s acc = ##class(User.WidgetAccessory).%New()
	s acc.Name = "Slip Cover" 
	s acc.Description = "This accessory protects the widget from scratches"
	s acc.Price = 7.24
	s acc.Quantity = 100
	s acc.FirstManufactured = $H-10 
	s acc.InProduction =1
	s acc.Import =1
	s acc.SKU ="AE2377800"
	w acc.%Save()
}

ClassMethod PopulateLinks()
{
	
	s link = ##class(User.WidgetAccessoryLink).%New()
	d link.WidgetSetObjectId(1)
	d link.AccessorySetObjectId(1) 	
	w link.%Save()

	s link = ##class(User.WidgetAccessoryLink).%New()
	d link.WidgetSetObjectId(1)
	d link.AccessorySetObjectId(2) 	
	w link.%Save()

	s link = ##class(User.WidgetAccessoryLink).%New()
	d link.WidgetSetObjectId(1)
	d link.AccessorySetObjectId(3) 	
	w link.%Save()
	
	s link = ##class(User.WidgetAccessoryLink).%New()
	d link.WidgetSetObjectId(2)
	d link.AccessorySetObjectId(2) 	
	w link.%Save()

	
	s link = ##class(User.WidgetAccessoryLink).%New()
	d link.WidgetSetObjectId(3)
	d link.AccessorySetObjectId(1) 	
	w link.%Save()

	s link = ##class(User.WidgetAccessoryLink).%New()
	d link.WidgetSetObjectId(5)
	d link.AccessorySetObjectId(3) 	
	w link.%Save()
}

}
