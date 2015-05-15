#tag Class
Protected Class CharSelectionManager
	#tag Method, Flags = &h0
		Function AddSelection(selection as CharSelection) As charSelection
		  if Selection.length = 0 then Return nil
		  
		  dim tmpSelection as CharSelection
		  dim overlapResult as Integer
		  
		  for i as Integer = 0 to UBound(Selections)
		    tmpSelection = Selections(i)
		    overlapResult = tmpSelection.OverlapsSelection(Selection)
		    
		    if overlapResult <> CharSelection.OVERLAP_NONE then
		      dim newOffset as Integer
		      
		      if tmpSelection.SelectionColor = selection.SelectionColor then
		        
		        dim newLength as Integer
		        dim newStartLine as Integer
		        dim newEndLine as Integer
		        
		        //merge selections if colors are the same
		        newOffset = min(tmpSelection.offset, Selection.offset)
		        newLength = max(tmpSelection.offset + tmpSelection.length, selection.offset + selection.length) - newOffset
		        newStartLine = min(tmpSelection.StartLine, selection.StartLine)
		        newEndLine = max(tmpSelection.EndLine, Selection.EndLine)
		        
		        Selection.StartLine = newStartLine
		        Selection.EndLine = newEndLine
		        Selection.offset = newOffset
		        Selection.length = newLength
		        
		        selections.Remove(i)
		        i = i - 1
		      else
		        
		        select case overlapResult
		        case CharSelection.OVERLAP_END, CharSelection.OVERLAP_CONTAINS
		          //add the remaining range to the range arrays for further sub-splitting or merging down the line...
		          dim tmp as new CharSelection(Selection.offset, tmpSelection.offset + tmpSelection.length - Selection.offset, Selection.StartLine, tmpSelection.EndLine, tmpSelection.SelectionColor)
		          tmp.LosesFocus = tmpSelection.LosesFocus
		          tmp.Rounded = tmpSelection.Rounded
		          selections.Append(tmp)
		          
		          //split tmpSelection at end and merge the end with Selection
		          tmpSelection.length = Selection.offset - tmpSelection.offset
		          tmpSelection.EndLine = Selection.StartLine
		          
		          
		        case CharSelection.OVERLAP_START
		          newOffset = Selection.offset + selection.length
		          tmpSelection.length = tmpSelection.offset + tmpSelection.length - newOffset
		          tmpSelection.offset = newOffset
		          tmpSelection.StartLine = Selection.EndLine
		          
		        else
		          //new selection totally swallows the old
		          selections.Remove(i)
		          i = i - 1
		          
		        end select
		        
		        
		      end if
		      
		    end if
		  next
		  
		  selections.Append(Selection)
		  mSelectioncount = UBound(Selections) + 1
		  Return selection
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Clear()
		  ReDim Selections(-1)
		  mSelectioncount = 0
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SelectionsForLine(lineIndex as integer) As charSelection()
		  dim result() as CharSelection
		  
		  dim Selection as CharSelection
		  for each Selection in Selections
		    if Selection.IsLineIndexInRange(lineIndex) then
		      result.Append Selection
		    end if
		  next
		  
		  Return result
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mSelectioncount As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mSelectioncount
			End Get
		#tag EndGetter
		SelectionCount As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected Selections() As charSelection
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="2147483648"
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
			Name="SelectionCount"
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
