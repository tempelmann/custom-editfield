#tag Class
Private Class GtkWidgetHeightFixHandlerClass
	#tag Method, Flags = &h0
		Sub constructor()
		  
		  #if TargetLinux
		    
		    declare function g_signal_add_emission_hook lib "libgobject-2" (id as uint32,detail as int32,hook as ptr, notify as ptr) as uint32
		    declare function g_signal_lookup lib "libgobject-2" (   name as CString, type as uint32)  as uint32
		    Declare Function gtk_widget_get_type Lib "libgtk-3" () As uint32
		    Declare Function gtk_button_get_type Lib "libgtk-3" () As uint32
		    
		    dim type as uint32=gtk_widget_get_type
		    GtkWidgetCallBackID=g_signal_add_emission_hook(g_signal_lookup("map",type),0,AddressOf GtkWidgetHeightFixCallback,nil)
		    GtkWidgetStyleCallBackID=g_signal_add_emission_hook(g_signal_lookup("style-updated",type),0,AddressOf GtkWidgetHeightFixCallback,nil)
		    
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub destructor()
		  #if TargetLinux
		    
		    declare sub g_signal_remove_emission_hook lib "libgobject-2" (id as uint32,detail as int32) 
		    declare function g_signal_lookup lib "libgobject-2" (   name as CString, type as uint32)  as uint32
		    Declare Function gtk_button_get_type Lib "libgtk-3" () As uint32
		    
		    dim type as uint32=gtk_button_get_type
		    g_signal_remove_emission_hook(g_signal_lookup("map",type),GtkWidgetCallBackID)
		    g_signal_remove_emission_hook(g_signal_lookup("style-updated",type),GtkWidgetStyleCallBackID)
		    
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function GtkWidgetHeightFixCallback(hint as ptr, count as uint32, params as ptr, data as ptr) As Boolean
		  #If TargetLinux
		    
		    declare function g_value_get_object lib "libgtk-3" ( cls as ptr)as ptr
		    Declare sub gtk_widget_get_preferred_height Lib "libgtk-3" (obj as ptr,byref minh as int32, byref nath as int32 ) 
		    Declare Function gtk_widget_get_toplevel Lib "libgtk-3" (obj as ptr) as ptr 
		    
		    dim widget as ptr=g_value_get_object(params)
		    dim widgetwindow as ptr=gtk_widget_get_toplevel(widget)
		    
		    for w as integer=0 to WindowCount-1
		      if ptr(window(w).Handle)=widgetwindow then
		        for c as integer=0 to window(w).ControlCount -1
		          
		          dim ctrl as control= window(w).control(c) 
		          if ctrl isA RectControl and ptr(RectControl(ctrl).handle)=widget then
		            
		            If ctrl IsA EmbeddedWindowControl Then Continue
		            dim minh,nath as int32
		            gtk_widget_get_preferred_height(widget,minh,nath)
		            dim r As RectControl=RectControl(ctrl)
		            r.Height=max(r.Height,nath)
		            exit
		            
		          end if
		        next
		      end if
		    next
		    
		    Return true
		  #Else
		    #Pragma unused data
		    #Pragma unused params
		    #Pragma unused count
		    #Pragma unused hint
		  #EndIf
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private GtkWidgetCallBackID As uint32
	#tag EndProperty

	#tag Property, Flags = &h21
		Private GtkWidgetStyleCallBackID As Integer
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
