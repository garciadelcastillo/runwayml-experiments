/*
  A quick example to manually connect Processing to RunwayML and receive a PoseNET prediction 
  using an HTTP request. 
  
  Instructions:
    - Open RunwayML.
    - Create/load a PoseNet model to your workspace.
    - Run it (either locally or on the cloud).
    - Run this sketch.
    - (If it is the dirst time you do it, set the correct value for `cameraID`, see below)
    - Press any key to take a snapshot.
    - Wait to receive the pose prediction from Runway. 
    - Copies of the snapshots were saved to this sketch folder. 
  
  Author: github.com/garciadelcastillo
  This work is licensed under a Creative Commons Attribution 4.0 International License:
    Share Alike, Attribute the Author/s.
*/

// Libraries
import java.util.Base64;
import processing.video.*;    // make sure to add this library to your sketch from the contributions manager

// SKETCH PARAMETERS
// When this sketch starts, it dumps a list of all the virtual webcams in your system.
// Place here the id of the one that most closely approximates 640x480 at 30fps:
int cameraID = 3;

// Global objects
Capture cam;
PImage snapImg;
Pose skeleton;

void setup() {
  size(640, 480);
  textAlign(CENTER, CENTER);

  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println("[" + i + "] " + cameras[i]);
    }
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[cameraID]);
    cam.start();     
  }      
}


void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  
  
  // Render the last snap or the live webcam feed
  if (snapImg != null) {
    image(snapImg == null ? cam : snapImg, 0, 0);
  } else {
    image(cam, 0, 0);
  }
  
  // Render the skeleton
  if (skeleton != null) {
    skeleton.render();
  }
  
  // Help text
  fill(0);
  rect(0, height - 30, width, 30);
  fill(255);
  text("Press any key to take a snapshot", width / 2, height - 15);
}


void keyPressed() 
{
  // Base filename
  String filename = "screenshot_" + frameCount;
  
  // Save snapshot to sketch folder
  snapImg = cam.copy();
  snapImg.save(filename + ".png");
  
  // Load bytes from file
  byte[] imgBytes = loadBytes(filename + ".png");

  // Encode them to base64. 
  // https://forum.processing.org/two/discussion/22523/pimage-to-base64-for-api-upload
  // https://stackoverflow.com/questions/13109588/encoding-as-base64-in-java/13109632#13109632
  byte[] encodedBytes = Base64.getEncoder().encode(imgBytes);
  String pngHeader = "data:image/Png;base64,";  // runway needs headers to properly parse images
  String base64Img = pngHeader + new String(encodedBytes);
  
  // Create the JSON request content based on R-ML input specification for PoseNet (V.0.10.32):
  /*
    {
       "image": <base 64 image>,
       "estimationType": <dropdown>,
       "maxPoseDetections": <slider>,
       "scoreThreshold": <slider>
    }
  */
  JSONObject req = new JSONObject();
  req.setString("image", base64Img);
  req.setString("estimationType", "multi pose");
  req.setInt("maxPoseDetections", 5);
  req.setDouble("scoreThreshold", 0.25);
  
  // Save the request json to the system
  saveStrings(filename + "_request.json", new String[]{ req.toString() });
  
  // Compose and send the HTTP POST request to Runway
  PostRequest post = new PostRequest("http://localhost:8000/query");
  post.addHeader("Content-Type", "application/json");
  post.addJSONString(req.toString());  // this method is custom added to Rune/Dan's library
  post.send();
  
  // Wait for the response
  String res = post.getContent();
  println("Response Content: " + res);
  println("Response Content-Length Header: " + post.getHeader("Content-Length"));
  
  // Save the response json to the system
  saveStrings(filename + "_response.json", new String[]{ res.toString() });

  // Parse the response into a custom Pose object
  skeleton = new Pose(res);
  
  // Save a composite image to sketch folder
  image(snapImg, 0, 0);
  skeleton.render();
  saveFrame(filename + "_skeleton.png");
}
