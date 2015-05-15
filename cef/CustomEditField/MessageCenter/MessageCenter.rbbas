#tag Module
Protected Module MessageCenter
	#tag Method, Flags = &h1
		Protected Function isMessageInQueue(type as variant, matchInfoKey as Variant, matchInfoValue as Variant) As Boolean
		  if queue <> nil then
		    return queue.findMessageInQueue (type, matchInfoKey, matchInfoValue) <> nil
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function messageInQueue(type as variant, matchInfoKey as Variant, matchInfoValue as Variant) As Message
		  if queue <> nil then
		    return queue.findMessageInQueue (type, matchInfoKey, matchInfoValue)
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub queueMessage(theMessage as Message)
		  if messages = nil then return //no receivers
		  if theMessage = nil then Return //???
		  
		  if queue = nil then
		    queue = new MessageQueue
		  end if
		  
		  queue.addMessage(theMessage)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub registerForMessage(extends theReceiver as MessageReceiver, messageType as variant)
		  //register a message receiver for a specific msg type
		  if messages = nil then
		    messages = new dictionary
		  end if
		  
		  dim tmp as dictionary
		  
		  if messages.hasKey(messageType) then
		    tmp = messages.value(messageType)
		  else
		    tmp = new Dictionary
		    messages.value(messageType) = tmp
		  end if
		  
		  tmp.value(theReceiver) = false
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub sendMessage(theMessage as Message)
		  #pragma DisableBackgroundTasks
		  #pragma DisableBoundsChecking
		  #pragma DisableAutoWaitCursor
		  
		  if messages = nil then return //no receivers
		  
		  dim type as Variant
		  type = theMessage.messageType
		  
		  //no receivers for msg
		  if not messages.hasKey(type) then return
		  
		  dim receivers as dictionary
		  dim receiver as messageReceiver
		  
		  //send to all receivers
		  receivers=messages.value(type)
		  
		  for each receiver in receivers.Keys
		    receiver.receiveMessage(theMessage)
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub unregisterForMessage(extends theReceiver as MessageReceiver, messageType as variant)
		  if messages = nil then return //no receivers
		  
		  //no such message
		  if not messages.hasKey(messageType) then return
		  
		  //remove receiver
		  dim receivers as dictionary
		  receivers = messages.value(messageType)
		  
		  if not receivers.hasKey(theReceiver) then Return
		  
		  receivers.remove(thereceiver)
		  if receivers.Count = 0 then Messages.Remove(messageType)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub unregisterReceiver(extends theReceiver as messageReceiver)
		  if messages = nil then return //no receivers
		  
		  //find the object within our registered receivers
		  dim item as integer
		  dim type as Variant
		  dim receivers as dictionary
		  dim typesToRemove() as Variant
		  
		  for item=0 to messages.count-1
		    //msg type
		    type = messages.key(item)
		    
		    //receivers
		    receivers = messages.value(type)
		    
		    if not receivers.hasKey(theReceiver) then Continue for
		    
		    receivers.remove(theReceiver)
		    if receivers.Count = 0 then typesToRemove.Append(type)
		  next
		  
		  for each type in typesToRemove
		    if Messages.HasKey(type) then Messages.Remove(Type)
		  next
		End Sub
	#tag EndMethod


	#tag Note, Name = Info
		Based on the article "Implementing a MessageCenter Module"
		by Charles Yeomans
		
		Available in realbasic developer 3.6
	#tag EndNote


	#tag Property, Flags = &h21
		Private messages As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private queue As MessageQueue
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
End Module
#tag EndModule
