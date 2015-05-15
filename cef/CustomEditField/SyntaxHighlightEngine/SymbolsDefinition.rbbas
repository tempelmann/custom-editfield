#tag Class
Protected Class SymbolsDefinition
	#tag Method, Flags = &h0
		Sub appendToXMLNode(parent as xmlNode, depth as integer = 2)
		  //appends this context to the parent xml node
		  //this is done to export the syntax definition as an xml file.
		  
		  dim xdoc as XmlDocument
		  dim node, context as XmlNode
		  
		  xdoc = parent.OwnerDocument
		  context=parent.AppendChild(xdoc.CreateElement("symbol"))
		  
		  //name
		  context.SetAttribute("type",type)
		  
		  //entry regex?
		  if EntryRegex<>"" then
		    node=context.AppendChild(xdoc.CreateElement("entryRegEx"))
		    node.AppendChild(xdoc.CreateTextNode(EntryRegEx))
		    IndentNode(node,depth+1)
		  end if
		  
		  IndentNode(Context,depth, true)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub IndentNode(node As XmlNode, level As Integer, indentCloseTag As Boolean = False)
		  Dim i As Integer
		  Dim s As String
		  s = EndOfLine
		  For i = 1 To level
		    s = s + Chr(9) // Tab
		  Next
		  node.Parent.Insert(node.OwnerDocument.CreateTextNode(s), node)
		  If indentCloseTag Then
		    node.AppendChild(node.OwnerDocument.CreateTextNode(s))
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub loadFromXmlNode(node as xmlNode)
		  //load context out of an xml node
		  
		  //type
		  type = node.GetAttribute("type")
		  
		  dim i as Integer
		  dim subNode as XmlNode
		  
		  for i=0 to node.ChildCount-1
		    subNode=node.Child(i)
		    select case subNode.Name
		    case "entryRegEx"
		      EntryRegex = subNode.FirstChild.Value
		    end select
		  next
		End Sub
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mRegex
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mRegex = value
			End Set
		#tag EndSetter
		EntryRegex As string
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mRegex As string
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mType As string
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mType
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mType = value
			End Set
		#tag EndSetter
		Type As string
	#tag EndComputedProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="EntryRegex"
			Group="Behavior"
			Type="string"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
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
		#tag ViewProperty
			Name="Type"
			Group="Behavior"
			Type="string"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
