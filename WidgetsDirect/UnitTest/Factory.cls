Include (%occInclude, %outUnitTest)

/// This is a generic object factory class
Class UnitTest.Factory [ Abstract ]
{

/// This method is used to add new object of ClassName class into database.
/// Returns ID of new object.
/// If there is an error during save throws an exception
/// Properties are in form $lb($lb(propName1,value1),$lb(propName2,value2),....)
/// 
/// You can specify property names and values for ClassName and for any of its required DRs.
/// If property is a required DR this method will create a new object by calling itself recursively.
/// If property is required string it will fill it with a random value.
ClassMethod Add(ClassName As %String, Properties As %List = "", ByRef Status As %Status = {$$$OK}) As %String
{
	if $tlevel = 0 {
		set Status = $$$ADDSC(Status, $$$ERROR($$$GeneralError, "UnitTest.Factory unavailable outside a transaction."))
		quit ""
	}
	
	set initValue=""
	do ..GetFieldsInfo(ClassName,.populate,.parref)
	for i=1:1:$listlength(Properties) {
		set currentProp=$listget(Properties,i)
		set prop=$select($listvalid(currentProp):$listget(currentProp,1),1:$piece(currentProp,"=",1))
		set value=$select($listvalid(currentProp):$listget(currentProp,2),1:$piece(currentProp,"=",2,99))
		if prop=parref set initValue=value
	}
	if parref'="",initValue="" {
		set initValue=..Add($$$comMemberKeyGet(ClassName,$$$cCLASSproperty,parref,$$$cPROPtype),Properties,.Status)
		set Properties=Properties_$listbuild($listbuild(parref,initValue))
	}
	$$$QuitOnError(..CheckIndexGlobal(ClassName,initValue))
	set obj=$classmethod(ClassName,"%New",initValue)
	do obj.%DowngradeConcurrency(0)
	for i=1:1:$listlength(Properties) {
		set currentProp=$listget(Properties,i)
		set prop=$select($listvalid(currentProp):$listget(currentProp,1),1:$piece(currentProp,"=",1))
		set value=$select($listvalid(currentProp):$listget(currentProp,2),1:$piece(currentProp,"=",2,99))
		if prop="" continue
		if '##class(%Dictionary.CompiledProperty).%ExistsId(ClassName_"||"_prop) continue
		if ##class(%Dictionary.CompiledMethod).%ExistsId(ClassName_"||"_prop_"BuildValueArray") {
			/// list of datatype property
			do $method($property(obj,prop),"InsertObjectId",value)
		} elseif ##class(%Dictionary.CompiledMethod).%ExistsId(ClassName_"||"_prop_"SetObjectId") {
			/// object reference property
			do $method(obj,prop_"SetObjectId",value)
		} else {
			/// scalar property
			set $property(obj,prop)=value
		}
		kill populate(prop)
	}
	
	// Fill remaining required fields with random values
	set prop=""
	for {
		set prop=$order(populate(prop),1,required)
		quit:prop=""
		
		set value = ""
		set collection = $$$comMemberKeyGet(ClassName,$$$cCLASSproperty,prop,$$$cPROPcollection)
		set dataType = $$$comMemberKeyGet(ClassName,$$$cCLASSproperty,prop,$$$cPROPtype)
		set classType = $$$getClassType(dataType)
		set typeCategory = $case(classType,$$$cCLASSCLASSTYPEDATATYPE:"literal",$$$cCLASSCLASSTYPEPERSISTENT:"reference",$$$cCLASSCLASSTYPESTREAM:"stream",:"serial")
		
		if ##class(%Dictionary.CompiledMethod).%ExistsId(ClassName_"||"_prop_"SetObjectId"),collection="" {
			// object reference property
			if $method(obj,prop_"GetObjectId")="" {
				set value = ..Add(dataType,Properties,.Status)
				do $method(obj,prop_"SetObjectId",value)
				//if $g(%debug) write !,prop," = $lb("""_value_""","""_dataType_""")"
			}
		} elseif ($$$comMemberArrayGet(ClassName,$$$cCLASSproperty,prop,$$$cPROPparameter,"VALUELIST")'="") {
			set value = $piece($$$comMemberArrayGet(ClassName,$$$cCLASSproperty,prop,$$$cPROPparameter,"VALUELIST"),",",2)
			set $property(obj,prop) = value
			//if $g(%debug) write !,prop," = "_value
		} elseif collection = $$$cPROPCOLLECTIONARRAY, typeCategory = "literal" {
			set array = $property(obj,prop)
			set value = ..GetLiteralValue(ClassName, prop, dataType)
			do array.SetAt(value,1)
			//if $g(%debug) write !,prop,"(1) = "_value
		}	elseif collection = $$$cPROPCOLLECTIONLIST, classType = $$$cCLASSCLASSTYPEPERSISTENT {
			if $property(obj,prop).Count() < 1 {
				set value = ..Add(dataType,Properties,.Status)
				if $$$ISOK(Status) set Status = $property(obj,prop).InsertObjectId(value)
				//if $g(%debug) write !,prop," = $lb("_value_")"
			}
		}	elseif collection = $$$cPROPCOLLECTIONLIST, typeCategory = "literal" {
			set array = $property(obj,prop)
			set value = ..GetLiteralValue(ClassName, prop, dataType)
			do array.Insert(value)
			//if $g(%debug) write !,prop," = $lb("_value_")"
		} elseif $zobjproperty(obj,prop)="" {
			// scalar property
			set value = ..GetLiteralValue(ClassName, prop, dataType)
			set $property(obj,prop) = value
			//if $g(%debug) write !,prop," = "_value
		}
	}
		
	set Status = $$$ADDSC(Status, $method(obj,"%Save",0))
	//if $g(%debug),$$$ISERR(Status) break
	if $$$ISERR(Status) {
		write !!,"FACTORY ERROR: error returned while inserting object of class "_ClassName
		do $system.OBJ.DisplayError(Status)
		do $system.OBJ.Dump(obj)
		//if $g(%debug) break
		ztrap "FACTORY"
	}
	set id = $method(obj,"%Id")
	if id="" {
		write !!,"FACTORY ERROR: failed to insert object of class "_ClassName
		do $system.OBJ.Dump(obj)
		//if $g(%debug) break
		ztrap "FACTORY"
	}
	quit id
}

