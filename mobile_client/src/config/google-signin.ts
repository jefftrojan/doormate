import { GoogleSignin } from '@react-native-google-signin/google-signin';

export const configureGoogleSignIn = () => {
  GoogleSignin.configure({
    webClientId: 'YOUR_WEB_CLIENT_ID', // Get this from Google Cloud Console
    iosClientId: 'YOUR_IOS_CLIENT_ID', // Get this from Google Cloud Console
  });
};