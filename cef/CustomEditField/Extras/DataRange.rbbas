#tag Class
Protected Class DataRange
	#tag Method, Flags = &h0
		Sub Constructor()
		  Constructor(0,0)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(offset as integer, length as integer)
		  moffset = offset
		  mLength = length
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function InRange(offset as integer) As Boolean
		  Return offset >= moffset and offset < moffset + mLength
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OverlapsOrTouchesRange(other as DataRange) As Boolean
		  return self.offset <= other.endOffset and other.offset <= self.endOffset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function OverlapsRange(other as DataRange) As Boolean
		  return self.offset < other.endOffset and other.offset < self.endOffset
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event LengthChanged()
	#tag EndHook


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return "["+Str(moffset)+","+Str(endOffset)+"["
			End Get
		#tag EndGetter
		DebugDescription As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return offset + length
			End Get
		#tag EndGetter
		EndOffset As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mLength
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  if mLength = value then Return
			  mLength = value
			  LengthChanged
			End Set
		#tag EndSetter
		Length As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mLength As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private moffset As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return moffset
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  moffset = value
			  
			End Set
		#tag EndSetter
		Offset As Integer
	#tag EndComputedProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="DebugDescription"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="EndOffset"
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
			Name="length"
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
			Name="offset"
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
