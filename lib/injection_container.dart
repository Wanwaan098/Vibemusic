import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ================= SERVICES =================
import 'package:music_app/core/services/audio_player_service.dart';

// ================= AUTH =================
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';

// ================= ARTIST =================
import 'features/artist/data/datasources/artist_remote_data_source.dart';
import 'features/artist/data/repositories/artist_repository_impl.dart';
import 'features/artist/domain/repositories/artist_repository.dart';
import 'features/artist/domain/usecases/add_artist.dart';
import 'features/artist/domain/usecases/delete_artist.dart';
import 'features/artist/domain/usecases/get_artist.dart';
import 'features/artist/domain/usecases/get_artists.dart';
import 'features/artist/domain/usecases/update_artist.dart';

// ================= SONG =================
import 'features/song/data/datasources/song_remote_data_source.dart';
import 'features/song/data/repositories/song_repository_impl.dart';
import 'features/song/domain/repositories/song_repository.dart';
import 'features/song/domain/usecases/get_songs.dart';
import 'features/song/domain/usecases/get_song.dart';
import 'features/song/domain/usecases/add_song.dart';
import 'features/song/domain/usecases/update_song.dart';
import 'features/song/domain/usecases/delete_song.dart';
import 'features/song/domain/usecases/search_songs.dart';
import 'features/song/domain/usecases/increase_play_count.dart';

// ================= ARTIST PROVIDER =================
import 'package:music_app/features/artist/presentation/admin/presentation/providers/artist_manager_provider.dart';
import 'package:music_app/features/artist/presentation/user/providers/artist_viewer_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ================= FIREBASE =================
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // ================= AUDIO SERVICE =================
  sl.registerLazySingleton<AudioPlayerService>(() => AudioPlayerService());

  // ================= AUTH =================
  sl.registerLazySingleton(() => AuthRemoteDataSource(sl(), sl()));

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));

  // ================= ARTIST =================
  sl.registerLazySingleton(() => ArtistRemoteDataSource(sl()));

  sl.registerLazySingleton<ArtistRepository>(() => ArtistRepositoryImpl(sl()));

  sl.registerLazySingleton(() => GetArtists(sl()));
  sl.registerLazySingleton(() => GetArtist(sl()));
  sl.registerLazySingleton(() => AddArtist(sl()));
  sl.registerLazySingleton(() => UpdateArtist(sl()));
  sl.registerLazySingleton(() => DeleteArtist(sl()));

  sl.registerFactory(
    () => ArtistManagerProvider(
      getArtistsUseCase: sl(),
      addArtistUseCase: sl(),
      updateArtistUseCase: sl(),
      deleteArtistUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ArtistViewerProvider(getArtist: sl(), getSongs: sl()),
  );

  // ================= SONG =================
  sl.registerLazySingleton(() => SongRemoteDataSource(sl()));

  sl.registerLazySingleton<SongRepository>(() => SongRepositoryImpl(sl()));

  sl.registerLazySingleton(() => GetSongs(sl()));
  sl.registerLazySingleton(() => GetSong(sl()));
  sl.registerLazySingleton(() => SearchSongs(sl()));
  sl.registerLazySingleton(() => AddSong(sl()));
  sl.registerLazySingleton(() => UpdateSong(sl()));
  sl.registerLazySingleton(() => DeleteSong(sl()));
  sl.registerLazySingleton(() => IncreasePlayCount(sl()));
}
