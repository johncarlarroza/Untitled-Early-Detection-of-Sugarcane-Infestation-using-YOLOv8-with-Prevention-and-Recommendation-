import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class CssvPage extends StatefulWidget {
  final Infos disease;

  const CssvPage({super.key, required this.disease});

  @override
  State<CssvPage> createState() => _CssvPageState();
}

class _CssvPageState extends State<CssvPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      widget.disease.imageUrl,
      'assets/diseases/cssv_2.jpg',
      'assets/diseases/cssv_3.jpg'
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
                      Text('A viral disease that causes swelling of shoots/stems and gradual decline, often leading to severe yield loss.', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),

                      const Text(
                        'Biology and Behavior',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text('Commonly spread by insect vectors (often mealybugs) and infected planting material.', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),

                      const Text(
                        'Control / Mitigation',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text('Use certified disease-free seedlings, manage mealybugs/ants, and remove infected trees when recommended by local authorities.', style: const TextStyle(fontSize: 16)),
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
