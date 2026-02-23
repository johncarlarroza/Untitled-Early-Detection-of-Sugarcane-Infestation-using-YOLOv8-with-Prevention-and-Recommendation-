import 'package:early_application_1/lists/all/anthracnose.dart';
import 'package:early_application_1/lists/all/black_pod_disease.dart';
import 'package:early_application_1/lists/all/canker_dieback.dart';
import 'package:early_application_1/lists/all/cercospora_leaf_spot.dart';
import 'package:early_application_1/lists/all/cherelle_wilt.dart';
import 'package:early_application_1/lists/all/cssv.dart';
import 'package:early_application_1/lists/all/frosty_pod_rot.dart';
import 'package:early_application_1/lists/all/pink_disease.dart';
import 'package:early_application_1/lists/all/vsd.dart';
import 'package:early_application_1/lists/all/witches_broom.dart';
import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class DiseaseListPage extends StatelessWidget {
  DiseaseListPage({super.key});

  final List<Infos> diseaseExamples = [
    Infos(
      type: "disease",
      name: "Black Pod Disease",
      description: "Pod rot that turns cacao pods dark/black in wet weather.",
      imageUrl: "assets/diseases/black_pod.jpg",
      fulldescription: """
Description:
Black Pod Disease causes cacao pods to rot and turn dark/black, leading to major yield loss.

Detailed Information:
It spreads quickly during rainy seasons and high humidity. If not controlled early, it can infect many pods on the same tree and spread across the farm.

Symptoms:
- Dark/black patches on pods
- Pod rotting and bad smell (in severe cases)
- Premature pod drop

Cause:
Usually caused by Phytophthora species (fungal-like pathogen), favored by high moisture.

Mitigation:
- Remove and destroy infected pods
- Improve airflow by pruning
- Maintain good drainage
- Apply recommended fungicides when needed
""",
    ),
    Infos(
      type: "disease",
      name: "Frosty Pod Rot",
      description: "White ‘frosty’ coating on pods that ruins beans.",
      imageUrl: "assets/diseases/frosty_pod_rot.jpg",
      fulldescription: """
Description:
Frosty Pod Rot produces a white powdery ‘frosty’ growth on cacao pods and ruins bean quality.

Detailed Information:
It can cause heavy crop losses because infected pods stop developing properly.

Symptoms:
- White powdery coating on pod surface
- Pods become deformed and rot
- Beans become unusable

Cause:
Fungal infection, spread by spores in humid environments.

Mitigation:
- Remove infected pods regularly
- Maintain sanitation and prune to reduce humidity
- Follow local control recommendations
""",
    ),
    Infos(
      type: "disease",
      name: "Witches’ Broom",
      description: "Abnormal clustered shoots (‘brooms’) and reduced yield.",
      imageUrl: "assets/diseases/witches_broom.jpg",
      fulldescription: """
Description:
Witches’ Broom causes abnormal growth that looks like dense clustered shoots (“brooms”).

Detailed Information:
It reduces flowering and pod production over time and can weaken trees badly.

Symptoms:
- Clustered shoots (broom-like)
- Reduced flowers and pods
- Weak tree growth

Cause:
Fungal disease that survives in infected tissues.

Mitigation:
- Prune and destroy infected brooms
- Keep farm clean and sanitized
- Use tolerant varieties if available
""",
    ),
    Infos(
      type: "disease",
      name: "Cacao Swollen Shoot Virus (CSSV)",
      description: "Viral disease causing swelling and tree decline.",
      imageUrl: "assets/diseases/cssv.jpg",
      fulldescription: """
Description:
CSSV causes swelling of shoots and reduces cacao productivity.

Detailed Information:
Trees gradually weaken and yield less; severe infection may kill the tree.

Symptoms:
- Swollen shoots and veins
- Leaf mottling or discoloration
- Reduced pod production

Cause:
Virus commonly spread by mealybugs and infected planting materials.

Mitigation:
- Use clean/approved planting material
- Control mealybugs and ants
- Remove infected trees based on local guidance
""",
    ),
    Infos(
      type: "disease",
      name: "Vascular-Streak Dieback (VSD)",
      description: "Yellowing leaves, leaf drop, and branch dieback.",
      imageUrl: "assets/diseases/vsd.jpg",
      fulldescription: """
Description:
VSD causes leaf yellowing, leaf drop, and dieback of branches.

Detailed Information:
It weakens young trees and reduces canopy health and yield.

Symptoms:
- Yellowing leaves
- Sudden leaf drop
- Branch dieback

Cause:
Fungal infection affecting internal tissues.

Mitigation:
- Prune affected branches
- Reduce excess shade and improve airflow
- Maintain proper nutrition and tree health
""",
    ),
    Infos(
      type: "disease",
      name: "Anthracnose (Leaf & Pod Spot)",
      description: "Dark spots on leaves/pods; may lead to dieback.",
      imageUrl: "assets/diseases/anthracnose.jpg",
      fulldescription: """
Description:
Anthracnose causes dark lesions on cacao leaves, stems, and pods.

Detailed Information:
Common in humid conditions and can reduce plant vigor.

Symptoms:
- Dark circular leaf spots
- Pod spots that may spread
- Twig dieback (sometimes)

Cause:
Fungal infection spread by rain splash and infected debris.

Mitigation:
- Remove infected parts
- Improve airflow
- Use recommended fungicides if needed
""",
    ),
    Infos(
      type: "disease",
      name: "Cercospora Leaf Spot",
      description: "Leaf spots that reduce photosynthesis and weaken plants.",
      imageUrl: "assets/diseases/cercospora.jpg",
      fulldescription: """
Description:
Cercospora leaf spot causes brown/gray spots on cacao leaves.

Detailed Information:
Heavy infection can lead to leaf drop and weak growth.

Symptoms:
- Brown/gray spots with yellow halos
- Leaves may dry and fall early

Cause:
Fungal infection favored by humid conditions.

Mitigation:
- Remove heavily infected leaves
- Improve spacing and airflow
- Keep plants healthy and apply fungicide only if needed
""",
    ),
    Infos(
      type: "disease",
      name: "Pink Disease",
      description: "Pinkish fungal growth on branches causing dieback.",
      imageUrl: "assets/diseases/pink_disease.jpg",
      fulldescription: """
Description:
Pink disease affects branches and stems, sometimes showing pinkish fungal growth.

Detailed Information:
If it girdles branches, nutrient flow is blocked and dieback occurs.

Symptoms:
- Pink/whitish fungal growth on bark
- Branch drying and dieback

Cause:
Fungal infection common in wet shaded conditions.

Mitigation:
- Prune infected branches
- Disinfect tools
- Improve airflow and reduce heavy shade
""",
    ),
    Infos(
      type: "disease",
      name: "Cherelle Wilt",
      description: "Young pods shrivel and drop before maturity.",
      imageUrl: "assets/diseases/cherelle_wilt.jpg",
      fulldescription: """
Description:
Cherelle wilt occurs when young cacao pods stop growing, shrivel, and fall.

Detailed Information:
Some is natural, but it increases with drought stress, nutrient imbalance, or heavy fruit load.

Symptoms:
- Small pods turn yellow/brown
- Pods shrivel and fall off

Cause:
Mostly plant stress + resource competition.

Mitigation:
- Improve nutrition (balanced fertilizer)
- Ensure adequate watering
- Manage shade and overall tree health
""",
    ),
    Infos(
      type: "disease",
      name: "Cocoa Canker / Dieback",
      description: "Stem lesions and branch dieback; worsened by stress.",
      imageUrl: "assets/diseases/canker_dieback.jpg",
      fulldescription: """
Description:
Canker/dieback involves lesions on stems or branches followed by drying of affected parts.

Detailed Information:
Often linked to fungal infection entering through wounds and worsened by poor plant health.

Symptoms:
- Lesions/cankers on bark
- Branch dieback
- Reduced yield

Cause:
Often fungal infections entering through wounds.

Mitigation:
- Prune affected parts early
- Protect wounds and sanitize tools
- Improve nutrition and reduce stress
""",
    ),
  ];

  void _openDiseasePage(BuildContext context, Infos disease) {
    final name = disease.name.trim();

    if (name == "Black Pod Disease") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => BlackPodDiseasePage(disease: disease)));
      return;
    }
    if (name == "Frosty Pod Rot") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => FrostyPodRotPage(disease: disease)));
      return;
    }
    if (name == "Witches’ Broom") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => WitchesBroomPage(disease: disease)));
      return;
    }
    if (name == "Cacao Swollen Shoot Virus (CSSV)") {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => CssvPage(disease: disease)));
      return;
    }
    if (name == "Vascular-Streak Dieback (VSD)") {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => VsdPage(disease: disease)));
      return;
    }
    if (name == "Anthracnose (Leaf & Pod Spot)") {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => AnthracnosePage(disease: disease)));
      return;
    }
    if (name == "Cercospora Leaf Spot") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CercosporaLeafSpotPage(disease: disease)));
      return;
    }
    if (name == "Pink Disease") {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => PinkDiseasePage(disease: disease)));
      return;
    }
    if (name == "Cherelle Wilt") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CherelleWiltPage(disease: disease)));
      return;
    }
    if (name == "Cocoa Canker / Dieback") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CocoaCankerDiebackPage(disease: disease)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("No page connected for: ${disease.name}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cocoa Diseases')),
      body: ListView.builder(
        itemCount: diseaseExamples.length,
        itemBuilder: (context, index) {
          final disease = diseaseExamples[index];

          return GestureDetector(
            onTap: () => _openDiseasePage(context, disease),
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
                          borderRadius: BorderRadius.circular(10)),
                      child: Image.asset(
                        disease.imageUrl,
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
                            disease.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(disease.description,
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
