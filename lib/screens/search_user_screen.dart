import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/friend_request_utils.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchUsers(_searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final results = snapshot.docs.map((doc) => {
            'uid': doc.id,
            'username': doc['username'],
          }).toList();

      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching users: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Users"),
        backgroundColor: isDark ? Colors.black : const Color(0xFF8E24AA),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Enter username",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: _searchResults.isEmpty
                    ? const Center(
                        child: Text(
                          'No users found',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          final userId = user['uid'];
                          final username = user['username'];
                          final currentUserId = FirebaseAuth.instance.currentUser?.uid;

                          if (currentUserId == userId) return const SizedBox.shrink();

                          return ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(
                              username,
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                            trailing: TextButton.icon(
                              onPressed: () async {
                                await FriendRequestUtils.sendFriendRequest(
                                  toUserId: userId,
                                  toUsername: username,
                                );

                               if (!context.mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Friend request sent!'),
    backgroundColor: Colors.green,
  ),
);

                              },
                              icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                              label: const Text('Add Friend', style: TextStyle(color: Colors.white)),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.purple,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
