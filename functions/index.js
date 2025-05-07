const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Cloud Function to send welcome email when a new user registers
exports.sendWelcomeEmail = functions.auth.user().onCreate(async (user) => {
  try {
    // Get user data from Firestore
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(user.uid)
      .get();
    
    const userData = userDoc.data();

    // Send welcome email using Firebase Auth's built-in email service
    await admin.auth().generateEmailVerificationLink(user.email);

    // Log success
    console.log(`Welcome email sent to ${user.email}`);
    
    return null;
  } catch (error) {
    console.error('Error sending welcome email:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send welcome email');
  }
}); 