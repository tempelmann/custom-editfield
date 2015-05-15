#tag Class
Protected Class ModifiedLineRangeManager
	#tag Method, Flags = &h0
		Sub AddRange(newStart as Integer, newLength as Integer)
		  if newLength = 0 then
		    return
		  end if
		  
		  mLock.Enter
		  
		  dim newEnd as Integer = newStart + newLength
		  
		  // cut the new range down to the space that's not already occupied by the existing ranges
		  dim i as Integer
		  for i = 0 to mRanges.Ubound
		    dim thisRange as DataRange = mRanges(i)
		    
		    if thisRange.offset > newEnd then
		      // there are no ranges before the new one -> add new range to end of array
		      exit
		    end if
		    
		    if thisRange.endOffset < newStart then
		      continue
		    end if
		    
		    // there is an overlap
		    
		    // newStart <= this range's end
		    
		    // find more ranges that touch the new range
		    dim nextRange as DataRange
		    dim k as Integer = i
		    while k < mRanges.Ubound
		      nextRange = mRanges(k+1)
		      if nextRange.endOffset <= newEnd then
		        // remove this range entirely
		        mRanges.Remove k+1
		        nextRange = nil
		      elseif nextRange.offset <= newStart then
		        // this range can be merged with the new range
		        exit while
		      else
		        k = k + 1
		      end if
		    wend
		    
		    // cut the new range
		    
		    if thisRange.offset <= newStart then
		      if thisRange.endOffset >= newEnd then
		        // all covered - we're done
		      else
		        // extend thisRange to end of new range
		        thisRange.length = newEnd - thisRange.offset
		        if nextRange <> nil and thisRange.endOffset >= nextRange.offset then
		          // thisRange reaches into next range -> merge them
		          thisRange.length = nextRange.endOffset - thisRange.offset
		          mRanges.Remove k
		        else
		          // we're done
		        end
		      end if
		    else // thisRange.offset > newStart
		      // adjust the start of thisRange
		      dim added as Integer = thisRange.offset - newStart
		      thisRange.offset = thisRange.offset - added
		      thisRange.length = thisRange.length + added
		      // adjust the end of thisRange
		      if thisRange.endOffset < newEnd then
		        thisRange.length = newEnd - thisRange.offset
		        if nextRange <> nil and thisRange.endOffset >= nextRange.offset then
		          // thisRange reaches into next range -> merge them
		          thisRange.length = nextRange.endOffset - thisRange.offset
		          mRanges.Remove k
		        end if
		      end if
		      
		    end if
		    
		    mLock.Leave
		    return
		    
		  next
		  
		  mRanges.Insert i, new DataRange (newStart, newEnd-newStart)
		  
		  mLock.Leave
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Clear()
		  ReDim mRanges(-1)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  mLock = new CriticalSection
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RemoveLine(offset as Integer) As Boolean
		  mLock.Enter
		  
		  for i as Integer = 0 to mRanges.Ubound
		    dim thisRange as DataRange = mRanges(i)
		    
		    if thisRange.offset > offset then
		      // not found
		      exit
		    end if
		    
		    if thisRange.endOffset <= offset then
		      continue
		    end if
		    
		    // found - now cut it out
		    
		    if offset = thisRange.offset then
		      // head cut
		      thisRange.length = thisRange.length - 1
		      thisRange.offset = offset + 1
		      if thisRange.length = 0 then
		        mRanges.Remove i
		      end if
		    elseif offset = thisRange.endOffset -1 then
		      // tail cut
		      thisRange.length = thisRange.length - 1
		      if thisRange.length = 0 then
		        mRanges.Remove i
		      end if
		    else
		      // center cut
		      mRanges.Insert i+1, new DataRange (offset+1, thisRange.EndOffset-offset-1)
		      thisRange.length = offset - thisRange.offset
		    end if
		    
		    mLock.Leave
		    return true
		    
		  next
		  
		  mLock.Leave
		  return false
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RemoveNextLine(ByRef lineIdx as Integer) As Boolean
		  if mRanges.Ubound < 0 then
		    return false
		  end if
		  
		  mLock.Enter
		  
		  dim firstRange as DataRange = mRanges(0)
		  lineIdx = firstRange.offset
		  if not RemoveLine (lineIdx) then
		    break // internal error!
		  end
		  
		  mLock.Leave
		  
		  return true
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mLock As CriticalSection
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			This array is sorted by DataRange.offset, no overlaps allowed
		#tag EndNote
		Private mRanges() As DataRange
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mRanges.Ubound + 1
			End Get
		#tag EndGetter
		RangeCount As Integer
	#tag EndComputedProperty


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
			Name="RangeCount"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
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
