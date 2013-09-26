#tag Class
Protected Class AccumulationTimer
	#tag Method, Flags = &h0
		Sub Constructor(name as String)
		  if DebugBuild or LogToFile then
		    mName = name
		    Debugging.AccumulationStart mName
		  end
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Destructor()
		  if DebugBuild or LogToFile then
		    Debugging.AccumulationStop mName
		  end
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mName As String
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="2147483648"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
