ChromeCast-Kinect
=================

<p>ChromeCast-Kinect allows you to control your ChromeCast device with a <a href="http://www.xbox.com/en-US/KINECT">Kinect</a> sensor.
You need a computer and a Microsoft Kinect sensor with a power adapter.</p>

<p>ChromeCast-Kinect is based on the <a href="https://code.google.com/p/simple-openni/">simple OpenNI wrapper</a> for <a href="http://processing.org/download/">Processing</a>.
Follow the <a href="https://code.google.com/p/simple-openni/wiki/Installation">installation instructions</a> for your operating system.
Download a copy of ChromeCast-Kinect and open the ChromeCastKinect.pde file in the Processing development environment.
</p>

<p>There is a dependency on a web app that needs to be <a href="https://developers.google.com/cast/whitelisting#whitelist-receiver">registered with Google</a>, so currently this solution will only work for ChromeCast developers until Google opens up their ChromeCast developer program.
You need to put your own app ID in the ChromeCastKinect.pde and receiver index.html files. </p>

<p>When you run ChromeCast-Kinect, it requires that you enter the IP address of the ChromeCast device you want to control. 
Once that is entered and the connection made, you need to do the surrendering pose (aka stand like a cactus) for calibration. 
When the calibration is done you will see a skeleton line figure. You can drop both hands now.
Lift up one hand and wave it until you see red dots. Now everything is ready to control your ChromeCast.
</p>

<p>There are two files that can be customized for gestures:
<ol>
<li>PointDrawer.pde: Logic for handling push gestures to play/pause video and to move the video (move works when the video is paused).</li>
<li>SwipeDetector.pde: Move the video up/down/left/right incrementally by using both hands for gestures (disabled in the code).</li>
</ol></p>

<p>The mapping of hand movements to screen positioning is very primitive and you might get into a situation where the location you want to reach on the screen is out of reach.
You can reset the pointer position by dropping your hand and then lifting it up again. </p>

<p>Watch this <a href="http://youtu.be/1xOWOPfRfrQ">video</a> to see ChromeCast-Kinect in action.</p>

<p>References:
<ul>
<li><a href="http://www.openni.org/">OpenNI</a></li>
<li><a href="http://www.primesense.com/?p=515">NITE</a></li>
<li><a href="http://kinectcar.ronsper.com/docs/nite/index.html">NITE API Reference</a></li>
<li><a href="http://simple-openni.googlecode.com/svn/trunk/SimpleOpenNI/dist/all/SimpleOpenNI/documentation/index.html">Simple OpenNI Java Docs</a></li>
<li><a href="https://developers.google.com/cast/">Google Cast</a></li>
<li><a href="https://github.com/entertailion/DIAL">DIAL Android app</a></li>
<li><a href="https://github.com/entertailion/Gesture-TV">Control your Google TV with Kinect gestures</a></li>
</ul>
</p>

<p>Other apps developed by Entertailion:
<ul>
<li><a href="https://play.google.com/store/apps/details?id=com.entertailion.android.tvremote">Able Remote for Google TV</a>: The ultimate Google TV remote</li>
<li><a href="https://play.google.com/store/apps/details?id=com.entertailion.android.launcher">Open Launcher for Google TV</a>: The ultimate Google TV launcher</li>
<li><a href="https://play.google.com/store/apps/details?id=com.entertailion.android.overlay">Overlay for Google TV</a>: Live TV effects for Google TV</li>
<li><a href="https://play.google.com/store/apps/details?id=com.entertailion.android.overlaynews">Overlay News for Google TV</a>: News headlines over live TV</li>
<li><a href="https://play.google.com/store/apps/details?id=com.entertailion.android.videowall">Video Wall</a>: Wall-to-Wall Youtube videos</li>
<li><a href="https://play.google.com/store/apps/details?id=com.entertailion.android.tasker">GTV Tasker Plugin</a>: Control your Google TV with Tasker actions</li>
</ul>
</p>