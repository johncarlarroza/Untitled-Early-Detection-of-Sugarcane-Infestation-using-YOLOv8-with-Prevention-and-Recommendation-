import 'package:early_application_1/lists/all/aphids.dart';
import 'package:early_application_1/lists/all/bean_weevils.dart';
import 'package:early_application_1/lists/all/cacao_pod_borer.dart';
import 'package:early_application_1/lists/all/cocoa_mirid_bug.dart';
import 'package:early_application_1/lists/all/cocoa_shield_bugs.dart';
import 'package:early_application_1/lists/all/mealybugs.dart';
import 'package:early_application_1/lists/all/red_banded_thrips.dart';
import 'package:early_application_1/lists/all/shoot_borers.dart';
import 'package:early_application_1/lists/all/stem_borers.dart';
import 'package:early_application_1/lists/all/termites.dart';
import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class PestListPage extends StatelessWidget {
  PestListPage({super.key});

  final List<Infos> pestExamples = [
    Infos(
      type: "pest",
      name: "Cacao Pod Borer",
      description: "A tiny moth pest whose larva drills into cacao pods.",
      imageUrl: "assets/pests/cacao_pod_borer.png",
      fulldescription: """
Description:
A tiny moth pest whose baby stage (larva) drills into cacao pods.

Detailed Information:
This is one of the most harmful pests for cacao farmers, especially in tropical regions. It damages the beans inside and lowers harvest quality.

Biology and Behavior:
The adult moth lays eggs on the pod surface. When the eggs hatch, the larvae bore inside and feed on the beans.

Control Measures:
Harvest pods regularly, remove infested pods, use pheromone traps, and encourage natural enemies like parasitoid wasps.
""",
    ),
    Infos(
      type: "pest",
      name: "Cocoa Mirid Bug (Capsid Bug)",
      description: "A small insect that sucks sap from cacao stems and pods.",
      imageUrl: "assets/pests/cocoa_mirid_bug.png",
      fulldescription: """
Description:
A small insect that sucks sap from cacao stems and pods.

Detailed Information:
Their feeding creates wounds that can turn into dark lesions and may cause branches to dry up.

Biology and Behavior:
They usually feed at night and inject toxins while sucking plant sap.

Control Measures:
Trim damaged parts, keep the plantation clean, and use recommended insecticides when needed.
""",
    ),
    Infos(
      type: "pest",
      name: "Mealybugs",
      description: "Tiny white insects that look like cotton.",
      imageUrl: "assets/pests/mealybugs.png",
      fulldescription: """
Description:
Tiny white insects that look like they’re covered in cotton.

Detailed Information:
They weaken plants by sucking sap and can also spread diseases. Ants often protect them.

Biology and Behavior:
They gather in groups on stems, leaves, and pods and multiply quickly.

Control Measures:
Control ants, wash them off with water, or use natural sprays like neem oil.
""",
    ),
    Infos(
      type: "pest",
      name: "Aphids",
      description:
          "Small soft insects that cluster on young leaves and shoots.",
      imageUrl: "assets/pests/aphids.jpg",
      fulldescription: """
Description:
Very small soft insects that cluster on young leaves and shoots.

Detailed Information:
They can cause leaves to curl and may spread plant viruses.

Biology and Behavior:
Aphids reproduce fast, especially in warm weather.

Control Measures:
Spray water to remove them, introduce ladybugs, or use mild organic sprays.
""",
    ),
    Infos(
      type: "pest",
      name: "Red-Banded Thrips",
      description: "Tiny insects that damage leaves and young pods.",
      imageUrl: "assets/pests/red_banded_thrips.jpg",
      fulldescription: """
Description:
Tiny insects with dark bodies and reddish markings.

Detailed Information:
They damage leaves, making them look silvery and dry. Heavy infestation can reduce plant vigor.

Biology and Behavior:
They prefer dry conditions and usually hide under leaves.

Control Measures:
Keep plants healthy and well-watered, remove damaged leaves, and use safe insecticides if needed.
""",
    ),
    Infos(
      type: "pest",
      name: "Cocoa Shield Bugs (Stink Bugs)",
      description: "Shield-shaped bugs that pierce pods and suck sap.",
      imageUrl: "assets/pests/cocoa_shield_bugs.jpg",
      fulldescription: """
Description:
Medium-sized bugs shaped like shields.

Detailed Information:
They pierce cacao pods and suck sap, causing spots and deformities. Damaged pods may develop poor bean quality.

Biology and Behavior:
They use needle-like mouthparts to feed on pods and may hide under leaves.

Control Measures:
Pick them off by hand, use traps, and protect natural predators. Use pesticides only when necessary.
""",
    ),
    Infos(
      type: "pest",
      name: "Stem Borers",
      description: "Larvae that tunnel inside trunks and branches.",
      imageUrl: "assets/pests/stem_borers.jpg",
      fulldescription: """
Description:
Beetle larvae that tunnel inside tree trunks and branches.

Detailed Information:
Their tunnels weaken the tree and may even kill young plants if severe.

Biology and Behavior:
Eggs are laid on bark; larvae live inside the wood for months, making them hard to detect early.

Control Measures:
Cut off infected branches, seal wounds, and use biological treatments or expert-recommended control methods.
""",
    ),
    Infos(
      type: "pest",
      name: "Bean Weevils (Stored Cocoa Beetles)",
      description:
          "Small beetles that attack stored cacao beans after harvest.",
      imageUrl: "assets/pests/bean_weevils.jpg",
      fulldescription: """
Description:
Small brown beetles that attack stored cacao beans.

Detailed Information:
They damage dried beans after harvest, causing storage losses and reduced quality.

Biology and Behavior:
Females lay eggs on beans; larvae grow inside them.

Control Measures:
Dry beans properly, store in sealed containers, keep storage clean, and check stocks regularly.
""",
    ),
    Infos(
      type: "pest",
      name: "Termites",
      description: "Wood-feeding insects that attack trunks and roots.",
      imageUrl: "assets/pests/termites.jpg",
      fulldescription: """
Description:
Social insects that feed on wood and plant material.

Detailed Information:
They attack roots and trunks, especially during dry seasons, and can weaken or kill young plants.

Biology and Behavior:
They live underground and travel through hidden tunnels.

Control Measures:
Destroy nests, treat soil when needed, reduce dry wood debris, and keep the farm environment balanced.
""",
    ),
    Infos(
      type: "pest",
      name: "Shoot Borers",
      description: "Caterpillars that bore into young shoots causing wilting.",
      imageUrl: "assets/pests/shoot_borers.jpg",
      fulldescription: """
Description:
Caterpillars that bore into young shoots.

Detailed Information:
Their feeding causes shoots to wilt and prevents normal growth.

Biology and Behavior:
Larvae stay hidden inside shoots, making them difficult to spot.

Control Measures:
Prune affected shoots early and use biological insecticides if recommended.
""",
    ),
  ];

  void _openPestPage(BuildContext context, Infos pest) {
    // ✅ Route to each specific page
    if (pest.name == "Cacao Pod Borer") {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => CacaoPodBorerPage(pest: pest)));
      return;
    }

    if (pest.name == "Cocoa Mirid Bug (Capsid Bug)") {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => CocoaMiridBugPage(pest: pest)));
      return;
    }

    if (pest.name == "Mealybugs") {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => MealybugsPage(pest: pest)));
      return;
    }

    if (pest.name == "Aphids") {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => AphidsPage(pest: pest)));
      return;
    }

    if (pest.name == "Red-Banded Thrips") {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => RedBandedThripsPage(pest: pest)));
      return;
    }

    if (pest.name == "Cocoa Shield Bugs (Stink Bugs)") {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => CocoaShieldBugsPage(pest: pest)));
      return;
    }

    if (pest.name == "Stem Borers") {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => StemBorersPage(pest: pest)));
      return;
    }

    if (pest.name == "Bean Weevils (Stored Cocoa Beetles)") {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => BeanWeevilsPage(pest: pest)));
      return;
    }

    if (pest.name == "Termites") {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => TermitesPage(pest: pest)));
      return;
    }

    if (pest.name == "Shoot Borers") {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => ShootBorersPage(pest: pest)));
      return;
    }

    // fallback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("No page connected for: ${pest.name}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cocoa Pests')),
      body: ListView.builder(
        itemCount: pestExamples.length,
        itemBuilder: (context, index) {
          final pest = pestExamples[index];

          return GestureDetector(
            onTap: () => _openPestPage(context, pest),
            child: Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset(
                        pest.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Image.asset('assets/u.png', fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pest.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(pest.description,
                              style: const TextStyle(fontSize: 14)),
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
