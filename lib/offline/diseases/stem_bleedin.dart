import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class StemBleedinPage extends StatefulWidget {
  final Infos disease;

  StemBleedinPage({required this.disease});

  @override
  _StemBleedinPageState createState() => _StemBleedinPageState();
}

class _StemBleedinPageState extends State<StemBleedinPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<String> images = [
      widget.disease.imageUrl,
      'assets/u.png', // Replace with actual image paths
      // Replace with actual image paths
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.disease.name)),
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
              widget.disease.name,
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
                        widget.disease.description,
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
                        """The coconut hispine beetle, Brontispa longissima, is a pest predominantly found in Southeast Asia and the Pacific Islands, with a lifecycle consisting of egg, larva, pupa, and adult stages, where females lay eggs on the undersides of coconut palm leaves, and upon hatching, larvae tunnel and feed on the soft leaf tissue, leading to characteristic damage like shot-holing and skeletonization, while adults also contribute to leaf damage through feeding, with both stages capable of dispersing locally and sometimes over longer distances via infested plant material, necessitating management strategies including cultural practices, biological control, and insecticide application to mitigate its impact on coconut palm cultivation and other palm species.""",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Symptoms',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "The disease is characterized by the oozing of dark brown to black fluid from cracks and wounds on the stem, eventually leading to decay of the inner tissues.",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Cause',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Caused by the fungus Thielaviopsis paradoxa, which infects through wounds and is facilitated by high humidity and rainfall.",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Mitigation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Mitigation includes improving tree vigor through proper nutrition, minimizing injuries to the stem, applying wound dressings to prevent fungal entry, and using fungicides on infected trees",
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
