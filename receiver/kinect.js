/**
 * Copyright (C) 2013 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * @fileoverview Tic Tac Toe Gameplay with Chromecast
 * This file exposes cast.TicTacToe as an object containing a ChannelHandler
 * and capable of receiving and sending messages to the sender application.
 */

// External namespace for cast specific javascript library
var cast = window.cast || {};

// Anonymous namespace
(function() {
  'use strict';

  Kinect.PROTOCOL = 'com.entertailion.android.kinect';

  function Kinect() {

    this.mChannelHandler =
        new cast.receiver.ChannelHandler('KinectDebug');
    this.mChannelHandler.addEventListener(
        cast.receiver.Channel.EventType.MESSAGE,
        this.onMessage.bind(this));
    this.mChannelHandler.addEventListener(
        cast.receiver.Channel.EventType.OPEN,
        this.onChannelOpened.bind(this));
    this.mChannelHandler.addEventListener(
        cast.receiver.Channel.EventType.CLOSED,
        this.onChannelClosed.bind(this));
  }

  // Adds event listening functions to Kinect.prototype.
  Kinect.prototype = {

    /**
     * Channel opened event; checks number of open channels.
     * @param {event} event the channel open event.
     */
    onChannelOpened: function(event) {
      console.log('onChannelOpened. Total number of channels: ' +
          this.mChannelHandler.getChannels().length);
    },

    /**
     * Channel closed event; if all devices are disconnected,
     * closes the application.
     * @param {event} event the channel close event.
     */
    onChannelClosed: function(event) {
      console.log('onChannelClosed. Total number of channels: ' +
          this.mChannelHandler.getChannels().length);

      if (this.mChannelHandler.getChannels().length == 0) {
        window.close();
      }
    },

    /**
     * Message received event; determines event message and command, and
     * choose function to call based on them.
     * @param {event} event the event to be processed.
     */
    onMessage: function(event) {
      var message = event.message;
      var channel = event.target;
      console.log('********onMessage********' + JSON.stringify(message));
      
      //var status = document.getElementById('title');
      //status.innerHTML = message.command;

      if (message.command == 'play') {
        this.onPlay(channel, message);
      } else if (message.command == 'pause') {
        this.onPause(channel);
      } else if (message.command == 'move') {
        this.onMove(channel, message);
         } else if (message.command == 'up') {
        this.onUp(channel, message);
         } else if (message.command == 'down') {
        this.onDown(channel, message);
         } else if (message.command == 'left') {
        this.onLeft(channel, message);
         } else if (message.command == 'right') {
        this.onRight(channel, message);
      } else {
        cast.log.error('Invalid message command: ' + message.command);
      }
      
      this.broadcast({ event: 'recieved',
          command: message.command
          });
    },

    onPlay: function(channel, message) {
      console.log('****onPlay: ' + JSON.stringify(message));
      
      var video = document.getElementById('vid');
      video.play();
     
    },

    onPause: function(channel) {
      console.log('****onPause');
      
      var video = document.getElementById('vid');
      video.pause();

    },

    onMove: function(channel, message) {
      console.log('****onMove: ' + JSON.stringify(message));
      
      var dx = '+=0px';
      var dy = '+=0px';
      
      var video = document.getElementById('vid');
      if (message.x>0) {
      	dx = '+='+(message.x)+'px';
      } else {
      	dx = '-='+(-message.x)+'px';
      }
      if (message.y>0) {
      	dy = '+='+(message.y)+'px';
      } else {
      	dy = '-='+(-message.y)+'px';
      }
    
      $(video).animate({left:dx, top:dy}, 'fast');
 
    },
    
    onUp: function(channel, message) {
      console.log('****onUp: ' + JSON.stringify(message));
      
      var video = document.getElementById('vid');
      $(video).animate({top:'-=200px'}, 'fast');
 
    },
    
    onDown: function(channel, message) {
      console.log('****onDown: ' + JSON.stringify(message));
      
      var video = document.getElementById('vid');
      $(video).animate({top:'+=200px'}, 'fast');
 
    },
    
    onLeft: function(channel, message) {
      console.log('****onLeft: ' + JSON.stringify(message));
      
      var video = document.getElementById('vid');
      $(video).animate({left:'-=200px'}, 'fast');
 
    },
    
    onRight: function(channel, message) {
      console.log('****onRight: ' + JSON.stringify(message));
      
      var video = document.getElementById('vid');
      $(video).animate({left:'+=200px'}, 'fast');
 
    },
    
    /**
     * Update event: update data
     * as necessary.
     * @param {cast.receiver.channel} channel the source of the move, which
     *     determines the player.
     * @param {Object|string} message contains the row and column of the move.
     */
    onUpdate: function(channel, message) {
      console.log('****onUpdate: ' + JSON.stringify(message));

    },

    /**
     * Broadcasts a message to all of this object's known channels.
     * @param {Object|string} message the message to broadcast.
     */
    broadcast: function(message) {
      this.mChannelHandler.getChannels().forEach(
        function(channel) {
          channel.send(message);
        });
    }

  };

  // Exposes public functions and APIs
  cast.Kinect = Kinect;
})();
