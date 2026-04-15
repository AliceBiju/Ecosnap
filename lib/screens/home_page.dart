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
                width: 50,
                height: 50,
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
                  style: TextStyle(fontSize: 14),
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

            CarouselSlider(
              options: CarouselOptions(
                height: 250,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
              ),
              items:
                  [
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

            const SizedBox(height: 70),

            CarouselSlider(
              options: CarouselOptions(
                height: 160,
                enlargeCenterPage: true,
                viewportFraction: 0.3,
              ),
              items:
                  [
                    Icons.nature,
                    Icons.local_florist,
                    Icons.yard,
                    Icons.spa,
                    Icons.park,
                  ].map((icon) {
                    return Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 117, 182, 154),
                          ),
                          child: Icon(
                            icon,
                            size: 50,
                            color: Color.fromARGB(255, 14, 85, 35),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text("Plantas"),
                      ],
                    );
                  }).toList(),
            ),

            const SizedBox(height: 25),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Identifique sua planta.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 14, 85, 35),
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        height: 150,
        color: Colors.grey[200],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble, size: 45),
              onPressed: () {
                Navigator.pushNamed(context, '/chat');
              },
            ),
            const SizedBox(width: 60),
            IconButton(
              icon: const Icon(
                Icons.camera_alt,
                size: 100,
                color: Color.fromARGB(255, 37, 114, 62),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/camera');
              },
            ),
            const SizedBox(width: 60),
            IconButton(
              icon: const Icon(Icons.person, size: 50),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ),
    );
  }
}
