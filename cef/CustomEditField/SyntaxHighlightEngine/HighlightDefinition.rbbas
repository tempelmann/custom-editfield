#tag Class
Protected Class HighlightDefinition
	#tag Method, Flags = &h21
		Private Sub addContext(context as HighlightContext)
		  if Context=nil then Return
		  subContexts.Append(Context)
		  
		  if Context <> PlaceholderContextDef then
		    context.PlaceholderContextDef = PlaceholderContextDef
		  end if
		  
		  subExpressionCount = subExpressionCount + 1
		  subExpressionIndex.Append subExpressionCount
		  
		  fixSubExpressionCount (context.ContextSearchPattern)
		  
		  refreshSearchString
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub addSymbol(symbol as symbolsDefinition)
		  if Symbol = nil then Return
		  Symbols.Append Symbol
		  
		  symbolCount = symbolCount + 1
		  symbolIndex.Append symbolCount
		  
		  // add pattern to search string
		  if symbolPattern <> "" then symbolPattern = symbolPattern + "|"
		  symbolPattern = symbolPattern + "(" + symbol.EntryRegex + ")"
		  fixSymbolCount(symbol.EntryRegex)
		  
		  // update prepared regex for symbolPattern
		  mSymbolRegex.SearchPattern = symbolPattern
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function bool2YN(value as boolean) As string
		  if value then Return "yes"
		  Return "no"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function ColorToText(c as Color) As String
		  dim v as Variant = c
		  return Right("0000000"+Hex(v.IntegerValue),6) // aIntegerValue doesn't include a Color's transparency, so we're safe here
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  //init regex scanner
		  mContextRegex = new RegEx
		  mContextRegex.Options.DotMatchAll=true
		  
		  mSymbolRegex = new RegEx
		  
		  //add a blank space context, this will tokenize strings.
		  dim blankSpaceContext as new HighlightContext(false, false)
		  blankSpaceContext.EntryRegEx = "([ ]|\t|\x0A|(?:\x0D\x0A?))"'"([\s])"
		  blankSpaceContext.Name = "fieldwhitespace"
		  
		  addContext(blankSpaceContext)
		  blockEndDef = new Dictionary
		  blockStartDef = new Dictionary
		  lineContinuationDef = new Dictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ContextEnabled(name as String) As Boolean
		  for each current as HighlightContext in subContexts
		    if current.Name = name then
		      return current.Enabled
		    end if
		  next
		  ' not found?
		  break
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ContextEnabled(name as String, assigns ena as Boolean)
		  for each current as HighlightContext in subContexts
		    if current.Name = name then
		      if current.Enabled <> ena then
		        current.Enabled = ena
		        refreshSearchString
		      end if
		      return
		    end if
		  next
		  ' not found?
		  break
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Contexts() As highlightcontext()
		  dim tmp() as HighlightContext
		  
		  for each current as HighlightContext in subContexts
		    if current.Name <> "fieldwhitespace" and current.Enabled then tmp.Append current
		  next
		  
		  Return tmp
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub fixSubExpressionCount(pattern as string)
		  // determine subexpression count
		  // This method is original from Nick Lockwood: http://www.charcoaldesign.co.uk/oss#tokenizer
		  // It speeds up the matching of the matched regex.
		  dim escaped, inCharClass, prevBracket as Boolean = false
		  escaped = false
		  for i as integer = 1 to pattern.Len
		    select case pattern.mid(i,1)
		    case "\"
		      escaped = true
		      prevBracket = false
		    case "("
		      dim nextChar as String = pattern.Mid(i+1,1)
		      if not inCharClass and not escaped and nextChar <> "?" then self.subExpressionCount = self.subExpressionCount + 1
		      prevBracket = false
		      escaped = false
		    case "["
		      if inCharClass or escaped then
		        prevBracket = false
		        escaped = false
		      else
		        inCharClass = true
		        prevBracket = true
		      end
		    case "]"
		      if not prevBracket then inCharClass = false
		      prevBracket = false
		    else
		      prevBracket = false
		      escaped = false
		    end
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub fixSymbolCount(pattern as string)
		  // determine subexpression count
		  // This method is original from Nick Lockwood: http://www.charcoaldesign.co.uk/oss#tokenizer
		  // It speeds up the matching of the matched regex.
		  dim escaped, inCharClass, prevBracket as Boolean = false
		  escaped = false
		  for i as integer = 1 to pattern.Len
		    select case pattern.mid(i,1)
		    case "\"
		      escaped = true
		      prevBracket = false
		    case "("
		      dim nextChar as String = pattern.Mid(i+1,1)
		      if not inCharClass and not escaped and nextChar <> "?" then symbolCount = symbolCount + 1
		      prevBracket = false
		      escaped = false
		    case "["
		      if inCharClass or escaped then
		        prevBracket = false
		        escaped = false
		      else
		        inCharClass = true
		        prevBracket = true
		      end
		    case "]"
		      if not prevBracket then inCharClass = false
		      prevBracket = false
		    else
		      prevBracket = false
		      escaped = false
		    end
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Highlight(text as string, tokens() as textsegment, placeholders() as textplaceholder, forceMatch as highlightContext = nil) As highlightcontext
		  #pragma DisableBackgroundTasks
		  
		  
		  #if DebugBuild and EditFieldGlobals.DebugTiming
		    dim runtimer as new Debugging.AccumulationTimer(CurrentMethodName)
		  #endif
		  
		  dim match as RegExMatch
		  dim subExpression as String
		  dim context as HighlightContext
		  dim startPos, startPosB as Integer
		  dim openContext as HighlightContext
		  
		  if text.Encoding <> nil then text = text.ConvertEncoding(EditFieldGlobals.InternalEncoding)
		  
		  if forceMatch = nil then
		    // perform the initial search
		    match = mContextRegex.Search(Text)
		  end if
		  
		  dim charPos, charPosB as Integer
		  while forceMatch <> nil or match<>nil
		    if match = nil Then
		      subExpression = ""
		    else
		      subExpression = match.SubExpressionString(0)
		    end if
		    
		    // determine which token was matched
		    if forceMatch <> nil then
		      context = forceMatch
		      forceMatch = nil
		    else
		      dim tknIndex as integer = -1
		      for i as integer = 1 to match.SubExpressionCount - 1
		        if match.SubExpressionString(i) = subExpression then
		          tknIndex = subExpressionIndex.IndexOf(i)
		          if tknIndex >= 0 then
		            context = subContexts(tknIndex)
		            if not context.Enabled then
		              break ' must not happen - the mContextRegex may not contain disabled contexts
		            end if
		          end if
		          exit
		        end
		      next
		      
		      if tknIndex < 0 then //definition can't handle source!?
		        exit while
		      end if
		    end if
		    
		    //find the actual character position within the string, since SubExpressionStartB returns the byte position,
		    //and if you have multi-byte strings you get an offsetted highlight.
		    if match = nil then
		      charPos = 0
		    else
		      charPos = text.leftb(match.SubExpressionStartB(0)).len
		      charposB = match.SubExpressionStartB(0)
		    end if
		    
		    //Highlight everything up to this point with the default color.
		    if charPos - startPos > 0 then
		      tokens.Append(new TextSegment(startPos, charPos-startPos, TextSegment.TYPE_WORD, DefaultColor))
		    end if
		    
		    startPos = charPos
		    startPosB = charPosB
		    
		    //forward execution to the context for any further processing.
		    if context <> nil and not context.isPlaceholder then
		      if context.Highlight(text, subExpression, startPos, startPosB, mContextRegex, tokens, placeholders) then
		        openContext = context
		      end if
		      startPos = text.leftb(mContextRegex.SearchStartPosition).len
		      startPosB = mContextRegex.SearchStartPosition
		      
		    ElseIf context <> nil and context.isPlaceholder then
		      dim label as String = match.SubExpressionString(match.SubExpressionCount - 1)
		      dim tmp as Integer = text.leftb(match.SubExpressionStartB(match.SubExpressionCount - 1)).len
		      dim placeholder as new TextPlaceholder(startPos, subExpression.Len, tmp, label.len, context.HighlightColor, context.BackgroundColor, context.Bold, context.Italic, context.Underline)
		      tokens.Append(placeholder)
		      placeholders.Append(placeholder)
		      
		      startPos = text.leftb(mContextRegex.SearchStartPosition).len
		      startPosB = mContextRegex.SearchStartPosition
		    end if
		    
		    //and search again
		    match = mContextRegex.Search
		  wend
		  
		  //Highlight the rest of the text with the default color.
		  if text.len - startPos > 0 then
		    tokens.Append(new TextSegment(startPos, text.len - startPos, TextSegment.TYPE_WORD, DefaultColor))
		  end if
		  
		  Return openContext
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub IndentNode(node As XmlNode, level As Integer, indentCloseTag As Boolean = False)
		  static ss As String
		  if ss = "" then
		    ss = EndOfLine
		    For i as Integer = 1 To 20
		      ss = ss + Chr(9) // Tab
		    Next
		  end if
		  dim s as String = ss.Left(level+1)
		  node.Parent.Insert(node.OwnerDocument.CreateTextNode(s), node)
		  If indentCloseTag Then
		    node.AppendChild(node.OwnerDocument.CreateTextNode(s))
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsBlockEnd(lineText as string, stateIn as String, ByRef stateOut as String, ByRef ruleOut as Object) As Boolean
		  // returns true if it's a block end, new state and the matched rule (opaque, only useful for matching with IsBlockStart's returned value)
		  
		  stateOut = stateIn
		  
		  #if DebugBuild and EditFieldGlobals.DebugTiming
		    dim runtimer as new Debugging.AccumulationTimer(CurrentMethodName)
		  #endif
		  
		  dim v as Variant = blockEndDef.Lookup (stateIn, nil)
		  if v.IsArray then
		    dim ps() as Pair = v
		    for each p as Pair in ps
		      if p <> nil then
		        dim scanner as RegEx = p.Left
		        if scanner.Search(lineText) <> nil then
		          dim ruleAndState as Pair = p.Right
		          dim state as Pair = ruleAndState.Right
		          if state.Left.BooleanValue then
		            // change state
		            stateOut = state.Right
		          end
		          ruleOut = ruleAndState.Left
		          return true
		        end
		      end if
		    next
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsBlockStart(lineText as string, stateIn as String, ByRef stateOut as String, ByRef ruleOut as Object) As Integer
		  // returns indent value, new state and the matched rule (opaque, only useful for matching with IsBlockEnd's returned value)
		  
		  #if DebugBuild and EditFieldGlobals.DebugTiming
		    dim runtimer as new Debugging.AccumulationTimer(CurrentMethodName)
		  #endif
		  
		  stateOut = stateIn
		  
		  dim v as Variant = blockStartDef.Lookup (stateIn, nil)
		  if v.IsArray then
		    dim ps() as Pair = v
		    for each p as Pair in ps
		      if p <> nil then
		        dim scanner as RegEx = p.Left
		        if scanner.Search(lineText) <> nil then
		          dim indentAndState as Pair = p.Right
		          dim state as Pair = indentAndState.Right
		          if state.Left.BooleanValue then
		            // change state
		            stateOut = state.Right
		          end
		          ruleOut = scanner
		          return indentAndState.Left
		        end
		      end if
		    next
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsLineContinuation(lineText as string) As Integer
		  // returns indent value
		  
		  #if DebugBuild and EditFieldGlobals.DebugTiming
		    dim runtimer as new Debugging.AccumulationTimer(CurrentMethodName)
		  #endif
		  
		  if lineContinuationDef.Count = 0 then Return 0
		  
		  dim scanner as RegEx = lineContinuationDef.Key(0)
		  
		  if scanner.Search(lineText) <> nil then
		    Return lineContinuationDef.Value(scanner)
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function Keywords() As string()
		  //get all the keyword strings in this definition.
		  dim tmp() as String
		  for i as Integer = 0 to UBound(subContexts)
		    subContexts(i).ListKeywords(tmp)
		  next
		  
		  tmp.Sort
		  Return tmp
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LineContinuationIndent() As Integer
		  // returns the block indentation of the first default state
		  
		  dim ps() as Pair = blockStartDef.Lookup ("", nil)
		  if not (ps is nil) then
		    dim p as Pair = ps(0)
		    dim indentAndState as Pair = p.Right
		    return indentAndState.Left
		  end
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LoadFromXml(data as folderItem) As boolean
		  if data=nil then Return False
		  
		  //read a file...
		  dim tis as TextInputStream=TextInputStream.Open(data)
		  if tis=nil then Return False
		  
		  dim xml as String=tis.ReadAll(Encodings.UTF8)
		  tis.Close
		  
		  Return loadFromXml(xml)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LoadFromXml(data as string) As boolean
		  dim xml as XmlDocument
		  Dim root, node as XMLNode
		  Dim context as HighlightContext
		  dim Symbol as SymbolsDefinition
		  Dim i, j as Integer
		  
		  //load a xml syntax definition.
		  try
		    xml=new XmlDocument
		    xml.LoadXml(data)
		    
		    root=xml.Child(0)
		    //doc check
		    if root.Name<>"highlightDefinition" then
		      break
		      Return False
		    end if
		    if val(root.GetAttribute("version")) > version then
		      break
		      Return False
		    end if
		    
		    dim lastStartRule as Object
		    
		    for i=0 to root.ChildCount-1
		      node=root.Child(i)
		      select case node.Name
		      case "name"
		        //syntax name
		        Name=node.FirstChild.Value
		        
		      case "blockStartMarker"
		        if lastStartRule <> nil then
		          // Error: There's still an unfinished start rule open
		          break
		          return false
		        end
		        dim newstate as XmlAttribute = node.GetAttributeNode("newstate")
		        dim newstateValue as String
		        if newstate <> nil then newstateValue = newstate.Value
		        dim cond as String = node.GetAttribute("condition")
		        dim values() as Pair
		        dim v as Variant = blockStartDef.Lookup(cond, nil)
		        if not v.IsArray then
		          blockStartDef.Value(cond) = values
		        else
		          values = v
		        end if
		        dim re as new RegEx
		        re.SearchPattern = node.FirstChild.Value
		        values.Append re : (node.GetAttribute("indent").Val : (newstate <> nil : newstateValue))
		        lastStartRule = re
		        
		      case "blockEndMarker"
		        if lastStartRule = nil then
		          // Error: End rule without start rule
		          break
		          return false
		        end
		        dim newstate as XmlAttribute = node.GetAttributeNode("newstate")
		        dim newstateValue as String
		        if newstate <> nil then newstateValue = newstate.Value
		        dim cond as String = node.GetAttribute("condition")
		        dim values() as Pair
		        dim v as Variant = blockEndDef.Lookup(cond, nil)
		        if not v.IsArray then
		          blockEndDef.Value(cond) = values
		        else
		          values = v
		        end if
		        dim re as new RegEx
		        re.SearchPattern = node.FirstChild.Value
		        values.Append re : (lastStartRule : (newstate <> nil : newstateValue))
		        lastStartRule = nil
		        
		      case "lineContinuationMarker"
		        //indent is the number of indentations.
		        dim re as new RegEx
		        re.SearchPattern = node.FirstChild.Value
		        lineContinuationDef.Value(re) = val(node.GetAttribute("indent"))
		        
		      case "symbols"
		        for j = 0 to node.ChildCount - 1
		          dim child as XmlNode = node.Child(j)
		          if child.Name = "symbol" then
		            Symbol = new SymbolsDefinition
		            Symbol.loadFromXmlNode(child)
		            addSymbol(Symbol)
		          end if
		        next
		        
		      case "placeholders"
		        placeholderContextDef = new HighlightContext(False, False)
		        placeholderContextDef.EntryRegEx = node.FirstChild.Value
		        placeholderContextDef.isPlaceholder = true
		        placeholderContextDef.Name = "Placeholders"
		        
		        dim tmpObj as Variant
		        if node.GetAttribute("highlightColor") <> "" then
		          tmpObj = "&h" + node.GetAttribute("highlightColor").Mid(1)
		          PlaceholderContextDef.HighlightColor = tmpObj.ColorValue
		        end if
		        
		        if node.GetAttribute("backgroundColor") <> "" then
		          tmpObj = "&h" + node.GetAttribute("backgroundColor").Mid(1)
		          PlaceholderContextDef.BackgroundColor = tmpObj.ColorValue
		        end if
		        
		        dim tmp as String
		        
		        //Bold
		        tmp = node.GetAttribute("bold")
		        if tmp <> "" then placeholderContextDef.Bold = tmp = "true"
		        
		        //Italic
		        tmp = node.GetAttribute("italic")
		        if tmp <> "" then placeholderContextDef.Italic = tmp = "true"
		        
		        //Underline
		        tmp = node.GetAttribute("underline")
		        if tmp <> "" then placeholderContextDef.Underline = tmp = "true"
		        
		        //Enabled
		        tmp = node.GetAttribute("enabled")
		        placeholderContextDef.Enabled = tmp <> "false"
		        
		        self.addContext placeholderContextDef
		        
		      case "contexts"
		        //contexts
		        dim tmpObj as Variant
		        tmpObj = "&h" + node.GetAttribute("defaultColor").Mid(1)
		        defaultColor=tmpObj.ColorValue
		        caseSensitive = YN2Bool(node.GetAttribute("caseSensitive"))
		        for j=0 to node.ChildCount-1
		          Context=new HighlightContext(caseSensitive)
		          Context.loadFromXmlNode(node.Child(j))
		          addContext(Context)
		        next
		      end select
		    Next
		    
		    Return true
		  Catch
		    break
		    Return False
		  end try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub refreshSearchString()
		  // build search string from all contexts
		  
		  dim patterns() as String
		  for each c as HighlightContext in subContexts
		    if c.Enabled then
		      patterns.Append "(" + c.ContextSearchPattern + ")"
		    end if
		  next
		  
		  mContextRegex.SearchPattern = Join (patterns, "|")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SaveAsXml(file as folderItem) As boolean
		  if file=nil then Return False
		  
		  //save definition as an xml
		  try
		    dim tos as TextOutputStream = TextOutputStream.Create(file)
		    tos.Write(toXml)
		    tos.Close
		    
		    Return true
		  catch
		    Return False
		  end try
		  
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ScanSymbols(forText as string) As dictionary
		  //simple symbol scan
		  
		  if mSymbolRegex = nil then Return nil
		  
		  if forText.Encoding <> nil then forText = forText.ConvertEncoding(Encodings.UTF8)
		  
		  dim match as RegExMatch
		  dim symbol as String
		  dim pos as integer
		  dim local as new Dictionary
		  dim tknIndex as integer
		  dim symbolDef as SymbolsDefinition
		  
		  match = mSymbolRegex.Search(forText)
		  while match <> nil
		    Symbol = match.SubExpressionString(0)
		    pos = forText.leftb(match.SubExpressionStartB(0)).len
		    
		    for i as integer = 1 to match.SubExpressionCount - 1
		      if match.SubExpressionString(i) = symbol then
		        tknIndex = symbolIndex.IndexOf(i)
		        exit
		      end
		    next
		    
		    if tknIndex < 0 or tknIndex > Symbols.Ubound then //definition can't handle source!?
		      exit while
		    end if
		    
		    symbolDef = Symbols(tknIndex)
		    
		    Symbol = Symbol.Trim //strip spaces
		    if Symbol <> "" then
		      local.Value(Symbol) = new DocumentSymbol(Symbol, pos, symbolDef.Type)
		    end if
		    
		    match = mSymbolRegex.Search
		  wend
		  
		  if local.Count = 0 then Return nil
		  Return local
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SupportsCodeBlocks() As boolean
		  Return blockStartDef.Count > 0 and blockEndDef.Count > 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToXML() As string
		  Dim xml as XmlDocument
		  Dim root, node as XMLNode
		  Dim context as HighlightContext
		  dim Symbol as SymbolsDefinition
		  
		  xml = New XmlDocument
		  
		  //root
		  root = xml.AppendChild(xml.CreateElement("highlightDefinition"))
		  root.SetAttribute("version",Str(version,"#.0"))
		  
		  //name
		  node = root.AppendChild(xml.CreateElement("name"))
		  node.AppendChild(xml.CreateTextNode(name))
		  IndentNode(node,1)
		  
		  //block markers
		  for each cond as String in blockStartDef.Keys
		    dim ps() as Pair = blockStartDef.Value(cond)
		    for each p as Pair in ps
		      // p.Left: RegEx with SearchPattern
		      // p.Right: Pair of indent and state
		      node = root.AppendChild(xml.CreateElement("blockStartMarker"))
		      node.AppendChild(xml.CreateTextNode(RegEx(p.Left.ObjectValue).SearchPattern))
		      if cond <> "" then
		        node.SetAttribute("condition", cond)
		      end if
		      dim indentAndState as Pair = p.Right
		      node.SetAttribute("indent", Str(indentAndState.Left, "#"))
		      dim state as Pair = indentAndState.Right
		      if state.Left.BooleanValue then
		        node.SetAttribute("newstate", state.Right)
		      end if
		      IndentNode(node,1)
		    next
		  next
		  for each cond as String in blockEndDef.Keys
		    dim ps() as Pair = blockEndDef.Value(cond)
		    for each p as Pair in ps
		      // p.Left: RegEx with SearchPattern
		      // p.Right: Pair of (rule_ref, Pair of (indent, state))
		      node = root.AppendChild(xml.CreateElement("blockEndMarker"))
		      node.AppendChild(xml.CreateTextNode(RegEx(p.Left.ObjectValue).SearchPattern))
		      if cond <> "" then
		        node.SetAttribute("condition", cond)
		      end if
		      dim state as Pair = Pair(p.Right).Right
		      if state.Left.BooleanValue then
		        node.SetAttribute("newstate", state.Right)
		      end if
		      IndentNode(node,1)
		    next
		  next
		  
		  for each key as RegEx in lineContinuationDef.Keys
		    node = root.AppendChild(xml.CreateElement("lineContinuationMarker"))
		    node.AppendChild(xml.CreateTextNode(key.SearchPattern))
		    node.SetAttribute("indent", Str(lineContinuationDef.Value(key), "#"))
		    IndentNode(node,1)
		  next
		  
		  node = root.AppendChild(xml.CreateElement("symbols"))
		  for each Symbol in Symbols
		    Symbol.appendToXMLNode(node)
		  next
		  IndentNode(node,1, true)
		  
		  if PlaceholderContextDef <> nil then
		    node = root.AppendChild(xml.CreateElement("placeholders"))
		    
		    //HighlightColor
		    node.SetAttribute("highlightColor","#"+ColorToText(HighlightColor))
		    
		    //BackgroundColor
		    if PlaceholderContextDef.HasBackgroundColor then
		      node.SetAttribute("backgroundColor","#"+ColorToText(PlaceholderContextDef.BackgroundColor))
		    end if
		    
		    //bold
		    if PlaceholderContextDef.Bold then
		      node.SetAttribute("bold", "true")
		    end if
		    //italic
		    if PlaceholderContextDef.Italic then
		      node.SetAttribute("italic", "true")
		    end if
		    //Underline
		    if PlaceholderContextDef.Underline then
		      node.SetAttribute("underline", "true")
		    end if
		    
		    //Enabled
		    if not PlaceholderContextDef.Enabled then
		      node.SetAttribute("enabled", "false")
		    end if
		    
		    node.AppendChild(xml.CreateTextNode(PlaceholderContextDef.EntryRegEx))
		    
		    IndentNode(node,1, false)
		  end if
		  
		  node = root.AppendChild(xml.CreateElement("contexts"))
		  node.SetAttribute("defaultColor","#"+ColorToText(defaultColor))
		  node.SetAttribute("caseSensitive",bool2YN(caseSensitive))
		  
		  //process contexts
		  for Each Context in subContexts
		    if Context.Name = "fieldwhitespace" or context.isPlaceholder then Continue for
		    
		    Context.appendToXMLNode(node)
		  next
		  
		  IndentNode(node,1, true)
		  IndentNode(root,0, true)
		  
		  Return xml.ToString
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function YN2Bool(value as string) As boolean
		  if value="yes" then Return true
		  Return False
		End Function
	#tag EndMethod


	#tag Note, Name = About
		Info
		
		HighlightDefinition
		By Alex Restrepo
		send comments, suggestions, fixes to alexrestrepo@mac.com
		
		A little experiment on SyntaxHighlighting
		Contains the rules of how to Highlight the contents of the EditField.
		A definition is composed of one or more HighlightContexts
		
		Methods:
		Highlight(text as string, style as styledText): highlights the provided text using the provided styledtext object.
		LoadFromXml(data as string): loads a HighlightDefinition stored in a xml string
		LoadFromXml(data as folderItem): loads a HighlightDefinition stored in a xml file
		SaveAsXml(file as folderitem): saves the HighlightDefinition as an xml file.
		 
		Properties:
		CaseSensitive: gets or sets if the contained syntax is case-sensitive
		DefaultColor: gets or sets the default color for the text
		Name: the name of the definition (ie: Xml or REALbasic)
		
		
		Open source under the creative commons license.
		Use in whatever way you like... at your own risk :P
		let me know if you find it useful.
		If you decide to use it in your projects, please give me credit in your about window or documentation, thanks.
	#tag EndNote


	#tag Property, Flags = &h21
		#tag Note
			Key: condition
			Value: Array of Pair of (regex, Pair of (regex_of_blockStart, Pair of (changeState as Boolean : newState as String))
		#tag EndNote
		Private blockEndDef As dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			Key: condition
			Value: Array of Pair of (regex, Pair of (indent as Integer, Pair of (changeState as Boolean : newState as String))
		#tag EndNote
		Private blockStartDef As dictionary
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return _caseSensitive
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  _caseSensitive = value
			  mContextRegex.Options.CaseSensitive = value
			End Set
		#tag EndSetter
		CaseSensitive As boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return _defaultColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  _defaultColor=value
			End Set
		#tag EndSetter
		DefaultColor As color
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private lineContinuationDef As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mContextRegex As RegEx
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSymbolRegex As RegEx
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return _name
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  _name=value
			End Set
		#tag EndSetter
		Name As string
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private PlaceholderContextDef As HighlightContext
	#tag EndProperty

	#tag Property, Flags = &h21
		Private subContexts() As HighlightContext
	#tag EndProperty

	#tag Property, Flags = &h21
		Private subExpressionCount As integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private subExpressionIndex() As integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private symbolCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private symbolIndex() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private symbolPattern As string
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Symbols() As SymbolsDefinition
	#tag EndProperty

	#tag Property, Flags = &h21
		Private _caseSensitive As boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private _defaultColor As color
	#tag EndProperty

	#tag Property, Flags = &h21
		Private _name As string
	#tag EndProperty


	#tag Constant, Name = version, Type = Double, Dynamic = False, Default = \"1.4", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="caseSensitive"
			Group="Behavior"
			InitialValue="0"
			Type="boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="defaultColor"
			Group="Behavior"
			InitialValue="&h000000"
			Type="color"
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
			Type="string"
			EditorType="MultiLineEditor"
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
