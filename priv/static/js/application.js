(async () => {

    // Start by creating a page to send room name
    // set media after page completes rendering()
    // receive offer or answer
    // receive sdp or ice candidate
    // https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia
    // let mediaConst = {
    //  audio: true,
    //  video: {
    //    width: { ideal: 1280 },
    //    height: { ideal: 720 }
    //  }
    // }
    var mediaConst = { audio: true, video: {frameRate: {ideal: 30}} };
    const offerOptions = {
      offerToReceiveAudio: 1,
      offerToReceiveVideo: 1
    }
    var myUserId = null;
    var extension = null;

    async function createMedia(constraints){
      console.log('setMedia')
      let stream = null

      try {
        stream = await navigator.mediaDevices.getUserMedia(constraints);
        /* use the stream */
        var video = document.getElementById('localVideo');
        video.srcObject = stream;
        video.onloadedmetadata = function(e) {
          video.play();
        };
      } catch(err) {
        /* handle the error */
        console.log('unable to detect camera or meet constraints')
        console.log(err.name + ": " + err.message);
      }
      return stream
    }

    var users = {}
    var localStream = await createMedia(mediaConst)

    function addUserConnection(fromUserId) {
      if (users[fromUserId] === undefined) {
        users[fromUserId] = {
          peerConnection: null
        }
      }

      return users;
    }

    function removeRemoteUserConnection() {
      for (const [fromUserId, peerConnection] of Object.entries(users)) {
        console.log(fromUserId, peerConnection);
        if( document.getElementById(fromUserId) )
          document.getElementById(fromUserId).remove()
        delete users[fromUserId]
      }
    }

    function createPeerConnection(sock, fromUserId, msg) {
      let newPeerConnection = new RTCPeerConnection({
        // using free stun server for dev
        iceServers: [
          { urls: "stun:stun4.l.google.com:19302" }
        ]
      })
      users[fromUserId].peerConnection = newPeerConnection;

      // Add each local track to the RTCPeerConnection.
      localStream.getTracks().forEach(track => newPeerConnection.addTrack(track, localStream))

      // If creating an answer, rather than an initial offer.
      if (msg !== undefined) {
        newPeerConnection.setRemoteDescription(msg)
        newPeerConnection.createAnswer()
          .then((answer) => {
            newPeerConnection.setLocalDescription(answer)
            console.log("Sending this ANSWER to the requester:", answer)

            // Need to send message to server
            var payload = {
              action: "sdp",
              fromUserId: myUserId,
              description: answer
            }
            sock.send(
              JSON.stringify(payload)
            )
          })
          .catch((err) => console.log(err))
      }

      newPeerConnection.onicecandidate = async ({candidate}) => {
        // fromUser is the new value for toUser because we're sending this data back
        // to the sender
        var payload = {
          action: "ice_candidate",
          fromUserId: myUserId,
          candidate
        }
        console.log("Sending ice candidate: ", payload)
        sock.send(
          JSON.stringify(payload)
        )
      }

      // This is called if remote peer joins the same room this peer resides in.
      // Therefore this peer is considered the offerer, starting the process.
      if (msg === undefined) {   
        newPeerConnection.onnegotiationneeded = async () => {
          try {
            newPeerConnection.createOffer(offerOptions)
              .then((sdp) => {
                newPeerConnection.setLocalDescription(sdp)
                console.log("Sending my offer SDP to remote peer:", sdp)
                myUserId = Date.now().toString(36) + Math.random().toString(36).substring(2)
                // socket sends the sdp offer generated from PeerConnectionRTC to other peers
                // 
                var payload = {
                  action: "sdp",
                  fromUserId: myUserId,
                  description: sdp
                }
                sock.send(
                  JSON.stringify(payload)
                )
              })
              .catch((err) => console.log(err))
          }
          catch (error) {
            console.log(error)
          }
        }
      }

      newPeerConnection.addEventListener('track', event => {
        console.log("Track received:", event)
        console.log("stream id", event.streams[0].id)
        if( videoElement = document.getElementById(`video-remote-${fromUserId}`)){
          console.log(`video-remote-${fromUserId} already created.`)
          if (videoElement.srcObject !== event.streams[0]){
            videoElement.srcObject = event.streams[0]
            console.log(`video-remote-${fromUserId} adding another remote stream.`)
          }
        } else {
          console.log(`creating remove video-remote-${fromUserId}`)
          let videoElement = document.createElement("video")
          videoElement.setAttribute("id",`video-remote-${fromUserId}`)
          videoElement.setAttribute("class", "rtcvideo")
          videoElement.setAttribute("autoplay", true)
          videoElement.setAttribute("playsinline", true)
          document.getElementById("remoteLayout").append(videoElement)
          videoElement.srcObject = event.streams[0]
        }
      })

      return newPeerConnection;
    }

    class rtcSocketHandler {
      setupSocket() {
        this.socket = new WebSocket("ws://localhost:1337/ws/signaler")
  
        this.socket.addEventListener("message", (event) => {

          if( event.data === 'ok' ) {
            console.log("Message successfully sent")
            return
          }

          try {
            var payload = JSON.parse(event.data);
          } catch (e) {
            console.log(`${event.data} is not a json format: ${e}`)
            return
          }

          console.log("JSON parsed:", payload)

          var fromUserId = payload.fromUserId
          addUserConnection(fromUserId)

          if (typeof payload.type !== "undefined" && payload.type === 'create_offer'){
            // Tells webrtc to begin with an offer
            createPeerConnection(this.socket, fromUserId)
          } else if (payload.action === 'sdp'){
            // begin the process of PeerConnection creating answer type SDP
            if (payload.description.type === 'offer'){
              createPeerConnection(this.socket, fromUserId, payload.description)
            } else {
              // Received type answer SDP from remote peer. Now digest the SDP.
              let peerConnection = users[fromUserId].peerConnection
              if (payload.description != "") {
                peerConnection.setRemoteDescription(payload.description)
              }
            }
          } else if (payload.action === "ice_candidate") {
            let fromUser = payload.fromUserId
            let peerConnection = users[fromUser].peerConnection      
            peerConnection.addIceCandidate(payload.candidate)
          }
        })
  
        this.socket.addEventListener("close", () => {
          this.setupSocket()
        })
      }
  
      login() {

        const input = document.getElementById("extension")
        extension = input.value
        input.value = ""


        // need to iterate and delete each remote peer
        removeRemoteUserConnection()
        myUserId = Date.now().toString(36) + Math.random().toString(36).substring(2)

        // in the future, add password
        var payload = {
          action: "login",
          extension: extension,
          myUserId: myUserId
        }
        this.socket.send(
          JSON.stringify(payload)
        )
      }

      call() {

        const input = document.getElementById("call")
        const to_extension = input.value
        input.value = ""


        // need to iterate and delete each remote peer
        removeRemoteUserConnection()
        var payload = {
          action: "call",
          to_extension: to_extension,
          from_extension: extension,
          from_user_id: myUserId
        }
        this.socket.send(
          JSON.stringify(payload)
        )
      }

      // sends the room name to join
      // at this point, we are starting clean
      joinChannel() {

        const input = document.getElementById("channel")
        const channel = input.value
        input.value = ""


        // need to iterate and delete each remote peer
        removeRemoteUserConnection()
        var payload = {
          action: "join_channel",
          channel: channel,
          myUserId: myUserId
        }
        this.socket.send(
          JSON.stringify(payload)
        )
      }

      vriPatronCall() {
        removeRemoteUserConnection()
        var payload = {
          action: "vri_call",
          fromUserId: myUserId
        }
        this.socket.send(
          JSON.stringify(payload)
        )
      }

      vriLogin() {
        removeRemoteUserConnection()
        myUserId = Date.now().toString(36) + Math.random().toString(36).substring(2)

        const input = document.getElementById("interpreterUsername")
        const extension = input.value
        input.value = ""

        // in the future, add password
        var payload = {
          action: "vri_login",
          extension: extension,
          myUserId: myUserId
        }

        this.socket.send(
          JSON.stringify(payload)
        )
      }
    }
  
    const rtcSocketClass = new rtcSocketHandler()
    rtcSocketClass.setupSocket()

    document.getElementById("login")
      .addEventListener("click", () => rtcSocketClass.login())
    document.getElementById("rtcChat")
      .addEventListener("click", () => rtcSocketClass.call())
    document.getElementById("vriCall")
      .addEventListener("click", () => rtcSocketClass.vriPatronCall())
    document.getElementById("vriLogin")
      .addEventListener("click", () => rtcSocketClass.vriLogin())
    document.getElementById("submitChannel")
      .addEventListener("click", () => rtcSocketClass.joinChannel())
  }
)()