#tag Module
Protected Module Debugging
	#tag Method, Flags = &h1
		Protected Sub AccumulationClear()
		  AccumulatedTimesOfNames = nil
		  AccumulatedStartsOfNames = nil
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub AccumulationClear(name as String)
		  if AccumulatedTimesOfNames <> nil then
		    if AccumulatedTimesOfNames.HasKey(name) then
		      AccumulatedTimesOfNames.Remove(name)
		    end if
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function AccumulationResult() As String
		  // Returns EndOfLine-delimited rows of names with spent times
		  
		  #pragma DisableBackgroundTasks
		  
		  if AccumulatedTimesOfNames <> nil then
		    dim lines() as String
		    
		    for each name as String in AccumulatedTimesOfNames.Keys
		      dim t as Double = AccumulatedTimesOfNames.Value(name).DoubleValue
		      lines.Append name + ": " + Str (t / 1000, "#") + "ms"
		    next
		    
		    return Join (lines, EndOfLine)
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub AccumulationStart(name as String)
		  if DebugBuild or LogToFile then
		    
		    if AccumulatedStartsOfNames = nil then
		      // one-time init
		      AccumulatedStartsOfNames = new Dictionary
		      AccumulatedTimesOfNames = new Dictionary
		    end if
		    
		    AccumulatedStartsOfNames.Value (name) = Microseconds
		    
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub AccumulationStop(name as String)
		  if DebugBuild or LogToFile then
		    
		    dim now as Double = Microseconds
		    
		    if AccumulatedStartsOfNames = nil then
		      break // oops - you called Stop without calling Start first!
		      return
		    end if
		    
		    // look up the start time for 'name'
		    dim start as Double = AccumulatedStartsOfNames.Lookup (name, 0)
		    if start = 0 then
		      break // oops - you called Stop without calling Start first!
		      return
		    end if
		    
		    // increment the accumulated time for 'name'
		    AccumulatedTimesOfNames.Value (name) = (now - start) + AccumulatedTimesOfNames.Lookup (name, 0)
		    
		    // reset the start time so that we can detect a Stop call without a start call
		    AccumulatedStartsOfNames.Value (name) = 0
		    
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub DebugLog(s as String)
		  if DebugBuild or LogToFile then
		    static spc as String = "                                                                                                              "
		    dim msg as String = spc.Left(Depth*2) + s.Trim
		    System.DebugLog msg
		    if LogToFile then
		      dim now as new Date
		      TextOutputStream.Append(LogFile()).WriteLine now.SQLDateTime + " " + msg
		    end if
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function LogFile() As FolderItem
		  static f as FolderItem
		  if f = nil then
		    f = SpecialFolder.Desktop.Child(App.AppName+" DebugLog.txt")
		  end if
		  return f
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private AccumulatedStartsOfNames As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private AccumulatedTimesOfNames As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Depth As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected LogToFile As Boolean
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
			Name="LogToFile"
			Group="Behavior"
			Type="Boolean"
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
End Module
#tag EndModule
