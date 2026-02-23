import 'package:early_application_1/lists/all/criollo.dart';
import 'package:early_application_1/lists/all/forastero.dart';
import 'package:early_application_1/lists/all/trinitario.dart';
import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class VariantListPage extends StatelessWidget {
  VariantListPage({super.key});

  final List<Infos> variantsExamples = [
    Infos(
      type: "variety",
      name: 'Criollo',
      description:
          'Rare premium cocoa variety known for fine flavor and low bitterness.',
      imageUrl: 'assets/varieties/criollo.jpg',
      fulldescription: """
Description:
Criollo is one of the rarest and highest-quality cocoa varieties, valued for its fine flavor and aroma.

Detailed Information:
Criollo cocoa is often used in premium chocolates. It usually has lower bitterness and a more complex fruity/floral taste.

Characteristics:
- Fine flavor and aroma
- Low bitterness and low astringency
- Lower yield and more sensitive to diseases

Best Practices:
Plant in well-managed farms, maintain good pruning and sanitation, and protect against pests/diseases due to its sensitivity.
""",
    ),
    Infos(
      type: "variety",
      name: 'Forastero',
      description:
          'Most common cocoa variety; strong, hardy, and widely cultivated.',
      imageUrl: 'assets/varieties/forastero.jpg',
      fulldescription: """
Description:
Forastero is the most widely grown cocoa variety in the world.

Detailed Information:
It is known for high yield and strong resistance compared to other varieties. Flavor is usually strong and more bitter, often blended in chocolate production.

Characteristics:
- High yield
- More resistant and hardy
- Strong cocoa taste, usually more bitter

Best Practices:
Maintain good farm sanitation, harvest regularly, and apply proper pruning and pest control for stable production.
""",
    ),
    Infos(
      type: "variety",
      name: 'Trinitario',
      description:
          'Hybrid variety combining Criollo quality and Forastero strength.',
      imageUrl: 'assets/varieties/trinitario.jpg',
      fulldescription: """
Description:
Trinitario is a hybrid cocoa variety developed from Criollo and Forastero.

Detailed Information:
It combines the fine flavor qualities of Criollo with the stronger, hardier traits of Forastero.

Characteristics:
- Balanced flavor and productivity
- Better disease resistance than Criollo
- Common in fine-flavor cocoa markets

Best Practices:
Use good pruning and spacing for airflow, harvest frequently, and monitor for pests/diseases to maximize bean quality.
""",
    ),
  ];

  void _openVarietyPage(BuildContext context, Infos variety) {
    final name = variety.name.trim();

    if (name == "Criollo") {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => CriolloPage(variety: variety)));
      return;
    }

    if (name == "Forastero") {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => ForasteroPage(variety: variety)));
      return;
    }

    if (name == "Trinitario") {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => TrinitarioPage(variety: variety)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("No page connected for: ${variety.name}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cocoa Varieties')),
      body: ListView.builder(
        itemCount: variantsExamples.length,
        itemBuilder: (context, index) {
          final variants = variantsExamples[index];

          return GestureDetector(
            onTap: () => _openVarietyPage(context, variants),
            child: Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    // Image section
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset(
                        variants.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Image.asset('assets/u.png', fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Text section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            variants.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            variants.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    const Icon(Icons.chevron_right),
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
