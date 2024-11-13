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
        const title = announcement.title || "New Announcement";
        const content = announcement.content || "Check out the latest announcement!";

        console.log(`New announcement created with title: ${title}`);
        console.log(`Announcement content: ${content}`);

        // Initialize arrays to hold FCM tokens from both collections
        let tokens = [];

        try {
            // Fetch FCM tokens from responders collection
            const respondersSnapshot = await admin.firestore().collection("responders").get();
            respondersSnapshot.forEach(doc => {
                const fcmtoken = doc.data().fcmToken;
                if (fcmtoken) tokens.push(fcmtoken); // Only add if the token exists
            });

            // Fetch FCM tokens from citizens collection
            const citizensSnapshot = await admin.firestore().collection("citizens").get();
            citizensSnapshot.forEach(doc => {
                const fcmtoken = doc.data().fcmToken;
                if (fcmtoken) tokens.push(fcmtoken); // Only add if the token exists
            });

            // Check if there are any tokens to send notifications to
            if (tokens.length > 0) {
                console.log("Preparing to send notification with the following payload:", {
                    title,
                    content,
                    announcementId: context.params.announcementId
                });

                const messagePayload = {
                    notification: {
                        title: title,
                        body: content,
                    },
                    data: {
                        type: "main",
                        announcementId: context.params.announcementId,
                    },
                    android: {
                        priority: "high", // High priority for immediate delivery
                        notification: {
                            sound: "emergencynotifsound",  // Use the custom sound file
                            channelId: "emergency_channel",  // Ensure this channel is set up on Android
                        }
                    },
                    webpush: {
                        headers: {
                            Urgency: "high",  // Ensures high priority for web notifications
                        }
                    },
                };

                // Send notifications to all valid tokens
                const responses = await Promise.all(tokens.map(token =>
                    admin.messaging().send({ ...messagePayload, token })
                ));

                console.log("Notification sent successfully to tokens:", responses);
            } else {
                console.log("No valid FCM tokens found.");
            }
        } catch (error) {
            console.error("Error sending notifications:", error);
        }
    });



// Helper function to chunk the tokens array into batches of a specific size (e.g., 500)



// New SOS notification function

// eslint-disable-next-line no-undef
exports.sendSOSNotification = functions.firestore
    .document('citizens/{userId}/sos_requests/{sosId}')
    .onCreate(async (snap, context) => {
        // const sosData = snap.data();
        const userId = context.params.userId;

        // Retrieve the main citizen document to get displayName and friends list
        const userDoc = await admin.firestore().collection('citizens').doc(userId).get();

        if (!userDoc.exists) {
            console.error(`User document for userId ${userId} does not exist.`);
            return;
        }

        const userData = userDoc.data();
        const displayName = userData.displayName || "A friend";
        const friendIds = userData.friends || [];

        try {
            let friendTokens = [];

            for (const friendId of friendIds) {
                const friendDoc = await admin.firestore().collection('citizens').doc(friendId).get();
                const friendData = friendDoc.data();

                if (friendData && friendData.fcmToken) {
                    friendTokens.push(friendData.fcmToken);
                } else {
                    console.log(`Friend ${friendId} does not have an FCM token.`);
                }
            }

            if (friendTokens.length > 0) {
                const sosMessagePayload = {
                    notification: {
                        title: "SOS Alert!",
                        body: `${displayName} sent an SOS alert. Please check on them.`,
                    },
                    data: {
                        type: "secondary",
                        sosId: context.params.sosId,
                    },
                    android: {
                        priority: "high",
                        notification: {
                            sound: "emergencynotifsound",
                            channelId: "emergency_channel",
                        }
                    },
                    webpush: {
                        headers: {
                            Urgency: "high",
                        }
                    },
                };

                // Send notifications to each token individually
                const responses = await Promise.all(friendTokens.map(token =>
                    admin.messaging().send({ ...sosMessagePayload, token })
                ));

                console.log(`SOS notifications sent. Success count: ${responses.length}`);
            } else {
                console.log("No valid FCM tokens found for friends.");
            }
        } catch (error) {
            console.error("Error sending SOS notifications:", error);
        }
    });


