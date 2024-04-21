import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';  
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PostDetailPage extends StatelessWidget {
  final DocumentSnapshot document;

  PostDetailPage({required this.document});

  @override
 Widget build(BuildContext context) {
    List<dynamic> imageUrls = document['images'] as List<dynamic>;
    PageController _pageController = PageController(); 

    return Scaffold(
      appBar: AppBar(
        title: Text(document['title']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (imageUrls.isNotEmpty)
                    Container(
                      height: 300,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: imageUrls.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () => _showFullScreenImage(context, imageUrls[index]),
                            child: Image.network(imageUrls[index], fit: BoxFit.cover),
                          );
                        },
                      ),
                    ),
                  if (imageUrls.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: _pageController, 
                          count: imageUrls.length, 
                          effect: WormEffect(),
                          onDotClicked: (index) {
                            _pageController.animateToPage(
                              index,
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        ),
                      ),
                    ),
                  Text('Description: ${document['description']}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text('Price: \$${document['price']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }
}
