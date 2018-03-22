#tag Class
Class LineManager
	#tag Method, Flags = &h1
		Protected Sub appendLine(segment as textline)
		  //append a line to the line array
		  lines.Append segment
		  
		  //mark it as changed
		  'NotifyLineChangedRange(lines.Ubound, 1)
		  
		  //see if this one is longer than the previous longest
		  if segment.length > longestLineLength then
		    longestLineIndex = UBound(lines)
		    longestLineLength =  segment.length
		    //and forward it to the delegate
		    NotifyMaxLineLengthChanged(longestLineIndex)
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function calcInvisibleLines() As integer
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  //clear the calculation caches
		  if neededCache <> nil then neededCache.Clear
		  if visibleCache <> nil then visibleCache.Clear
		  
		  //returns what is the logical pos of the given lineNumber
		  dim invisibleLines as Integer
		  
		  for i as Integer = 0 to Count - 1
		    if not lines(i).visible then invisibleLines = invisibleLines + 1
		  next
		  
		  Return invisibleLines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub clear()
		  //clear lines and vars
		  RemoveLineSymbols(0, Count - 1)
		  ReDim lines(-1)
		  longestLineIndex = -1
		  longestLineLength = 0
		  lineEnding = chr(13)
		  currentInvisibleLines = -1
		  mFirstLineForIndentation = 0
		  mLastLineForIndentation = -1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub clearDirtyLines()
		  dim line as TextLine
		  for each line in lines
		    line.isDirty = False
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(TextStorage as gapBuffer, TabWidth as integer)
		  //create generic eol segment
		  self.TextStorage = TextStorage
		  
		  //no need to find the longest line yet
		  needsLongestRescan = False
		  
		  //default the line endings to chr(13)
		  lineEnding = chr(13)
		  
		  self.TabWidth = TabWidth
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function createLines(lineInsertPoint as integer, offset as integer, length as integer, indent as Integer, lineContIdx as Integer, markDirty as Boolean = false) As integer
		  // This function creates TextLine objects from the textbuffer
		  
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  dim text as String = TextStorage.getText(offset, length)
		  dim insertedLines as integer
		  dim startSearchIndex as integer
		  dim ariLineLen() as integer
		  dim ariLineDelimeter() as integer
		  
		  FindLineLengths( text, ariLineLen, ariLineDelimeter )
		  
		  dim lastDirtyLine as TextLine, wasLastDirtyBefore as Boolean
		  
		  for i as integer = 0 to ariLineLen.Ubound - 1
		    dim segment as TextLine
		    segment = new TextLine(offset+startSearchIndex, ariLineLen(i), ariLineDelimeter(i), TabWidth, indent, lineContIdx)
		    startSearchIndex = startSearchIndex + ariLineLen(i)
		    
		    if markDirty then
		      lastDirtyLine = segment
		      wasLastDirtyBefore = lastDirtyLine.isDirty
		      lastDirtyLine.isDirty = true
		    end if
		    
		    //append/insert?
		    if lineInsertPoint + insertedLines > UBound(lines) then
		      AppendLine(segment)
		    else
		      insertLine(lineInsertPoint + insertedLines, segment)
		    end if
		    
		    insertedLines = insertedLines + 1
		  next
		  
		  //trailing text
		  if startSearchIndex <= text.len then
		    if lineInsertPoint + insertedLines > UBound(lines) then
		      dim line as TextLine = new TextLine(offset + startSearchIndex, text.len - startSearchIndex, 0, TabWidth, indent, lineContIdx)
		      if markDirty then
		        lastDirtyLine = line
		        wasLastDirtyBefore = lastDirtyLine.isDirty
		        lastDirtyLine.isDirty = true
		      end if
		      appendLine(line)
		      insertedLines = insertedLines + 1
		    end if
		  end if
		  
		  if lastDirtyLine <> nil then
		    // This deals with a special case: If we're called by CustomEditField.private_replace(), the first line gets deleted and then added here
		    // again. But if the insertion was a new line with a CR at the end, then this deleted/added line is only shifted down, but not actually
		    // changed. This code tries to deal with that by not marking it dirty.
		    lastDirtyLine.isDirty = wasLastDirtyBefore
		  end
		  
		  NotifyLineChangedRange(lineInsertPoint, insertedLines)
		  
		  Return insertedLines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub FindLineLengths(sText as string, ariLineLen() as integer, ariDelimeterLen() as integer)
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  dim prevLineEnding as String = lineEnding
		  lineEnding = "" // will be set below, by the first line delimiter that's encountered
		  
		  if sText <> "" then
		    
		    if sText.Encoding <> EditFieldGlobals.InternalEncoding then
		      // should not happen
		      break
		      sText = sText.ConvertEncoding(EditFieldGlobals.InternalEncoding)
		    end
		    
		    dim sTextCanonical as string = ReplaceLineEndings( sText, EndOfLine.UNIX )
		    dim ars() as string = Split( sTextCanonical, EndOfLine.UNIX )
		    dim iOffsetB as integer = 0
		    
		    dim currentEncoding as TextEncoding = sText.Encoding
		    if currentEncoding = nil then currentEncoding = Encodings.ASCII
		    
		    //get the byte length for an EOL char... it could be > 1, e.g. in UTF-16
		    dim EOLlen as Integer = currentEncoding.Chr(13).LenB
		    
		    for each sLine as string in ars
		      dim iLineLen as integer = sLine.Len
		      iOffsetB = iOffsetB + sLine.LenB
		      
		      dim c as integer = sText.MidB( iOffsetB + 1, EOLlen ).Asc
		      
		      if c = 13 then
		        iOffsetB = iOffsetB + EOLlen //move the offset by the already found marker
		        
		        if sText.MidB( iOffsetB + 1, EOLlen ).Asc = 10 then //windows
		          iLineLen = iLineLen + 2
		          iOffsetB = iOffsetB + EOLlen
		          ariDelimeterLen.Append( 2 )
		          if lineEnding = "" then lineEnding = Chr(13)+Chr(10)
		          
		        else //mac
		          iLineLen = iLineLen + 1
		          ariDelimeterLen.Append( 1 )
		          if lineEnding = "" then lineEnding = Chr(13)
		          
		        end if
		        
		      elseif c = 10 then //unix
		        iLineLen = iLineLen + 1
		        iOffsetB = iOffsetB + EOLlen
		        ariDelimeterLen.Append( 1 )
		        if lineEnding = "" then lineEnding = Chr(10)
		        
		      elseif c = 0 then
		        // end of text
		        ariDelimeterLen.Append( 0 )
		        ariLineLen.Append( iLineLen )
		        Exit
		        
		      else
		        Continue
		      end if
		      
		      ariLineLen.Append( iLineLen )
		    next
		    
		  end if
		  
		  if lineEnding = "" then
		    // if text had no line delimiters we'll use the OS default
		    lineEnding = prevLineEnding
		    if lineEnding = "" then
		      #if TargetWin32
		        lineEnding = EndOfLine.Windows
		      #else
		        // Mac nowadays uses Unix, not the old Chr(13), so does Linux
		        lineEnding = EndOfLine.Unix
		      #endif
		    end if
		  end if
		  
		  lineEnding = lineEnding.ConvertEncoding(EditFieldGlobals.InternalEncoding)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function findLineNumberForOffset(offset as integer) As integer
		  //binary search for the line that contains offset.
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  if Count = 0 then Return -1
		  
		  dim leftIndex as Integer
		  dim rightIndex as Integer = Count - 1
		  
		  dim currLine as TextLine
		  
		  while leftIndex < rightIndex
		    dim pivot as Integer = (leftIndex + rightIndex) / 2
		    
		    currLine = lines(pivot)
		    if offset < currLine.offset then
		      rightIndex = pivot - 1
		    elseif offset > currLine.offset then
		      leftIndex = pivot + 1
		    else
		      leftIndex = pivot
		      exit while
		    end if
		  wend
		  
		  if lines(leftIndex).offset > offset then Return leftIndex - 1
		  Return leftIndex
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub fixOffsets(lineNumber as integer, startOffset as integer)
		  //fix all the offsets starting at the given line number, with the given offset
		  
		  #pragma DisableBackgroundTasks
		  
		  dim maxIndex as Integer = UBound(lines)
		  dim line as TextLine
		  
		  for i as Integer = lineNumber to maxIndex
		    line = lines(i)
		    line.offset = startOffset //set offset
		    startOffset = line.offset + line.length //add line length
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub foldAll()
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  for i as Integer = 0 to UBound(lines)
		    if lines(i).isBlockStart and not lines(i).folded then
		      call toggleLineFolding(i)
		    end if
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getAttributesOfLinesInRange(offset as Integer, length as Integer) As TextLineAttributes()
		  dim attrs() as TextLineAttributes
		  for each line as TextLine in linesInRange (offset, length)
		    attrs.Append line.getAttributes
		  next
		  return attrs
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getLine(index as integer) As TextLine
		  //get a given line
		  if index < 0 or index >= Count then Return nil
		  
		  Return lines(index)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getLineNumberForOffset(offset as integer, length as integer = 0) As integer
		  //trivial case
		  if offset = 0 then Return 0
		  
		  if offset = textLength + length then
		    //empty?
		    if Count = 0 then Return 0
		    
		    //last line?
		    dim last as TextLine = lines(UBound(lines))
		    if last.delimiterLength > 0 then Return Count
		    Return Count - 1
		  end if
		  
		  //general case
		  Return findLineNumberForOffset(offset)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getLongestLine() As textline
		  if longestLineIndex < 0 then Return nil
		  Return lines(longestLineIndex)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function getNumberOfAffectedLines(startLine as integer, offset as integer, length as integer) As integer
		  if length = 0 then Return 1 //same line
		  
		  dim target as Integer = offset + length
		  
		  dim line as TextLine = lines(startLine)
		  if line.delimiterLength = 0 then
		    //last line
		    Return 1
		  end if
		  
		  if line.offset + line.length > Target then
		    Return 1 //within line
		  end if
		  
		  if line.offset + line.length = Target then
		    Return 2 //this and next
		  end if
		  
		  //general case
		  Return getLineNumberForOffset(Target) - startLine + 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getNumberOfLinesNeededToView(linesNeeded as integer) As integer
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  if invisibleLines = 0 then Return linesNeeded
		  if neededCache = nil then neededCache = new Dictionary
		  
		  //check cache
		  if neededCache.HasKey(linesNeeded) then Return neededCache.Value(linesNeeded)
		  
		  //returns the number of lines needed to display "lineNumber" visible lines.
		  dim visibleLines as Integer
		  
		  for i as Integer = 0 to Count - 1
		    if lines(i).visible then visibleLines = visibleLines + 1
		    
		    if visibleLines > linesNeeded then
		      neededCache.Value(linesNeeded) = i
		      Return i
		    end if
		  next
		  
		  neededCache.Value(linesNeeded) = Count - 1
		  Return Count - 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getNumberOfVisibleLinesUpToLine(lineNumber as integer) As integer
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  if invisibleLines = 0 then Return lineNumber
		  if visibleCache = nil then visibleCache = new Dictionary
		  
		  //check cache
		  if visibleCache.HasKey(lineNumber) then Return visibleCache.Value(lineNumber)
		  
		  //returns the number of visible lines up to "lineNumber"
		  dim invisibleLines as Integer
		  
		  for i as Integer = 0 to lineNumber
		    if not lines(i).visible then invisibleLines = invisibleLines + 1
		    
		    'if i >= lineNumber then Return i - invisibleLines
		  next
		  'Return Count - invisibleLines
		  visibleCache.Value(lineNumber) = lineNumber - invisibleLines
		  return lineNumber - invisibleLines
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IndentationFinished()
		  mFirstLineForIndentation = lines.Ubound+1
		  mLastLineForIndentation = -1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub insert(offset as integer, text as string, alwaysMarkDirty as Boolean)
		  replace(offset, 0, text, alwaysMarkDirty)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub insertLine(index as integer, segment as textline)
		  //insert into line array
		  lines.Insert(index, segment)
		  
		  //mark it
		  'NotifyLineChangedRange(index, 1)
		  
		  //see if new line is longer than previous longest
		  if segment.length > longestLineLength then
		    longestLineIndex = index
		    longestLineLength =  segment.length
		    NotifyMaxLineLengthChanged(longestLineIndex)
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LineIsIndented(lineIdx as Integer)
		  if lineIdx = mFirstLineForIndentation then
		    mFirstLineForIndentation = lineIdx + 1
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LineNeedsIndentation(lineIdx as Integer)
		  dim line as TextLine = getLine(lineIdx)
		  if line <> nil then
		    if lineIdx < mFirstLineForIndentation then
		      mFirstLineForIndentation = lineIdx
		    end if
		    if lineIdx > mLastLineForIndentation then
		      mLastLineForIndentation = lineIdx
		    end if
		    #if DebugBuild and EditFieldGlobals.DebugIndentation
		      System.DebugLog "InvalidateLine "+str(lineIdx)+", now: "+Str(mFirstLineForIndentation)+" to "+Str(mLastLineForIndentation)
		    #endif
		    line.NeedsIndentation = true
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function linesInRange(offset as Integer, length as Integer) As TextLine()
		  dim result() as TextLine
		  
		  dim idx as Integer = getLineNumberForOffset(offset, length)
		  if idx >= 0 and idx <= lines.Ubound then
		    dim line as TextLine = lines(idx)
		    length = length + (offset - line.Offset) // so that we cover the range from the start of the line
		    while length >= 0
		      result.Append line
		      length = length - line.Length
		      idx = idx + 1
		      if idx > lines.Ubound then
		        exit while
		      end if
		      line = lines(idx)
		    wend
		  end if
		  
		  return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LongestLineIdx() As Integer
		  Return longestLineIndex
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MarkAllLinesAsChanged()
		  NotifyLineChangedRange(0, self.Count)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function nextBlockEndLine(forLine as integer, ignoreIfLineIsBlockStart as boolean = false) As integer
		  //Finds the next block end from this line,
		  //It accounts for nested blocks.
		  
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		  #endif
		  
		  dim testLine as TextLine
		  testLine = getLine (forLine)
		  if testLine = nil then Return -1
		  if not ignoreIfLineIsBlockStart and not testLine.isBlockStart then
		    Return -1
		  end if
		  
		  dim forRule as Object = testLine.BlockStartRule
		  
		  dim depth as integer
		  dim idx, match, lastLine as Integer
		  
		  //search down
		  lastLine = UBound(lines)
		  match = -1
		  for idx = forLine + 1 to lastLine
		    testLine = getLine(idx)
		    if testLine = nil then Continue for
		    
		    dim isBlkEnd as Boolean = testLine.isBlockEnd (forRule)
		    if depth = 0 and isBlkEnd then
		      //found it
		      match = idx
		      exit for
		    else
		      //nested
		      dim isBlkStart as Boolean = testLine.isBlockStart (forRule)
		      if isBlkStart and not isBlkEnd then
		        depth = depth + 1
		      elseif isBlkEnd and not isBlkStart then //nested out
		        depth = depth - 1
		      end if
		    end if
		  next
		  
		  Return match
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function nextVisibleLine(fromLine as integer) As integer
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  if invisibleLines = 0 then Return fromLine
		  
		  for i as Integer = fromLine to Count - 1
		    if lines(i).visible then Return i
		  next
		  Return previousVisibleLine(fromLine)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub NotifyLineChangedRange(startIndex as integer, length as Integer)
		  if length <= 0 then return
		  
		  #if DebugBuild
		    'System.DebugLog "NotifyLineChangedRange("+Str(startIndex,"-#")+", "+Str(length,"-#")+")"
		  #endif
		  
		  dim msg as new Message(self, self)
		  msg.addInfo(1, LineChangedMsg)
		  msg.addInfo(2, startIndex)
		  msg.addInfo(3, length)
		  
		  MessageCenter.sendMessage(msg)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub NotifyLineCountChanged()
		  //notify changes
		  dim msg as new Message(self, self)
		  msg.addInfo(1, LineCountChangedMsg)
		  msg.addInfo(2, count)
		  MessageCenter.sendMessage(msg)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub NotifyMaxLineLengthChanged(longestLineIndex as integer)
		  //notify changes
		  dim msg as new Message(self, self)
		  msg.addInfo(1, MaxLineLengthChangedMsg)
		  msg.addInfo(2, longestLineIndex)
		  MessageCenter.sendMessage(msg)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function previousBlockStartLine(forLine as integer, ignoreIfLineIsBlockEnd as boolean = false) As integer
		  //Finds the previous block start from this line,
		  //It accounts for nested blocks.
		  
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		  #endif
		  
		  dim testLine as TextLine
		  testLine = getLine (forLine)
		  if testLine = nil then Return - 1
		  if not ignoreIfLineIsBlockEnd and not testLine.isBlockEnd then
		    Return -1
		  end if
		  
		  dim forRule as Object = testLine.BlockEndRule
		  
		  dim depth as integer
		  dim idx, match as Integer
		  
		  match = -1
		  for idx = forLine - 1 DownTo 0
		    testLine = getLine(idx)
		    if testLine = nil then Continue for
		    
		    dim isBlkStart as Boolean = testLine.isBlockStart (forRule)
		    if depth = 0 and isBlkStart then
		      //found it
		      match = idx
		      exit for
		    else
		      //nested
		      dim isBlkEnd as Boolean = testLine.isBlockEnd (forRule)
		      if isBlkEnd and not isBlkStart then
		        depth = depth + 1
		      elseif isBlkStart and not isBlkEnd then //out of inner block
		        depth = depth - 1
		      end if
		    end if
		  next
		  
		  Return match
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function previousVisibleLine(fromLine as integer) As integer
		  //finds a the previous visible line from a given line.
		  
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  if invisibleLines = 0 then Return fromLine
		  
		  for i as Integer = fromLine downto 0
		    if lines(i).visible then Return i
		  next
		  Return -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub remove(offset as integer, length as integer)
		  replace(offset, length, "", true)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub removeLine(index as integer)
		  RemoveLineSymbols(index, index)
		  lines.Remove(index)
		  //if removed line was the longest... we need to rescan
		  if index = longestLineIndex then needsLongestRescan = true
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub RemoveLineSlice(arr() As textline, fromIndex As Integer = 0, toIndex As Integer = 0)
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  // Deletes a portion of the array.
		  // See "Slice Indexing" note.
		  // taken from Joe Strout's open source Array Utilities
		  // http://www.verex.com/opensource/
		  
		  Dim ub As Integer = UBound( arr )
		  if fromIndex < 0 then fromIndex = ub + 1 + fromIndex
		  if toIndex <= 0 then toIndex = ub + 1 + toIndex
		  
		  if fromIndex >= toIndex then return  // empty (or invalid) range
		  RemoveLineSymbols(fromIndex, toIndex - 1) //used to be toIndex
		  if longestLineIndex >= fromIndex and longestLineIndex <= toIndex then needsLongestRescan = true
		  
		  // easy case: deleting the end of the array, we can just redim and be done
		  if toIndex - 1 = ub then
		    Redim arr( fromIndex - 1 )
		    return
		  end if
		  
		  // another easy case: deleting just one element (equivalent to Array.Remove)
		  if fromIndex = toIndex - 1 then
		    arr.Remove fromIndex
		    return
		  end if
		  
		  // harder case: copy the data down, and THEN redim
		  Dim dest, src As Integer
		  dest = fromIndex
		  for src = toIndex to ub
		    arr(dest) = arr(src)
		    dest = dest + 1
		  next
		  Redim arr( dest - 1 )
		  return
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub RemoveLineSymbols(fromIndex as integer, toIndex as integer)
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  //look for symbols in the lines that are being removed. if found, signal the editfield to remove such symbols from its symbol table.
		  dim tmp as new Dictionary
		  
		  dim line as TextLine
		  for i as integer = fromIndex to toIndex
		    line = getLine(i)
		    if line = nil or line.LineSymbols = nil or line.LineSymbols.Count = 0 then Continue for
		    
		    'for each key in line.LineSymbols.Keys
		    tmp.Value(line) = nil
		    'next
		  next
		  
		  if tmp.Count = 0 then Return
		  
		  dim msg as new Message(self, self)
		  msg.addInfo(1, LineSymbolsRemovedMsg)
		  msg.addInfo(2, tmp)
		  
		  if toIndex - fromIndex <= 2 then
		    MessageCenter.sendMessage(msg)
		  else
		    MessageCenter.queueMessage(msg)
		  end if
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub replace(offset as integer, length as integer, text as string, alwaysMarkDirty as Boolean)
		  // Replaces a chunk of text with "text" and length "length" at pos offset
		  //
		  // This method doesn't actually store the text (that's handled by TextStorage.replace),
		  // but only needs to read its length.
		  
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  dim lineNumber as Integer = getLineNumberForOffset(offset, length)
		  
		  if alwaysMarkDirty then
		    // mark line for needing indendation
		    LineNeedsIndentation lineNumber
		  end if
		  
		  //save original index as it may change
		  dim originalLine as Integer = lineNumber
		  
		  //old highlight context, in case the modified line has one
		  dim oldContext as HighlightContext
		  
		  dim lineCount as Integer = self.Count
		  
		  dim line as TextLine
		  if lineNumber <= lines.Ubound then
		    line = lines(lineNumber)
		  end if
		  
		  if length > 0 and line <> nil then //merge affected lines...
		    dim numberOfAffectedLines as Integer = getNumberOfAffectedLines(lineNumber, offset, length)
		    dim endLine as TextLine = lines(lineNumber + numberOfAffectedLines - 1)
		    
		    if numberOfAffectedLines > 1 and invisibleLines > 0 then
		      currentInvisibleLines = -1
		    end if
		    
		    //save highlight context of last line
		    oldContext = endLine.Context
		    
		    line.length = endLine.offset + endLine.length - line.offset
		    line.delimiterLength = endLine.delimiterLength
		    removeLineSlice(lines, lineNumber + 1, lineNumber + numberOfAffectedLines)
		    line.InvalidateWords
		  end if
		  
		  if line = nil then
		    // ignore
		  elseif length = 0 and text.len = 1 and text <> lineEnding then //simple keystroke
		    RemoveLineSymbols(lineNumber, lineNumber)
		    line.length = line.length + 1 //make line longer by one char
		    fixOffsets(lineNumber + 1, line.offset + line.length) //fix the offsets
		    line.InvalidateWords
		    
		    //mark it
		    NotifyLineChangedRange(lineNumber, 1)
		    
		    //see if it's now the longestLine
		    if line.length > longestLineLength then
		      longestLineIndex = lineNumber
		      longestLineLength =  line.length
		      NotifyMaxLineLengthChanged(longestLineIndex)
		    end if
		    
		  elseif length = 1 and Text.len = 0 then //simple delete
		    RemoveLineSymbols(lineNumber, lineNumber)
		    line.length = line.length - 1 //make smaller by one char
		    fixOffsets(lineNumber + 1, line.offset + line.length) //fix offsets
		    line.InvalidateWords
		    
		    //mark it
		    NotifyLineChangedRange(lineNumber, 1)
		    
		    //if this was the longest line, do a rescan
		    if lineNumber = longestLineIndex then needsLongestRescan = true
		    
		  else //every other case... long text, enters...
		    'first, unfold line if folded, and we're adding to the end of the line...
		    if line.folded and offset = line.offset + line.length - line.delimiterLength then
		      call toggleLineFolding(originalLine)
		    end if
		    
		    //Line now contains a merged line composing all affected lines.
		    dim delta as Integer = line.length - length + text.len
		    
		    //remove merged line, and start parsing/inserting.
		    removeLine(lineNumber)
		    dim insertedLines as Integer = createLines(lineNumber, line.offset, delta, line.indent, line.isContinuedFromLine, alwaysMarkDirty)
		    lines(lineNumber).AdoptLine line
		    lineNumber = lineNumber + insertedLines
		    
		    //fix offsets starting from the last modified line.
		    line = lines(max(lineNumber - 1,0))
		    if delta <> 0 then fixOffsets(lineNumber, line.offset + line.length)
		    
		    //reset context if any.
		    if oldContext <> nil then
		      lines(originalLine).Context = oldContext
		      NotifyLineChangedRange(originalLine, 1)
		    end
		    
		  end if
		  
		  //rescan lengths if necessary
		  if needsLongestRescan then rescanLengths
		  
		  //fire LineChangedDelegate if any
		  if lineCount <> count then
		    NotifyLineCountChanged
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub rescanLengths()
		  //find the longest line.
		  longestLineIndex = -1
		  longestLineLength = -1
		  
		  #pragma DisableBackgroundTasks
		  
		  dim line as TextLine
		  dim idx as Integer
		  
		  for Each line in lines
		    if line.length > longestLineLength then
		      longestLineLength = line.length
		      longestLineIndex = idx
		    end if
		    idx = idx + 1
		  next
		  
		  needsLongestRescan = False
		  if longestLineIndex < 0 then Return
		  NotifyMaxLineLengthChanged(longestLineIndex)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub revealLine(lineNumber as integer)
		  //expand all invisible lines starting at linenumber, up
		  dim current as TextLine
		  for i as Integer = lineNumber DownTo 0
		    current = lines(i)
		    if current.folded then call toggleLineFolding(i)
		    if current.visible then Return
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub setAttributesOfLinesInRange(offset as Integer, length as Integer, attrs() as TextLineAttributes)
		  dim lineCount as Integer
		  for each line as TextLine in linesInRange (offset, length)
		    line.setAttributes attrs(lineCount)
		    lineCount = lineCount + 1
		  next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub setText(length as Integer)
		  Clear
		  call createLines(0, 0, length, 0, -1)
		  NotifyLineCountChanged
		  NotifyMaxLineLengthChanged(longestLineIndex)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function toggleLineFolding(lineNumber as integer) As integer
		  dim line as TextLine = getLine(lineNumber)
		  if line = nil then Return -1
		  
		  //check if line is a block end/start
		  if not line.isBlockStart and not line.isBlockEnd then
		    Return -1
		  end if
		  
		  //now, find the range...
		  dim testLine as TextLine
		  dim idx, match as Integer
		  dim forRule as Object
		  
		  match = -1
		  if line.isBlockStart then
		    //search down
		    match = nextBlockEndLine(lineNumber)
		    
		    if match < 0 then
		      Return -1
		    end if
		    
		    forRule = line.BlockStartRule
		    
		  else
		    //search up
		    match = previousBlockStartLine(lineNumber)
		    
		    if match < 0 then
		      Return -1
		    end if
		    
		    forRule = line.BlockEndRule
		    
		    //toggle lines' visibility
		    line = getLine(match)
		    dim tmp as Integer
		    tmp = match
		    match = lineNumber
		    lineNumber = tmp
		  end if
		  
		  line.folded = not line.folded
		  dim targetState as Boolean = not line.folded
		  
		  dim lineStack() as Boolean
		  lineStack.Append not line.folded
		  
		  for idx = lineNumber + 1 to match
		    testLine = lines(idx)
		    if targetState = false then //we're making everything invisible, we don't care
		      testLine.visible = false
		    else
		      //we have to check for parentStates!
		      testLine.visible = lineStack(UBound(lineStack))
		      
		      dim isBlkStart as Boolean = testLine.isBlockStart (forRule)
		      dim isBlkEnd as Boolean = testLine.isBlockEnd (forRule)
		      
		      if isBlkStart and not isBlkEnd then
		        lineStack.Append(not testLine.folded and lineStack(UBound(lineStack)))
		        
		      ElseIf isBlkEnd and not isBlkStart then
		        call lineStack.Pop
		        
		      End if
		    end if
		  next
		  
		  //force recalculation of invisibleLines
		  currentInvisibleLines = -1
		  NotifyLineCountChanged
		  Return lineNumber
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub unfoldAll()
		  #if not DebugBuild
		    #pragma DisableBackgroundTasks
		    #pragma DisableBoundsChecking
		    
		  #endif
		  
		  //expand all foldings
		  dim lines as Integer = Count - invisibleLines
		  
		  //make everything visible
		  for i as Integer = 0 to Count - 1
		    if lines(i).folded then lines(i).folded = False
		    lines(i).visible = true
		  next
		  currentInvisibleLines = -1
		  
		  if lines <> Count - invisibleLines then NotifyLineCountChanged
		End Sub
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return UBound(lines) + 1
			End Get
		#tag EndGetter
		Count As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected currentInvisibleLines As Integer = -1
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mFirstLineForIndentation
			End Get
		#tag EndGetter
		FirstLineForIndentation As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  if currentInvisibleLines < 0 then
			    currentInvisibleLines = calcInvisibleLines
			  end if
			  Return currentInvisibleLines
			End Get
		#tag EndGetter
		invisibleLines As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mLastLineForIndentation
			End Get
		#tag EndGetter
		LastLineForIndentation As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		lineEnding As string
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected lines() As TextLine
	#tag EndProperty

	#tag Property, Flags = &h0
		linesLock As CriticalSection
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected longestLineIndex As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected longestLineLength As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFirstLineForIndentation As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastLineForIndentation As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTabwidth As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected neededCache As dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected needsLongestRescan As boolean = false
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mTabwidth
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mTabwidth = value
			  
			  dim line as TextLine
			  for each line in lines
			    line.TabWidth = value
			  next
			End Set
		#tag EndSetter
		TabWidth As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  Return TextStorage.Length
			End Get
		#tag EndGetter
		Protected TextLength As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected TextStorage As gapBuffer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected tmpDefinition As highlightdefinition
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected visibleCache As dictionary
	#tag EndProperty


	#tag Constant, Name = LineChangedMsg, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = LineCountChangedMsg, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = LineSymbolsRemovedMsg, Type = Double, Dynamic = False, Default = \"4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = MaxLineLengthChangedMsg, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Count"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FirstLineForIndentation"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="invisibleLines"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LastLineForIndentation"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="lineEnding"
			Group="Behavior"
			Type="string"
			EditorType="MultiLineEditor"
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
			Name="TabWidth"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
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
