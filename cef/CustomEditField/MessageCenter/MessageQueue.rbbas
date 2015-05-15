#tag Class
Protected Class MessageQueue
Inherits Timer
	#tag Event
		Sub Action()
		  // Timer tick... send the next queued msg
		  if ubound(queue)<0 then return
		  
		  dim msg as Message
		  msg = queue(0)
		  queue.remove(0)
		  
		  MessageCenter.sendMessage(msg)
		  
		  // if queue not empty, keep timer running
		  if UBound(queue) >= 0 then
		    me.Mode = Timer.ModeSingle
		  else
		    me.Mode = Timer.ModeOff ' necessary for RB 2012r2.1 in Cocoa - fixed in Xojo
		  end
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub addMessage(theMessage as Message)
		  queue.append theMessage
		  
		  if me.Mode = Timer.ModeOff then
		    me.Mode = Timer.ModeSingle
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1000
		Sub Constructor()
		  me.Mode = Timer.ModeOff
		  me.Period = 0 // -> delivers as soon as possible, after the current event
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function findMessageInQueue(type as variant, matchInfoKey as Variant, matchInfoValue as Variant) As Message
		  for each m as Message in queue
		    if m.MessageType = type and m.Info(matchInfoKey) = matchInfoValue then
		      return m
		    end
		  next
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private queue(-1) As Message
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			Type="Integer"
			InheritedFrom="Timer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InheritedFrom="Timer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Mode"
			Visible=true
			Group="Behavior"
			InitialValue="2"
			Type="Integer"
			EditorType="Enum"
			InheritedFrom="Timer"
			#tag EnumValues
				"0 - Off"
				"1 - Single"
				"2 - Multiple"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Timer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Period"
			Visible=true
			Group="Behavior"
			InitialValue="1000"
			Type="Integer"
			InheritedFrom="Timer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Timer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InheritedFrom="Timer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
