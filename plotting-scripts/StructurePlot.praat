# TITLE:		StructurePlot
# INPUT:		Soundfile, TextGrid
# TASK:			Plot spectrogram, waveform, pitchtrack, and textgrid for all textgrids of all subdirectories (up to one level) of one directory
# REQUIREMENTS:	TextGrids must be in subfolders of token$ and Soundfiles must be in subfolders of grids$, whereby subfolders must be equally named (e.g. sound\speaker_a\sound_a.wav & praat\speaker_a\sound_a.TextGrid).
# OUTPUT:		EPS file, PDF file, PNG file, praatpicture file,
# VERSION:		2.1
# DATE:			2014-09-24
# NOTES:		Works on Praat 5.3.80 under Mac OS 10.9.4
#				Requires EPS printer
#				Textgrid takes lower num_tiers/(4+num_tiers)
# AUTHOR:		Meikal Mumin

form Input
	sentence tokens /path/to/wav/files/
	sentence grids /path/to/text/grids/
	integer pitchfloor 75
	integer pitchceiling 150
	choice fontsize: 3
		button 10
		button 12
		button 14
		button 18
		button 24
	choice font: 2
		button Times
		button Helvetica
		button Palatino
		button Courier
	choice fontcolor: 1
		button Black
		button White
		button Red
		button Blues
	choice pitchcolor: 3
		button Black
		button White
		button Red
		button Blues
	choice linestyle: 1
		button Solid line
		button Dotted line
		button Dashed line
		button Dashed-dotted line
	boolean createeps 1
	boolean createpdf 1
	boolean createpng 1
	boolean createpraapic 1
endform

#Get number of folders contained in structure and run for-loop
folderstrings = Create Strings as directory list: "folderlist", grids$ + "*"
numberOfFolders = Get number of strings
for ifolder to numberOfFolders

	#Get number of .TextGrid files contained in current folder and run for-loop
	selectObject: folderstrings
	gridfolder$ = Get string: ifolder
	filestrings = Create Strings as file list: "filelist", grids$ + gridfolder$ + "/*.TextGrid"
	numberOfFiles = Get number of strings
	for ifile to numberOfFiles

		#Set gridfile and clean filename
		selectObject: filestrings
		gridfile$ = Get string: ifile
		cleangridfile$ = replace$(gridfile$, "(", "_", 0)
		cleangridfile$ = replace$(cleangridfile$, ")", "_", 0)
		cleangridfile$ = replace$(cleangridfile$, ".", "_", 0)
		cleangridfile$ = replace$(cleangridfile$, "'", "_", 0)
		cleangridfile$ = replace$(cleangridfile$, " ", "_", 0)

		#Open files
		if fileReadable (tokens$+gridfolder$+"/"+replace$(gridfile$, ".TextGrid", ".wav", 1))
			do ("Read from file...", tokens$+gridfolder$+"/"+replace$(gridfile$, ".TextGrid", ".wav", 1))
			do ("Read from file...", grids$+gridfolder$+"/"+gridfile$)
		else
			soundfile$ = replace$(gridfile$, "_", " ", 0)
			do ("Read from file...", tokens$+gridfolder$+"/"+replace$(soundfile$, ".TextGrid", ".wav", 1))
			do ("Read from file...", grids$+gridfolder$+"/"+gridfile$)
		endif

		#Cleanup viewport and set intial properties
		do ("Erase all")
		do (linestyle$)
		do (fontcolor$)
		do (font$)
		do (fontsize$)
		Select outer viewport: 0, 6, 0, 3
		
		#Create spectogram
		selectObject ("Sound "+replace$(cleangridfile$, "_TextGrid", "", 1))
		To Spectrogram: 0.005, 5000, 0.002, 20, "Gaussian"
	
		#Draw spectogram
		Paint: 0, 0, 0, 0, 100, "yes", 50, 6, 0, "no"
	
		#Draw Left scale for spectogram
		Select outer viewport: 0, 6, 0, 3
		Draw inner box
		Marks left every: 1, 1000, "yes", "yes", "no"
		Text left: "yes", "Spectogram: Frequency (Hz)"
	
		#Create Pitch contour
		selectObject ("Sound "+replace$(cleangridfile$, "_TextGrid", "", 1))
		To Pitch: 0, pitchfloor, pitchceiling
	
		#Draw Pitch contour
		Line width: 3
		Red
		Draw: 0, 0, pitchfloor, pitchceiling, "no"
	
		#Draw Right scale for pitch contour
		Line width: 1
		Black
		Marks right every: 1, 25, "yes", "yes", "no"
		Text right: "yes", "Pitch contour: Frequency (Hz)"
	
		#Draw Waveform
		#Select outer viewport: 0, 6, 2.5, 5.5
		Select outer viewport: 0, 6, 2.5, 5
		selectObject ("Sound "+replace$(cleangridfile$, "_TextGrid", "", 1))
		Draw: 0, 0, 0, 0, "no", "Curve"
	
		#Draw Textgrid
		Select outer viewport: 0, 6, 2.5, 6
		selectObject ("TextGrid "+replace$(cleangridfile$, "_TextGrid", "", 1))
		Draw: 0, 0, "yes", "yes", "yes"
	
		#Clean up filename for drawing, check length, and shorten if overly long
		#Keep order of replacements below, or else the backslash of \_ will be replaced again
		title$ = gridfolder$+ "\" +replace$(cleangridfile$, "_TextGrid", ".wav", 1)
		if length(title$) > 50
			title$ = replace$(cleangridfile$, "_TextGrid", ".wav", 1)
		endif
		title$ = replace$ (title$, "\", "\bs", 0)
		title$ = replace$ (title$, "_", "\_ ", 0)
		
		#Draw Filename
		Select outer viewport: 0, 6, 0, 6
		Text top: "no", title$
	
		#Export Graphics
		if createeps = 1
			do ("Save as EPS file...", ""+grids$+gridfolder$+"/"+replace$(gridfile$, ".TextGrid", ".eps", 1))
		endif
		if createpdf = 1
			do ("Save as PDF file...", ""+grids$+gridfolder$+"/"+replace$(gridfile$, ".TextGrid", ".pdf", 1))
		endif
		if createpng = 1
			do ("Save as 300-dpi PNG file...", ""+grids$+gridfolder$+"/"+replace$(gridfile$, ".TextGrid", ".png", 1))
		endif
		if createpraapic = 1
			do ("Save as praat picture file...", ""+grids$+gridfolder$+"/"+replace$(gridfile$, ".TextGrid", ".prapic", 1))
		endif

		#Clean up filelist
		plusObject ("Sound "+replace$(cleangridfile$, "_TextGrid", "", 1))
		plusObject ("Spectrogram "+replace$(cleangridfile$, "_TextGrid", "", 1))
		plusObject ("Pitch "+replace$(cleangridfile$, "_TextGrid", "", 1))
		do ("Remove")

	endfor
endfor

#Clean up filelist and viewport
selectObject ("Strings folderlist")
do ("Remove")
for ifolder to numberOfFolders 
	plusObject ("Strings filelist")
	do ("Remove")
endfor
#do ("Erase all")

#End of file