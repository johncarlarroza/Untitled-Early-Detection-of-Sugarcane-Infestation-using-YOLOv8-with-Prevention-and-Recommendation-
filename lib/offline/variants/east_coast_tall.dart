import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class EastCoastTallPage extends StatefulWidget {
  final Infos variants;

  EastCoastTallPage({required this.variants});

  @override
  _EastCoastTallPageState createState() => _EastCoastTallPageState();
}

class _EastCoastTallPageState extends State<EastCoastTallPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<String> images = [widget.variants.imageUrl, 'assets/ect2.jpg'];

    return Scaffold(
      appBar: AppBar(title: Text(widget.variants.name)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: 200,
              child: PageView.builder(
                itemCount: images.length,
                controller: PageController(viewportFraction: 0.8),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage(images[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.height * 0.8,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(images[index]),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              widget.variants.name,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        widget.variants.description,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Detailed Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        """The East Coast Tall coconut, also known as Desi coconut or Aru saha tall, is a popular coconut cultivar native to the eastern coast of India. It's known for its high yield, large-sized coconuts, and strong resistance to pests and diseases.  These tall palms begin producing coconuts after 6 or 8 years and can produce 60-70 coconuts per year. The East Coast Tall prefers sandy or loamy soils with good drainage and thrives in full sun.""",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Soil:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        """Well drained deep sandy loam, alluvial and red loamy soils are ideal""",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Time take for bearing:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("6 to 8 years", style: TextStyle(fontSize: 16)),
                      Text(
                        'Average Yield:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "70 nuts / palm / year",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Oil content:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("64 percent", style: TextStyle(fontSize: 16)),
                      Text(
                        'Special Features:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        " It is recommended for large scale cultivation in coastal regions of Tamil Nadu, Andhra Pradesh, Bihar, Pondicherry, Orissa, Madhya Pradesh, Andamans and West Bengal. The nuts are smaller than West Coast Tall",
                        style: TextStyle(fontSize: 16),
                      ),
                      // Add more detailed information as needed
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
