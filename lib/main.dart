import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:young_care/app/common/main_binding.dart';
import 'package:young_care/app/common/widgets/bluetooth_connection_banner.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );

  runApp(
    GetMaterialApp(
      title: "Young Care",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: MainBinding(),
      builder: (context, child) =>
          BluetoothConnectionBanner(child: child),
    ),
  );
}
