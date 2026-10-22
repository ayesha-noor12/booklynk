import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/book_card.dart';
import '../../widgets/empty_library.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    enabled: false,
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(authProvider.user?.displayName ?? 'User'),
                      subtitle: Text(authProvider.user?.email ?? ''),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Sign Out'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                onSelected: (String value) async {
                  if (value == 'logout') {
                    await authProvider.signOut();
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          if (bookProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookProvider.books.isEmpty) {
            return EmptyLibrary(
              onAddBook: () => bookProvider.addBook(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => bookProvider.loadBooks(),
            child: _isGridView
                ? _buildGridView(bookProvider)
                : _buildListView(bookProvider),
          );
        },
      ),
      floatingActionButton: Consumer<BookProvider>(
        builder: (context, bookProvider, child) {
          return FloatingActionButton.extended(
            onPressed: bookProvider.isLoading
                ? null
                : () async {
                    await bookProvider.addBook();
                  },
            icon: const Icon(Icons.add),
            label: const Text('Add Book'),
          );
        },
      ),
    );
  }

  Widget _buildGridView(BookProvider bookProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: bookProvider.books.length,
        itemBuilder: (context, index) {
          return BookCard(
            book: bookProvider.books[index],
            isGridView: true,
          );
        },
      ),
    );
  }

  Widget _buildListView(BookProvider bookProvider) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookProvider.books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return BookCard(
          book: bookProvider.books[index],
          isGridView: false,
        );
      },
    );
  }
}