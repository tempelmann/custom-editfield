#tag Class
Protected Class TextSegment
Inherits DataRange
	#tag Method, Flags = &h0
		Function Clone() As textsegment
		  dim tmp as new TextSegment
		  tmp.backgroundColor = backgroundColor
		  tmp.bold = bold
		  tmp.hasBackgroundColor = hasBackgroundColor
		  tmp.italic = italic
		  tmp.lastFont = lastFont
		  tmp.lastSize = lastSize
		  tmp.textColor = textColor
		  tmp.Type = TYPE
		  tmp.underline = underline
		  tmp.width = width
		  tmp.offset = offset
		  tmp.length = length
		  
		  Return tmp
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  Constructor(0,0,0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(offset as integer, length as integer, type as integer, highlightColor as color = &c0, backgroundColor as color = &c0, bold as boolean = false, italic as boolean = false, underline as boolean = false)
		  super.Constructor(offset, length)
		  self.Type = TYPE
		  self.textColor = highlightColor
		  self.backgroundColor = backgroundColor
		  hasBackgroundColor = backgroundColor <> &c0
		  self.bold = bold
		  self.italic = italic
		  self.underline = underline
		  width = -1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SplitAtLength(length as integer) As textsegment
		  dim tmp as TextSegment = clone
		  tmp.offset = tmp.offset + length
		  tmp.length = self.length - length
		  tmp.width = -1
		  self.length = length
		  self.width = -1
		  
		  Return tmp
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		BackgroundColor As color
	#tag EndProperty

	#tag Property, Flags = &h0
		Bold As boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		HasBackgroundColor As boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		ID As string
	#tag EndProperty

	#tag Property, Flags = &h0
		Italic As boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected lastFont As string
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected lastSize As integer
	#tag EndProperty

	#tag Property, Flags = &h0
		TextColor As color
	#tag EndProperty

	#tag Property, Flags = &h0
		Type As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Underline As boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Width As double
	#tag EndProperty


	#tag Constant, Name = TYPE_EOL, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TYPE_PLACEHOLDER, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TYPE_SPACE, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TYPE_TAB, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = TYPE_WORD, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="BackgroundColor"
			Group="Behavior"
			InitialValue="&h000000"
			Type="color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="bold"
			Group="Behavior"
			InitialValue="0"
			Type="boolean"
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
		#tag EndViewProperty
		#tag ViewProperty
			Name="ID"
			Group="Behavior"
			Type="string"
			EditorType="MultiLineEditor"
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
		#tag EndViewProperty
		#tag ViewProperty
			Name="underline"
			Group="Behavior"
			InitialValue="0"
			Type="boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="width"
			Group="Behavior"
			InitialValue="0"
			Type="double"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
