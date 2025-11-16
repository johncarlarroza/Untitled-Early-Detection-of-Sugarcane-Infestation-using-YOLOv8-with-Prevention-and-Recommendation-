import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class ChowghatOrangeDwarfPage extends StatefulWidget {
  final Infos variants;

  ChowghatOrangeDwarfPage({required this.variants});

  @override
  _ChowghatOrangeDwarfPageState createState() =>
      _ChowghatOrangeDwarfPageState();
}

class _ChowghatOrangeDwarfPageState extends State<ChowghatOrangeDwarfPage> {
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
                        """Unlike the East Coast Tall, the Chowghat Orange Dwarf (COD) is a compact coconut variety reaching only about 5 meters in height.  Originating from India, this dwarf coconut matures faster, bearing fruit in just 3.5 to 4 years, and is prized for its sweet, tender coconut water.  While yielding fewer coconuts than its taller relative, the COD is popular for home gardens and ornamental use due to its manageable size.""",
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
                      Text("3 to 4 years", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text(
                        'Copra Content:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("150 gram/nut", style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text(
                        'Oil content:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("66 percent", style: TextStyle(fontSize: 16)),
                      Text(
                        'Special Features:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        """This cultivar is known as ‘Gowrigathram’ or ‘Chenthangu’ and ‘Kenthali’ in Kerala and Karnataka respectively. The palm has a thin stem with closely arranged leaf scars, a small compact crown with characteristic orange colour on leaf petioles, inflorescences and nuts. This cultivar was released by CPCRI in 1991 for large scale cultivation in the states of Kerala, Karnataka and Tamil Nadu. High wind areas and drought-prone regions should be avoided. If planted in high wind-prone regions, good shelterbelts should be provided to minimise the damage due to winds.""",
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
