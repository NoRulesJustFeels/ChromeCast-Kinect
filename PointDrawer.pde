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

/////////////////////////////////////////////////////////////////////////////////////////////////////
// PointDrawer keeps track of the handpoints

// see http://simple-openni.googlecode.com/svn/trunk/SimpleOpenNI/dist/all/SimpleOpenNI/documentation/SimpleOpenNI/XnVPushDetector.html
class PointDrawer extends XnVPushDetector
{
  HashMap    _pointLists;
  int        _maxPoints;
  color[]    _colorList = { 
    color(255, 0, 0), color(0, 255, 0), color(0, 0, 255), color(255, 255, 0)
  };
  int pushed = 0;
  float lastX = -1; 
  float lastY = -1;
  boolean playing = false;
  long lastTime = 0;

  public PointDrawer()
  {
    _maxPoints = 30;
    _pointLists = new HashMap();

    RegisterPush(this);
  }

  public void OnPointCreate(XnVHandPointContext cxt)
  {
    println("OnPointCreate");
    lastX = -1;
    lastY = -1;
    // create a new list
    addPoint(cxt.getNID(), new PVector(cxt.getPtPosition().getX(), cxt.getPtPosition().getY(), cxt.getPtPosition().getZ()));
  }

  public void OnPointUpdate(XnVHandPointContext cxt)
  {  
    addPoint(cxt.getNID(), new PVector(cxt.getPtPosition().getX(), cxt.getPtPosition().getY(), cxt.getPtPosition().getZ()));
  }

  public void OnPointDestroy(long nID)
  {
    if (_pointLists.containsKey(nID))
      _pointLists.remove(nID);
  }

  void onPush(float vel, float angle) {
    println(">>>>>>>>> PUSH v:" + vel + "a: " + angle);
    pushed = 10;
    if (rampClient!=null) {
      if (playing) {
        rampClient.send("com.entertailion.android.kinect","\"command\":\"pause\"");
        lastX = -1; 
        lastY = -1;
      } else {
         rampClient.send("com.entertailion.android.kinect","\"command\":\"play\"");
      }
      playing = !playing;
    }
  }

  public ArrayList getPointList(long handId)
  {
    ArrayList curList;
    if (_pointLists.containsKey(handId))
      curList = (ArrayList)_pointLists.get(handId);
    else
    {
      curList = new ArrayList(_maxPoints);
      _pointLists.put(handId, curList);
    }
    return curList;
  }

  public void addPoint(long handId, PVector handPoint)
  {
    ArrayList curList = getPointList(handId);

    curList.add(0, handPoint);      
    if (curList.size() > _maxPoints)
      curList.remove(curList.size() - 1);
  }

  public void draw()
  {
   
    if (_pointLists.size() <= 0)
      return;

    pushStyle();
    noFill();

    PVector vec;
    PVector firstVec;
    PVector screenPos = new PVector();
    int colorIndex=0;

    // draw the hand lists
    Iterator<Map.Entry> itrList = _pointLists.entrySet().iterator();
    while (itrList.hasNext ()) 
    {
      strokeWeight(2);
      stroke(_colorList[colorIndex % (_colorList.length - 1)]);

      ArrayList curList = (ArrayList)itrList.next().getValue();     

      // draw line
      firstVec = null;
      Iterator<PVector> itr = curList.iterator();
      beginShape();
      while (itr.hasNext ()) 
      {
        vec = itr.next();
        if (firstVec == null)
          firstVec = vec;
        // calc the screen pos
        context.convertRealWorldToProjective(vec, screenPos);
        vertex(screenPos.x, screenPos.y);
      } 
      endShape();   

      // draw current pos of the hand
      if (firstVec != null)
      {
        strokeWeight(8);
        context.convertRealWorldToProjective(firstVec, screenPos);
        point(screenPos.x, screenPos.y);

        if (pushed > 0) {
          rect(screenPos.x, screenPos.y, 10, 10);
          pushed --;
        }
        //println("x="+screenPos.x+" y="+screenPos.y);
        long currentTime = System.currentTimeMillis();
        if (currentTime-lastTime>200) {
        if (rampClient!=null && !playing) {
          // map Kinect 640x480 resolution to TV resolution
          float dx = screenPos.x/(1280.0f/2);
          float dy = screenPos.y/(720.0f/2);
          
          if (lastX==-1 && lastY==-1) {
            float mx = 1280*dx;
            float my = 720*dy;
            mx = 1280/2;
            my = 720/2;

            lastX = mx;
            lastY = my;
          } else {
            float mx = 1280*dx;
            float my = 720*dy;
            int sx = (int)(mx-lastX);
            int sy = (int)(my-lastY);
            if (sx!=0 && sy!=0) {
              rampClient.send("com.entertailion.android.kinect","\"command\":\"move\", \"x\":"+sx+", \"y\":"+sy+"");
            }
            println("dx="+sx+", dy="+sy);
            lastX = mx;
            lastY = my;
          }
         
        }
        lastTime = currentTime;
      }
      
      }
      colorIndex++;
    }

    popStyle();
  }
}

