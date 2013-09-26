#tag Class
Protected Class LinesLock
	#tag Method, Flags = &h0
		Sub Constructor(cef as CustomEditField)
		  // acquire a lock on the LineManager
		  
		  dim lineMgr as LineManager = cef.private_lines
		  
		  if lineMgr.linesLock = nil then
		    lineMgr.linesLock = new CriticalSection
		  end if
		  
		  lineMgr.linesLock.Enter
		  
		  mLineMgr = lineMgr
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Destructor()
		  // Release the lock
		  if mLineMgr <> nil then
		    mLineMgr.linesLock.Leave
		  end if
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mLineMgr As LineManager
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
