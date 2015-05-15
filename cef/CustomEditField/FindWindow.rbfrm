#tag Window
Begin Window FindWindow
   BackColor       =   16777215
   Backdrop        =   ""
   CloseButton     =   True
   Composite       =   True
   Frame           =   0
   FullScreen      =   False
   HasBackColor    =   False
   Height          =   154
   ImplicitInstance=   True
   LiveResize      =   True
   MacProcID       =   0
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
   Title           =   "Find"
   Visible         =   True
   Width           =   527
   Begin Label StaticText1
      AutoDeactivate  =   True
      Bold            =   ""
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   18
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Multiline       =   ""
      Scope           =   0
      Selectable      =   False
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   "Find:"
      TextAlign       =   2
      TextColor       =   0
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   14
      Transparent     =   False
      Underline       =   ""
      Visible         =   True
      Width           =   100
   End
   Begin Label StaticText2
      AutoDeactivate  =   True
      Bold            =   ""
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   18
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Multiline       =   ""
      Scope           =   0
      Selectable      =   False
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   "Replace With:"
      TextAlign       =   2
      TextColor       =   0
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   46
      Transparent     =   False
      Underline       =   ""
      Visible         =   True
      Width           =   100
   End
   Begin ComboBox txtToFind
      AutoComplete    =   False
      AutoDeactivate  =   True
      Bold            =   ""
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   ""
      Index           =   -2147483648
      InitialValue    =   ""
      Italic          =   ""
      Left            =   123
      ListIndex       =   0
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Scope           =   0
      TabIndex        =   2
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   15
      Underline       =   ""
      UseFocusRing    =   True
      Visible         =   True
      Width           =   384
   End
   Begin ComboBox txtToReplace
      AutoComplete    =   False
      AutoDeactivate  =   True
      Bold            =   ""
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   ""
      Index           =   -2147483648
      InitialValue    =   ""
      Italic          =   ""
      Left            =   123
      ListIndex       =   0
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Scope           =   0
      TabIndex        =   3
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   47
      Underline       =   ""
      UseFocusRing    =   True
      Visible         =   True
      Width           =   384
   End
   Begin CheckBox ignoreCase
      AutoDeactivate  =   True
      Bold            =   ""
      Caption         =   "Ignore Case"
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   123
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Scope           =   0
      State           =   1
      TabIndex        =   4
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   79
      Underline       =   ""
      Value           =   True
      Visible         =   True
      Width           =   100
   End
   Begin CheckBox wrapAround
      AutoDeactivate  =   True
      Bold            =   ""
      Caption         =   "Wrap Around"
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   235
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Scope           =   0
      State           =   1
      TabIndex        =   5
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   79
      Underline       =   ""
      Value           =   True
      Visible         =   True
      Width           =   110
   End
   Begin PushButton btnReplaceAll
      AutoDeactivate  =   True
      Bold            =   ""
      ButtonStyle     =   0
      Cancel          =   ""
      Caption         =   "Replace All"
      Default         =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   "Replace all occurrences of the find text"
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   100
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Scope           =   0
      TabIndex        =   6
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   114
      Underline       =   ""
      Visible         =   True
      Width           =   93
   End
   Begin PushButton btnReplace
      AutoDeactivate  =   True
      Bold            =   ""
      ButtonStyle     =   0
      Cancel          =   ""
      Caption         =   "Replace"
      Default         =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   "Replace selected text with the replacement text"
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   205
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Scope           =   0
      TabIndex        =   7
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   114
      Underline       =   ""
      Visible         =   True
      Width           =   80
   End
   Begin PushButton btnReplaceAndFind
      AutoDeactivate  =   True
      Bold            =   ""
      ButtonStyle     =   0
      Cancel          =   ""
      Caption         =   "Replace && Find"
      Default         =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   "Replace selected text and find next occurrence of the find text"
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   297
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Scope           =   0
      TabIndex        =   8
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   114
      Underline       =   ""
      Visible         =   True
      Width           =   118
   End
   Begin PushButton btnNext
      AutoDeactivate  =   True
      Bold            =   ""
      ButtonStyle     =   0
      Cancel          =   ""
      Caption         =   "Next"
      Default         =   True
      Enabled         =   True
      Height          =   20
      HelpTag         =   "find next occurrence of the find text"
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   427
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Scope           =   0
      TabIndex        =   9
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   114
      Underline       =   ""
      Visible         =   True
      Width           =   80
   End
   Begin Label results
      AutoDeactivate  =   True
      Bold            =   ""
      DataField       =   ""
      DataSource      =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   357
      LockBottom      =   ""
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   True
      Multiline       =   ""
      Scope           =   0
      Selectable      =   False
      TabIndex        =   10
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextAlign       =   2
      TextColor       =   8947848
      TextFont        =   "System"
      TextSize        =   0
      TextUnit        =   0
      Top             =   79
      Transparent     =   False
      Underline       =   ""
      Visible         =   True
      Width           =   150
   End
