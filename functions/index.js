const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Cloud Function to send push notifications
 * Called via HTTPS request from the Flutter app
 */
exports.sendPushNotification = functions.https.onCall(async (data, context) => {
  // Verify the user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to send notifications'
    );
  }

  const { recipientId, title, body, notificationData } = data;

  // Validate input
  if (!recipientId || !title || !body) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required fields: recipientId, title, body'
    );
  }

  try {
    // Get recipient's FCM token from Firestore
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(recipientId)
      .get();

    if (!userDoc.exists) {
      console.log(`User ${recipientId} not found`);
      return { success: false, error: 'User not found' };
    }

    const userData = userDoc.data();
    const fcmToken = userData.fcmToken;

    if (!fcmToken) {
      console.log(`No FCM token for user ${recipientId}`);
      return { success: false, error: 'No FCM token' };
    }

    // Prepare the notification message
    const message = {
      token: fcmToken,
      notification: {
        title: title,
        body: body,
      },
      data: notificationData || {},
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    // Send the notification
    const response = await admin.messaging().send(message);
    console.log('Successfully sent notification:', response);

    return { success: true, messageId: response };
  } catch (error) {
    console.error('Error sending notification:', error);
    
    // Handle invalid token errors
    if (error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered') {
      // Remove invalid token from user document
      await admin.firestore()
        .collection('users')
        .doc(recipientId)
        .update({ fcmToken: admin.firestore.FieldValue.delete() });
      
      return { success: false, error: 'Invalid or expired FCM token' };
    }

    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Cloud Function to send batch notifications
 * Useful for sending to multiple users at once
 */
exports.sendBatchNotifications = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const { recipientIds, title, body, notificationData } = data;

  if (!recipientIds || !Array.isArray(recipientIds) || recipientIds.length === 0) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'recipientIds must be a non-empty array'
    );
  }

  try {
    const results = [];
    
    // Get all user documents
    const userDocs = await Promise.all(
      recipientIds.map(id => 
        admin.firestore().collection('users').doc(id).get()
      )
    );

    // Collect valid FCM tokens
    const tokens = [];
    userDocs.forEach((doc, index) => {
      if (doc.exists && doc.data().fcmToken) {
        tokens.push(doc.data().fcmToken);
      } else {
        results.push({
          recipientId: recipientIds[index],
          success: false,
          error: 'No FCM token'
        });
      }
    });

    if (tokens.length === 0) {
      return { success: false, error: 'No valid FCM tokens found' };
    }

    // Send multicast message
    const message = {
      tokens: tokens,
      notification: {
        title: title,
        body: body,
      },
      data: notificationData || {},
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    
    console.log(`${response.successCount} notifications sent successfully`);
    console.log(`${response.failureCount} notifications failed`);

    return {
      success: true,
      successCount: response.successCount,
      failureCount: response.failureCount,
    };
  } catch (error) {
    console.error('Error sending batch notifications:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});
