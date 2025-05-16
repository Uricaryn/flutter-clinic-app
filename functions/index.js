const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Super admin oluşturma fonksiyonu
exports.createSuperAdmin = functions.https.onCall(async (data, context) => {
  try {
    const { email, password } = data;

    // Email ve şifre kontrolü
    if (!email || !password) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Email and password are required'
      );
    }

    // Kullanıcıyı oluştur
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      emailVerified: true,
    });

    // Firestore'da kullanıcı dokümanını oluştur
    await admin.firestore().collection('users').doc(userRecord.uid).set({
      email: email,
      role: 'super_admin',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
    });

    return {
      success: true,
      message: 'Super admin created successfully',
      uid: userRecord.uid
    };
  } catch (error) {
    console.error('Error creating super admin:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Test verilerini oluşturmak için HTTP fonksiyonu
exports.createTestData = functions.https.onCall(async (data, context) => {
  try {
    // Kullanıcının admin olduğunu kontrol et
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const userDoc = await admin.firestore()
      .collection('users')
      .doc(context.auth.uid)
      .get();
    
    const userData = userDoc.data();
    if (!userData || userData.role !== 'super_admin') {
      throw new functions.https.HttpsError('permission-denied', 'User must be a super admin');
    }

    // Departmanları oluştur
    const departments = [
      {
        name: 'Cardiology',
        description: 'Heart and cardiovascular system care',
        isActive: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {
        name: 'Neurology',
        description: 'Brain and nervous system care',
        isActive: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {
        name: 'Pediatrics',
        description: 'Children\'s health care',
        isActive: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      },
    ];

    for (const dept of departments) {
      await admin.firestore().collection('departments').add(dept);
    }

    // Doktorları oluştur
    const doctors = [
      {
        fullName: 'Dr. John Smith',
        email: 'john.smith@clinic.com',
        department: 'Cardiology',
        specialization: 'Cardiologist',
        isActive: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {
        fullName: 'Dr. Sarah Johnson',
        email: 'sarah.johnson@clinic.com',
        department: 'Neurology',
        specialization: 'Neurologist',
        isActive: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {
        fullName: 'Dr. Michael Brown',
        email: 'michael.brown@clinic.com',
        department: 'Pediatrics',
        specialization: 'Pediatrician',
        isActive: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      },
    ];

    for (const doctor of doctors) {
      await admin.firestore().collection('doctors').add(doctor);
    }

    // Hastaları oluştur
    const patients = [
      {
        fullName: 'Alice Wilson',
        email: 'alice.wilson@example.com',
        phone: '+1234567890',
        dateOfBirth: new Date(1990, 5, 15),
        gender: 'Female',
        isActive: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {
        fullName: 'Bob Thompson',
        email: 'bob.thompson@example.com',
        phone: '+1987654321',
        dateOfBirth: new Date(1985, 8, 22),
        gender: 'Male',
        isActive: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {
        fullName: 'Carol Martinez',
        email: 'carol.martinez@example.com',
        phone: '+1122334455',
        dateOfBirth: new Date(1995, 3, 10),
        gender: 'Female',
        isActive: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      },
    ];

    for (const patient of patients) {
      await admin.firestore().collection('patients').add(patient);
    }

    return { success: true, message: 'Test data created successfully' };
  } catch (error) {
    console.error('Error creating test data:', error);
    throw new functions.https.HttpsError('internal', 'Failed to create test data');
  }
}); 