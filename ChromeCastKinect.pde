/*
 * Copyright (C) 2013 ENTERTAILION, LLC. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */

// Original code: https://groups.google.com/forum/?fromgroups=#!searchin/simple-openni-discuss/XnVSwipeDetector/simple-openni-discuss/dDV8UZDpTgg/nTlOZOk9MMAJ

import SimpleOpenNI.*;


import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.InterfaceAddress;
import java.net.NetworkInterface;
import java.net.URL;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.ResourceBundle;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.xml.sax.InputSource;
import org.xml.sax.XMLReader;

String LOG_TAG = "ChromeCastKinect";
// TODO 
String APP_ID = "YOUR_APP_ID";
String HEADER_APPLICATION_URL = "Application-URL";
String CHROME_CAST_MODEL_NAME = "Eureka Dongle";

BroadcastDiscoveryClient broadcastClient;
Thread broadcastClientThread;
TrackedDialServers trackedServers = new TrackedDialServers();
RampClient rampClient = new RampClient();
List<DialServer> servers = new ArrayList<DialServer>();

SimpleOpenNI context;
XnVSessionManager sessionManager;
SwipeDetector swipeDetector;
PointDrawer pointDrawer;

String instructions = new String();
String currentInput = new String();
boolean hasIpAddress = false;
boolean kinectReady = false;
boolean autoCalibrate = true;
PVector rightHand = new PVector(); // track hand positions
PVector rightElbow = new PVector();
PVector leftHand = new PVector();
PVector leftElbow = new PVector();
boolean rightUp = false;
boolean leftUp = false;

void setup() {
  size(640, 480);
  smooth();
  PFont font = createFont("FFScala", 32);
  textFont(font);
  textAlign(CENTER);

  instructions = "Enter ChromeCast device IP address:";
  currentInput = "";
}

void startKinect() {
  context = new SimpleOpenNI(this);
  // enable depthMap generation 
  if (context.enableDepth() == false)
  {
    println("Can't open the depthMap, maybe the camera is not connected!"); 
    exit();
    return;
  }
  context.setMirror(true);
  context.enableHands();
  context.enableGesture();
  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  sessionManager = context.createSessionManager("Wave", "RaiseHand"); // context.createSessionManager("Click,Wave", "RaiseHand");
  swipeDetector = new SwipeDetector();
  pointDrawer = new PointDrawer();
  sessionManager.AddListener(swipeDetector);
  sessionManager.AddListener(pointDrawer);

  size(context.depthWidth(), context.depthHeight()); 
  kinectReady = true;
}

void draw() {
  if (kinectReady) { // kinect output
    context.update();
    context.update(sessionManager);
    image(context.depthImage(), 0, 0, width, height);
    pointDrawer.draw();

    // draw the skeleton if it's available
    int[] userList = context.getUsers();
    for (int i=0;i<userList.length;i++)
    {
      if (context.isTrackingSkeleton(userList[i]))
        drawSkeleton(userList[i]);
    }
  } 
  else {  // initial input screen
    background(255, 255, 255);
    fill(0);
    text(instructions, width/2, height/2);
    fill(255, 0, 0);
    text(currentInput, width/2, height*.75);
  }
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);  // TODO support multiple users
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, rightElbow);
  rightUp = rightHand.y > rightElbow.y;
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, leftElbow);
  leftUp = leftHand.y > leftElbow.y;

  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
}

void keyPressed()
{
  if (key == ENTER || key==RETURN)
  {
    if (!hasIpAddress) {
      hasIpAddress = discoverDevices(currentInput);
      if (hasIpAddress) {
        instructions = "";
      }
    } 

    currentInput = "";
  }
  else if (key == BACKSPACE && currentInput.length() > 0)
  {
    currentInput = currentInput.substring(0, currentInput.length() - 1);
  }
  else
  {
    currentInput = currentInput + key;
  }
}


//////////////////////////////////////////////////
///////////////////////////////////////////////////
// session callbacks

void onStartSession(PVector pos)
{
  println("onStartSession: " + pos);
  context.removeGesture("Wave");
}

void onEndSession()
{
  println("onEndSession: ");
  context.addGesture("Wave");
}

void onFocusSession(String strFocus, PVector pos, float progress)
{
  println("onFocusSession: focus=" + strFocus + ",pos=" + pos + ",progress=" + progress);
}

