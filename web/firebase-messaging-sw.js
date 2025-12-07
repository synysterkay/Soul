importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyB1j8XhqSAYw_7nvtbzYCrVz7xqmqVrT0E",
  authDomain: "soulplan-dateplanner.firebaseapp.com",
  projectId: "soulplan-dateplanner",
  storageBucket: "soulplan-dateplanner.firebasestorage.app",
  messagingSenderId: "543297399935",
  appId: "1:543297399935:web:faa75f23e90f0e51d06eaf",
  measurementId: "G-WKM40C8PM6"
});

const messaging = firebase.messaging();

// Optional: Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
