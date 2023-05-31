// This macro requires a single channel image. If starting from a multichannel,
// split the channels first and choose the window that will be counted.

// Prepare the image for analysis: rename, transform into Greys.
print("Counting RFP nuclei in:");
titleImage = getTitle();
print(titleImage);
rename("Original");
run("Grays");

// Normalize image intensities for proper segmentation. Comment this line if images are already normalized.
// run("Enhance Contrast...", "saturated=0.1 normalize process_all use");

// Duplicate the image to continue the pipeline for the watershedding
run("Duplicate...", "duplicate");
rename("Ilastik_classifier");
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
// Max intensity must be set according to the image background. In the case of tub-nRFP, a max of 240
// seemed to be the most efficient way to segment and ignore background.
run("Classic Watershed", "input=Ilastik_classifier mask=None use min="+Hmin+" max=240");

// Prepares the image for object classification by changing to 8 bits and creating a mask
run("8-bit");
setThreshold(1, 255, "raw");
setOption("BlackBackground", false);
run("Convert to Mask", "method=Default background=Dark");

// Run Ilastik's object classification using the original file as input and the watershed as segmentation


// Count with MorphoLibJ (connected component labeling)
run("Connected Components Labeling", "connectivity=26 type=[16 bits]");
run("Label Size Filtering", "operation=Greater_Than size=10"); //Count only >10px
run("Remap Labels");
lastSlice = nSlices();
setSlice(lastSlice);
run("Select All");
run("Measure");
print("Final RFP counts: "+getValue("Max"));

// Final part: closing or saving images. There are two workflows here: the user-guided prompt to either
// close the images or keep them for feedback, or the batch script that will merge some of the images
// (original, mask, final counts) for later review once the batch analysis is done.

// User-guided script: keep or close images? To activate, uncomment the following lines
/*
closeImages = getBoolean("Do you want to close the images from the analysis?")
if (closeImages == 1) {
close("watershed");
close("Original");
close("Mask");
close("watershed-lbl-sizeFilt");
close("watershed-lbl");
}
*/

// Batch script: Merge images and save to SSD. To inactivate, comment the following lines
selectWindow("watershed-lbl-sizeFilt");
run("8-bit");
selectWindow("Original");
run("Merge Channels...", "c1=Mask c2=watershed-lbl-sizeFilt c4=Original create");
saveAs("Tiff", "/Volumes/PSB-T7/Images/RFP GFP counts/Batch_output_RFP/"+titleImage);
close();
close("watershed");
close("Original");
close("Probabilities");
close("Mask");
close("watershed-lbl-sizeFilt");
close("watershed-lbl");