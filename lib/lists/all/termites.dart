import 'package:early_application_1/models/infos.dart';
import 'package:flutter/material.dart';

class TermitesPage extends StatefulWidget {
  final Infos pest;

  const TermitesPage({super.key, required this.pest});

  @override
  State<TermitesPage> createState() => _TermitesPageState();
}

class _TermitesPageState extends State<TermitesPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      widget.pest.imageUrl,
      'assets/pests/termites_2.jpg',
      'assets/pests/termites_3.jpg'
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(widget.pest.description, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),

                      const Text(
                        'Detailed Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text('Wood-feeding insects that can attack roots and trunks, especially in dry seasons, weakening or killing young trees.', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),

                      const Text(
                        'Biology and Behavior',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text('Live in underground colonies and travel through soil tunnels to reach food sources.', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),

                      const Text(
                        'Control / Mitigation',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text('Destroy nests where possible, reduce woody debris, maintain balanced farm environment, and treat soil if recommended.', style: const TextStyle(fontSize: 16)),
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
