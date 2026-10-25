import 'routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  await Supabase.initialize(
   url: 'https://rsqagixdvwdgmdtnaiod.supabase.co/',
   publishableKey: 'sb_publishable_zEHBGl0H_No79HT8f1oQ2w_YT-a8pDG',
 );
  runApp(MyApp());
}

class   MyApp extends StatelessWidget {
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
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}