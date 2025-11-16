import 'package:early_application_1/mitigation/chemspraying.dart';
import 'package:early_application_1/mitigation/culcontrol.dart';
import 'package:early_application_1/mitigation/mechacontrol.dart';
import 'package:early_application_1/mitigation/trunkinj.dart';
import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class OffCocomitig extends StatelessWidget {
  final List<Infos> pestmitigExamples = [
    Infos(
      name: 'Mechanical Control',
      description:
          'Prune infested leaves and destroy beetles especially in nursery seedlings and young plantings ',
      imageUrl: 'assets/mecha.png',
    ),
    Infos(
      name: 'Cultural Control',
      description:
          'Plant covercrops, other leguminous crops and banana under coconut to enhance population of parasitoids and predators (earwig) as they feed on nectars of these crops ',
      imageUrl: 'assets/cultu.png',
    ),
    Infos(
      name: 'Chemical Spraying',
      description:
          'Chemical spraying may be done on a case to case basis (feasible only in nursery seedlings and young plantings) but not compulsory especially when the biological control agents are numerous enough to minimize pest population. This may not be feasible on tall palms.',
      imageUrl: 'assets/chem.png',
    ),
    Infos(
      name: 'Trunk Injection',
      description:
          'Chemical spraying may be done on a case to case basis (feasible only in nursery seedlings and young plantings) but not compulsory especially when the biological control agents are numerous enough to minimize pest population. This may not be feasible on tall palms.',
      imageUrl: 'assets/csi.jpg',
    ),
    // Add more examples as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Coconut Pests Mitigation')),
      body: ListView.builder(
        itemCount: pestmitigExamples.length,
        itemBuilder: (context, index) {
          final mitig = pestmitigExamples[index];
          return GestureDetector(
            onTap: () {
              Widget page;
              if (mitig.name == 'Mechanical Control') {
                page = Mechacontrol(mitig: mitig);
              } else if (mitig.name == 'Cultural Control') {
                page = Cultcontrol(mitig: mitig);
              } else if (mitig.name == 'Chemical Spraying') {
                page = Chemspraying(mitig: mitig);
              } else if (mitig.name == 'Trunk Injection') {
                page = Trunkinj(mitig: mitig);
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
                      child: Image.asset(mitig.imageUrl, fit: BoxFit.cover),
                    ),
                    SizedBox(width: 10),
                    // Description and Button section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mitig.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            mitig.description,
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
