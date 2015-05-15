#tag Interface
Protected Interface UndoableAction
	#tag Method, Flags = &h0
		Function EventID() As integer
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EventID(assigns value as integer)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Redo()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Undo()
		  
		End Sub
	#tag EndMethod


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
End Interface
#tag EndInterface