/////////////////
// HANDS

// -----------------------------------------------------------------
// hand events

void onCreateHands(int handId, PVector pos, float time)
{
  println("onCreateHands - handId: " + handId + ", pos: " + pos + ", time:" + time);
}

void onUpdateHands(int handId, PVector pos, float time)
{
  // println("onUpdateHandsCb - handId: " + handId + ", pos: " + pos + ", time:" + time);
}

void onDestroyHands(int handId, float time)
{
  println("onDestroyHandsCb - handId: " + handId + ", time:" + time);
}

// -----------------------------------------------------------------
// gesture events

void onRecognizeGesture(String strGesture, PVector idPosition, PVector endPosition)
{
  println("onRecognizeGesture - strGesture: " + strGesture + 
    ", idPosition: " + idPosition + ", endPosition:" + endPosition);
}

void onProgressGesture(String strGesture, PVector position, float progress)
{
  println("onProgressGesture - strGesture: " + strGesture + 
    ", position: " + position + ", progress:" + progress);
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");

  if (autoCalibrate)
    context.requestCalibrationSkeleton(userId, true);
  else    
    context.startPoseDetection("Psi", userId);
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}

void onExitUser(int userId)
{
  println("onExitUser - userId: " + userId);
}

void onReEnterUser(int userId)
{
  println("onReEnterUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);

  if (successfull) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId);
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");

  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
}

void onEndPose(String pose, int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}


////////////////

boolean discoverDevices(final String ip) {
  broadcastClient = new BroadcastDiscoveryClient(getBroadcastAddress(), 
  new BroadcastDiscoveryHandler() {
    public void onBroadcastFound(final BroadcastAdvertisement advert) {
      if (advert.getLocation() != null) {
        new Thread(new Runnable() {
          public void run() {
            Log.d(LOG_TAG, "location=" + advert.getLocation());
            HttpResponse response = new HttpRequestHelper()
              .sendHttpGet(advert.getLocation());
            if (response != null) {
              String appsUrl = null;
              Header header = response
                .getLastHeader(HEADER_APPLICATION_URL);
              if (header != null) {
                appsUrl = header.getValue();
                Log.d(LOG_TAG, "appsUrl=" + appsUrl);
              }
              try {
                InputStream inputStream = response.getEntity()
                  .getContent();
                BufferedReader reader = new BufferedReader(
                new InputStreamReader(inputStream));

                InputSource inStream = new org.xml.sax.InputSource();
                inStream.setCharacterStream(reader);
                SAXParserFactory spf = SAXParserFactory
                  .newInstance();
                SAXParser sp = spf.newSAXParser();
                XMLReader xr = sp.getXMLReader();
                BroadcastHandler broadcastHandler = new BroadcastHandler();
                xr.setContentHandler(broadcastHandler);
                xr.parse(inStream);
                Log.d(LOG_TAG, "modelName="
                  + broadcastHandler.getDialServer()
                  .getModelName());
                // Only handle ChromeCast devices; not other DIAL
                // devices like ChromeCast devices
                if (broadcastHandler.getDialServer().getModelName()
                  .equals(CHROME_CAST_MODEL_NAME) && advert.getIpAddress()
                    .getHostAddress().equals(ip)) {
                  Log.d(LOG_TAG, "ChromeCast device found: "
                    + advert.getIpAddress()
                    .getHostAddress());
                  DialServer dialServer = new DialServer(advert
                    .getLocation(), advert.getIpAddress(), 
                  advert.getPort(), appsUrl, 
                  broadcastHandler.getDialServer()
                    .getFriendlyName(), 
                  broadcastHandler.getDialServer()
                    .getUuid(), broadcastHandler
                    .getDialServer()
                    .getManufacturer(), 
                  broadcastHandler.getDialServer()
                    .getModelName());
                  trackedServers.add(dialServer);
                }
              } 
              catch (Exception e) {
                Log.e(LOG_TAG, "parse device description", e);
              }
            }
          }
        }
        ).start();
      }
    }
  }
  );
  broadcastClientThread = new Thread(broadcastClient);

  // discovering devices can take time, so do it in a thread
  new Thread(new Runnable() {
    public void run() {
      try {
        broadcastClientThread.start();

        // wait a while...
        // TODO do this better
        Thread.sleep(10 * 1000);

        broadcastClient.stop();

        Log.d(LOG_TAG, "size=" + trackedServers.size());
        if (trackedServers.size() > 0) {
          for (DialServer dialServer : trackedServers) {
            servers.add(dialServer);
          }
          DialServer dialServer = servers.get(0);
          rampClient.launchApp(APP_ID, dialServer);

          // TODO should be async
          Thread.sleep(5 * 1000);
          rampClient.load("http://commondatastorage.googleapis.com/gtv-videos-bucket/big_buck_bunny_1080p.mp4");


          Thread.sleep(10 * 1000);
          rampClient.send("com.entertailion.android.kinect", "\"command\":\"pause\"");

          /*
          Thread.sleep(5 * 1000);
           	  rampClient.send("com.entertailion.android.kinect","\"command\":\"up\"");
           
           Thread.sleep(5 * 1000);
           	  rampClient.send("com.entertailion.android.kinect","\"command\":\"down\"");
           
           Thread.sleep(5 * 1000);
           	  rampClient.send("com.entertailion.android.kinect","\"command\":\"left\"");
           
           Thread.sleep(5 * 1000);
           	  rampClient.send("com.entertailion.android.kinect","\"command\":\"right\"");
           
           Thread.sleep(5 * 1000);
           	  rampClient.send("com.entertailion.android.kinect","\"command\":\"play\"");
           */
        }

        startKinect();
      } 
      catch (InterruptedException e) {
        Log.e(LOG_TAG, "discoverDevices", e);
      }
    }
  }
  ).start();
  return true;
}