End
#tag EndWindow

#tag WindowCode
	#tag Event
		Sub Close()
		  lastLeft = me.Left
		  lastTop = me.top
		  CurrentFindWindow = nil
		End Sub
	#tag EndEvent

	#tag Event
		Function KeyDown(Key As String) As Boolean
		  if Key = Chr(3) or Key = Chr(13) then
		    btnNext.Push
		    return true
		  end if
		End Function
	#tag EndEvent

	#tag Event
		Sub Open()
		  if findTerms = nil then
		    findTerms = new Dictionary
		  end if
		  
		  if replaceTerms = nil then
		    replaceTerms = new Dictionary
		  end if
		  
		  CurrentFindWindow = self
		  txtToFind.Text = lastSearchTerm
		  txtToReplace.text = lastReplaceTerm
		  wrapAround.Value = lastWrapAroundValue
		  ignoreCase.Value = lastIgnoreCaseValue
		  if lastLeft >= 0 then me.Left = lastLeft
		  if lastTop >=0 then me.Top = lastTop
		  
		  for i as Integer = 0 to findTerms.Count - 1
		    txtToFind.AddRow findTerms.Key(i)
		  next
		  
		  for i as Integer = 0 to replaceTerms.Count - 1
		    txtToReplace.AddRow replaceTerms.Key(i)
		  next
		End Sub
	#tag EndEvent


	#tag MenuHandler
		Function FileClose() As Boolean Handles FileClose.Action
			self.Close
			Return True
			
		End Function
	#tag EndMenuHandler


	#tag Method, Flags = &h1
		Protected Shared Sub addFindTerm()
		  if findTerms = nil then
		    findTerms = new Dictionary
		  end if
		  
		  if findTerms.HasKey(lastSearchTerm) then Return
		  
		  findTerms.Value(lastSearchTerm) = nil
		  if CurrentFindWindow <> nil then
		    CurrentFindWindow.txtToFind.AddRow lastSearchTerm
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Sub addReplaceTerm()
		  if replaceTerms = nil then
		    replaceTerms = new Dictionary
		  end if
		  
		  if replaceTerms.HasKey(lastReplaceTerm) then Return
		  
		  replaceTerms.Value(lastReplaceTerm) = nil
		  
		  if CurrentFindWindow <> nil then
		    CurrentFindWindow.txtToReplace.AddRow lastReplaceTerm
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function findNext() As boolean
		  if CurrentFindWindow <> nil then
		    CurrentFindWindow.results.Text = ""
		    lastIgnoreCaseValue = CurrentFindWindow.ignoreCase.Value
		    lastWrapAroundValue = CurrentFindWindow.wrapAround.Value
		  end if
		  
		  if CurrentFindWindow <> nil and CurrentFindWindow.txtToFind.Text = "" then
		    beep
		    Return false
		  end if
		  
		  Return findNext(lastIgnoreCaseValue, lastWrapAroundValue, true, -1)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Function findNext(ignoreCase as boolean, wrapAround as boolean, redraw as boolean, startPos as integer) As boolean
		  dim Target as CustomEditField = CustomEditField.CurrentFocusedField
		  if Target = nil then Return false
		  
		  addFindTerm
		  if Target.Find(lastSearchTerm, ignoreCase, wrapAround, redraw, startPos) > -1 then Return true
		  
		  beep
		  if CurrentFindWindow <> nil then
		    CurrentFindWindow.results.Text = "Not Found"
		  end if
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Sub replace()
		  if CurrentFindWindow <> nil then
		    CurrentFindWindow.results.Text = ""
		    lastIgnoreCaseValue = CurrentFindWindow.ignoreCase.Value
		    lastWrapAroundValue = CurrentFindWindow.wrapAround.Value
		  end if
		  
		  dim Target as CustomEditField = CustomEditField.CurrentFocusedField
		  if Target = nil then Return
		  
		  addReplaceTerm
		  Target.SelText = lastReplaceTerm
		  Target.Redraw
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Shared Sub replaceAll()
		  dim Target as CustomEditField = CustomEditField.CurrentFocusedField
		  if Target = nil then Return
		  
		  dim count as Integer
		  dim eventID as Integer = Ticks // -> grouped undo
		  
		  addFindTerm
		  addReplaceTerm
		  Target.ignoreRepaint = true
		  dim startPos as Integer = 0 //start at begining of file
		  while findNext(lastIgnoreCaseValue, false, false, startPos) //WITHOUT wrapping, since this could lead to an infinite loop if replacement contains find term.
		    Target.private_replace(Target.SelStart, Target.SelLength, lastReplaceTerm, true, eventID)
		    count = count + 1
		    startPos = Target.CaretPos //update startPos
		  wend
		  Target.ignoreRepaint = false
		  Target.Redraw
		  
		  if Count > 1 and CurrentFindWindow <> nil then
		    CurrentFindWindow.results.Text = str(Count) + " Replaced"
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Sub replaceAndFind()
		  replace
		  call findNext
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected Shared CurrentFindWindow As FindWindow
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Shared findTerms As dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Shared lastIgnoreCaseValue As Boolean = true
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Shared lastLeft As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Shared lastReplaceTerm As string
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Shared lastSearchTerm As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Shared lastTop As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Shared lastWrapAroundValue As Boolean = true
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected Shared replaceTerms As dictionary
	#tag EndProperty


