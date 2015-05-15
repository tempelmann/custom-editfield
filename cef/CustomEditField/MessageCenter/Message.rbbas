#tag Class
Protected Class Message
Inherits Dictionary
	#tag Method, Flags = &h0
		Sub AddInfo(key as variant, info as variant)
		  //Add info to the message in a key/data fashion
		  value(key)=info
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(type as variant, sender as object)
		  self.type = Type
		  messageSender = sender
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Info(key as variant) As variant
		  //get the info for a given key
		  return Lookup(key,nil)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function InfoCount() As integer
		  return count
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MessageType() As variant
		  return type
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Sender() As object
		  return messageSender
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToString() As string
		  dim tmp as String
		  dim key as String
		  
		  tmp="Type: "+messageType+EndOfLine
		  for Each key in Keys
		    tmp=tmp+key+": "+Value(key).StringValue+EndOfLine
		  Next
		  
		  Return tmp
		End Function
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected messageSender As object
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected type As variant
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="BinCount"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Dictionary"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Count"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Dictionary"
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
