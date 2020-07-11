#tag Module
Module modGTK3
	#tag Method, Flags = &h1
		Protected Function GetObjectPropertyList(obj as ptr) As String()
		  #If TargetLinux
		    declare function g_object_class_list_properties lib "libgobject-2" (obj as ptr, byref length as uint32) as ptr
		    declare function g_param_spec_get_name lib "libgobject-2" (obj as ptr) as CString
		    declare function g_param_spec_get_default_value lib "libgobject-2" (obj as ptr) as ptr
		    declare function g_strdup_value_contents lib "libgobject-2" (obj as ptr) as CString
		    Soft Declare Sub g_object_getv Lib "libgobject-2" (obj As ptr,count As UInt32,ByRef value As cstring, res As ptr, term As ptr=Nil)
		    Declare Sub free Lib "libgobject-2" (obj As ptr)
		    Dim ptrSize As Integer=4
		    If Target64Bit Then ptrSize=8
		    
		    dim ret() as String
		    If System.isFunctionAvailable("g_object_getv","libgobject-2") Then
		      dim count As UInt32
		      dim list as ptr=g_object_class_list_properties(obj.ptr(0),count)
		      
		      for i as integer=0 to count-1
		        Dim name As CString=g_param_spec_get_name(list.Ptr(i*ptrSize))
		        dim value as new MemoryBlock(20) //not sure how big a value can be but this seems safe
		        dim pvalue as ptr=value
		        g_object_getv(obj,1,name,pvalue)
		        ret.Append name + " = " + g_strdup_value_contents(pvalue)
		      next
		      
		      free(list)
		      
		      ret.Sort
		    end if
		    Return ret
		  #Else
		    #Pragma unused obj
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub InitGlobalGtk3Style()
		  //GTK3
		  #If TargetLinux and (RBVersion >= 2017.02) Then
		    
		    //call the setter with the default style fix
		    call modGTK3.set_GTK3_GlobalStyleCSS( kGlobalGTK3CSS )
		    
		  #EndIf
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub initGtkEntryFix()
		  if mGtkEntryFixHandlerSingleton=nil then mGtkEntryFixHandlerSingleton=new GtkEntryFixHandlerClass
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub initGtkWidgetHeightFix()
		  if mGtkWidgetHeightFixHandlerSingleton=nil then mGtkWidgetHeightFixHandlerSingleton=new GtkWidgetHeightFixHandlerClass
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub init_Linux_OS_Description()
		  #if TargetLinux then
		    //get the Current Desktop
		    dim shl as new Shell
		    shl.Execute "echo $XDG_CURRENT_DESKTOP"
		    Desktop = trim(shl.Result)
		    
		    //get the GDMSESSION
		    shl.Execute "echo $GDMSESSION"
		    Session = trim(shl.Result)
		    
		    //get the GDMSESSION
		    shl.Execute "lsb_release -si"
		    OS = trim(shl.Result)
		    
		    //get the GDMSESSION
		    shl.Execute "lsb_release -sr"
		    Release = trim(shl.Result)
		    
		  #endif
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function parseCSSforConditionals(css As String) As String
		  init_Linux_OS_Description
		  
		  // Adds conditional CSS
		  //Sections within '#IF' and '#END IF' will be removed if the conditions are not  met
		  // can be  XOJO<|>[RBVersion]  OS=[OS Name] RELEASE<|(!)=|>[Release number] DESKTOP(!)=[Desktop] SESSION(!)=[Session] or any combination
		  // parsing is LTR with no nested logic (no parens)
		  
		  //example:
		  //#IF XOJO<2018 AND OS=LinuxMint  OR RELEASE>17   <--this will always pass if Release is above 17!
		  //---a bunch of conditional CSS---
		  //#END IF
		  
		  
		  dim lines() as String=css.Split(EndOfLine.UNIX)
		  dim r As new RegEx
		  r.SearchPattern="(\w+)([\!\<=\>]+)(\S+)"
		  
		  dim i as integer
		  while i < lines.Ubound
		    
		    dim pass As Boolean = true
		    dim logic as string="AND"
		    
		    if Lines(i).Left(3)="#IF" then
		      
		      dim chunks() as string=lines(i).Split
		      for c as integer=1 to chunks.Ubound
		        
		        select case chunks(c)
		        case "AND","OR","NOR"
		          logic=chunks(c)
		        else //condition
		          dim condition_pass as Boolean=true
		          dim m As RegExMatch=r.Search(chunks(c)) //better be a condition
		          if m<>nil and m.SubExpressionCount=4 then //match,comparison,value
		            
		            dim type as String=m.SubExpressionString(1)
		            dim cmp as String=m.SubExpressionString(2)
		            dim value as String=m.SubExpressionString(3)
		            
		            select case type
		            case "OS"
		              if cmp="=" and OS<>value then condition_pass=False
		              if cmp="!=" and OS=value then condition_pass=False
		            case "DESKTOP" 
		              if cmp="=" and Desktop<>value then condition_pass=False
		              if cmp="!=" and Desktop=value then condition_pass=False
		            case "SESSION"
		              if cmp="=" and Session<>value then condition_pass=False
		              if cmp="!=" and Session=value then condition_pass=False
		            case "XOJO"
		              select case cmp
		              case "="
		                if RBVersion<>val(value) then condition_pass=False
		              case "!="
		                if RBVersion=val(value) then condition_pass=False
		              case ">" 
		                if RBVersion<=val(value) then condition_pass=False
		              case "<"
		                if RBVersion>=val(value) then condition_pass=False
		              end select
		            case "RELEASE"
		              Select case cmp
		              case "="
		                if Release<>value then condition_pass=False
		              case "!="
		                if Release=value then condition_pass=False
		              case ">"
		                if Release<=value then condition_pass=False
		              case "<"
		                if Release>=value then condition_pass=False
		              end select
		            end Select
		            
		            select case logic
		            case "OR"
		              pass = pass or condition_pass
		            case "NOR"
		              pass = Not ( pass or condition_pass )
		            case "AND"
		              pass = pass and condition_pass
		            end Select
		            
		            m=r.Search
		          end if
		        end Select //end condition
		      next //next chunk
		      
		      lines.Remove(i) //remove #IF
		      
		      while i<=lines.Ubound 
		        if lines(i).left(7)="#END IF" then //remove end if
		          lines.Remove(i)
		          exit
		        end if
		        if Not pass then //remove line between failed if/end if
		          lines.Remove(i)
		        else
		          i=i+1
		        end if
		      wend
		      
		    elseif lines(i).Left(1)="#" then  //remove comments
		      lines.Remove(i)
		    else
		      i=i+1
		    end if
		    
		  wend
		  
		  css=join(lines,EndOfLine.UNIX)
		  
		  Return css
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function set_GTK3_GlobalStyleCSS(psCSSData As String) As Boolean
		  #If TargetLinux And (RBVersion >= 2017.02) Then
		    GtkCssParsingErrorInfo.LastParsingError=nil
		    
		    //If (Trim(psCSSData) = "") Then Return true //nothing to do. Not an error.
		    
		    psCSSData=parseCSSforConditionals(psCSSData)
		    
		    Try
		      Declare Function gdk_screen_get_default Lib "libgdk-3" () As Ptr 
		      Declare Function gtk_css_provider_new Lib "libgtk-3" () As Ptr
		      Declare Function gtk_css_provider_load_from_data Lib "libgtk-3" (provider As Ptr, data As CString, dataLen As Integer, error As Ptr) As Boolean
		      Declare Sub gtk_style_context_add_provider_for_screen Lib "libgtk-3" (Screen As Ptr, provider As Ptr, priority As UInt32)
		      Declare Sub g_object_unref Lib "libgobject-2.0" (obj As Ptr)
		      declare function g_signal_connect_data lib  "libgobject-2.0" (obj as ptr,name as cstring,func as ptr,data as ptr,closure as ptr, flags as uint32) as uint32
		      
		      Const GTK_STYLE_PROVIDER_PRIORITY_APPLICATION = 600
		      
		      Dim Screen As Ptr = gdk_screen_get_default
		      Static provider As Ptr //we'll keep a single provider around instead of creating a new one each time
		      if provider = nil then provider = gtk_css_provider_new
		      If provider = Nil Then Break
		      
		      dim res as uint32= g_signal_connect_data(provider,"parsing-error",AddressOf modGtk3.GtkCssParsingErrorInfo.Gtk_parsing_error,nil,nil,0)
		      dim success as Boolean
		      
		      call gtk_css_provider_load_from_data(provider, psCSSData, psCSSData.Len, Nil) 
		      
		      if GtkCssParsingErrorInfo.LastParsingError<>nil and GtkCssParsingErrorInfo.LastParsingError.Provider=provider then
		        //parsing error
		      else
		        gtk_style_context_add_provider_for_screen(Screen, provider, GTK_STYLE_PROVIDER_PRIORITY_APPLICATION)
		        success=true
		      End If
		      
		      
		      'g_object_unref(provider)  //keep this around so we can reload it instead of layering providers
		      
		      Return success
		      
		    Catch err As RuntimeException
		      'ignore
		    End Try
		  #Else
		    #Pragma unused psCSSData
		  #EndIf
		End Function
	#tag EndMethod


	#tag Note, Name = About
		
		modGtk3 for Xojo
		Modifies CSS and adjusts control sizes in Xojo apps deployed to Linux platforms to create a more native interface.
		
		see https://forum.xojo.com/48126-gtk3-theming-modgtk3-resolves-layout-corruption-under-all-linux/last
		
		Includes code from Jürg Otter, Jim McKay, and others (please add here).
		
		Thanks to Tim Jones for starting the thread.
		
		
		
		Getting started
		
		Add the modGtk3 module to your Xojo app.
		
		In the open event of the app object, add the following lines-
		    modGTK3.initGtkEntryFix  // adjusts the char-widths property of GtkEntry to be 0
		    modGTK3.initGtkWidgetHeightFix // adjusts all controls to be at least their minimum height
		    modGTK3.InitGlobalGTK3Style  // various CSS tweaks to override theme CSS
		modGtk3.kGlobalGTK3CSS contains the default CSS override.
		
		Please feel free to expirement with modifications for specific platform combinations.
		
		
		
		To include conditionals in the CSS:
		
		Sections within '#IF' and '#END IF' will be removed if the conditions are not met
		
		can be XOJO<|>[RBVersion] OS=[OS Name] RELEASE<|(!)=|>[Release number] DESKTOP(!)=[Desktop] SESSION(!)=[Session] or any combination
		
		parsing is LTR with no nested logic (no parens)
		
		example:
		
		#IF XOJO<2018 AND OS=LinuxMint OR RELEASE>17 <--this will always pass if Release is above 17!
		---a bunch of conditional CSS---
		#END IF
		
		
	#tag EndNote


	#tag Property, Flags = &h1
		Protected Desktop As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mGtkEntryFixHandlerSingleton As GtkEntryFixHandlerCLass
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mGtkWidgetHeightFixHandlerSingleton As GtkWidgetHeightFixHandlerClass
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected OS As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Release As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Session As String
	#tag EndProperty


	#tag Constant, Name = kGlobalGTK3CSS, Type = String, Dynamic = False, Default = \"entry\x2C .entry  { min-height:10px; min-width:18px; }\nentry\x2C .entry  { padding:1px; padding-left: 5px; padding-right: 5px; margin:0px; }\nbutton\x2C .button { min-height:16px; min-width:18px; }\nbutton\x2C .button { padding:0px; padding-left: 4px; padding-right: 4px; margin:0px; }\nmessagedialog .dialog-action-area button { padding: 5px; }\nGtkMessageDialog  * { padding: 5px; margin: 5px; }\nGtkMessageDialog GtkButton GtkLabel{ padding: 4px; padding-top: 2px; padding-bottom: 4px; margin: 0px; }\nnotebook.frame{margin-top:5px;margin-bottom:1985px;}\nnotebook.frame header{padding:0px}\nnotebook.frame stack{padding-top:45px}\nnotebook.frame header tabs\x2C tabs tab{padding:0px;min-height:1px}\nnotebook.frame header tabs tab label{padding-left:5px;padding-right:5px;}\n#checkbutton {margin-top:-4px}\n\n#IF OS\x3DUbuntu AND RELEASE>16.03\nprogressbar trough {min-width:1px;}\nentry\x2C .entry  { padding:4px; }\nscale {min-width:10px;margin:0px;padding:9px;padding-top:6px;}\n#END IF\n\n#IF SESSION\x3Dcinnamon\nscrollbar.horizontal slider{min-height:10px} \nscrollbar.vertical slider{min-width:10px;} \nprogressbar trough {min-width:1px;}\nentry \x2C button {padding:0px;padding-bottom:1px;padding-left:4px;padding-right:4px;}\ncombobox cellview {margin:0px;margin-top:-1px;padding:0px;}\nscale {min-width:10px;margin:0px;padding:9px;padding-top:6px;}\n#END IF", Scope = Public
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
