#tag Class
Class LineHighlighter
Inherits Thread
	#tag Event
		Sub Run()
		  dim owner as CustomEditField = self.owner
		  if owner = nil then Return
		  
		  #if DebugBuild and EditFieldGlobals.DebugIndentation
		    System.DebugLog "LineHighlighter.Run..."
		  #endif
		  
		  dim lock as LinesLock
		  if not owner.IndentVisually then
		    lock = new LinesLock(owner)
		  end if
		  
		  #if DebugBuild and EditFieldGlobals.DebugTiming
		    dim runtimer as new Debugging.LifeTimer(CurrentMethodName)
		  #endif
		  
		  do
		    ProcessVisibleLines
		    ProcessDirtyLines
		    if changedLines.RangeCount = 0 then
		      exit
		    end
		    #if DebugBuild and EditFieldGlobals.DebugIndentation
		      System.DebugLog "LineHighlighter loop"
		    #endif
		  loop
		  
		  HighlightingDone
		  
		  #if DebugBuild and EditFieldGlobals.DebugIndentation
		    System.DebugLog "LineHighlighter.Run done."
		  #endif
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Constructor(owner as customEditField, definition as highlightdefinition, changedLines as modifiedLineRangeManager, buffer as gapBuffer, lines as linemanager)
		  self.definition = definition
		  self.changedLines = changedLines
		  self.buffer = buffer
		  self.mLines = new WeakRef(lines)
		  self.mOwner = new WeakRef(owner)
		  self.Priority = Thread.HighPriority
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoneWithScreenLines()
		  if not MessageCenter.isMessageInQueue (self, 1, ScreenLinesHighlightedMsg) then
		    dim msg as new Message(self, self)
		    msg.addInfo(1, ScreenLinesHighlightedMsg)
		    MessageCenter.sendMessage(msg)
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HighlightingDone()
		  if not MessageCenter.isMessageInQueue (self, 1, HighlightDoneMsg) then
		    dim msg as new Message(self, self)
		    msg.addInfo(1, HighlightDoneMsg)
		    MessageCenter.queueMessage(msg)
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HighlightLine(index as integer)
		  #pragma DisableBackgroundTasks
		  
		  dim lock as new LinesLock(owner)
		  
		  dim line, previous, nextLine as TextLine
		  dim context, previousContext as HighlightContext
		  dim processed as Integer
		  
		  dim lineFoldingsEnabled as Boolean = owner.EnableLineFoldings
		  
		  dim lines as LineManager = LineManager(mLines.Value)
		  
		  //get line
		  line = lines.getLine(index)
		  if line = nil then return //line can be nil if no longer in document
		  
		  //get context of previous line
		  previous = lines.getLine(index - 1)
		  if previous <> nil then
		    context = previous.Context
		  end if
		  
		  previousContext = line.Context
		  context = line.Highlight(definition, buffer, context)
		  
		  //restore fold markers
		  //if the line is a blockStart, or if it was and it's folded, check the fold markers
		  if lineFoldingsEnabled and (line.isBlockStart or (line.folded and not line.isBlockStart)) then
		    nextLine = lines.getLine(lines.nextBlockEndLine(index, true))
		    if nextLine <> nil and ((line.folded <> not nextLine.visible) or (line.folded and not line.isBlockStart)) then
		      //if we got to this point, is because it's a startblock in an invalid state.
		      line.isBlockStart = true
		      call lines.toggleLineFolding(index)
		    end if
		  end if
		  
		  LineHighlighted(index)
		  processed = processed + 1
		  
		  if context <> nil then
		    //scan next
		    do
		      index = index + 1
		      line = lines.getLine(index)
		      if line = nil then exit do
		      if line.Context = context then Continue
		      context = line.Highlight(definition, buffer, context)
		      processed = processed + 1
		      LineHighlighted(index)
		    Loop Until context = nil
		    
		    //add final line
		    line = lines.getLine(index + 1)
		    if line <> nil then
		      owner.InvalidateLine(index + 1)
		      call changedLines.AddRange(index + 1, 1) // it will be highlighted in a future pass
		    end if
		    
		    //if context changed
		  elseif previousContext <> context then
		    
		    index = index + 1
		    line = lines.getLine(index)
		    while line <> nil and line.Context = previousContext
		      context = line.Highlight(definition, buffer, context)
		      processed = processed + 1
		      LineHighlighted(index)
		      index = index + 1
		      line = lines.getLine(index)
		    wend
		    
		    //final line
		    if line <> nil then
		      call changedLines.AddRange(index, 1)
		      owner.InvalidateLine(index)
		    end if
		    
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LineHighlighted(index as integer)
		  dim msg as new Message(self, self)
		  msg.addInfo(1, LineHighlightedMsg)
		  msg.addInfo(2, index)
		  MessageCenter.sendMessage(msg)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ProcessDirtyLines()
		  do
		    dim lock as LinesLock
		    
		    try
		      lock = new LinesLock(owner)
		      
		      #if DebugBuild and EditFieldGlobals.DebugTiming
		        dim runtimer as new Debugging.AccumulationTimer(CurrentMethodName)
		      #endif
		      
		      dim lineIdx as Integer
		      if not changedLines.RemoveNextLine (lineIdx) then
		        exit do
		      end if
		      
		      HighlightLine (lineIdx)
		      
		    exception exc as ThreadEndException
		      lock = nil
		      return
		    end try
		    
		  loop
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ProcessVisibleLines()
		  dim lock as new LinesLock(owner)
		  
		  #if DebugBuild and EditFieldGlobals.DebugTiming
		    dim runtimer as new Debugging.AccumulationTimer(CurrentMethodName)
		  #endif
		  
		  try
		    dim needsRefresh as Boolean
		    
		    dim startLine as Integer = owner.VisibleLineRange.offset
		    dim endLine as Integer = Max(owner.MaxVisibleLines,owner.VisibleLineRange.length) - startLine + 1
		    
		    for lineIdx as Integer = startLine to endLine
		      
		      if changedLines.RemoveLine(lineIdx) then
		        // this is a dirty line that needs processing
		        HighlightLine (lineIdx)
		        needsRefresh = true
		      end if
		      
		    next
		    
		    if needsRefresh then
		      DoneWithScreenLines
		    end if
		    
		  exception exc as ThreadEndException
		    lock = nil
		    return
		  end try
		  
		End Sub
	#tag EndMethod


	#tag Note, Name = How this works
		The algorithm was changed in 1.7.3 (10 Sep2013)
		
		Before, this class tried to maintain its own Dictionary to remember what lines were already highlighted
		in the latest thread run.
		
		Now this is all managed by ModifiedLineRangeManager: Modified lines get added to it, and this
		class fetches lines from it, thereby removing them from the ModifiedLineRangeManager. This avoids
		duplicate handling unless a line gets changed again afterwards.
	#tag EndNote


	#tag Property, Flags = &h1
		Protected buffer As gapBuffer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected changedLines As ModifiedLineRangeManager
	#tag EndProperty

	#tag Property, Flags = &h0
		definition As highlightdefinition
	#tag EndProperty

	#tag Property, Flags = &h1
		#tag Note
			LineManager
		#tag EndNote
		Protected mLines As WeakRef
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOwner As weakRef
	#tag EndProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  if mOwner <> nil then
			    return CustomEditField(mOwner.Value)
			  else
			    //stop thread, since the owner is no longer valid
			    self.Kill
			    return nil
			  end if
			End Get
		#tag EndGetter
		Private owner As CustomEditField
	#tag EndComputedProperty


	#tag Constant, Name = HighlightDoneMsg, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = LineHighlightedMsg, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = ScreenLinesHighlightedMsg, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant


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
			Name="Priority"
			Visible=true
			Group="Behavior"
			InitialValue="5"
			Type="Integer"
			InheritedFrom="Thread"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StackSize"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			InheritedFrom="Thread"
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
