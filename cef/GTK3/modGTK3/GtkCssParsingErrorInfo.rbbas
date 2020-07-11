#tag Class
Protected Class GtkCssParsingErrorInfo
	#tag Method, Flags = &h0
		Sub Constructor(provider as ptr, Section as ptr, error as ptr)
		  #If TargetLinux
		    
		    Declare Function gtk_css_section_get_start_line Lib "libgtk-3" (obj as ptr) As uint32
		    Declare Function gtk_css_section_get_start_position Lib "libgtk-3" (obj as ptr) As uint32
		    Declare Function gtk_css_section_get_end_position Lib "libgtk-3" (obj as ptr) As uint32
		    Declare Function gtk_css_section_get_end_line Lib "libgtk-3" (obj as ptr) As uint32
		    Declare Function g_quark_to_string Lib "libgtk-3" (obj as ptr) As CString
		    
		    StartLine=gtk_css_section_get_start_line(Section)
		    StartPosition=gtk_css_section_get_start_position(Section)
		    Endline=gtk_css_section_get_end_line(Section)
		    EndPosition=gtk_css_section_get_end_position(Section)
		    
		    me.Provider=provider
		    
		    ErrorMessage=error.CString(8)
		  #Else
		    #Pragma unused error
		    #Pragma unused Section
		    #Pragma unused provider
		  #EndIf
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Sub Gtk_parsing_error(GtkCssProvider as ptr, GtkCssSection as ptr, GError As ptr, data as ptr)
		  #If TargetLinux
		    
		    LastParsingError=new GtkCssParsingErrorInfo(GtkCssProvider,GtkCssSection,GError)
		    
		  #Else
		    #Pragma unused data
		    #Pragma unused GError
		    #Pragma unused GtkCssSection
		    #Pragma unused GtkCssProvider
		  #EndIf
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Endline As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		EndPosition As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		ErrorMessage As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Shared LastParsingError As modGTK3.GtkCssParsingErrorInfo
	#tag EndProperty

	#tag Property, Flags = &h0
		Provider As ptr
	#tag EndProperty

	#tag Property, Flags = &h0
		StartLine As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		StartPosition As Integer
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Endline"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="EndPosition"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ErrorMessage"
			Group="Behavior"
			Type="String"
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
			Name="StartLine"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StartPosition"
			Group="Behavior"
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
