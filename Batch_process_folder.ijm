// Select a folder and apply a counting macro to all files in that folder.
// Twin spot counts makes the counting of Ilastik's already processed files

// Variables used by the macro. Change the macroFolder to the location where your macros are stored
macroFolder = "/Users/Elroth/Fiji macros/";
macroOptions = newArray("DAPI nuclei counts", "Clone counts", "Twin spot counts");

// Create a dialog box to get the folder and macro selection
Dialog.create("Batch Process Folder");
Dialog.addDirectory("Folder to Process:", "");
Dialog.addMessage("Are your images multi-channel? \n The macros below can only process single channel images. \n If you have multi-channel images, please split the channels \n for each file first and save each channel in a separate folder. \n Select then the folder with single-channel images.");
Dialog.addChoice("Macro to Apply:", macroOptions, macroOptions[0]);
Dialog.show();

// Get the selected folder and macro index
folder = Dialog.getString();
macroIndex = Dialog.getChoice();

// Next, loop through all the files in the folder
list = getFileList(folder);
print("Processing "+list.length+" files");
for (i=0; i<list.length; i++) {
	// Make sure the file is an image file or Ilastik h5 file
	if (endsWith(list[i], ".tif") || endsWith(list[i], ".tiff") || endsWith(list[i], ".h5")) {
	    // Get the file path
	    path = folder+list[i];
	         
	    // Run the selected macro on the file
	    if (macroIndex == "DAPI nuclei counts") {
			runMacro(macroFolder+"HL_DAPI_counts.ijm", path);
	    } else if (macroIndex == "Clone counts") {
			runMacro(macroFolder+"HL_GFP_counts.ijm", path);
	    } else if (macroIndex == "Twin spot counts") {
	        runMacro(macroFolder+"HL_RFP_counts.ijm", path);
	    }
	}
}
print("Finished batch processing");