#tag Window
Begin Window SyntaxColors
   BackColor       =   16777215
   Backdrop        =   ""
   CloseButton     =   True
   Composite       =   False
   Frame           =   8
   FullScreen      =   False
   HasBackColor    =   False
   Height          =   300
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
   Title           =   "Untitled"
   Visible         =   True
   Width           =   278
   Begin Listbox definitionColors
      AutoDeactivate  =   True
      AutoHideScrollbars=   True
      Bold            =   ""
      Border          =   True
      ColumnCount     =   6
      ColumnsResizable=   ""
      ColumnWidths    =   "*,40,40,24,24,24"
      DataField       =   ""
      DataSource      =   ""
      DefaultRowHeight=   24
      Enabled         =   True
      EnableDrag      =   ""
      EnableDragReorder=   ""
      GridLinesHorizontal=   0
      GridLinesVertical=   0
      HasHeading      =   True
      HeadingIndex    =   -1
      Height          =   248
      HelpTag         =   ""
      Hierarchical    =   True
      Index           =   -2147483648
      InitialParent   =   ""
      InitialValue    =   "Context Name	Color	Back	B	I	U"
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
      ScrollBarVertical=   False
      SelectionType   =   0
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "SmallSystem"
      TextSize        =   0
      TextUnit        =   0
      Top             =   0
      Underline       =   ""
      UseFocusRing    =   True
      Visible         =   True
      Width           =   278
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
   Begin PushButton btnOk
      AutoDeactivate  =   True
      Bold            =   ""
      ButtonStyle     =   0
      Cancel          =   ""
      Caption         =   "Ok"
      Default         =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   145
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   ""
      Scope           =   0
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "SmallSystem"
      TextSize        =   0
      TextUnit        =   0
      Top             =   260
      Underline       =   ""
      Visible         =   True
      Width           =   80
   End
   Begin Timer sizeTimer
      Height          =   32
      Index           =   -2147483648
      InitialParent   =   ""
      Left            =   0
      LockedInPosition=   False
      Mode            =   0
      Period          =   5
      Scope           =   0
      TabPanelIndex   =   0
      Top             =   309
      Width           =   32
   End
   Begin PushButton btnSave
      AutoDeactivate  =   True
      Bold            =   ""
      ButtonStyle     =   0
      Cancel          =   ""
      Caption         =   "Save XML"
      Default         =   ""
      Enabled         =   True
      Height          =   20
      HelpTag         =   ""
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   ""
      Left            =   53
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   ""
      LockTop         =   ""
      Scope           =   0
      TabIndex        =   3
      TabPanelIndex   =   0
      TabStop         =   True
      TextFont        =   "SmallSystem"
      TextSize        =   0
      TextUnit        =   0
      Top             =   260
      Underline       =   ""
      Visible         =   True
      Width           =   80
   End
End
#tag EndWindow

#tag WindowCode
	#tag Method, Flags = &h0
		Function show(definition as highlightdefinition) As boolean
		  self.definition = definition
		  showDefinition
		  me.Title = definition.Name
		  Super.ShowModal
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub ShowContexts(contexts() as highlightcontext, showPlaceholders as Boolean)
		  dim subContext as HighlightContext
		  
		  for each subContext in Contexts
		    if subContext.isPlaceholder and not showPlaceholders then Continue for
		    
		    dim subContexts() as HighlightContext = subContext.contexts
		    if subContexts.Ubound > - 1 and not subContexts(0).isPlaceholder then
		      definitionColors.AddFolder subContext.Name
		      
		    else
		      definitionColors.AddRow subContext.Name
		      
		    end if
		    
		    definitionColors.CellTag(definitionColors.LastIndex, 0) = subContext
		    definitionColors.CellCheck(definitionColors.LastIndex, 3) = subContext.Bold
		    definitionColors.CellCheck(definitionColors.LastIndex, 4) = subContext.Italic
		    definitionColors.CellCheck(definitionColors.LastIndex, 5) = subContext.Underline
		    definitionColors.Expanded(definitionColors.LastIndex) = true //expand all!
		  next
		  
		  Height = (definitionColors.ListCount + 1) * definitionColors.DefaultRowHeight + 52
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub showDefinition()
		  ShowContexts(definition.Contexts, true)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected definition As highlightdefinition
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected result As boolean
	#tag EndProperty


