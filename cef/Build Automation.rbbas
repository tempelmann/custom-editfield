#tag BuildAutomation
			Begin BuildStepList Linux
				Begin BuildProjectStep Build
				End
				Begin CopyFilesBuildStep CopyDefinitionsLinux
					AppliesTo = 0
					Destination = 1
					Subdirectory = 
					FolderItem = Li4vRGVmaW5pdGlvbnMv
				End
			End
			Begin BuildStepList Mac OS X
				Begin BuildProjectStep Build
				End
				Begin CopyFilesBuildStep CopyDefinitionsMac
					AppliesTo = 0
					Destination = 1
					Subdirectory = 
					FolderItem = Li4vRGVmaW5pdGlvbnMv
				End
				Begin IDEScriptBuildStep EnableRetinaSupport , AppliesTo = 0
					// Adds a key to the Info.plist to enable Retina (HiDPI) resolition.
					// Works only for Mac Cocoa builds.
					
					if CurrentBuildTarget <> 7 and CurrentBuildTarget <> 16 then
					return
					end
					
					const key = "NSHighResolutionCapable"
					const keyType = "bool"
					const value = "true"
					
					dim infoPlistPath as string = CurrentBuildLocation+"/"""+CurrentBuildAppName + ".app/Contents/Info.plist"
					dim cmd as string = "/usr/libexec/PlistBuddy -c ""Add :" + key + " " + keyType + " " + value + """ " + infoPlistPath + """"
					dim result as string = DoShellCommand(cmd)
					
					if result <> "" then
					print "PlistBuddy not installed. This tool is necessary for the UpdatePlist script to function properly."+EndOfLine+EndOfLine+cmd+EndOfLine+EndOfLine+result
					end
				End
			End
			Begin BuildStepList Windows
				Begin BuildProjectStep Build
				End
				Begin CopyFilesBuildStep CopyDefinitionsWin
					AppliesTo = 0
					Destination = 1
					Subdirectory = 
					FolderItem = Li4vRGVmaW5pdGlvbnMv
				End
			End
#tag EndBuildAutomation
