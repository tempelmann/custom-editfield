#tag BuildAutomation
			Begin BuildStepList Linux
				Begin BuildProjectStep Build
				End
			End
			Begin BuildStepList Mac OS X
				Begin BuildProjectStep Build
				End
				Begin IDEScriptBuildStep EnableRetinaSupport , AppliesTo = 0
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
			End
#tag EndBuildAutomation
