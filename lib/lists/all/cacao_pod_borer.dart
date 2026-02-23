import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class CacaoPodBorerPage extends StatefulWidget {
  final Infos pest;

  const CacaoPodBorerPage({super.key, required this.pest});

  @override
  State<CacaoPodBorerPage> createState() => _CacaoPodBorerPageState();
}

class _CacaoPodBorerPageState extends State<CacaoPodBorerPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      widget.pest.imageUrl,
      'assets/pests/cacao_pod_borer.jpg',
      'assets/pests/cacao_pod_borer2.jpg'
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.pest.name)),
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
              widget.pest.name,
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(widget.pest.description,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      const Text(
                        'Detailed Information',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                          'One of the most harmful pests in many cacao-growing regions. Larvae bore into pods and damage beans, reducing quality and yield.',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      const Text(
                        'Biology and Behavior',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                          'Adult moths lay eggs on pod surfaces. After hatching, larvae tunnel into pods and feed on developing beans.',
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      const Text(
                        'Control / Mitigation',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                          'Harvest pods regularly, remove/destroy infested pods, use pheromone traps where available, maintain sanitation, and encourage natural enemies (e.g., parasitoid wasps).',
                          style: const TextStyle(fontSize: 16)),
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
