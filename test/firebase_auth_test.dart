import 'package:firedart/firedart.dart';
import 'package:test/test.dart';

import 'test_config.dart';

Future main() async {
  TokenStore tokenStore;
  FirebaseAuth auth;

  setUp(() {
    tokenStore = VolatileStore();
    auth = FirebaseAuth(apiKey, tokenStore);
  });

  test('Sign In', () async {
    expect(auth.isSignedIn, false);
    await auth.signIn(email, password);
    expect(auth.isSignedIn, true);
    auth.signOut();
    expect(auth.isSignedIn, false);
  });

  test('Get user on signin', () async {
    var user = await auth.signIn(email, password);
    expect(user.email, email);
  });

  test('Get user id', () async {
    await auth.signIn(email, password);
    expect(auth.userId, isNotEmpty);
  });

  test('Get user', () async {
    await auth.signIn(email, password);
    var user = await auth.getUser();
    expect(user.email, email);
  });

  test('Refresh token when expired', () async {
    await auth.signIn(email, password);
    tokenStore.expireToken();
    var user = await auth.getUser();
    expect(user.email, isNotEmpty);
    expect(auth.isSignedIn, true);
  });

  test('Sign out on bad refresh token', () async {
    await auth.signIn(email, password);
    tokenStore.setToken('user_id', 'bad_token', 'bad_token', 0);
    await expectLater(auth.getUser(), throwsNoSuchMethodError);
    expect(auth.isSignedIn, false);
  });

  test('Emit signedIn events', () async {
    var stream = auth.signInState;
    var expect = expectLater(
        stream,
        emitsInOrder([
          (isSignedIn) => isSignedIn == true,
          (isSignedIn) => isSignedIn == false,
        ]));
    await auth.signIn(email, password);
    auth.signOut();
    await expect;
  });
}