#tag EndWindowCode

#tag Events txtToFind
	#tag Event
		Sub TextChanged()
		  lastSearchTerm = me.Text
		End Sub
	#tag EndEvent
	#tag Event
		Function KeyDown(Key As String) As Boolean
		  if Key = Chr(3) or Key = Chr(13) then
		    btnNext.Push
		    return true
		  end if
		End Function
	#tag EndEvent
#tag EndEvents
#tag Events txtToReplace
	#tag Event
		Sub TextChanged()
		  lastReplaceTerm = me.text
		End Sub
	#tag EndEvent
	#tag Event
		Function KeyDown(Key As String) As Boolean
		  if Key = Chr(3) or Key = Chr(13) then
		    btnNext.Push
		    return true
		  end if
		End Function
	#tag EndEvent
#tag EndEvents
#tag Events ignoreCase
	#tag Event
		Sub Action()
		  lastIgnoreCaseValue = me.Value
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events wrapAround
	#tag Event
		Sub Action()
		  lastWrapAroundValue = me.Value
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events btnReplaceAll
	#tag Event
		Sub Action()
		  replaceAll
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events btnReplace
	#tag Event
		Sub Action()
		  replace
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events btnReplaceAndFind
	#tag Event
		Sub Action()
		  replaceAndFind
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events btnNext
	#tag Event
		Sub Action()
		  call findNext
		End Sub
	#tag EndEvent
#tag EndEvents
