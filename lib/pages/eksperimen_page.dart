import 'package:flutter/material.dart';

class EksperimenPage extends StatefulWidget {
  const EksperimenPage({super.key});

  @override
  State<EksperimenPage> createState() => _EksperimenPageState();
}

class _EksperimenPageState extends State<EksperimenPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnim;

  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _sizeAnim = Tween<double>(begin: 100, end: 200).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Eksperimen Animasi")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("1️⃣ Implicit Animation (AnimatedContainer)",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() => isExpanded = !isExpanded);
                },
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  width: isExpanded ? 200 : 100,
                  height: isExpanded ? 200 : 100,
                  color: isExpanded ? Colors.orange : Colors.grey,
                  child: const Center(child: Text("Tap Me")),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text("2️⃣ Explicit Animation (AnimationController)",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Center(
              child: AnimatedBuilder(
                animation: _sizeAnim,
                builder: (context, child) {
                  return Container(
                    width: _sizeAnim.value,
                    height: _sizeAnim.value,
                    color: Colors.deepOrangeAccent,
                    child: const Center(child: Text("Explicit")),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () => _controller.forward(),
                    child: const Text("Start")),
                const SizedBox(width: 10),
                ElevatedButton(
                    onPressed: () => _controller.stop(),
                    child: const Text("Stop")),
                const SizedBox(width: 10),
                ElevatedButton(
                    onPressed: () => _controller.repeat(reverse: true),
                    child: const Text("Repeat")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
