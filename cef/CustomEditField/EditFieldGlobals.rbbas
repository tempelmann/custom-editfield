#tag Module
Protected Module EditFieldGlobals
	#tag Method, Flags = &h1
		Protected Function AdjustColorForDarkMode(c as Color) As Color
		  // Returns Dark Mode equivalent color _if_ we're in Dark Mode (this assumes a Bright Mode color is passed)
		  
		  #if RBVersion >= 2019.02
		    #if AppSupportsDarkMode
		      if Color.IsDarkMode then
		        if c = &cFFFFFF00 then // white
		          c = Color.FillColor
		        elseif c = &c00000000 then // black
		          c = Color.TextColor
		        else
		          // make bright colors darker and vice versa
		          c = InvertedModeColor (c)
		        end if
		      end if
		    #endif
		  #endif
		  
		  return c
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function DarkerColor(extends forColor as Color, offset as integer, adjustForDarkMode as Boolean) As Color
		  //get a darker color for the given color.
		  if adjustForDarkMode and IsDarkMode then
		    Return rgb( min(forColor.Red + offset, 255), min(forColor.green + offset, 255), min(forColor.blue + offset, 255)) // darker
		  else
		    Return rgb( max(forColor.Red - offset, 0), max(forColor.green - offset, 0), max(forColor.blue - offset, 0))
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function InvertColor(extends input as Color) As color
		  Return rgb(255 - input.Red, 255 - input.Green, 255 - input.Blue)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function InvertedModeColor(c as Color) As Color
		  // Issue #37 - support for Dark Mode
		  #if RBVersion >= 2019.02
		    #if AppSupportsDarkMode
		      // make bright colors darker and vice versa
		      if c = &c000000 then
		        c = &cFFFFFF
		      elseif c = &cFFFFFF then
		        c = &c000000
		      else
		        // This brightness inversion is based on trial-and-error
		        dim lum as Double = luminence (c)
		        if lum > 0.6 then
		          c = lerpColor (c, RGB(0,0,0), lum * 0.7)
		        else
		          c = lerpColor (c, &cFFFFFF, (1 - lum) * 0.7)
		        end if
		      end if
		    #endif
		  #endif
		  
		  return c
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function IsDarkMode() As Boolean
		  // Issue #37 - support for Dark Mode
		  dim isDark as Boolean
		  #if RBVersion >= 2019.02
		    #if AppSupportsDarkMode
		      isDark = Color.IsDarkMode
		    #endif
		  #endif
		  return isDark
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function lerp(start as Double, ende as Double, amt as Double) As Double
		  dim diff as Double = ende - start
		  dim adj as Double = diff * amt
		  return start + adj
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function lerpColor(fromCol as Color, toCol as Color, amount as Double) As Color
		  // https://stackoverflow.com/a/2690026/43615
		  dim sr as Double = fromCol.Red
		  dim sg as Double = fromCol.Green
		  dim sb as Double = fromCol.Blue
		  dim er as Double = toCol.Red
		  dim eg as Double = toCol.Green
		  dim eb as Double = toCol.Blue
		  return RGB (lerp (sr, er, amount), lerp (sg, eg, amount), lerp (sb, eb, amount))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LighterColor(extends forColor as color, offset as integer, adjustForDarkMode as Boolean) As color
		  //get a darker color for the given color.
		  if adjustForDarkMode and IsDarkMode then
		    Return rgb( max(forColor.Red - offset, 0), max(forColor.green - offset, 0), max(forColor.blue - offset, 0)) // lighter
		  else
		    Return rgb( min(forColor.Red + offset, 255), min(forColor.green + offset, 255), min(forColor.blue + offset, 255))
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function loadMaskedPicture(image as picture) As picture
		  if Image = nil then Return nil
		  
		  dim newpic as Picture = New Picture(image.Width/2, Image.Height, 32)
		  NewPic.Graphics.DrawPicture Image, 0,0
		  NewPic.Mask.Graphics.DrawPicture Image, 0, 0, NewPic.Width, NewPic.Height, Image.Width/2, 0
		  
		  Return newpic
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function LongestCommonPrefixIndex(extends source as string, target as string) As integer
		  //finds the longest common prefix between 2 strings
		  #pragma DisableBackgroundTasks
		  #pragma DisableBoundsChecking
		  
		  dim n as Integer = min(source.len, Target.Len)
		  dim i as Integer
		  for i = 1 to n
		    if source.Mid(i,1) <> Target.Mid(i,1) then Exit for
		  next
		  Return i - 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function luminence(c as Color) As Double
		  dim r as Double = c.Red
		  dim g as Double = c.Green
		  dim b as Double = c.Blue
		  
		  return (r+r+b+g+g+g) / 6 / 255 // https://stackoverflow.com/a/596241/43615
		  
		  'return sqrt(0.299 * r*r + 0.587 * g*g + 0.114 * b*b) / 255
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function SupportDarkMode() As Boolean
		  // Returns whether we need to support Dark Mode
		  #if RBVersion >= 2019.02
		    #if AppSupportsDarkMode
		      return true
		    #endif
		  #endif
		  return false
		End Function
	#tag EndMethod


	#tag Note, Name = TextStorageType
		STORAGE_ARRAY and STORAGE_WIDEMEMORYBLOCK are Unicode-savvy, i.e. they can handle any character.
		STORAGE_MEMORYBLOCK can only handle 1-byte encodings and will fail with most non-ASCII chars, therefore.
		
		STORAGE_WIDEMEMORYBLOCK should be more efficient than STORAGE_ARRAY.
		STORAGE_MEMORYBLOCK is the most compact but the least versatile.
		
		Also note: STORAGE_WIDEMEMORYBLOCK may not work work right on Linux, but STORAGE_ARRAY should.
	#tag EndNote


	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  if mBlocktrailimage = nil then
			    mBlocktrailimage = EditFieldGlobals.LoadMaskedPicture(blockFoldedTrailMarker)
			  end if
			  
			  return mBlocktrailimage
			End Get
		#tag EndGetter
		Protected BlockFoldedTrailImage As picture
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  // We must use either UTF-32 or UTF-8 but never UTF-16
			  // because some chars (e.g. "🔍") in UTF-16 return 2 for their
			  // Length, which is incorrect and causes errors with this code.
			  if false then
			    // This should work but doesn't yet
			    return Encodings.UTF32
			  else
			    return Encodings.UTF8
			  end if
			End Get
		#tag EndGetter
		Protected InternalEncoding As TextEncoding
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mBlocktrailimage As picture
	#tag EndProperty


	#tag Constant, Name = CEF_VERSION, Type = String, Dynamic = False, Default = \"1.11.0", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = DebugIndentation, Type = Boolean, Dynamic = False, Default = \"false", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = DebugTiming, Type = Boolean, Dynamic = False, Default = \"false", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Replace00With01, Type = Boolean, Dynamic = False, Default = \"true", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = STORAGE_ARRAY, Type = Double, Dynamic = False, Default = \"1", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = STORAGE_MEMORYBLOCK, Type = Double, Dynamic = False, Default = \"0", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = STORAGE_WIDEMEMORYBLOCK, Type = Double, Dynamic = False, Default = \"2", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = TextStorageType, Type = Double, Dynamic = False, Default = \"2", Scope = Protected
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"1"
	#tag EndConstant

	#tag Constant, Name = UseOldRenderer, Type = Boolean, Dynamic = False, Default = \"false", Scope = Protected
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
