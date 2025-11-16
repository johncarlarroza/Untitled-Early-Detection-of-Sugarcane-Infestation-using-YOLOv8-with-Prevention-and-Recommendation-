import 'package:early_application_1/models/infos.dart';
import 'package:early_application_1/offline/variants/COD.dart';
import 'package:early_application_1/offline/variants/east_coast_tall.dart';
import 'package:early_application_1/offline/variants/west_coast_tall.dart';
import 'package:flutter/material.dart';

class VariantListPage extends StatelessWidget {
  final List<Infos> variantsExamples = [
    Infos(
      name: 'Aromatic Green Dwarf (AROD)',
      description:
          "The Aromatic Green Dwarf coconut variety is known for its sweet and tender meat and water. It's particularly popular for buko (young coconut) production due to its delicious taste. This variety has gained market demand, encouraging farmers to plant it.",
      imageUrl: 'assets/wct.jpg',
    ),
    Infos(
      name: 'Galas Green Dwarf (GALD)',
      description:
          "The coconut variety is another excellent choice for buko (young coconut) production. It has medium-sized nuts with a thick husk and a spherical, wel lbalanced crown. The fronds are shorter but have more and longer leaflets compared to other dwarf varieties. The Galas Green Dwarf is known for its high yield potential and good autogamy (self-pollination). Due to its sweet and tender meat and water, it's highly favored for commercial buko production.",
      imageUrl: 'assets/ect.jpg',
    ),
    Infos(
      name: 'Tacunan Green Dwarf (TACD)',
      description:
          ' Known locally as "Bilaka" or "Linkuranay," it has medium to large nuts with thick stems and closely spaced leaf scars. The fronds are born on a spherical crown with wide leaflets.',
      imageUrl: 'assets/cod.jpg',
    ),
    Infos(
      name: 'La Victoria Brown Dwarf (VIBD)',
      description:
          ' Known locally as "Bilaka" or "Linkuranay," it has medium to large nuts with thick stems and closely spaced leaf scars. The fronds are born on a spherical crown with wide leaflets.',
      imageUrl: 'assets/cod.jpg',
    ),
    Infos(
      name: 'Baguer Green Dwarf (BAGD)',
      description:
          ' Known locally as "Bilaka" or "Linkuranay," it has medium to large nuts with thick stems and closely spaced leaf scars. The fronds are born on a spherical crown with wide leaflets.',
      imageUrl: 'assets/cod.jpg',
    ),
    Infos(
      name: 'Catigan Green Dwarf (CATD)',
      description:
          ' The Catigan Green Dwarf (CATD) coconut variety is a popular choice for buko (young coconut) production due to its sweet and tender meat and water. It has medium-sized nuts with a thick husk and a well-balanced crown. The fronds are shorter but have more and longer leaflets compared to other dwarf varieties. This variety exhibits uniformity in nut size and a slow rate of upward growth.',
      imageUrl: 'assets/cod.jpg',
    ),
    // Add more examples as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sugarcane Varieties')),
      body: ListView.builder(
        itemCount: variantsExamples.length,
        itemBuilder: (context, index) {
          final variants = variantsExamples[index];
          return GestureDetector(
            onTap: () {
              Widget page;
              if (variants.name == 'West Coast Tall') {
                page = WestCoastTallPage(variants: variants);
              } else if (variants.name == 'East Coast Tall') {
                page = EastCoastTallPage(variants: variants);
              } else if (variants.name == 'Chowghat Orange Dwarf (COD)') {
                page = ChowghatOrangeDwarfPage(variants: variants);
              } else {
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
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
