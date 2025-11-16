import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class DiseaseListPage extends StatelessWidget {
  final List<Infos> diseasesExamples = [
    Infos(name: 'NA', description: '', imageUrl: 'assets/u.png'),
    Infos(name: 'NA', description: "", imageUrl: 'assets/u.png'),
    Infos(name: 'NA', description: "", imageUrl: 'assets/u.png'),
    // Add more examples as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sugarcane diseases')),
      body: ListView.builder(
        itemCount: diseasesExamples.length,
        itemBuilder: (context, index) {
          final diseases = diseasesExamples[index];
          return GestureDetector(
            onTap: () {
              Widget page;
              // if (diseases.name == 'Bud Rot (Phytophthora palmivora)') {
              //   page = BudRotPage(disease: diseases);
              // } else if (diseases.name == 'Coconut Lethal Yellowing') {
              //   page = CoconutLethalYellowingPage(disease: diseases);
              // } else if (diseases.name == 'Stem Bleeding Disease') {
              //   page = StemBleedinPage(disease: diseases);
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
                      child: Image.asset(diseases.imageUrl, fit: BoxFit.cover),
                    ),
                    SizedBox(width: 10),
                    // Description and Button section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diseases.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            diseases.description,
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
