import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/widgets/widgets.dart';
import 'config/routes/router.dart';
import 'features/auth/controller/auth_controller.dart';
import 'features/landing/screens/landing_screen.dart';
import 'firebase_options.dart';
import 'screens/screen.dart';
import 'utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatApp Uc',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          color: appBarColor,
        ),
      ),
      onGenerateRoute: (settings) => generateRoute(settings),
      home: ref.watch(userDataAuthProvider).when(
            data: (user) {
              ///user.id si şuysa buraya buysa buraya yönlendir yapabilirim burda
              if (user == null) {
                return const LandingScreen();
              }
              return const MobileLayoutScreen();
            },
            error: (err, trace) {
              return ErrorScreen(error: err.toString());
            },
            loading: () => const Loader(),
          ),
      // const LandingScreen()
      // const ResponsiveLayout(
      //   mobileScreenLayout: MobileChatScreen(),
      //   webScreenLayout: WebLayoutScreen(),
      // ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


/*
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end

flutter_sound: ^9.2.13
permission_handler: ^10.2.0

    config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] || =
      '$(inherited)'
      'PERMISSION_MICROPHONE=1',



    target.build_configuration.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] || =[
      '$(inherited)'
      'PERMISSION_MICROPHONE=1',

      ]
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end


///bunu kullanınca paketlerin hepsini 11den başlasın demektir
      post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
              end
          end
  end
end
    
*/