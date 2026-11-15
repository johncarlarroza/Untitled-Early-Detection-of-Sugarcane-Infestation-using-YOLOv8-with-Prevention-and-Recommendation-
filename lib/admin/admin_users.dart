import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  static const background = Color(0xFFF7F9F7);
  static const surface = Colors.white;
  static const border = Color(0xFFE0E7E1);
  static const orange = Color(0xFFFF982F);
  static const green = Color(0xFF24B75A);
  static const muted = Color(0xFF647568);

  final _search = TextEditingController();
  String _sort = 'Newest first';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  DateTime? _createdAt(Map<String, dynamic> user) {
    final value = user['createdAt'];
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _text(dynamic value, String fallback) {
    final result = (value ?? '').toString().trim();
    return result.isEmpty ? fallback : result;
  }

  Widget _avatar(Map<String, dynamic> user) {
    final url = _text(user['profilePictureUrl'], '');
    final name = _text(user['fullName'], 'User');
    return CircleAvatar(
      radius: 23,
      backgroundColor: const Color(0xFFE3F4E8),
      foregroundColor: green,
      backgroundImage: url.startsWith('https://') ? NetworkImage(url) : null,
      child: url.startsWith('https://')
          ? null
          : Text(name.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  Widget _userCard(Map<String, dynamic> user) {
    final name = _text(user['fullName'], 'Unnamed user');
    final username = _text(user['username'], 'No username');
    final email = _text(user['email'], 'No email');
    final joined = _createdAt(user);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(user),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF18271D),
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('@$username',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: green, fontSize: 12)),
                const SizedBox(height: 8),
                Text(email,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: muted, fontSize: 12)),
                const SizedBox(height: 5),
                Text('Joined ${joined == null ? 'Unknown' : DateFormat('MMM d, yyyy').format(joined)}',
                    style: const TextStyle(color: muted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _searchDecoration() => InputDecoration(
        hintText: 'Search name, username or email',
        hintStyle: const TextStyle(color: muted, fontSize: 13),
        prefixIcon: const Icon(Icons.search, color: muted),
        suffixIcon: _search.text.isNotEmpty
            ? IconButton(
                tooltip: 'Clear search',
                onPressed: () => setState(_search.clear),
                icon: const Icon(Icons.close, color: muted, size: 19))
            : null,
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: orange)),
      );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: background,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load users. Check your connection and permissions.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF18271D))));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: orange));
          }
          final all = snapshot.data!.docs.map((d) => d.data()).toList();
          final query = _search.text.trim().toLowerCase();
          final filtered = all.where((user) {
            if (query.isEmpty) return true;
            return ['fullName', 'username', 'email'].any((key) =>
                (user[key] ?? '').toString().toLowerCase().contains(query));
          }).toList();
          filtered.sort((a, b) {
            if (_sort == 'Name A–Z') {
              return _text(a['fullName'], '').toLowerCase().compareTo(
                  _text(b['fullName'], '').toLowerCase());
            }
            final left = _createdAt(a);
            final right = _createdAt(b);
            if (left == null && right == null) return 0;
            if (left == null) return 1;
            if (right == null) return -1;
            return _sort == 'Oldest first'
                ? left.compareTo(right)
                : right.compareTo(left);
          });

          return LayoutBuilder(builder: (context, constraints) {
            final compact = constraints.maxWidth < 550;
            return ListView(
              padding: EdgeInsets.all(compact ? 16 : 26),
              children: [
                const Text('Users',
                    style: TextStyle(color: Color(0xFF18271D),
                        fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                const Text('Registered accounts',
                    style: TextStyle(color: muted, fontSize: 13)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: orange.withOpacity(.13),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.people_outline, color: orange)),
                    const SizedBox(width: 14),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Total Users',
                          style: TextStyle(color: muted, fontSize: 12)),
                      const SizedBox(height: 3),
                      Text('${all.length}',
                          style: const TextStyle(color: Color(0xFF18271D),
                              fontSize: 27, fontWeight: FontWeight.bold)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 22),
                if (compact) ...[
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: Color(0xFF18271D)),
                    decoration: _searchDecoration(),
                  ),
                  const SizedBox(height: 12),
                  _sortMenu(),
                ] else
                  Row(children: [
                    Expanded(child: TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Color(0xFF18271D)),
                      decoration: _searchDecoration(),
                    )),
                    const SizedBox(width: 12),
                    _sortMenu(),
                  ]),
                const SizedBox(height: 18),
                Row(children: [
                  const Expanded(child: Text('User List',
                      style: TextStyle(color: Color(0xFF18271D),
                          fontWeight: FontWeight.w700, fontSize: 17))),
                  Text('${filtered.length} shown',
                      style: const TextStyle(color: muted, fontSize: 12)),
                ]),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border)),
                    child: Center(child: Text(
                        all.isEmpty ? 'No registered users yet.' : 'No matching users.',
                        style: const TextStyle(color: muted))),
                  )
                else
                  ...filtered.map(_userCard),
              ],
            );
          });
        },
      ),
    );
  }

  Widget _sortMenu() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: surface,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(12)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _sort,
            dropdownColor: surface,
            iconEnabledColor: orange,
            style: const TextStyle(color: Color(0xFF18271D), fontSize: 13),
            items: ['Newest first', 'Oldest first', 'Name A–Z']
                .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _sort = value);
            },
          ),
        ),
      );
}
