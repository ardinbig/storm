import 'package:storm/app/app.dart';
import 'package:storm/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
