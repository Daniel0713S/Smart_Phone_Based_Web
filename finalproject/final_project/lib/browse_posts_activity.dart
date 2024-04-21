import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'new_post_activity.dart';
import 'post_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'sign_in_page.dart';

class BrowsePostsActivity extends StatefulWidget {
  @override
  _BrowsePostsActivityState createState() => _BrowsePostsActivityState();
}

class _BrowsePostsActivityState extends State<BrowsePostsActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Posts'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignInPage()));
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              String title = document['title'];
              String description = document['description'];
              String price = document['price'].toString();
              List<dynamic> imageUrls = document['images'] ?? []; 

              return ListTile(
                leading: imageUrls.isNotEmpty
                    ? Image.network(imageUrls[0], width: 100, height: 100, fit: BoxFit.cover)  // Show first image as thumbnail
                    : SizedBox(width: 100, height: 100),
                title: Text(title),
                subtitle: Text('$description\nPrice: \$${price}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailPage(document: document),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => NewPostActivity()));
        },
        child: Icon(Icons.add),
        tooltip: 'Add New Post',
      ),
    );
  }
}
