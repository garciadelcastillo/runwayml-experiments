
// Represents a Pose skeleton coming from Runway-ML PoseNET model (Beta V.0.10.32)
// See `posenet_schema.json` file on sketch folder for more info.
public class Pose {

  // Skeleton components in the order they come from the PoseNET model
  PVector nose, 
    leftEye, 
    rightEye, 
    leftEar, 
    rightEar, 
    leftShoulder, 
    rightShoulder, 
    leftElbow, 
    rightElbow, 
    leftWrist, 
    rightWrist, 
    leftHip, 
    rightHip, 
    leftKnee, 
    rightKnee, 
    leftAnkle, 
    rightAnkle;

  float r = 10;  // radius for nodes
  color nodeColor = color(255, 0, 0);
  float w = 10;  // width for lines; 
  color lineColor = color(255, 0, 0, 127);


  Pose(String poseNetResponse) {
    JSONObject resObj = parseJSONObject(poseNetResponse);

    // The data is nested below three arrays...
    JSONArray posArrRoot = resObj.getJSONArray("poses");
    JSONArray posArr = posArrRoot.getJSONArray(0);

    parseArrayIntoParts(posArr);
  }

  public void render() {
    push();

    // Connections
    stroke(lineColor);
    strokeWeight(w);

    drawLine(leftHip, leftShoulder);
    drawLine(leftElbow, leftShoulder);
    drawLine(leftElbow, leftWrist);
    drawLine(leftHip, leftKnee);
    drawLine(leftKnee, leftAnkle);
    drawLine(rightHip, rightShoulder);
    drawLine(rightElbow, rightShoulder);
    drawLine(rightElbow, rightWrist);
    drawLine(rightHip, rightKnee);
    drawLine(rightKnee, rightAnkle);
    drawLine(leftShoulder, rightShoulder);
    drawLine(leftHip, rightHip);

    // Single nodes
    noStroke();
    fill(nodeColor);
    circle(nose.x, nose.y, r);
    circle(leftEye.x, leftEye.y, r);
    circle(rightEye.x, rightEye.y, r);
    circle(leftEar.x, leftEar.y, r);
    circle(rightEar.x, rightEar.y, r);

    // Connected nodes
    circle(leftShoulder.x, leftShoulder.y, r);
    circle(rightShoulder.x, rightShoulder.y, r);
    circle(leftElbow.x, leftElbow.y, r);
    circle(rightElbow.x, rightElbow.y, r);
    circle(leftWrist.x, leftWrist.y, r);
    circle(rightWrist.x, rightWrist.y, r);
    circle(leftHip.x, leftHip.y, r);
    circle(rightHip.x, rightHip.y, r);
    circle(leftKnee.x, leftKnee.y, r);
    circle(rightKnee.x, rightKnee.y, r);
    circle(leftAnkle.x, leftAnkle.y, r);
    circle(rightAnkle.x, rightAnkle.y, r);

    pop();
  }

  private void drawLine(PVector start, PVector end) {
    line(start.x, start.y, end.x, end.y);
  }

  private void parseArrayIntoParts(JSONArray jsonParts) {
    nose = vec2FromArr(jsonParts.getJSONArray(0).getFloatArray());
    leftEye = vec2FromArr(jsonParts.getJSONArray(1).getFloatArray());
    rightEye = vec2FromArr(jsonParts.getJSONArray(2).getFloatArray());
    leftEar = vec2FromArr(jsonParts.getJSONArray(3).getFloatArray());
    rightEar = vec2FromArr(jsonParts.getJSONArray(4).getFloatArray());
    leftShoulder = vec2FromArr(jsonParts.getJSONArray(5).getFloatArray());
    rightShoulder = vec2FromArr(jsonParts.getJSONArray(6).getFloatArray());
    leftElbow = vec2FromArr(jsonParts.getJSONArray(7).getFloatArray());
    rightElbow = vec2FromArr(jsonParts.getJSONArray(8).getFloatArray());
    leftWrist = vec2FromArr(jsonParts.getJSONArray(9).getFloatArray());
    rightWrist = vec2FromArr(jsonParts.getJSONArray(10).getFloatArray());
    leftHip = vec2FromArr(jsonParts.getJSONArray(11).getFloatArray());
    rightHip = vec2FromArr(jsonParts.getJSONArray(12).getFloatArray());
    leftKnee = vec2FromArr(jsonParts.getJSONArray(13).getFloatArray());
    rightKnee = vec2FromArr(jsonParts.getJSONArray(14).getFloatArray());
    leftAnkle = vec2FromArr(jsonParts.getJSONArray(15).getFloatArray());
    rightAnkle = vec2FromArr(jsonParts.getJSONArray(16).getFloatArray());
  }

  // Returns a node in PVector format scaled for the screen
  private PVector vec2FromArr(float[] params) {
    return new PVector(params[0] * width, params[1] * height, 0.0);
  }
}