/// Get information about required fields and parref of a given class
ClassMethod GetFieldsInfo(ClassName As %String, Output Populate As %String, Output ParRef As %String) As %Status
{
	set ParRef=""
	set prop=""
	for {
		set prop=$$$comMemberNext(ClassName,$$$cCLASSproperty,prop)
		quit:prop=""
		
		#; Check to see if this property is the parent.
		set relationship=$$$defMemberKeyGet(ClassName,$$$cCLASSproperty,prop,$$$cPROPrelationship)
		if relationship {
			set cardinality=$$$defMemberKeyGet(ClassName,$$$cCLASSproperty,prop,$$$cPROPcardinality)
			if (cardinality="parent") set ParRef=prop
		}
		
		if ($extract(prop)="%") continue
		#; oddDEF is used as oddCOM does not reflect required fields in all circumstances.  For example, User.ARCBillGrp::ARCBGCode.
		set required = ($$$defMemberKeyGet(ClassName,$$$cCLASSproperty,prop,$$$cPROPrequired))||($$$comMemberKeyGet(ClassName,$$$cCLASSproperty,prop,$$$cPROPrequired))
		if ('required) continue
		if $$$comMemberKeyGet(ClassName,$$$cCLASSproperty,prop,$$$cPROPprivate) continue
		if $$$comMemberKeyGet(ClassName,$$$cCLASSproperty,prop,$$$cPROPcalculated) continue
		if $$$comMemberKeyGet(ClassName,$$$cCLASSproperty,prop,$$$cPROPtransient) continue
		
		set Populate(prop)=required
	}
	quit $$$OK
}

/// Generate random value for specific field
ClassMethod GetLiteralValue(ClassName, Property, DataType As %String)
{
	
	set dataTypeShortName = $$$ClassShortName(DataType)
	set minlen = $$$comMemberArrayGet(ClassName,$$$cCLASSproperty,Property,$$$cPROPparameter,"MINLEN")
	set maxlen = $$$comMemberArrayGet(ClassName,$$$cCLASSproperty,Property,$$$cPROPparameter,"MAXLEN")
	if (dataTypeShortName = "String") && (minlen > 1) {
		set val = ##class(%PopulateUtils).StringMin(minlen,maxlen)
	} else {
		#; Property parameter should remain undefined if there is not a value.
		#; Using null instead of undefined will change the populate behaviour.
		set minval = $$$comMemberArrayGet(ClassName,$$$cCLASSproperty,Property,$$$cPROPparameter,"MINVAL")
		set maxval = $$$comMemberArrayGet(ClassName,$$$cCLASSproperty,Property,$$$cPROPparameter,"MAXVAL")
		set scale = $$$comMemberArrayGet(ClassName,$$$cCLASSproperty,Property,$$$cPROPparameter,"SCALE")
		if minval = "" kill minval
		if maxval = "" kill maxval
		if scale = "" kill scale
		if (dataTypeShortName="StandardTypeDataType") {
			set StandardTypeName=$$$comMemberArrayGet(ClassName,$$$cCLASSproperty,Property,$$$cPROPparameter,"StandardTypeName")
		}
		
		set val = $case(dataTypeShortName,
			"String":		..GetRandomString(.maxlen),
			"Integer":		##class(%PopulateUtils).Integer(.minval,.maxval),
			"Date":			##class(%PopulateUtils).Date(.minval,.maxval),
			"Time":	##class(%PopulateUtils).Integer($get(minval,0),$get(maxval,83699)),
			"Binary":		##class(%PopulateUtils).String(.maxlen),
			"Double":		##class(%PopulateUtils).Float(.minval,.maxval,.scale),
			"Name":			##class(%PopulateUtils).Name(),
			"Boolean":		$random(2),
			"Currency":		##class(%PopulateUtils).Currency(.minval,.maxval),
			"Float":		##class(%PopulateUtils).Float(.minval,.maxval,.scale),
			"Numeric":		##class(%PopulateUtils).Float(.minval,.maxval,.scale),
			"TimeStamp":	##class(%PopulateUtils).TimeStamp(.minval,.maxval),
			"StandardTypeDataType": $order(^websys.StandardTypeD("STD",StandardTypeName,"ITM",0,"StoredValue","")),
			:			"")
	}
	
	if val = "" {
		set msg = "Could not generate literal value"
		set msg = msg_$$$NL_"ClassName: "_ClassName
		set msg = msg_$$$NL_"Property: "_Property
		set msg = msg_$$$NL_"DataType: "_DataType
		write !,msg
		set generalException = ##class(%Exception.General).%New("Unit Test Factory Exception", "5001", , msg)
		throw generalException
	}
	
	quit val
}

/// Check index value if it did not exist in database
/// It will be killed on transaction rollback if it doesn't exist
ClassMethod CheckIndexGlobal(ClassName, initValue = "") As %Status
{
	set IdLocation=$$$comMemberKeyGet(ClassName,$$$cCLASSstorage,"SQLStorage",$$$cSDEFidlocation)
	if IdLocation="" quit $$$OK
	try {
		set %d(0)=initValue
		set currentId=$get(@IdLocation)
		if currentId="" set ^||FactoryKill($increment(^||FactoryKill))=$listbuild(IdLocation,initValue)
	} catch(e) {
	}
	quit $$$OK
}

/// Return a string value of the form <random character>_<random number less than 9999>_<$ZHorolog> and whose length
/// does not exceed <var>len</var>.
ClassMethod GetRandomString(len As %Integer = 50) As %String
{
	quit $extract($char($random(26)+65)_$random(9999)_$translate($zhorolog,"."),1,$select(len>0:len,1:1))
}

}