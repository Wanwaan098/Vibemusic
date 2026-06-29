import 'package:flutter/material.dart';
import 'package:music_app/features/song/presentation/admin/pages/manage_songs_page.dart';
import 'package:music_app/features/song/presentation/admin/providers/song_manager_provider.dart';
import 'package:music_app/features/album/presentation/pages/manage_albums_page.dart';
import 'package:music_app/features/album/presentation/providers/album_provider.dart';
import 'package:music_app/features/playlist/presentation/pages/manage_system_playlists_page.dart';
import 'package:music_app/features/playlist/presentation/pages/system_playlist_detail_page.dart';
import 'package:music_app/features/playlist/presentation/providers/system_playlist_provider.dart';
import 'package:music_app/features/search/presentation/pages/search_page.dart';
import 'package:music_app/features/search/presentation/providers/search_provider.dart';
import 'package:provider/provider.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/profile_page.dart';
import '../features/admin/presentation/pages/admin_page.dart';
import '../features/artist/presentation/admin/presentation/pages/manage_artists_page.dart';
import '../features/artist/presentation/admin/presentation/providers/artist_manager_provider.dart';
import '../features/artist/presentation/user/pages/artist_detail_page.dart';
import '../features/artist/presentation/user/providers/artist_viewer_provider.dart';
import '../features/favorite/presentation/pages/favorites_page.dart';
import '../features/favorite/presentation/providers/favorite_provider.dart';
import '../features/playlist/presentation/pages/playlists_page.dart';
import '../features/playlist/presentation/providers/playlist_provider.dart';
import '../features/song/presentation/user/pages/home_page.dart';
import '../features/song/presentation/user/providers/song_provider.dart';
import '../injection_container.dart' as di;

class AppRouter {
  static Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      case '/admin':
        return MaterialPageRoute(builder: (_) => const AdminPage());

      case '/admin/artists':
        return MaterialPageRoute(builder: (_) => const ManageArtistsPage());

      case '/admin/songs':
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => di.sl<SongManagerProvider>(),
              ),
              ChangeNotifierProvider(create: (_) => di.sl<AlbumProvider>()),
              ChangeNotifierProvider(
                create: (_) => di.sl<ArtistManagerProvider>(),
              ),
            ],
            child: const ManageSongsPage(),
          ),
        );

      case '/admin/albums':
        return MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => di.sl<AlbumProvider>()),
              ChangeNotifierProvider(
                create: (_) => di.sl<ArtistManagerProvider>(),
              ),
            ],
            child: const ManageAlbumsPage(),
          ),
        );

      case '/admin/playlists':
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => di.sl<SystemPlaylistProvider>(),
              ),
              // reuse root SongProvider so state (mini player) stays shared
              ChangeNotifierProvider.value(
                value: Provider.of<SongProvider>(context, listen: false),
              ),
            ],
            child: const ManageSystemPlaylistsPage(),
          ),
        );

      // ✅ HOME FIXED WITH PROVIDERS
      case '/home':
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(
                value: Provider.of<SongProvider>(context, listen: false),
              ),
              ChangeNotifierProvider(
                create: (_) => di.sl<SystemPlaylistProvider>(),
              ),
            ],
            child: const HomePage(),
          ),
        );

      // ✅ ARTIST DETAIL WITH PROVIDERS
      case '/artist':
        final artistId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => di.sl<ArtistViewerProvider>(),
              ),
              ChangeNotifierProvider(create: (_) => di.sl<AlbumProvider>()),
              ChangeNotifierProvider.value(
                value: Provider.of<SongProvider>(context, listen: false),
              ),
            ],
            child: ArtistDetailPage(artistId: artistId),
          ),
        );

      // ✅ FAVORITES WITH PROVIDERS
      case '/favorites':
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => di.sl<FavoriteProvider>()),
              ChangeNotifierProvider.value(
                value: Provider.of<SongProvider>(context, listen: false),
              ),
            ],
            child: const FavoritesPage(),
          ),
        );

      // ✅ PLAYLISTS WITH PROVIDERS
      case '/playlists':
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => di.sl<PlaylistProvider>()),
              ChangeNotifierProvider.value(
                value: Provider.of<SongProvider>(context, listen: false),
              ),
            ],
            child: const PlaylistsPage(),
          ),
        );

      // ✅ SYSTEM PLAYLIST DETAIL WITH PROVIDERS
      case '/system-playlist':
        try {
          final playlistId = settings.arguments as String? ?? '';
          if (playlistId.isEmpty) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text("❌ Playlist ID không hợp lệ")),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (context) => MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (_) => di.sl<SystemPlaylistProvider>(),
                ),
                ChangeNotifierProvider.value(
                  value: Provider.of<SongProvider>(context, listen: false),
                ),
              ],
              child: SystemPlaylistDetailPage(playlistId: playlistId),
            ),
          );
        } catch (e) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(body: Center(child: Text("❌ Lỗi: $e"))),
          );
        }

      // ✅ SEARCH WITH PROVIDERS
      case '/search':
        return MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => di.sl<SearchProvider>()),
              ChangeNotifierProvider.value(
                value: Provider.of<SongProvider>(context, listen: false),
              ),
              ChangeNotifierProvider(
                create: (_) => di.sl<ArtistManagerProvider>(),
              ),
              ChangeNotifierProvider(create: (_) => di.sl<AlbumProvider>()),
              ChangeNotifierProvider(
                create: (_) => di.sl<SystemPlaylistProvider>(),
              ),
            ],
            child: const SearchPage(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("📍 Route not found"))),
        );
    }
  }
}
