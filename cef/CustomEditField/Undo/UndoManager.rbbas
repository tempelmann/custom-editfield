#tag Class
Protected Class UndoManager
	#tag Method, Flags = &h1
		Protected Sub addActionToRedoStack(action as UndoableAction)
		  RedoStack.Append action
		  undoStackIndex = undoStackIndex - 1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub addActionToUndoStack(action as UndoableAction)
		  UndoStack.Append action
		  undoStackIndex = undoStackIndex + 1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  mEnabled = true
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsDirty() As boolean
		  Return undoStackIndex <> 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsUndoing() As boolean
		  Return undoing
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Push(action as UndoableAction)
		  if undoing or not mEnabled then Return
		  if action = nil then Return
		  addActionToUndoStack(action)
		  
		  redim RedoStack(-1)
		  EnableMenuItems
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Redo()
		  if not CanRedo then Return
		  dim ID as Integer = RedoStack(UBound(RedoStack)).EventID
		  redo(ID)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Redo(id as integer)
		  if not CanRedo then Return
		  
		  dim match as Boolean
		  do
		    match = false
		    undoing = true
		    
		    if id = RedoStack(UBound(RedoStack)).EventID then
		      dim action as UndoableAction = RedoStack.Pop
		      addActionToUndoStack(action)
		      
		      action.Redo
		      match = true
		    end if
		    
		    undoing = False
		  loop until id = 0 or not CanRedo or not match
		  
		  EnableMenuItems
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Reset()
		  ReDim UndoStack(-1)
		  ReDim RedoStack(-1)
		  undoStackIndex = 0
		  undoing = False
		  EnableMenuItems
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ResetDirtyFlag()
		  undoStackIndex = 0
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Undo()
		  if not CanUndo then Return
		  dim ID as Integer = UndoStack(UBound(UndoStack)).EventID
		  Undo(ID)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Undo(ID as integer)
		  if not CanUndo then Return
		  
		  dim match as Boolean
		  do
		    match = false
		    undoing = true
		    
		    if id = UndoStack(UBound(UndoStack)).EventID then
		      dim action as UndoableAction = UndoStack.Pop
		      addActionToRedoStack(action)
		      
		      action.Undo
		      match = true
		    end if
		    
		    undoing = False
		  loop until id = 0 or not CanUndo or not match
		  
		  EnableMenuItems
		  
		End Sub
	#tag EndMethod


	#tag Note, Name = About
		Part of CustomEditField
	#tag EndNote


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mEnabled and UBound(RedoStack) > -1
			End Get
		#tag EndGetter
		CanRedo As boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mEnabled and UBound(UndoStack) > -1
			End Get
		#tag EndGetter
		CanUndo As boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mEnabled
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mEnabled = value
			End Set
		#tag EndSetter
		Enabled As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mEnabled As Boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected RedoStack() As UndoableAction
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected undoing As boolean
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected UndoStack() As UndoableAction
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected undoStackIndex As Integer
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="CanRedo"
			Group="Behavior"
			InitialValue="0"
			Type="boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="CanUndo"
			Group="Behavior"
			InitialValue="0"
			Type="boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Group="Behavior"
			Type="Boolean"
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
