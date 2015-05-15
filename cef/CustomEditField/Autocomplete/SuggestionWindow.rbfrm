#tag Window
Begin Window SuggestionWindow
   BackColor       =   16777215
   Backdrop        =   ""
   CloseButton     =   False
   Composite       =   False
   Frame           =   3
   FullScreen      =   False
   HasBackColor    =   False
   Height          =   300
   ImplicitInstance=   True
   LiveResize      =   True
   MacProcID       =   1040
   MaxHeight       =   32000
   MaximizeButton  =   False
   MaxWidth        =   32000
   MenuBar         =   ""
   MenuBarVisible  =   True
   MinHeight       =   64
   MinimizeButton  =   False
   MinWidth        =   64
   Placement       =   0
   Resizeable      =   False
   Title           =   ""
   Visible         =   True
   Width           =   120
   Begin ListBox optionList
      AutoDeactivate  =   True
      AutoHideScrollbars=   True
      Bold            =   ""
      ColumnCount     =   1
      ColumnsResizable=   ""
      ColumnWidths    =   ""
      DataField       =   ""
      DataSource      =   ""
      DefaultRowHeight=   14
      Enabled         =   True
      EnableDrag      =   ""
      EnableDragReorder=   ""
      GridLinesHorizontal=   0
      GridLinesVertical=   0
      HasHeading      =   ""
      HeadingIndex    =   -1
      Height          =   300
      HelpTag         =   ""
      Hierarchical    =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   ""
      Italic          =   ""
      Left            =   0
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      RequiresSelection=   ""
      Scope           =   0
      ScrollbarHorizontal=   ""
      ScrollBarVertical=   True
      SelectionType   =   0
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "SmallSystem"
      TextSize        =   0
      Top             =   0
      Underline       =   ""
      UseFocusRing    =   False
      Visible         =   True
      Width           =   120
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
   Begin Timer Timer1
      Enabled         =   True
      Height          =   32
      Index           =   -2147483648
      Left            =   0
      LockedInPosition=   False
      Mode            =   0
      Period          =   10
      Scope           =   0
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Top             =   305
      Visible         =   True
      Width           =   32
   End
End
#tag EndWindow