public Inet4Address getBroadcastAddress() {
  Inet4Address selectedInetAddress = null;
  try {
    Enumeration<NetworkInterface> list = NetworkInterface
      .getNetworkInterfaces();

    while (list.hasMoreElements ()) {
      NetworkInterface iface = list.nextElement();
      if (iface == null)
        continue;

      if (!iface.isLoopback() && iface.isUp()) {
        Iterator<InterfaceAddress> it = iface
          .getInterfaceAddresses().iterator();
        while (it.hasNext ()) {
          InterfaceAddress interfaceAddress = it.next();
          if (interfaceAddress == null)
            continue;
          InetAddress address = interfaceAddress.getAddress();
          if (address instanceof Inet4Address) {
            if (address.getHostAddress().toString().charAt(0) != '0') {
              InetAddress broadcast = interfaceAddress
                .getBroadcast();
              if (selectedInetAddress == null) {
                selectedInetAddress = (Inet4Address) broadcast;
              } 
              else if (iface.getName().startsWith("wlan")
                || iface.getName().startsWith("en")) { // prefer
                // wlan
                // interface
                selectedInetAddress = (Inet4Address) broadcast;
              }
            }
          }
        }
      }
    }
  } 
  catch (Exception ex) {
  }

  return selectedInetAddress;
}


public Inet4Address getNetworAddress() {
  Inet4Address selectedInetAddress = null;
  try {
    Enumeration<NetworkInterface> list = NetworkInterface
      .getNetworkInterfaces();

    while (list.hasMoreElements ()) {
      NetworkInterface iface = list.nextElement();
      if (iface == null)
        continue;

      if (!iface.isLoopback() && iface.isUp()) {
        Iterator<InterfaceAddress> it = iface
          .getInterfaceAddresses().iterator();
        while (it.hasNext ()) {
          InterfaceAddress interfaceAddress = it.next();
          if (interfaceAddress == null)
            continue;
          InetAddress address = interfaceAddress.getAddress();
          if (address instanceof Inet4Address) {
            if (address.getHostAddress().toString().charAt(0) != '0') {
              InetAddress networkAddress = interfaceAddress
                .getAddress();
              if (selectedInetAddress == null) {
                selectedInetAddress = (Inet4Address) networkAddress;
              } 
              else if (iface.getName().startsWith("wlan")
                || iface.getName().startsWith("en")) { // prefer
                // wlan
                // interface
                selectedInetAddress = (Inet4Address) networkAddress;
              }
            }
          }
        }
      }
    }
  } 
  catch (Exception ex) {
  }

  return selectedInetAddress;
}


