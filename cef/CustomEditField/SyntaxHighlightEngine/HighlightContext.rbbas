#tag Class
Protected Class HighlightContext
	#tag Method, Flags = &h0
		Sub addKeyword(keyword as string)
		  if keyword="" then Return
		  keywords.Append(keyword)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub addRegEx(newRegEx as string)
		  if newRegEx="" then Return
		  regexes.Append(newRegEx)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub addSubContext(entry as HighlightContext)
		  if entry=nil then Return
		  subContexts.Append(entry)
		  
		  subExpressionCount = subExpressionCount + 1
		  subExpressionIndex.Append subExpressionCount
		  
		  // clear caches, just in case
		  _subContextPattern = ""
		  _contextPattern = ""
		  
		  // add pattern to search string
		  if mSearchPattern <> "" then mSearchPattern = mSearchPattern + "|"
		  mSearchPattern = mSearchPattern + "(" + entry.ContextSearchPattern + ")"
		  fixSubExpressionCount(entry.ContextSearchPattern)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub appendToXMLNode(parent as xmlNode, depth as integer = 2)
		  // Appends this context to the parent xml node.
		  // This is done to export the syntax definition as an xml file.
		  
		  dim xdoc as XmlDocument
		  dim node, context as XmlNode
		  
		  xdoc = parent.OwnerDocument
		  context=parent.AppendChild(xdoc.CreateElement("highlightContext"))
		  
		  //name
		  context.SetAttribute("name",Name)
		  
		  //HighlightColor
		  context.SetAttribute("highlightColor","#"+HighlightDefinition.ColorToText(HighlightColor))
		  
		  //BackgroundColor
		  if HasBackgroundColor then
		    context.SetAttribute("backgroundColor","#"+HighlightDefinition.ColorToText(BackgroundColor))
		  end if
		  
		  //bold
		  if Bold then
		    context.SetAttribute("bold", "true")
		  end if
		  //italic
		  if Italic then
		    context.SetAttribute("italic", "true")
		  end if
		  //Underline
		  if Underline then
		    context.SetAttribute("underline", "true")
		  end if
		  
		  //Enabled
		  if not Enabled then
		    context.SetAttribute("enabled", "false")
		  end if
		  
		  //start regex?
		  if StartRegEx<>"" then
		    node=context.AppendChild(xdoc.CreateElement("startRegEx"))
		    node.AppendChild(xdoc.CreateTextNode(StartRegEx))
		    IndentNode(node,depth+1)
		  end if
		  
		  //end regex?
		  if EndRegEx<>"" then
		    node=context.AppendChild(xdoc.CreateElement("endRegEx"))
		    node.AppendChild(xdoc.CreateTextNode(EndRegEx))
		    IndentNode(node,depth+1)
		  end if
		  
		  //entry regex?
		  if EntryRegEx<>"" then
		    node=context.AppendChild(xdoc.CreateElement("entryRegEx"))
		    node.AppendChild(xdoc.CreateTextNode(EntryRegEx))
		    IndentNode(node,depth+1)
		  end if
		  
		  //keywords
		  if UBound(keywords)>-1 then
		    node=context.AppendChild(xdoc.CreateElement("keywords"))
		    dim tmp as String
		    dim kw as XmlNode
		    for each tmp in keywords
		      kw=node.AppendChild(xdoc.CreateElement("string"))
		      kw.AppendChild(xdoc.CreateTextNode(tmp))
		      IndentNode(kw,depth+2)
		    next
		    IndentNode(node,depth+1,true)
		  end if
		  
		  //regexes
		  if UBound(regexes)>-1 then
		    node=context.AppendChild(xdoc.CreateElement("regExes"))
		    dim tmp as String
		    dim kw as XmlNode
		    for each tmp in regexes
		      kw=node.AppendChild(xdoc.CreateElement("string"))
		      kw.AppendChild(xdoc.CreateTextNode(tmp))
		      IndentNode(kw,depth+2)
		    next
		    IndentNode(node,depth+1,true)
		  end if
		  
		  //finally, subcontexs, if any
		  dim subContext as HighlightContext
		  for each subContext in subContexts
		    if subContext.Name = "fieldwhitespace" or subContext.isPlaceholder then Continue for
		    subContext.appendToXMLNode(context,depth+1)
		  next
		  
		  IndentNode(Context,depth, true)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(caseSensitive as boolean, createBlank as boolean = true)
		  //init regex scanner
		  mScanner=new RegEx
		  mScanner.Options.DotMatchAll=true
		  mScanner.Options.CaseSensitive=caseSensitive
		  
		  mEnabled = true ' default
		  
		  //if add whitespace tokenizer
		  if createBlank then
		    dim blankSpaceContext as new HighlightContext(false, false)
		    blankSpaceContext.EntryRegEx = "([ ]|\t|\x0A|(?:\x0D\x0A?))"'"([\s])"
		    blankSpaceContext.Name = "fieldwhitespace"
		    addSubContext(blankSpaceContext)
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Contexts() As highlightcontext()
		  dim current, tmp() as HighlightContext
		  
		  for each current in subContexts
		    if current.Name <> "fieldwhitespace" and current.Enabled then tmp.Append current
		  next
		  
		  Return tmp
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ContextSearchPattern() As String
		  //return the regex pattern for this context
		  
		  //if there's a StartRegEx then the pattern is the StartRegEx, the same goes with the EntryRegEx
		  if StartRegEx<>"" then Return StartRegEx
		  if entryRegEx<>"" then Return entryRegEx
		  
		  //else, if there's a cached version of the regex, return it.
		  if _contextPattern<>"" then Return _contextPattern
		  
		  //finally, build the pattern using the keywords, regexes and subcontexts (these are exclusive)
		  //check for keywords
		  dim keyword as String
		  if UBound(keywords)>-1 then
		    _contextPattern="\b("
		    for Each keyword in keywords
		      _contextPattern=_contextPattern+keyword+"|"
		    next
		    _contextPattern=Left(_contextPattern,_contextPattern.Len-1)+")\b"
		    Return _contextPattern
		  end if
		  
		  //else, check for regexes
		  dim aRegEx as String
		  if UBound(regexes)>-1 then
		    _contextPattern="("
		    for Each aRegEx in regexes
		      _contextPattern=_contextPattern+aRegEx+"|"
		    next
		    _contextPattern=Left(_contextPattern,_contextPattern.Len-1)+")"
		    Return _contextPattern
		  end if
		  
		  // we seem never to get here
		  _contextPattern = subContextPattern
		  Return _contextPattern
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub fixSubExpressionCount(pattern as string)
		  // determine subexpression count
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
		      if not inCharClass and not escaped and nextChar <> "?" then subExpressionCount = subExpressionCount + 1
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
		Function Highlight(text as string, subExpression as string, position as integer, positionB as integer, scanner as regex, tokens() as textsegment, placeholders() as TextPlaceholder) As boolean
		  #pragma DisableBackgroundTasks
		  
		  
		  //Highlight this context
		  dim match as RegExMatch
		  dim scanNextLine as Boolean = false
		  
		  //if there's a start and end regexes we need to find the EndRegEx
		  if StartRegEx.trim<>"" and mEndRegEx<>nil then
		    //find end...
		    #if true
		      dim oldPattern as String = scanner.SearchPattern
		      scanner.SearchPattern = EndRegEx
		      match = scanner.Search(text, positionB + subExpression.Lenb) //fix, added .lenb to support utf correctly
		      scanner.SearchPattern = oldPattern
		    #else
		      // this would be a slightly faster version, but it doesn't work right, e.g. with Postgresql syntax. No idea why
		      match = mEndRegex.Search(text, positionB + subExpression.Lenb) //fix, added .lenb to support utf correctly
		      scanner.SearchStartPosition = mEndRegex.SearchStartPosition
		    #endif
		    
		    //find the subExpression
		    if match<>nil then
		      subExpression=LeftB(text, match.SubExpressionStartB(0)+match.SubExpressionString(0).LenB)
		      subExpression=Right(subExpression, subExpression.Len-position)
		    else
		      //no match? then use the rest of the String...
		      subExpression=Right(text, text.Len-position)
		      scanner.SearchStartPosition = text.Lenb //fix, added .lenb to support utf correctly
		      scanNextLine = true
		    end if
		  end if
		  
		  dim entry as HighlightContext
		  dim substring as String
		  dim startPos, startPosB, charPos, charPosB as Integer
		  
		  //scan subcontexts
		  substring = mSearchPattern
		  if substring = "" then
		    //Highlight subExpression
		    select case subExpression
		    case " "
		      tokens.Append(new TextSegment(position, 1, TextSegment.TYPE_SPACE, HighlightColor, BackgroundColor))
		      
		    case chr(9)
		      tokens.Append(new TextSegment(position, 1, TextSegment.TYPE_TAB, HighlightColor, BackgroundColor))
		      
		    case chr(10), chr(13), chr(13) + chr(10)
		      tokens.Append(new TextSegment(position, subExpression.Len, TextSegment.TYPE_EOL, HighlightColor, BackgroundColor))
		      
		    else
		      if subExpression.len > 0 then _
		      tokens.Append(new TextSegment(position, subExpression.Len, TextSegment.TYPE_WORD, HighlightColor, BackgroundColor, bold, italic, underline))
		      
		    end select
		  else
		    if mScanner.SearchPattern <> substring then
		      if mScanner.SearchPattern <> "" then break // should get set only once!
		      mScanner.SearchPattern = substring
		    end if
		    match=mScanner.Search(subExpression)
		    
		    while match<>nil
		      substring=match.SubExpressionString(0)
		      
		      // determine which token was matched
		      dim tknIndex as integer
		      for i as integer = 1 to match.SubExpressionCount - 1
		        if match.SubExpressionString(i) = substring then
		          tknIndex = subExpressionIndex.IndexOf(i)
		          exit
		        end
		      next
		      
		      if tknIndex < 0 then //definition can't handle source!
		        exit while
		      end if
		      
		      #if DebugBuild
		        dim start as Integer = match.SubExpressionStartB(0)
		        dim wtf as String = subExpression.leftb(start)
		        #pragma unused wtf
		      #endif
		      charPos = subExpression.leftb(match.SubExpressionStartB(0)).len
		      charPosB = match.SubExpressionStartB(0)
		      
		      if charPos - startPos > 0 then _
		      tokens.Append(new TextSegment(startPos + position, charPos - startPos, TextSegment.TYPE_WORD, HighlightColor, BackgroundColor, bold, italic, underline))
		      
		      startPos = charPos
		      startPosB = charPosB
		      
		      entry = subContexts(tknIndex) 'findSubContextForMatch(substring, subExpression, start)
		      
		      //forward execution to subcontext...
		      if entry<>nil and not entry.isPlaceholder then
		        call entry.Highlight(subExpression, substring, position + startPos, positionB + startPosB, mScanner, tokens, placeholders)
		        #if DebugBuild
		          dim asub as String = subExpression.leftb(mScanner.SearchStartPosition)
		          #pragma unused asub
		        #endif
		        startPos = subExpression.leftb(mScanner.SearchStartPosition).len
		        startPosB = mScanner.SearchStartPosition
		        
		      elseIf entry <> nil and entry.isPlaceholder then
		        dim label as String = match.SubExpressionString(match.SubExpressionCount - 1)
		        dim tmp as Integer = text.leftb(match.SubExpressionStartB(match.SubExpressionCount - 1)).len
		        
		        dim placeholder as new TextPlaceholder(startPos + position, substring.Len, tmp + position, label.len, entry.HighlightColor, entry.BackgroundColor, entry.Bold, entry.Italic, entry.Underline)
		        tokens.Append(placeholder)
		        placeholders.Append(placeholder)
		        
		        startPos = subExpression.leftb(mScanner.SearchStartPosition).len
		        startPosB = mScanner.SearchStartPosition
		      end if
		      match=mScanner.Search
		    wend
		    
		    if subExpression.len - startPos > 0 then _
		    tokens.Append(new TextSegment(startPos + position, subExpression.len - startPos, TextSegment.TYPE_WORD, HighlightColor, BackgroundColor, bold, italic, underline))
		  end if
		  
		  Return scanNextLine
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub IndentNode(node As XmlNode, level As Integer, indentCloseTag As Boolean = False)
		  Dim i As Integer
		  Dim s As String
		  s = EndOfLine
		  For i = 1 To level
		    s = s + Chr(9) // Tab
		  Next
		  node.Parent.Insert(node.OwnerDocument.CreateTextNode(s), node)
		  If indentCloseTag Then
		    node.AppendChild(node.OwnerDocument.CreateTextNode(s))
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ListKeywords(storage() as string)
		  //add mine..
		  dim keyword as String
		  for each keyword in keywords
		    storage.Append(keyword)
		  next
		  
		  //then subs...
		  for i as Integer = 0 to UBound(subContexts)
		    subContexts(i).ListKeywords(storage)
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadFromXmlNode(node as xmlNode)
		  //load context out of an xml node
		  dim tmpObj as Variant
		  dim tmp as String
		  
		  //Highlight color
		  Name = node.GetAttribute("name")
		  
		  tmpObj = "&h" + node.GetAttribute("highlightColor").Mid(1)
		  HighlightColor = tmpObj.ColorValue
		  
		  //background color
		  tmp = node.GetAttribute("backgroundColor")
		  if tmp <> "" then
		    tmpObj = "&h" + tmp
		    BackgroundColor = tmpObj.ColorValue
		  end if
		  
		  //Bold
		  tmp = node.GetAttribute("bold")
		  if tmp <> "" then Bold = tmp = "true"
		  
		  //Italic
		  tmp = node.GetAttribute("italic")
		  if tmp <> "" then Italic = tmp = "true"
		  
		  //Underline
		  tmp = node.GetAttribute("underline")
		  if tmp <> "" then Underline = tmp = "true"
		  
		  //Enabled
		  tmp = node.GetAttribute("enabled")
		  Enabled = tmp <> "false"
		  
		  dim i, j as Integer
		  dim subNode as XmlNode
		  dim subContext as HighlightContext
		  
		  for i=0 to node.ChildCount-1
		    subNode=node.Child(i)
		    select case subNode.Name
		    case "startRegEx"
		      StartRegEx=subNode.FirstChild.Value
		    case "endRegEx"
		      EndRegEx=subNode.FirstChild.Value
		    case "entryRegEx"
		      EntryRegEx=subNode.FirstChild.Value
		    case "keywords"
		      for j=0 to subNode.ChildCount-1
		        if not subNode.Child(j) isa XmlComment then _ //add only if it's not a comment
		        addKeyword(subNode.Child(j).FirstChild.Value)
		      next
		    case "regExes"
		      for j=0 to subNode.ChildCount-1
		        if not subNode.Child(j) isa XmlComment then _
		        addRegEx(subNode.Child(j).FirstChild.Value)
		      next
		    case "highlightContext"
		      subContext=new HighlightContext(mScanner.Options.CaseSensitive)
		      subContext.loadFromXmlNode(subNode)
		      addSubContext(subContext)
		    end select
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function subContextPattern() As String
		  // this seems never to get called
		  
		  if _subContextPattern = "" then
		    
		    //get the regex for the subContexts
		    if UBound(subContexts)>= 0 then
		      dim s as String = "("
		      for each current as HighlightContext in subContexts
		        s = s + current.ContextSearchPattern+"|"
		      next
		      s = Left(s,s.Len-1)+")"
		      _subContextPattern = s
		    end if
		    
		  end if
		  
		  Return _subContextPattern
		End Function
	#tag EndMethod


	#tag Note, Name = About
		Info
		
		HighlightContext
		By Alex Restrepo
		send comments, suggestions, fixes to alexrestrepo@mac.com
		
		A little experiment on SyntaxHighlighting
		Contains the rules of how to Highlight a Context within a HighlightDefinition
		A context is composed of ONE of the following:
		- a start and end regexes, everything inside the start and end regexes is part of the context, this is a full match regex (subexpression 0)
		- an EntryRegEx, specifies the regular expression to match the whole context (ie: an html tag), the first subexpression of the expression is used (subexpression 1)
		- keywords, one or more keywords that need to be Highlighted, you can have multiple keyword contexts with different highlight colors. (array of strings)
		- regexes, one or more regular expressions that define variations of the same context (ie: in java #include or #package), subexpression 1 is used for each entry.
		
		Methods:
		addKeyword(keyword as String): adds the keyword to the keywords array
		addRegEx(newRegEx as String): adds the newRegEx to the regexes array
		addSubContext(context as HighlightContext): adds the context as a subcontext of this one, for example: properties within xml tags
		appendToXMLNode(parent as xmlNode, depth as integer = 2): appends this context to the parent xml node as an xml node, this is done when exporting the parent definition as an xml.
		Constructor(caseSensitive as Boolean): the constructor sets the case sensitiviness of the context.
		contextRegEx as string: returns the composed regular expression with all the contents of the context, if the context has StartRegEx and EndRegEx, the contextRegEx is the StartRegEx
		Highlight(text as string, style as styledText, subExpression as string, position as integer, scanner as regex): Highlights the subexpression, text is the text of the parent context, position is the position of the first character of the subexpression in the context.
		loadFromXmlNode(node as XmlNode): loads the context from the xmlNode.
		
		Properties:
		StartRegEx: the regular expression that defines the start of the context (ie: in java, /* for multiline comments)
		EndRegEx: the regular expression that marks the end of the context (ie: */)
		EntryRegEx: the regular expression that defines the context, ie: an xml tag: (<[^>]*>)
		HighlightColor: the HighlightColor for the context
		Name: the name of the Context, ie: "Tags"
		
		
		Open source under the creative commons license.
		Use in whatever way you like... at your own risk :P
		let me know if you find it useful.
		If you decide to use it in your projects, please give me credit in your about window or documentation, thanks.
	#tag EndNote


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mBackgroundcolor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mBackgroundcolor = value
			  
			  //this is to make whitespaces the same color as the "parent" context
			  //whitespace should always be subcontext(0)... if it's available at all.
			  if UBound(subContexts) > -1 and subContexts(0).Name = "fieldwhitespace" then
			    subContexts(0).BackgroundColor = value
			  end if
			  
			  mHasBackgroundColor = value <> &c0
			End Set
		#tag EndSetter
		BackgroundColor As color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mBold
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mBold = value
			End Set
		#tag EndSetter
		Bold As boolean
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

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  if mEndRegex <> nil then
			    Return mEndRegex.SearchPattern
			  end if
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  if value = "" then
			    mEndRegex = nil
			  else
			    mEndRegex = new RegEx
			    mEndRegex.Options.DotMatchAll = true
			    mEndRegex.SearchPattern = value
			  end if
			End Set
		#tag EndSetter
		EndRegEx As string
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mEntryRegex
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mEntryRegex = value
			End Set
		#tag EndSetter
		EntryRegEx As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mHasbackgroundcolor
			End Get
		#tag EndGetter
		HasBackgroundColor As boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mForeColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mForeColor = value
			End Set
		#tag EndSetter
		HighlightColor As color
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		isPlaceholder As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mItalic
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mItalic = value
			End Set
		#tag EndSetter
		Italic As boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private keywords() As string
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBackgroundcolor As color
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBold As boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mEnabled As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mEndRegex As RegEx
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mEntryRegex As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mForeColor As color = &c000000
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHasbackgroundcolor As boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mItalic As boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPlaceholderContextDef As HighlightContext
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mScanner As regex
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSearchPattern As string
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStartRegex As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mUnderline As boolean
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

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mPlaceholderContextDef
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  if mPlaceholderContextDef <> nil then Return //if already set, bail out...
			  
			  mPlaceholderContextDef = value
			  self.addSubContext(value)
			  
			  for each subcontext as HighlightContext in subContexts
			    if subContext <> value then subContext.placeholderContextDef = value
			  next
			End Set
		#tag EndSetter
		PlaceholderContextDef As HighlightContext
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private regexes() As string
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mStartRegex
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mStartRegex = value
			End Set
		#tag EndSetter
		StartRegEx As string
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private subContexts() As HighlightContext
	#tag EndProperty

	#tag Property, Flags = &h21
		Private subExpressionCount As integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private subExpressionIndex() As integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mUnderline
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mUnderline = value
			End Set
		#tag EndSetter
		Underline As boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private _contextPattern As string
	#tag EndProperty

	#tag Property, Flags = &h21
		Private _name As string
	#tag EndProperty

	#tag Property, Flags = &h21
		Private _subContextPattern As String
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="BackgroundColor"
			Group="Behavior"
			InitialValue="&h000000"
			Type="color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Bold"
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
			Name="EndRegEx"
			Group="Behavior"
			Type="string"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="entryRegEx"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasBackgroundColor"
			Group="Behavior"
			InitialValue="0"
			Type="boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HighlightColor"
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
			Name="isPlaceholder"
			Group="Behavior"
			InitialValue="0"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Italic"
			Group="Behavior"
			InitialValue="0"
			Type="boolean"
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
			Name="StartRegEx"
			Group="Behavior"
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
		#tag ViewProperty
			Name="Underline"
			Group="Behavior"
			InitialValue="0"
			Type="boolean"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