#tag WindowCode
	#tag Event
		Sub Open()
		  #if TargetWin32
		    Const WS_BORDER = &H800000
		    ChangeWindowStyle( self, WS_BORDER, false )
		    
		    Const WS_CAPTION = &h00C00000
		    ChangeWindowStyle( self, WS_CAPTION, false )
		  #endif
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub cancel(requestFocus as boolean)
		  //cancel action
		  if optionSubmitted then Return
		  optionSubmitted = true
		  
		  dim msg as new Message(self, self)
		  msg.addInfo(1, AutocompleteCancelledMsg)
		  msg.addInfo(2, requestFocus)
		  MessageCenter.sendMessage(msg)
		  
		  StartTimer
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ChangeWindowStyle(w as Window, flag as Integer, set as Boolean)
		  #pragma unused set
		  #if TargetWin32
		    Dim oldFlags as Integer
		    Dim newFlags as Integer
		    Dim styleFlags As Integer
		    
		    Const SWP_NOSIZE = &H1
		    Const SWP_NOMOVE = &H2
		    Const SWP_NOZORDER = &H4
		    Const SWP_FRAMECHANGED = &H20
		    
		    Const GWL_STYLE = -16
		    
		    Declare Function GetWindowLong Lib "user32" Alias "GetWindowLongA" (hwnd As Integer,  _
		    nIndex As Integer) As Integer
		    Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (hwnd As Integer, _
		    nIndex As Integer, dwNewLong As Integer) As Integer
		    Declare Function SetWindowPos Lib "user32" (hwnd as Integer, hWndInstertAfter as Integer, _
		    x as Integer, y as Integer, cx as Integer, cy as Integer, flags as Integer) as Integer
		    
		    oldFlags = GetWindowLong(w.WinHWND, GWL_STYLE)
		    
		    if not set then
		      newFlags = BitwiseAnd( oldFlags, Bitwise.OnesComplement( flag ) )
		    else
		      newFlags = BitwiseOr( oldFlags, flag )
		    end
		    
		    
		    styleFlags = SetWindowLong( w.WinHWND, GWL_STYLE, newFlags )
		    styleFlags = SetWindowPos( w.WinHWND, 0, 0, 0, 0, 0, SWP_NOMOVE +_
		    SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED )
		  #else
		    #pragma unused w
		    #pragma unused flag
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub loadSuggestions(options() as string)
		  //load options
		  optionList.DeleteAllRows
		  
		  dim option as String
		  for each option in options
		    optionList.AddRow option
		    if self.Graphics.StringWidth(option) > self.Width then  //auto-expand to fit the options. Thanks to Dr Gerard Hammond
		      self.Width = self.Graphics.StringWidth(option)  + 10
		    end
		  next
		  if optionList.ListCount > 0 then _
		  optionList.ListIndex = 0
		  
		  me.Height = min(optionList.ListCount * optionList.DefaultRowHeight + 4, Screen(0).Height/2)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub show(left as integer, top as integer)
		  //get options
		  dim options as AutocompleteOptions
		  dim msg as new Message(self, self)
		  msg.addInfo(1, CurrentAutocompleteOptionsMsg)
		  MessageCenter.sendMessage(msg)
		  options = msg.Info(3)
		  
		  if options = nil then Return
		  
		  //load suggestions
		  loadSuggestions(options.Options)
		  
		  me.Left = Left
		  me.Top = top
		  
		  if me.top + me.Height > Screen(0).Height then
		    me.Top = Screen(0).Height - me.Height
		  end if
		  
		  Super.Show
		  super.SetFocus
		  optionList.SetFocus
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub StartTimer()
		  //this is a workaround to close the window without crashing, don't know why
		  timer1.Mode = timer.ModeSingle
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub submit(what as string = "")
		  //submit selected option
		  if optionSubmitted then Return
		  optionSubmitted = true
		  
		  dim option as String
		  if what ="" then
		    option = optionList.Text
		  else
		    option = what
		  end if
		  
		  dim msg as new Message(self, self)
		  msg.addInfo(1, OptionSelectedMsg)
		  msg.addInfo(2, Option)
		  MessageCenter.sendMessage(msg)
		  
		  StartTimer
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private optionSubmitted As boolean
	#tag EndProperty


	#tag Constant, Name = AutocompleteCancelledMsg, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = CurrentAutocompleteOptionsMsg, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = KeyDownMsg, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = OptionSelectedMsg, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant


#tag EndWindowCode

#tag Events optionList
	#tag Event
		Function CellClick(row as Integer, column as Integer, x as Integer, y as Integer) As Boolean
		  #pragma unused x
		  #pragma unused y
		  
		  submit(me.cell(row,column))
		End Function
	#tag EndEvent
	#tag Event
		Function KeyDown(Key As String) As Boolean
		  'MsgBox str(asc(key))
		  select case asc(key)
		  case 27, 8, 127
		    cancel(true)
		    
		  case 9, 13, 3, 32
		    submit
		    
		  case 28, 29, 30, 31
		    Return False
		    
		  else
		    dim options as AutocompleteOptions
		    
		    dim msg as new Message(self, self)
		    Msg.addInfo(1, KeyDownMsg)
		    msg.addInfo(2, key)
		    MessageCenter.sendMessage(Msg)
		    
		    //KeyDownMsg
		    msg = new Message(self, self)
		    msg.addInfo(1, CurrentAutocompleteOptionsMsg)
		    MessageCenter.sendMessage(msg)
		    //msg should have the options now
		    options = msg.Info(3)
		    
		    if options = nil then
		      cancel(true)
		      Return true
		    end if
		    
		    loadSuggestions(options.Options)
		    if optionList.ListCount = 0 then cancel(true)
		  end select
		  Return true
		End Function
	#tag EndEvent
	#tag Event
		Sub LostFocus()
		  cancel(False)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events Timer1
	#tag Event
		Sub Action()
		  self.Close
		End Sub
	#tag EndEvent
#tag EndEvents
