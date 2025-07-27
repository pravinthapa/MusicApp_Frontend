import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  signInWithGoogle() async {
    //begin interactive sign in process
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    //  obtain auth details from request
    final GoogleSignInAuthentication? gAuth = await gUser!.authentication;
    //  create a new credential for the user
    final credential = GoogleAuthProvider.credential(
        accessToken: gAuth!.accessToken, idToken: gAuth.idToken);
    //  finally let's sign in

    final signIn = await FirebaseAuth.instance.signInWithCredential(credential);
    print(gUser.displayName);
    print(FirebaseAuth.instance.currentUser!.email);
    return signIn;
  }
}
