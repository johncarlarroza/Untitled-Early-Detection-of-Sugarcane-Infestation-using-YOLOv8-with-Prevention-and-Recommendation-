import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class BlackPodDiseasePage extends StatefulWidget {
  final Infos disease;

  const BlackPodDiseasePage({super.key, required this.disease});

  @override
  State<BlackPodDiseasePage> createState() => _BlackPodDiseasePageState();
}

class _BlackPodDiseasePageState extends State<BlackPodDiseasePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      widget.disease.imageUrl,
      'assets/diseases/black_pod_2.jpg',
      'assets/diseases/black_pod_3.jpg'
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.disease.name)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: images.length,
                controller: PageController(viewportFraction: 0.8),
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
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
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final active = i == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active ? Colors.green : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            Text(
              widget.disease.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(widget.disease.description, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),

                      const Text(
                        'Detailed Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text('A major cacao disease causing pods to rot and turn dark/black, especially during rainy seasons and high humidity.', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),

                      const Text(
                        'Biology and Behavior',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text('Often linked to water-splash spread. Infection starts on pods and can spread quickly in wet conditions.', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),

                      const Text(
                        'Control / Mitigation',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text('Remove and destroy infected pods, improve drainage and airflow (pruning/spacing), keep field sanitary, and apply recommended fungicides when needed.', style: const TextStyle(fontSize: 16)),
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
