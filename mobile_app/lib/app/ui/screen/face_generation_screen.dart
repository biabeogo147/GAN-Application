import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app/app/controller/face_generation_controller.dart';

class FaceGenerationScreen extends GetView<FaceGenerationController> {
  const FaceGenerationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Face Generation'),
        centerTitle: true,
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Instructions card
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AI Face Generator',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text(
                                'Generate realistic faces using AI. Choose one of the options below:'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Random face generation button
                    ElevatedButton.icon(
                      onPressed: controller.generateRandomFace,
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Generate Random Face'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Text-to-image section
                    const Text('Generate face from description:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'E.g., "A woman with blonde hair and blue eyes"',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: controller.generateFaceFromText,
                      icon: const Icon(Icons.text_fields),
                      label: const Text('Generate from Description'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            )),
    );
  }
}