#tag Class
Protected Class TextPlaceholder
Inherits TextSegment
	#tag Method, Flags = &h0
		Function Clone() As textsegment
		  dim tmp as new TextPlaceholder(offset, length, textRange.offset, textRange.length, self.textColor, backgroundColor, bold, italic, underline)
		  tmp.lastFont = lastFont
		  tmp.lastSize = lastSize
		  tmp.Type = TYPE
		  tmp.width = width
		  tmp.placeholderBackgroundColor = placeholderBackgroundColor
		  
		  Return tmp
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(offset as integer, length as integer, labelOffset as integer, labelLength as Integer, highlightColor as color, backgroundColor as color, bold as boolean = false, italic as boolean = false, underline as boolean = false)
		  // Calling the overridden superclass constructor.
		  // Note that this may need modifications if there are multiple constructor choices.
		  // Possible constructor calls:
		  // Constructor(offset as integer, length as integer, type as integer, highlightColor as color = &c0, backgroundColor as color = &c0, bold as boolean = false, italic as boolean = false, underline as boolean = false) -- From TextSegment
		  // Constructor() -- From TextSegment
		  // Constructor(offset as integer, length as integer) -- From DataRange
		  // Constructor() -- From DataRange
		  
		  Super.Constructor(offset, length, TextSegment.TYPE_PLACEHOLDER, HighlightColor, &c0, bold, italic, underline)
		  placeholderBackgroundColor = backgroundColor
		  if placeholderBackgroundColor = &c0 then placeholderBackgroundColor = &ce9effa
		  textRange = new DataRange(labelOffset, labelLength)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function inRange(offset as integer) As boolean
		  Return offset > self.offset and offset < self.offset + self.length //changed to  < instead of <= per Thomas Tempelmann's suggestion.
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		placeholderBackgroundColor As color
	#tag EndProperty

	#tag Property, Flags = &h0
		textRange As DataRange
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="BackgroundColor"
			Group="Behavior"
			InitialValue="&h000000"
			Type="color"
			InheritedFrom="TextSegment"
		#tag EndViewProperty
		#tag ViewProperty
			Name="bold"
			Group="Behavior"
			InitialValue="0"
			Type="boolean"
			InheritedFrom="TextSegment"
		#tag EndViewProperty
		#tag ViewProperty
			Name="DebugDescription"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
			InheritedFrom="DataRange"
		#tag EndViewProperty
		#tag ViewProperty
			Name="EndOffset"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="DataRange"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasBackgroundColor"
			Group="Behavior"
			Type="boolean"
			InheritedFrom="TextSegment"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ID"
			Group="Behavior"
			Type="string"
			EditorType="MultiLineEditor"
			InheritedFrom="TextSegment"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="italic"
			Group="Behavior"
			InitialValue="0"
			Type="boolean"
			InheritedFrom="TextSegment"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="length"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="DataRange"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="offset"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="DataRange"
		#tag EndViewProperty
		#tag ViewProperty
			Name="placeholderBackgroundColor"
			Group="Behavior"
			InitialValue="&h000000"
			Type="color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TextColor"
			Group="Behavior"
			InitialValue="&h000000"
			Type="color"
			InheritedFrom="TextSegment"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Type"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="TextSegment"
		#tag EndViewProperty
		#tag ViewProperty
			Name="underline"
			Group="Behavior"
			InitialValue="0"
			Type="boolean"
			InheritedFrom="TextSegment"
		#tag EndViewProperty
		#tag ViewProperty
			Name="width"
			Group="Behavior"
			InitialValue="0"
			Type="double"
			InheritedFrom="TextSegment"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
