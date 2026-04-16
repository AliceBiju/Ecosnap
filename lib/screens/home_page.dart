import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 123, 184, 141),
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                "assets/images/Logo.jpg",
                width: 45,
                height: 45,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Pesquisar...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

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

      // 🔥 BOTTOM NAV CORRIGIDO (SEM OVERFLOW)
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.grey[200],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.chat_bubble, size: 32),
                onPressed: () {
                  Navigator.pushNamed(context, '/chat');
                },
              ),

              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/camera');
                },
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 37, 114, 62),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 38,
                    color: Colors.white,
                  ),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.person, size: 32),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}