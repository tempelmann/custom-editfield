#tag Class
Protected Class CaretBlinker
Inherits timer
	#tag Event
		Sub Action()
		  if owner = nil then Return
		  owner.RedrawCaret
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Constructor(owner as CustomEditField)
		  me.Reference = new WeakRef(owner)
		  me.Period = 500
		  me.Mode = timer.ModeMultiple
		  me.Enabled = true
		End Sub
	#tag EndMethod


	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  if me.Reference <> nil then
			    return CustomEditField(me.Reference.Value)
			  else
			    return nil
			  end if
			End Get
		#tag EndGetter
		Private owner As CustomEditField
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private Reference As weakRef
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InheritedFrom="timer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InheritedFrom="timer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Mode"
			Visible=true
			Group="Behavior"
			InitialValue="2"
			Type="Integer"
			EditorType="Enum"
			InheritedFrom="timer"
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
			InheritedFrom="timer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Period"
			Visible=true
			Group="Behavior"
			InitialValue="1000"
			Type="Integer"
			InheritedFrom="timer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="timer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InheritedFrom="timer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
