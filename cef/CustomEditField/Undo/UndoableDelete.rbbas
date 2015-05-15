#tag Class
Protected Class UndoableDelete
Implements UndoableAction
	#tag Method, Flags = &h0
		Sub Constructor(field as CustomEditField, offset as integer, length as integer, text as string, attrs() as TextLineAttributes, oldCaretPos as integer, ID as integer)
		  Reference = new WeakRef(field)
		  self.offset = offset
		  self.length = length
		  self.text = text
		  self.attrs = attrs
		  self.oldCaretPos = oldCaretPos
		  EventID = ID
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EventID() As integer
		  // Part of the UndoableAction interface.
		  Return EventDesc
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EventID(assigns value as integer)
		  // Part of the UndoableAction interface.
		  EventDesc = value
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Redo()
		  if owner = nil then Return
		  owner.private_remove(offset, text.len)
		  owner.SelStart = min(owner.TextLength, max(0, owner.CaretPos))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Undo()
		  if owner = nil then Return
		  owner.Insert(offset, text)
		  owner.private_lines.setAttributesOfLinesInRange(offset, length, attrs)
		  owner.SelStart = min(owner.TextLength, max(0, oldCaretPos))
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected attrs() As TextLineAttributes
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected EventDesc As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected length As integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected offset As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected oldCaretPos As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  if me.Reference <> nil then
			    return CustomEditField(me.Reference.Value)
			  else
			    return nil
			  end if
			End Get
		#tag EndGetter
		Protected owner As CustomEditField
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected Reference As weakRef
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected text As string
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
