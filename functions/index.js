/* eslint-env node */

/**
 * Import function triggers from their respective submodules:
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// eslint-disable-next-line no-undef
const functions = require("firebase-functions");

// eslint-disable-next-line no-undef
const admin = require("firebase-admin");

// eslint-disable-next-line no-undef
const serviceAccount = require("./firebase-admin.json");

// Initialize Firebase Admin SDK
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

// eslint-disable-next-line no-undef
exports.sendAnnouncementNotification = functions.firestore
    .document("announcements/{announcementId}")
    .onCreate(async (snap, context) => {
        const announcement = snap.data();

        // Ensure title and content exist to avoid issues
        const title = announcement.title || "New Announcement";
        const content = announcement.content || "Check out the latest announcement!"; // Rename this variable

        console.log(`New announcement created with title: ${title}`);

        try {
            // Fetch all users from the "citizens" collection
            const usersSnapshot = await admin.firestore().collection("citizens").get();

            // Collect FCM tokens from users who have one
            const tokens = [];
            usersSnapshot.forEach((doc) => {
                const userData = doc.data();
                if (userData.fcmToken) {
                    tokens.push(userData.fcmToken);
                } else {
                    console.log(`User ${doc.id} does not have an FCM token.`);
                }
            });

            // If there are tokens, proceed to send notifications
            if (tokens.length > 0) {
                const messagePayload = { // Rename this variable to avoid conflict
                    notification: {
                        title: title,
                        body: content, // Use the renamed content variable here
                    },
                    tokens: tokens, // Send to multiple devices
                    data: {
                        announcementId: context.params.announcementId,
                    },
                    android: {
                        priority: "high",
                    },
                    apns: {
                        headers: {
                            "apns-priority": "10",
                        },
                    },
                    webpush: {
                        headers: {
                            Urgency: "high",
                        },
                    },
                };

                try {
                    // Send the notification to all device tokens
                    const response = await admin.messaging().sendEachForMulticast(messagePayload);
                    console.log(
                        `Notifications sent successfully: ${response.successCount} successful, ${response.failureCount} failed.`
                    );
                } catch (error) {
                    console.error("Error sending notifications:", error);
                }
            } else {
                console.log("No valid FCM tokens found.");
            }
        } catch (error) {
            console.error("Error fetching users or sending notifications:", error);
        }
    });

// Helper function to chunk the tokens array into batches of a specific size (e.g., 500)

