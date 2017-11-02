#tag Module
Protected Module DragImage
	#tag Method, Flags = &h21
		Private Function NewCGImage(p as Picture) As Ptr
		  #if targetMacOS
		    if p is nil then
		      return nil
		    end if
		    dim g as Graphics = p.Graphics
		    
		    if g is nil then //copy into new picture
		      dim pCopy as new Picture(p.Width, p.Height, 32)
		      dim gCopy as Graphics = pCopy.Graphics
		      if gCopy is nil then
		        return nil
		      end if
		      gCopy.DrawPicture p, 0, 0
		      p = pCopy
		      g = gCopy
		    end if
		    if g is nil then //I give up
		      return nil
		    end if
		    
		    dim gworldData as Ptr = Ptr(g.Handle(Graphics.HandleTypeCGrafPtr))
		    if gworldData = nil then
		      return nil
		    end if
		    
		    declare function QDBeginCGContext lib CarbonFramework (port as Ptr, ByRef contextPtr as Ptr) as Integer
		    
		    dim c as Ptr
		    dim OSError as Integer = QDBeginCGContext(gworldData, c)
		    if OSError <> 0 or c = nil then
		      return nil
		    end if
		    
		    
		    declare function CGBitmapContextCreateImage lib CarbonFramework (c as Ptr) as Ptr
		    
		    dim image as Ptr = CGBitmapContextCreateImage(c)
		    
		    declare function QDEndCGContext lib CarbonFramework (port as Ptr, ByRef context as Ptr) as Integer
		    
		    OSError = QDEndCGContext(gworldData, c)
		    
		    return image
		  #endif
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetImage(extends d as Dragitem, p as Picture)
		  #if targetMacOS and not Target64Bit
		    dim theImage as Ptr = NewCGImage(p)
		    if theImage = nil then
		      return
		    end if
		    
		    declare function SetDragImageWithCGImage lib "Carbon.framework" (inDrag as Integer, inCGImage as Ptr, inImageOffsetPt as Ptr, inImageFlags as UInt32) as Integer
		    
		    declare function CGImageGetHeight lib "Carbon.framework" (image as Ptr) as UInt32
		    declare function CGImageGetWidth lib "Carbon.framework" (image as Ptr) as UInt32
		    
		    const sizeOfHIPoint = 8
		    dim offset as new MemoryBlock(sizeOfHIPoint)
		    offset.SingleValue(0) = -CGImageGetWidth(theImage)/2
		    offset.SingleValue(4) = -CGImageGetHeight(theImage)/2
		    
		    const kDragStandardTranslucency = 0
		    
		    'kDragRegionAndImage = (1L << 4)
		    'kDragStandardTranslucency = 0, 65%
		    'kDragDarkTranslucency = 1, 50%
		    'kDragDarkerTranslucency = 2, 25%
		    'kDragOpaqueTranslucency = 3 0%
		    
		    dim OSError as Integer = SetDragImageWithCGImage(d.Handle, theImage, offset, kDragStandardTranslucency)
		    #pragma unused OSError
		    
		  #else
		    #pragma unused d
		    #pragma unused p
		  #endif
		  
		  finally // careful: any "return" above will not execute this finally block!
		    #if targetMacOS and not Target64Bit
		      declare sub CFRelease lib "Carbon.framework" (cf as Ptr)
		      CFRelease theImage
		    #endif
		    
		    
		    
		End Sub
	#tag EndMethod


	#tag Note, Name = Info
		Code by Charles Yeomans
		http://www.declaresub.com/article/121/providing-a-better-drag-image
	#tag EndNote


	#tag Constant, Name = CarbonFramework, Type = String, Dynamic = False, Default = \"Carbon.framework", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="2147483648"
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
