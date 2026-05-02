import 'package:flutter/material.dart';
import 'package:music_app/core/widgets/admin_sidebar.dart';
import 'package:provider/provider.dart';

import '../providers/artist_manager_provider.dart';
import '../widgets/artist_form_dialog.dart';

class ManageArtistsPage extends StatefulWidget {
  const ManageArtistsPage({super.key});

  @override
  State<ManageArtistsPage> createState() => _ManageArtistsPageState();
}

class _ManageArtistsPageState extends State<ManageArtistsPage> {
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArtistManagerProvider>().fetchArtists();
    });
  }

  Future<void> _refresh() async {
    await context.read<ArtistManagerProvider>().fetchArtists();
  }

  void logout() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ArtistManagerProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const ArtistFormDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Stack(
        children: [
          // CONTENT
          Positioned(
            top: 0,
            bottom: 0,
            left: 70,
            right: 0,
            child: GestureDetector(
              onTap: () {
                if (isExpanded) setState(() => isExpanded = false);
              },
              child: Stack(
                children: [
                  if (provider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (provider.error != null)
                    Center(child: Text(provider.error!))
                  else if (provider.artists.isEmpty)
                    const Center(child: Text("No artists found"))
                  else
                    RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.builder(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        itemCount: provider.artists.length,
                        itemBuilder: (context, index) {
                          final artist = provider.artists[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    artist.avatarUrl.isNotEmpty
                                        ? NetworkImage(
                                            artist.avatarUrl)
                                        : null,
                                child: artist.avatarUrl.isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(
                                artist.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                artist.biography,
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // EDIT
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) =>
                                            ArtistFormDialog(
                                                artist: artist),
                                      );
                                    },
                                  ),

                                  // DELETE
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      await context
                                          .read<
                                              ArtistManagerProvider>()
                                          .deleteArtistById(
                                              artist.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // SIDEBAR
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: AdminSidebar(
              isExpanded: isExpanded,
              onToggle: () =>
                  setState(() => isExpanded = !isExpanded),
              onLogout: logout,
            ),
          ),
        ],
      ),
    );
  }
}