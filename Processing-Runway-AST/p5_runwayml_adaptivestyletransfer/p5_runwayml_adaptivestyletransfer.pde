/*
  A quick example to manually connect Processing to RunwayML and receive an
  Adaptive Style Transfer prediction using an HTTP request. 
  
  Instructions: see attached README file.
  
  Author: github.com/garciadelcastillo
  This work is licensed under a Creative Commons Attribution 4.0 International License:
    Share Alike, Attribute the Author/s.
*/

// Libraries
import java.util.Base64;
import java.nio.charset.StandardCharsets;
import processing.video.*;    // make sure to add this library to your sketch from the contributions manager

// SKETCH PARAMETERS
// When this sketch starts, it dumps a list of all the virtual webcams in your system.
// Place here the id of the one that most closely approximates 640x480 at 30fps:
int cameraID = 1;

// Global objects
Capture cam;
PImage snapImg;
boolean predicting = false;

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
  if (predicting && snapImg != null) 
  {
    image(snapImg, 0, 0);
  }
  else
  {
    image(cam, 0, 0);
  }
    
  // Help text
  fill(0);
  rect(0, height - 30, width, 30);
  fill(255);
  text("Press any key to change image style", width / 2, height - 15);
  
  // If on prediction mode, request
  if (predicting) {
    requestPrediction();
  }
}


void keyPressed() 
{
  predicting = !predicting;
}

void requestPrediction() {
  println("Prediction on frame " + frameCount);
  
  // Base filename
  String filename = "screenshot_" + frameCount;
  
  // Save snapshot to sketch folder
  snapImg = cam.copy();
  snapImg.save(filename + ".jpeg");
  
  // Load bytes from file
  byte[] imgBytes = loadBytes(filename + ".jpeg");

  // Encode them to base64. 
  // https://forum.processing.org/two/discussion/22523/pimage-to-base64-for-api-upload
  // https://stackoverflow.com/questions/13109588/encoding-as-base64-in-java/13109632#13109632
  byte[] encodedBytes = Base64.getEncoder().encode(imgBytes);
  String pngHeader = "data:image/Jpeg;base64,";  // runway needs headers to properly parse images
  String base64Img = pngHeader + new String(encodedBytes);
  
  // Create the JSON request content based on R-ML input specification for PoseNet (V.0.10.32):
  /*
    {
       "contentImage": <base 64 image>  // in jpeg format
    }
  */
  JSONObject req = new JSONObject();
  req.setString("contentImage", base64Img);
  
  // Save the request json to the system
  saveStrings(filename + "_request.json", new String[]{ req.toString() });
  
  // Compose and send the HTTP POST request to Runway
  PostRequest post = new PostRequest("http://localhost:8000/query");
  post.addHeader("Content-Type", "application/json");
  post.addJSONString(req.toString());  // this method is custom added to Rune/Dan's library
  post.send();
  
  // Wait for the response
  String res = post.getContent();
  //println("Response Content: " + res);
  println("Response Content-Length Header: " + post.getHeader("Content-Length"));
  
  // Save the response json to the system
  saveStrings(filename + "_response.json", new String[]{ res.toString() });

  // Deserialize the response into a PImage
  JSONObject resjson = parseJSONObject(res);
  String base64res = resjson.getString("stylizedImage");
  base64res = base64res.split(",")[1];  // remove mime header
  byte[] decodedBytes = Base64.getDecoder().decode(base64res);
  saveBytes(filename + "_prediction.jpeg", decodedBytes);  // the response is also in jpeg format. 
  snapImg = loadImage(filename + "_prediction.jpeg"); 
}
