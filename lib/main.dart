import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'features/auth/auth_provider.dart';
import 'features/shared/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/otp_screen.dart';
import 'features/auth/role_selection_screen.dart';
import 'features/auth/kyc_screen.dart';
import 'features/gig_worker/worker_home_screen.dart';
import 'features/gig_worker/ongoing_gig_screen.dart';
import 'features/gig_worker/task_details_screen.dart';
import 'features/gig_worker/worker_profile_screen.dart';
import 'features/employer/employer_home_screen.dart';
import 'features/employer/manage_gigs_screen.dart';
import 'features/employer/employer_profile_screen.dart';
import 'features/auth/employer_kyc_screen.dart'; // Import this
import 'features/shared/chat_list_screen.dart';
import 'features/employer/create_gig/create_gig_screen.dart';
import 'features/gig_worker/work_list_screen.dart';
import 'features/gig_worker/active_gig_screen.dart';
import 'features/employer/live_gig_tracking_screen.dart';
import 'features/admin/admin_dashboard.dart';
import 'models/task_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Ensure Supabase is imported if used directly or via service
import 'services/supabase_service.dart';
import 'services/api_service.dart';
import 'data/repositories/task_repository.dart';
import 'data/repositories/api_task_repository.dart';
import 'data/repositories/api_wallet_repository.dart';
import 'data/repositories/wallet_repository.dart';
import 'features/wallet/wallet_screen.dart';
import 'data/repositories/api_chat_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'features/chat/chat_screen.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/review_repository.dart';
import 'features/shared/notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService().initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider<TaskRepository>(
          create: (_) => ApiTaskRepository(),
        ),
        Provider<WalletRepository>(
          create: (_) => ApiWalletRepository(),
        ),
        Provider<ChatRepository>(
          create: (_) => ApiChatRepository(),
        ),
        Provider<NotificationRepository>(
          create: (_) => ApiNotificationRepository(ApiService()),
        ),
        Provider<ReviewRepository>(
          create: (_) => ApiReviewRepository(ApiService()),
        ),
      ],

      child: const ZiggersApp(),
    ),
  );
}

class ZiggersApp extends StatefulWidget {
  const ZiggersApp({super.key});

  @override
  State<ZiggersApp> createState() => _ZiggersAppState();
}

class _ZiggersAppState extends State<ZiggersApp> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    
    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      debugLogDiagnostics: true,
      errorBuilder: (context, state) => const Error404Screen(),
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoggingIn = state.uri.toString() == '/login' || 
                            state.uri.toString() == '/otp' ||
                            state.uri.toString() == '/'; // Splash
        
        // 1. Not Logs -> Login
        if (!isLoggedIn) {
          // Allow splash, login, otp
          if (state.uri.toString() == '/' && authProvider.isLoading) return null; // Stay on splash if loading
          if (state.uri.toString() == '/login') return null;
          if (state.uri.toString().startsWith('/otp')) return null;
          return '/login'; // Redirect to login
        }

        // 2. Logged In -> Check Role
        final role = authProvider.role;
        if (role == null || role == 'user') {
          if (state.uri.toString() == '/role-selection') return null;
          return '/role-selection';
        }

        // 3. Role Selected -> Check KYC (Allow Pending to proceed)
        if (role != 'admin' && !authProvider.isKycApproved && authProvider.userProfile?.kycStatus != 'pending') {
             // Worker
             if (role == 'worker') {
                if (state.uri.toString() == '/worker-kyc') return null;
                return '/worker-kyc';
             }
             // Employer
             if (role == 'employer') {
                if (state.uri.toString() == '/employer-kyc') return null;
                return '/employer-kyc';
             }
        }

        // 4. Everything Good -> Home
        if (isLoggingIn || 
            state.uri.toString() == '/role-selection' || 
            state.uri.toString() == '/worker-kyc' ||
            state.uri.toString() == '/employer-kyc') {
            
            if (role == 'worker') return '/worker/home';
            if (role == 'employer') return '/employer/home';
            if (role == 'admin') return '/admin/dashboard';
        }

        // Allow navigation
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/otp',
          builder: (context, state) {
            final phone = state.extra as String? ?? '';
            return OtpScreen(phoneNumber: phone);
          },
        ),
        GoRoute(
          path: '/role-selection',
          builder: (context, state) => const RoleSelectionScreen(),
        ),
        GoRoute(
          path: '/worker/home',
          builder: (context, state) => const WorkerHomeScreen(),
        ),
        GoRoute(
          path: '/worker-kyc',
          builder: (context, state) => const KycScreen(),
        ),
        GoRoute(
          path: '/employer-kyc',
          builder: (context, state) => const EmployerKycScreen(),
        ),
        GoRoute(
          path: '/worker/jobs',
          builder: (context, state) => const WorkListScreen(),
        ),
        GoRoute(
          path: '/worker/task-details',
          builder: (context, state) {
            final task = state.extra as Task;
            return TaskDetailsScreen(task: task);
          },
        ),
        GoRoute(
          path: '/worker/profile',
          builder: (context, state) => const WorkerProfileScreen(),
        ),
        GoRoute(
          path: '/employer/home',
          builder: (context, state) => const EmployerHomeScreen(),
        ),
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/employer/create-gig',
          builder: (context, state) => const CreateGigScreen(),
        ),
        GoRoute(
          path: '/employer/manage-gigs',
          builder: (context, state) => const EmployerManageGigsScreen(),
        ),
        GoRoute(
          path: '/employer/profile',
          builder: (context, state) => const EmployerProfileScreen(),
        ),
        GoRoute(
          path: '/chats',
          builder: (context, state) => const ChatListScreen(),
        ),
        GoRoute(
          path: '/active-gig',
          builder: (context, state) {
             final task = state.extra as Task;
             return ActiveGigScreen(task: task);
          },
        ),
        GoRoute(
          path: '/live-gig-tracking',
          builder: (context, state) {
            final task = state.extra as Task;
            return LiveGigTrackingScreen(task: task);
          },
        ),
        GoRoute(
          path: '/wallet',
          builder: (context, state) => const WalletScreen(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) {
            final extras = state.extra as Map<String, dynamic>;
            return ChatScreen(taskId: extras['taskId'], chatTitle: extras['title']);
          },
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/worker/ongoing-gig',
          builder: (context, state) {
             // For now, pass mock data or retrieve from state/extra
             // Ideally this comes from state management or arguments
             final mockData = {
               'title': 'Retail Store Assistant',
               'employer': 'Zara Pvt Ltd',
               'address': '123 Fashion Street',
               'location': {'lat': 37.7749, 'lng': -122.4194},
             };
             return OngoingGigScreen(gigData: mockData);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ziggers',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class Error404Screen extends StatelessWidget {
  const Error404Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(child: Text('404 - Page Not Found')),
    );
  }
}
