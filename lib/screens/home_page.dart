import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../layout/main_layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🌿 CARROSSEL IMAGENS
            CarouselSlider(
              options: CarouselOptions(
                height: 220,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
              ),
              items: [
                "assets/images/planta1.jpg",
                "assets/images/planta2.jpg",
                "assets/images/planta3.jpg",
              ].map((item) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    item,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            // 🌱 ICONES
            CarouselSlider(
              options: CarouselOptions(
                height: 140,
                enlargeCenterPage: true,
                viewportFraction: 0.33,
              ),
              items: [
                Icons.nature,
                Icons.local_florist,
                Icons.yard,
                Icons.spa,
                Icons.park,
              ].map((icon) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 117, 182, 154),
                      ),
                      child: Icon(
                        icon,
                        size: 40,
                        color: Color.fromARGB(255, 14, 85, 35),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text("Plantas"),
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Identifique sua planta.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 14, 85, 35),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}