import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No users found."));
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index].data() as Map<String, dynamic>;

            final fullName = user['fullName'] ?? 'No name';
            final username = user['username'] ?? 'No username';
            final email = user['email'] ?? 'No email';
            final profilePictureUrl = user['profilePictureUrl'] ?? '';
            final createdAt = user['createdAt'] != null
                ? (user['createdAt'] as Timestamp).toDate()
                : null;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: profilePictureUrl.isNotEmpty
                      ? NetworkImage(profilePictureUrl)
                      : null,
                  child: profilePictureUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.blue)
                      : null,
                ),
                title: Text(fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('@$username'),
                    Text(email),
                    if (createdAt != null)
                      Text(
                        "Joined: ${createdAt.toLocal().toString().split(' ')[0]}",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
