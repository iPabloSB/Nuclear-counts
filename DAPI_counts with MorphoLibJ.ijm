// This macro requires a single channel image. If starting from a multichannel,
// split the channels first and choose the window that will be counted.

// Prepare the image for analysis: rename, transform into Greys, invert LUT.
file_name = getTitle();
print("Counting DAPI nuclei in:");
print(file_name);
rename("original");
run("Grays");
run("Invert", "stack");

// Run Gaussian blur on the stack to remove noise and smoothen the surfaces
run("Gaussian Blur 3D...", "x=2 y=2 z=2");

// Get the minimal intensity in the image to set it as the initial value for the watershed processing
run("Z Project...", "projection=[Min Intensity]");
run("Set Measurements...", "min redirect=None decimal=6");
run("Measure");
Hmin = getResult("Min") - 1
close();

// Runs watershed to separate merged nuclei and creates an image with the objects to be counted
run("Classic Watershed", "input=original mask=None use min="+Hmin+" max=250");

// Prepares the image for counting and changes the LUT to easily visualize the objects
run("8-bit");
run("3-3-2 RGB");

// Count with MorphoLibJ (connected component labeling)
run("Connected Components Labeling", "connectivity=26 type=[16 bits]");
run("Label Size Filtering", "operation=Greater_Than size=10"); //Count only >10px
run("Remap Labels");
run("Z Project...", "projection=[Max Intensity]");
run("Select All");
run("Measure");
print("Final DAPI counts: "+getValue("Max"));
close();

// Calculate the disc total volume by measuring each cell's volume and adding all toghether
selectWindow("watershed-lbl-sizeFilt");
run("Analyze Regions 3D", "volume surface_area_method=[Crofton (13 dirs.)] euler_connectivity=26");

DAPICells = Table.size;
DAPIVolume = 0
for (i = 0; i < DAPICells; i++) {
	DAPIVolume += Table.get("Volume", i); 
}

// Print the DAPI volume to the log
print("DAPI total volume: "+DAPIVolume);
Table.rename("watershed-lbl-sizeFilt-morpho", file_name);

// showMessageWithCancel("Close the images?","Do you want to close the images generated during the analysis?");
closeImages = getBoolean("Do you want to close the images from the analysis?")
if (closeImages == 1) {
close("watershed");
close("original");
close("watershed-lbl-sizeFilt");
close("watershed-lbl");
}