import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class VariantListPage extends StatelessWidget {
  final List<Infos> variantsExamples = [
    Infos(name: 'West Coast Tall', description: 'NA', imageUrl: 'assets/u.png'),
    Infos(name: 'East Coast Tall', description: "NA", imageUrl: 'assets/u.png'),
    Infos(
      name: 'Chowghat Orange Dwarf (COD)',
      description: 'NA',
      imageUrl: 'assets/u.png',
    ),
    // Add more examples as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sugarcane Variants')),
      body: ListView.builder(
        itemCount: variantsExamples.length,
        itemBuilder: (context, index) {
          final variants = variantsExamples[index];
          return GestureDetector(
            onTap: () {
              Widget page;
              // if (variants.name == 'West Coast Tall') {
              //   page = WestCoastTallPage(variants: variants);
              // } else if (variants.name == 'East Coast Tall') {
              //   page = EastCoastTallPage(variants: variants);
              // } else if (variants.name == 'Chowghat Orange Dwarf (COD)') {
              //   page = ChowghatOrangeDwarfPage(variants: variants);
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
                      child: Image.asset(variants.imageUrl, fit: BoxFit.cover),
                    ),
                    SizedBox(width: 10),
                    // Description and Button section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            variants.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            variants.description,
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
