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

// ================= SONG PROVIDERS =================
import 'package:music_app/features/song/presentation/user/providers/song_provider.dart';
import 'package:music_app/features/song/presentation/admin/providers/song_manager_provider.dart';

// ================= ARTIST PROVIDER =================
import 'package:music_app/features/artist/presentation/admin/presentation/providers/artist_manager_provider.dart';
import 'package:music_app/features/artist/presentation/user/providers/artist_viewer_provider.dart';

// ================= ALBUM =================
import 'features/album/data/datasources/album_remote_data_source.dart';
import 'features/album/data/repositories/album_repository_impl.dart';
import 'features/album/domain/repositories/album_repository.dart';
import 'features/album/domain/usecases/get_albums.dart';
import 'features/album/domain/usecases/get_albums_by_artist.dart';
import 'features/album/domain/usecases/add_album.dart';
import 'features/album/domain/usecases/update_album.dart';
import 'features/album/domain/usecases/delete_album.dart';
import 'package:music_app/features/album/presentation/providers/album_provider.dart';
// ================= ADMIN =================
import 'features/admin/domain/usecases/get_admin_stats.dart';
import 'package:music_app/features/admin/presentation/providers/admin_stats_provider.dart';

// ================= PLAYLIST =================
import 'features/playlist/data/datasources/playlist_remote_data_source.dart';
import 'features/playlist/data/repositories/playlist_repository_impl.dart';
import 'features/playlist/domain/repositories/playlist_repository.dart';
import 'features/playlist/domain/usecases/playlist_usecases.dart';
import 'features/playlist/data/datasources/system_playlist_remote_data_source.dart';
import 'features/playlist/data/repositories/system_playlist_repository_impl.dart';
import 'features/playlist/domain/repositories/system_playlist_repository.dart';
import 'features/playlist/domain/usecases/system_playlist_usecases.dart';
import 'package:music_app/features/playlist/presentation/providers/playlist_provider.dart';
import 'package:music_app/features/playlist/presentation/providers/system_playlist_provider.dart';

// ================= FAVORITE =================
import 'features/favorite/data/datasources/favorite_remote_data_source.dart';
import 'features/favorite/data/repositories/favorite_repository_impl.dart';
import 'features/favorite/domain/repositories/favorite_repository.dart';
import 'features/favorite/domain/usecases/favorite_usecases.dart';
import 'package:music_app/features/favorite/presentation/providers/favorite_provider.dart';

// ================= SEARCH =================
import 'package:music_app/features/search/presentation/providers/search_provider.dart';

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

  // ✅ SONG PROVIDERS
  sl.registerFactory(
    () => SongProvider(
      getSongs: sl(),
      getSong: sl(),
      searchSongs: sl(),
      increasePlayCount: sl(),
      audio: sl(),
    ),
  );

  sl.registerFactory(
    () => SongManagerProvider(
      getSongs: sl(),
      addSong: sl(),
      updateSong: sl(),
      deleteSong: sl(),
    ),
  );

  // ================= PLAYLIST =================
  sl.registerLazySingleton<PlaylistRemoteDataSource>(
    () => PlaylistRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<PlaylistRepository>(
    () => PlaylistRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetPlaylistsByUser(sl()));
  sl.registerLazySingleton(() => GetPlaylist(sl()));
  sl.registerLazySingleton(() => CreatePlaylist(sl()));
  sl.registerLazySingleton(() => UpdatePlaylist(sl()));
  sl.registerLazySingleton(() => DeletePlaylist(sl()));
  sl.registerLazySingleton(() => AddSongToPlaylist(sl()));
  sl.registerLazySingleton(() => RemoveSongFromPlaylist(sl()));

  sl.registerFactory(
    () => PlaylistProvider(
      getPlaylistsByUser: sl(),
      createPlaylist: sl(),
      addSongToPlaylist: sl(),
      removeSongFromPlaylist: sl(),
      deletePlaylist: sl(),
      updatePlaylist: sl(),
    ),
  );

  // ================= FAVORITE =================
  sl.registerLazySingleton<FavoriteRemoteDataSource>(
    () => FavoriteRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetFavoritesByUser(sl()));
  sl.registerLazySingleton(() => AddToFavorites(sl()));
  sl.registerLazySingleton(() => RemoveFromFavorites(sl()));
  sl.registerLazySingleton(() => IsFavorite(sl()));

  sl.registerFactory(
    () => FavoriteProvider(
      getFavoritesByUser: sl(),
      addToFavorites: sl(),
      removeFromFavorites: sl(),
      isFavorite: sl(),
    ),
  );

  // ================= ALBUM =================
  sl.registerLazySingleton(() => AlbumRemoteDataSource(sl()));

  sl.registerLazySingleton<AlbumRepository>(() => AlbumRepositoryImpl(sl()));

  sl.registerLazySingleton(() => GetAlbums(sl()));
  sl.registerLazySingleton(() => GetAlbumsByArtist(sl()));
  sl.registerLazySingleton(() => AddAlbum(sl()));
  sl.registerLazySingleton(() => UpdateAlbum(sl()));
  sl.registerLazySingleton(() => DeleteAlbum(sl()));

  sl.registerFactory(
    () => AlbumProvider(
      getAlbums: sl(),
      getAlbumsByArtist: sl(),
      addAlbum: sl(),
      updateAlbum: sl(),
      deleteAlbum: sl(),
    ),
  );

  // ================= ADMIN STATS =================
  sl.registerLazySingleton(
    () => GetAdminStats(getSongs: sl(), getAlbums: sl(), getArtists: sl()),
  );
  sl.registerFactory(() => AdminStatsProvider(getAdminStats: sl()));
  // ================= SYSTEM PLAYLIST =================
  sl.registerLazySingleton(() => SystemPlaylistRemoteDataSource(sl()));

  sl.registerLazySingleton<SystemPlaylistRepository>(
    () => SystemPlaylistRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetSystemPlaylists(sl()));
  sl.registerLazySingleton(() => CreateSystemPlaylist(sl()));
  sl.registerLazySingleton(() => UpdateSystemPlaylist(sl()));
  sl.registerLazySingleton(() => DeleteSystemPlaylist(sl()));
  sl.registerLazySingleton(() => AddSongToSystemPlaylist(sl()));
  sl.registerLazySingleton(() => RemoveSongFromSystemPlaylist(sl()));

  sl.registerFactory(
    () => SystemPlaylistProvider(
      getSystemPlaylists: sl(),
      createSystemPlaylist: sl(),
      updateSystemPlaylist: sl(),
      deleteSystemPlaylist: sl(),
      addSongToSystemPlaylist: sl(),
      removeSongFromSystemPlaylist: sl(),
    ),
  );

  // ================= SEARCH =================
  sl.registerFactory(() => SearchProvider(searchSongs: sl()));
}