#tag EndWindowCode

#tag Events definitionColors
	#tag Event
		Sub ExpandRow(row As Integer)
		  dim selectedContext as HighlightContext
		  
		  selectedContext = me.CellTag(row, 0)
		  ShowContexts(selectedContext.Contexts, false)
		End Sub
	#tag EndEvent
	#tag Event
		Sub Open()
		  me.ColumnType(3) = Listbox.TypeCheckbox
		  me.ColumnType(4) = Listbox.TypeCheckbox
		  me.ColumnType(5) = Listbox.TypeCheckbox
		End Sub
	#tag EndEvent
	#tag Event
		Function CellBackgroundPaint(g As Graphics, row As Integer, column As Integer) As Boolean
		  if row >= me.ListCount then Return False
		  
		  dim context as HighlightContext = me.CellTag(row, 0)
		  
		  select case column
		  case 1
		    g.ForeColor = EditFieldGlobals.AdjustColorForDarkMode (Context.HighlightColor)
		    g.FillRect (g.Width - 18)/2, 2, 20, 20
		    g.ForeColor = EditFieldGlobals.AdjustColorForDarkMode (&c0)
		    g.drawRect (g.Width - 18)/2, 2, 20, 20
		    
		    Return true
		  case 2
		    if context.HasBackgroundColor then
		      g.ForeColor = EditFieldGlobals.AdjustColorForDarkMode (Context.BackgroundColor)
		      g.FillRect (g.Width - 18)/2, 2, 20, 20
		    else
		      g.DrawLine (g.Width - 18)/2, 2, (g.Width - 18)/2 + 19, 21
		    end if
		    g.ForeColor = EditFieldGlobals.AdjustColorForDarkMode (&c0)
		    g.drawRect (g.Width - 18)/2, 2, 20, 20
		    
		    Return true
		  end select
		  
		End Function
	#tag EndEvent
	#tag Event
		Sub CellAction(row As Integer, column As Integer)
		  dim context as HighlightContext = me.CellTag(row, 0)
		  
		  if Context = nil then Return
		  select case column
		  case 3 'b
		    Context.Bold = me.CellCheck(row, column)
		  case 4 'i
		    Context.Italic = me.CellCheck(row, column)
		  case 5 'u
		    Context.Underline = me.CellCheck(row, column)
		  end select
		  result = true
		End Sub
	#tag EndEvent
	#tag Event
		Function CellClick(row as Integer, column as Integer, x as Integer, y as Integer) As Boolean
		  #pragma unused x
		  #pragma unused y
		  #pragma unused row
		  
		  dim context as HighlightContext = me.CellTag(row, 0)
		  if context = nil then Return true
		  
		  dim newColor as color
		  select case column
		  case 1 'fore
		    newColor = context.HighlightColor
		    if SelectColor(newColor, context.Name + " highlight color") then
		      context.HighlightColor = newColor
		      result = true
		    end if
		  case 2 'back
		    newColor = context.BackgroundColor
		    if SelectColor(newColor, context.Name + " back color") then
		      context.BackgroundColor = newColor
		      result = true
		    end if
		    
		  end select
		End Function
	#tag EndEvent
	#tag Event
		Sub CollapseRow(row As Integer)
		  #pragma unused row
		  sizeTimer.Mode = timer.ModeSingle
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events btnOk
	#tag Event
		Sub Action()
		  Close
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events sizeTimer
	#tag Event
		Sub Action()
		  Height = (definitionColors.ListCount + 1) * definitionColors.DefaultRowHeight + 52
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events btnSave
	#tag Event
		Sub Action()
		  dim file as FolderItem = GetSaveFolderItem("Text", definition.Name+"_sdef.xml")
		  if file = nil then Return
		  
		  if not definition.saveAsXml(file) Then
		    MsgBox "Error saving"
		  end if
		End Sub
	#tag EndEvent
#tag EndEvents
