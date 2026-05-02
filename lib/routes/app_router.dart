import 'package:flutter/material.dart';
import 'package:music_app/features/song/presentation/admin/pages/manage_songs_page.dart';
import 'package:provider/provider.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/admin/presentation/pages/admin_page.dart';
import '../features/artist/presentation/admin/presentation/pages/manage_artists_page.dart';
import '../features/artist/presentation/user/pages/artist_detail_page.dart';
import '../features/artist/presentation/user/providers/artist_viewer_provider.dart';
import '../features/song/presentation/user/pages/home_page.dart';
import '../injection_container.dart' as di;

class AppRouter {
  static Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case '/admin':
        return MaterialPageRoute(builder: (_) => const AdminPage());

      case '/admin/artists':
        return MaterialPageRoute(builder: (_) => const ManageArtistsPage());
      case '/admin/songs':
        return MaterialPageRoute(builder: (_) => const ManageSongsPage());
      // ✅ HOME FIXED
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());

      // ✅ ARTIST DETAIL
      case '/artist':
        final artistId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => di.sl<ArtistViewerProvider>(),
            child: ArtistDetailPage(artistId: artistId),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }
}
