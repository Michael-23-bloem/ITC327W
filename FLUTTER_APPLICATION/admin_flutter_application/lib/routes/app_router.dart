import 'package:go_router/go_router.dart';
import '../views/auth_login_view.dart';
import '../views/owner_dashboard_view.dart';
import '../views/client_analytics_view.dart';
import '../views/decor_upload_item_view.dart';
import '../views/quotation_list_view.dart';
import '../views/quotation_details_view.dart';
import '../views/quotation_edit_view.dart';
import '../views/quotation_eft_validation_view.dart';
import '../views/booking_view.dart';
import '../views/booking_detail_view.dart';
import '../views/booking_progress_update_view.dart';
import '../views/portfolio_upload_event_view.dart';
import '../views/accounts_list_views.dart';
import '../views/accounts_details_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (c, s) => const AuthLoginView()),
    GoRoute(path: '/dashboard', builder: (c, s) =>  OwnerDashboardView()),
    GoRoute(path: '/analytics', builder: (c, s) => const ClientAnalyticsView()),
    GoRoute(path: '/decor/upload', builder: (c, s) =>  DecorUploadItemView()),
    GoRoute(path: '/quotations', builder: (c, s) => const QuotationListView(), routes: [
      GoRoute(path: ':orderId', builder: (c, s) => QuotationDetailView(orderId: s.pathParameters['orderId']!), routes: [
        GoRoute(path: 'edit', builder: (c, s) => QuotationEditView(orderId: s.pathParameters['orderId']!)),
        GoRoute(path: 'validate', builder: (c, s) => ValidatePaymentView(orderId: s.pathParameters['orderId']!)),
      ]),
    ]),
    GoRoute(path: '/bookings', builder: (c, s) => const BookingsView(), routes: [
      GoRoute(path: ':orderId', builder: (c, s) => BookingDetailView(orderId: s.pathParameters['orderId']!), routes: [
        GoRoute(path: 'progress', builder: (c, s) => UpdateProgressView(orderId: s.pathParameters['orderId']!)),
      ]),
    ]),
    GoRoute(path: '/portfolio/upload', builder: (c, s) => const PortfolioUploadEventView()),
    GoRoute(path: '/accounts', builder: (c, s) => const AccountListView(), routes: [
      GoRoute(path: ':userId', builder: (c, s) => AccountDetailView(userId: s.pathParameters['userId']!)),
    ]),
  ],
);