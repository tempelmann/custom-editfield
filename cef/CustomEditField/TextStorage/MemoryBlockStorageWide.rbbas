#tag Class
Protected Class MemoryBlockStorageWide
Implements IBufferStorage
	#tag Method, Flags = &h0
		Sub Constructor(size as integer)
		  Storage = new MemoryBlock(size * BytesPerChar)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Copy(from as IbufferStorage, fromIndex as integer, localIndex as integer, length as integer)
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  //indexes and length all have to be multiplied by BytesPerChar
		  fromIndex = fromIndex * BytesPerChar
		  localIndex = localIndex * BytesPerChar
		  length = length * BytesPerChar
		  
		  if from.size = 0 or length = 0 then Return //nuthin' to copy
		  dim src as MemoryBlockStorageWide = MemoryBlockStorageWide(from)
		  
		  Storage.StringValue(localIndex, min(length, storage.Size - localIndex)) = src.Storage.StringValue(fromIndex, min(length, src.Size * BytesPerChar - fromIndex))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Size() As integer
		  Return Storage.Size / BytesPerChar
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Size(assigns length as integer)
		  // Part of the IBufferStorage interface.
		  Storage.Size = length * BytesPerChar
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue(index as integer, length as integer) As string
		  // Part of the IBufferStorage interface.
		  if length = 0 then Return ""
		  if index >= Size then Return ""
		  
		  index = index * BytesPerChar
		  length = length * BytesPerChar
		  
		  dim res as String = Storage.StringValue(index, min(length, storage.Size - index)).DefineEncoding(Encodings.UTF32)
		  
		  return res.ConvertEncoding(EditFieldGlobals.InternalEncoding)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StringValue(index as integer, length as integer, assigns value as string)
		  // Part of the IBufferStorage interface.
		  
		  if length = 0 then Return
		  
		  #if BytesPerChar <> 4
		    error - this code requires that this value is always 4
		  #endif
		  
		  // We need to store the data in UTF-32 format
		  dim newVal as String = value
		  if newVal.Encoding <> Encodings.UTF32 then
		    #if TargetCarbon
		      // Oddly, Carbon can't convert from UTF-8 directly to UTF-32, so we go with UTF-16 in between
		      newVal = value.ConvertEncoding(Encodings.UTF16).ConvertEncoding(Encodings.UTF32)
		    #else
		      newVal = value.ConvertEncoding(Encodings.UTF32)
		    #endif
		  end if
		  
		  index = index * BytesPerChar
		  length = length * BytesPerChar
		  
		  if newVal.LenB <> length then
		    dim d as MemoryBlock = newVal
		    if d.UInt32Value(0) = &h0000FEFF or d.UInt32Value(0) = &hFFFE0000 then
		      // remove BOM
		      newVal = d.StringValue(4, d.Size-4)
		    end if
		    if newVal.LenB <> length then
		      // This would happen with UTF-16 chars that occupy two 16 bit words.
		      // For example, "🔍" has Length=2 in UTF-16, but has Length=1 in UTF-32 and in UTF-8.
		      // Since we cannot handle this, this must never happen, i.e. the caller may never
		      // handle UTF-16 encoded Strings. If it does, it's an internal bug.
		      break
		    end if
		  end if
		  
		  Storage.StringValue(index, length) = newVal
		End Sub
	#tag EndMethod


	#tag Note, Name = Info
		Text storage as a MemoryBlock
	#tag EndNote


	#tag Property, Flags = &h21
		Private Storage As memoryBlock
	#tag EndProperty


	#tag Constant, Name = BytesPerChar, Type = Double, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant


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
