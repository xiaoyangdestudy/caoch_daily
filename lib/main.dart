import 'package:caoch_daily/app/app.dart';
import 'package:caoch_daily/app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const LifeCoachApp());
}
