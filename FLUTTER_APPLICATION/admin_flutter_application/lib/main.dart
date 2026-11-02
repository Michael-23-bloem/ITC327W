import 'routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/akea_theme.dart';
import 'viewmodels/user_viewmodel.dart';
import 'viewmodels/order_viewmodel.dart';
import 'viewmodels/decor_product_viewmodel.dart';
import 'viewmodels/portfolio_viewmodel.dart';
import 'viewmodels/order_item_viewmodel.dart';
import 'viewmodels/package_viewmodel.dart';
import 'viewmodels/contact_enquiry_viewmodel.dart';
import 'viewmodels/user_login_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabasePublishableKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'];
  if (supabaseUrl == null || supabasePublishableKey == null) {
    throw StateError(
      'SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY must be set in .env',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => UserLoginViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
        ChangeNotifierProvider(create: (_) => DecorProductViewModel()),
        ChangeNotifierProvider(create: (_) => PortfolioViewModel()),
        ChangeNotifierProvider(create: (_) => OrderItemViewModel()),
        ChangeNotifierProvider(create: (_) => PackageViewModel()),
        ChangeNotifierProvider(create: (_) => ContactEnquiryViewModel()),
      ],
      child: MaterialApp.router(
        title: 'AkeaEvents Admin',
        theme: AkeaTheme.light(),
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
