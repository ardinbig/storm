import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:storm/app/app.dart';
import 'package:storm/bootstrap.dart';
import 'package:talker_flutter/talker_flutter.dart';

Future<void> main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  configureDependencies(environment: 'production');

  final talker = getIt<Talker>();

  await bootstrap(() => const App(), talker: talker, tracesSampleRate: 0.2);
}