// eslint-disable-next-line no-undef
exports.sendReportNotification = functions.firestore
    .document("reports/{reportId}")
    .onCreate(async (snap, context) => {
        const report = snap.data();

        // Set title based on incidentType, with a fallback
        const title = report.incidentType || "New Report Submitted";

        // Limit content description to 30 characters
        const maxDescriptionLength = 30;
        let content = report.description || "A new report has been submitted. Please review it.";
        if (content.length > maxDescriptionLength) {
            content = content.substring(0, maxDescriptionLength) + "...";
        }

        console.log(`New report created with title: ${title}`);

        try {
            // Collect FCM tokens from both "responders" and "operator" collections
            let tokens = [];

            // Fetch FCM tokens from responders collection
            const respondersSnapshot = await admin.firestore().collection("responders").get();
            respondersSnapshot.forEach((doc) => {
                const userData = doc.data();
                if (userData.fcmToken) {
                    tokens.push(userData.fcmToken);
                }
            });

            // Fetch FCM tokens from operators collection
            const operatorsSnapshot = await admin.firestore().collection("operator").get();
            operatorsSnapshot.forEach((doc) => {
                const userData = doc.data();
                if (userData.fcmToken) {
                    tokens.push(userData.fcmToken);
                }
            });

            // Check if there are tokens to send notifications
            if (tokens.length > 0) {
                console.log("Preparing to send notification with the following payload:", {
                    title,
                    content,
                    reportId: context.params.reportId,
                });

                const messagePayload = {
                    notification: {
                        title: title,
                        body: content,
                    },
                    data: {
                        reportId: context.params.reportId,
                    },
                    android: {
                        priority: "high",
                        notification: {
                            sound: "emergencynotifsound",  // Custom sound file for emergency notifications
                            channelId: "emergency_channel",  // Ensure this channel is set up on Android
                        }
                    },
                    webpush: {
                        headers: {
                            Urgency: "high",
                        }
                    }
                };

                // Send notifications to each token
                const responses = await Promise.all(tokens.map(token =>
                    admin.messaging().send({ ...messagePayload, token })
                ));

                console.log(`Report notifications sent successfully to ${responses.length} tokens.`);
            } else {
                console.log("No valid FCM tokens found for responders or operators.");
            }
        } catch (error) {
            console.error("Error fetching users or sending report notifications:", error);
        }
    });



// eslint-disable-next-line no-undef
exports.sendChatMessageNotification = functions.firestore
    .document("chats/{chatId}/messages/{messageId}")
    .onCreate(async (snap, context) => {
        const message = snap.data();
        const chatId = context.params.chatId;

        // Get the chat document to retrieve participants and chat_name
        const chatDoc = await admin.firestore().collection("chats").doc(chatId).get();
        const chatData = chatDoc.data();

        const title = chatData.chat_name || "New Message";
        const maxMessageLength = 30;
        let body = `${message.displayName}: ${message.message}`;
        if (body.length > maxMessageLength) {
            body = body.substring(0, maxMessageLength) + "...";
        }

        const participants = chatData.participants || [];

        try {
            const tokens = [];
            for (const participantRef of participants) {
                const participantSnapshot = await participantRef.get();
                const participantData = participantSnapshot.data();
                if (participantData && participantData.fcmToken) {
                    tokens.push(participantData.fcmToken);
                }
            }

            if (tokens.length > 0) {
                const messagePayload = {
                    notification: {
                        title: title,
                        body: body,
                    },
                    data: {
                        type: "secondary",
                        chatId: chatId,
                        messageId: context.params.messageId,
                    },
                    android: {
                        priority: "high",
                        notification: {
                            sound: "chatsound",
                            channelId: "chat_channel",
                        },
                    },
                    webpush: {
                        headers: {
                            Urgency: "high",
                        },
                    },
                };

                try {

                    await Promise.all(tokens.map(token =>
                        admin.messaging().send({ ...messagePayload, token })
                    ));
                    console.log(
                        `Chat message notifications sent successfully. Tokens notified: ${tokens.length}`
                    );
                } catch (error) {
                    console.error("Error sending chat message notifications:", error);
                }
            } else {
                console.log("No valid FCM tokens found for participants.");
            }
        } catch (error) {
            console.error("Error fetching participants or sending notifications:", error);
        }
    });


// eslint-disable-next-line no-undef
exports.createResponderAccount = functions.https.onCall(async (data) => {
    const { email, password, displayName } = data;

    try {
        const userRecord = await admin.auth().createUser({
            email,
            password,
            displayName,

        });

        await admin.firestore().collection("responders").doc(userRecord.uid).set({
            uid: userRecord.uid,
            email,
            displayName,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            address: '',
            type: 'Responder',
            status: 'Activated',
        });

        return { success: true, uid: userRecord.uid };
    } catch (error) {
        throw new functions.https.HttpsError("unknown", error.message);
    }
});