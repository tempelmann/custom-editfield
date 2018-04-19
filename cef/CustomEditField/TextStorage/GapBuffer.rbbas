#tag Class
Class GapBuffer
	#tag Method, Flags = &h1
		Protected Sub checkBounds(index as integer)
		  //checks if index is within bounds...
		  
		  if index < 0 or index > Length then
		    dim ex as new OutOfBoundsException
		    ex.Message = "Tried to access the buffer at invalid index."+EndOfLine+"Logic length = "+str(Length)+", index = "+str(index)
		    Raise ex
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  //create a new gap buffer
		  buffer = getBufferStorage(0)
		  gapStart = 0
		  gapEnd = 0
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub ensureBufferSize(minRequiredLength as integer)
		  //makes sure there's at least minRequiredLength spaces available in the buffer
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  dim newbuffer as IBufferStorage
		  
		  dim delta as Integer
		  
		  //gap too small
		  if GapLength < minRequiredLength or GapLength < minGapSize then
		    //resize buffer
		    delta = max(minRequiredLength, maxGapSize) - GapLength
		    newbuffer = getBufferStorage(buffer.Size + delta)
		    
		    //gap too big!
		  elseif GapLength > maxGapSize then
		    delta = max(minRequiredLength, minGapSize) - GapLength
		    newbuffer = getBufferStorage(buffer.size + delta)
		    
		  else //no need to resize!
		    Return
		    
		  end if
		  
		  //copy contents to new buffer
		  newbuffer.Copy(buffer, 0, 0, gapStart)
		  'newbuffer.StringValue(0, gapStart) = buffer.StringValue(0, gapStart) //before gap
		  newbuffer.Copy(buffer, gapEnd, newbuffer.Size - (buffer.Size - gapEnd), buffer.Size - gapEnd)
		  'newbuffer.StringValue(newbuffer.Size - (buffer.Size - gapEnd), buffer.Size - gapEnd) = buffer.StringValue(gapEnd, buffer.Size - gapEnd) //after gap
		  buffer = newbuffer
		  gapEnd = gapEnd + delta
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function getBufferStorage(size as integer) As IBufferStorage
		  #if EditFieldGlobals.TextStorageType = EditFieldGlobals.STORAGE_MEMORYBLOCK then
		    Return new MemoryBlockStorage(size)
		  #elseif EditFieldGlobals.TextStorageType = EditFieldGlobals.STORAGE_ARRAY then
		    Return new ArrayStorage(size)
		  #else
		    Return new MemoryBlockStorageWide(size)
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getCharAt(offset as integer) As string
		  //if offset before gap
		  if offset < gapStart then
		    Return buffer.StringValue(offset, 1)
		  end if
		  
		  //else, offset it by length
		  Return buffer.StringValue(offset + GapLength, 1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getText(index as integer, length as integer) As string
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  //nothing to get
		  if Length <= 0 or self.Length = 0 then Return ""
		  
		  checkBounds(index)
		  
		  dim delta as Integer = index + Length
		  
		  //all text before gap?
		  if delta < gapStart then
		    Return buffer.StringValue(index, Length)
		  end if
		  
		  //all text after gap?
		  if index > gapStart then
		    return buffer.StringValue(index + GapLength, Length)
		  end if
		  
		  //text before and after gap
		  dim result as IBufferStorage = getBufferStorage(length)
		  result.Copy(buffer, index, 0, gapStart - index)
		  result.Copy(buffer, gapEnd, gapStart - index, delta - gapStart)
		  
		  Return result.StringValue(0, result.size)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub insert(index as integer, text as string)
		  replace(index, 0, text)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub placeGap(index as integer)
		  //move the gap to a different place within the buffer
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  if index = gapStart and GapLength>0 then Return
		  
		  dim newbuffer as IBufferStorage = buffer
		  
		  //empty?
		  if buffer.Size = 0 then Return
		  
		  //moving before current gap
		  if index < gapStart then
		    dim count as Integer = gapStart - index //items to move
		    newbuffer.StringValue(index + GapLength, Count) = buffer.StringValue(index, Count) //move items
		    
		    gapStart = gapStart - Count
		    gapEnd = gapEnd - Count
		    
		    //moving after current gap start
		  else
		    dim count as Integer = index - gapStart //items to move
		    if count > 0 then
		      newbuffer.StringValue(gapStart, Count) = buffer.StringValue(gapEnd, Count) //move items
		      
		      gapStart = gapStart + Count
		      gapEnd = gapEnd + Count
		    end if
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function remove(index as integer, length as integer) As boolean
		  //make sure we can remove
		  if index < 0 or index > self.Length or self.Length = 0 then Return false
		  replace(index, Length, "")
		  Return true
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub replace(index as integer, length as integer, text as string)
		  text = text.ConvertEncoding(EditFieldGlobals.InternalEncoding) ' make sure it's not in UTF-16
		  
		  checkBounds(index)
		  
		  placeGap(index)
		  dim minLengthRequired as Integer = text.len
		  ensureBufferSize(minLengthRequired)
		  
		  //replace chars by moving them INTO the gap
		  gapEnd = gapEnd + Length
		  
		  //add the text
		  buffer.StringValue(index, text.len) = text
		  gapStart = gapStart + text.len
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub setText(text as string)
		  //set the whole thing at once
		  
		  if text.Encoding=nil then //Text without encoding cannot be converted and will cause a break in MemoryBlockStorageWide.StringValue
		    raise new TextHasNoEncodingException
		  end if
		  
		  text = text.ConvertEncoding(EditFieldGlobals.InternalEncoding) ' make sure it's not in UTF-16
		  buffer.Size = text.len
		  buffer.StringValue(0, text.len) = text
		  gapStart = text.Len/2
		  gapEnd = gapStart
		End Sub
	#tag EndMethod


	#tag Note, Name = Info
		loosely adapted from:
		http://www.codeproject.com/KB/recipes/GenericGapBuffer.aspx
		
		more info here:
		http://en.wikipedia.org/wiki/Gap_buffer
	#tag EndNote


	#tag Property, Flags = &h1
		Protected buffer As IBufferStorage
	#tag EndProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  return mgapEnd
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  if value > buffer.Size then value = buffer.Size
			  mgapEnd = value
			End Set
		#tag EndSetter
		Protected gapEnd As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return gapEnd - gapStart
			End Get
		#tag EndGetter
		GapLength As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected gapStart As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return buffer.Size - GapLength
			End Get
		#tag EndGetter
		Length As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mgapEnd As Integer
	#tag EndProperty


	#tag Constant, Name = maxGapSize, Type = Double, Dynamic = False, Default = \"256", Scope = Private
	#tag EndConstant

	#tag Constant, Name = minGapSize, Type = Double, Dynamic = False, Default = \"32", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="GapLength"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
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
			Name="Length"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
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
