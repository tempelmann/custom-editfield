#tag Interface
Protected Interface IBufferStorage
	#tag Method, Flags = &h0
		Sub Copy(from as IbufferStorage, fromIndex as integer, localIndex as integer, length as integer)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Size() As integer
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Size(assigns length as integer)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function StringValue(index as integer, length as integer) As string
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StringValue(index as integer, length as integer, assigns value as string)
		  
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
