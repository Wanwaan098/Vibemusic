import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'injection_container.dart' as di;
import 'routes/app_router.dart';

// ================= AUTH =================
import 'features/auth/presentation/providers/auth_provider.dart';

// ================= ARTIST =================
import 'features/artist/presentation/admin/presentation/providers/artist_manager_provider.dart';

// ================= SONG USER =================
import 'features/song/presentation/user/providers/song_provider.dart';
import 'features/song/domain/usecases/get_songs.dart';
import 'features/song/domain/usecases/get_song.dart';
import 'features/song/domain/usecases/search_songs.dart';
import 'features/song/domain/usecases/increase_play_count.dart';

// ================= SONG ADMIN =================
import 'features/song/presentation/admin/providers/song_manager_provider.dart';
import 'features/song/domain/usecases/add_song.dart';
import 'features/song/domain/usecases/update_song.dart';
import 'features/song/domain/usecases/delete_song.dart';

// ================= AUDIO =================
import 'package:music_app/core/services/audio_player_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? "",
    ),
  );

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ================= AUTH =================
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUser: di.sl(),
            registerUser: di.sl(),
          ),
        ),

        // ================= ARTIST =================
        ChangeNotifierProvider(
          create: (_) => di.sl<ArtistManagerProvider>(),
        ),

        // ================= AUDIO SINGLETON =================
        Provider<AudioPlayerService>(
          create: (_) => di.sl<AudioPlayerService>(),
        ),

        // ================= SONG USER =================
        ChangeNotifierProvider(
          create: (context) => SongProvider(
            getSongs: di.sl<GetSongs>(),
            getSong: di.sl<GetSong>(),
            searchSongs: di.sl<SearchSongs>(),
            increasePlayCount: di.sl<IncreasePlayCount>(),
            audio: context.read<AudioPlayerService>(), // ✅ FIX HERE
          ),
        ),

        // ================= SONG ADMIN =================
        ChangeNotifierProvider(
          create: (_) => SongManagerProvider(
            getSongs: di.sl<GetSongs>(),
            addSong: di.sl<AddSong>(),
            updateSong: di.sl<UpdateSong>(),
            deleteSong: di.sl<DeleteSong>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Music App',
        theme: ThemeData(
          useMaterial3: true,
        ),
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}