#tag Class
Protected Class ArrayStorage
Implements IBufferStorage
	#tag Method, Flags = &h0
		Sub Constructor(size as integer)
		  ReDim Storage(size - 1)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Copy(from as IbufferStorage, fromIndex as integer, localIndex as integer, length as integer)
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  if length = 0 then Return
		  dim src as ArrayStorage = ArrayStorage(from)
		  
		  dim maxLocal, maxSrc as Integer
		  maxLocal = UBound(Storage)
		  maxSrc = UBound(src.Storage)
		  
		  for i as Integer = 0 to length - 1
		    if localIndex + i > maxLocal or fromIndex + i > maxSrc then exit for
		    Storage(localIndex + i) = src.Storage(fromIndex + i)
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Size() As integer
		  Return UBound(Storage) + 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Size(assigns length as integer)
		  // Part of the IBufferStorage interface.
		  ReDim Storage(length - 1)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue(index as integer, length as integer) As string
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  if length = 0 then Return ""
		  if index >= Size then Return ""
		  
		  //create a copy of the right size
		  dim tmp() as String
		  ReDim tmp(length - 1)
		  
		  for i as Integer = 0 to length - 1
		    tmp(i) = Storage(i + index)
		  next
		  
		  dim ret as String = Join(tmp, "")
		  
		  if ret.Encoding = nil then
		    break ' must never happen
		  end if
		  
		  return ret.ConvertEncoding(EditFieldGlobals.InternalEncoding)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StringValue(index as integer, length as integer, assigns value as string)
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  if length = 0 then Return
		  if value.Len = 0 then Return
		  
		  dim encoding as TextEncoding = value.Encoding
		  if encoding = nil then
		    // we should never get here - it would probably lead to incorreclty encoded text when it's not pure ASCII
		    break
		    encoding = Encodings.SystemDefault
		    value = value.DefineEncoding(encoding)
		  end
		  if encoding.Equals(encodings.UTF16) then
		    // UTF-16 causes problems with certain chars (e.g. "🔍"), so we must
		    // convert it into UTF-8 or UTF-32.
		    value = value.ConvertEncoding(EditFieldGlobals.InternalEncoding)
		  end if
		  
		  //split data into a tmp array
		  dim chars() as String = value.Split("")
		  
		  //and copy it
		  for i as Integer = 0 to length - 1
		    Storage(i + index) = chars(i)
		  next
		End Sub
	#tag EndMethod


	#tag Note, Name = Info
		Text storage as an array of strings.
	#tag EndNote


	#tag Property, Flags = &h21
		Private Storage() As string
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
