import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class PestListPage extends StatelessWidget {
  final List<Infos> pestExamples = [
    Infos(name: 'NA', description: 'NA.', imageUrl: 'assets/u.png'),
    Infos(name: 'NA', description: 'NA', imageUrl: 'assets/u.png'),
    Infos(name: 'NA', description: 'NA.', imageUrl: 'assets/u.png'),
    // Add more examples as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sugarcane Pests')),
      body: ListView.builder(
        itemCount: pestExamples.length,
        itemBuilder: (context, index) {
          final pest = pestExamples[index];
          return GestureDetector(
            onTap: () {
              Widget page;
              // if (pest.name == 'Coconut Rhinoceros Beetle') {
              //   page = CoconutRhinoBeetlePage(pest: pest);
              // } else if (pest.name == 'Coconut Hispine Beetle') {
              //   page = CoconutLeafBeetlePage(pest: pest);
              // } else if (pest.name == 'Coconut Scale Insect') {
              //   page = CoconutScaleInsectPage(pest: pest);
              // } else {
              //   return;
              // }

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => page,
              //   ),
              // );
            },
            child: Card(
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    // Image section
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset(pest.imageUrl, fit: BoxFit.cover),
                    ),
                    SizedBox(width: 10),
                    // Description and Button section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pest.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            pest.description,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
