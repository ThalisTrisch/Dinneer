import * as admin from 'firebase-admin';
import * as path from 'path';

let initialized = false;

export function getFirebaseAdmin(): admin.app.App {
  if (!initialized) {
    const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
    if (!serviceAccountPath) {
      throw new Error('FIREBASE_SERVICE_ACCOUNT_PATH não configurado no .env');
    }

    admin.initializeApp({
      credential: admin.credential.cert(path.resolve(serviceAccountPath)),
      databaseURL: 'https://dinneer-19ada-default-rtdb.firebaseio.com',
    });

    initialized = true;
  }
  return admin.app();
}
