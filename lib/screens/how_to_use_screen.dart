import 'package:flutter/material.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.indigoAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('How to use', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildIntroCard(),
            const SizedBox(height: 16),

            _buildStepCard(
              title: "Step 1: Create a Batch",
              items: [
                "Open the home screen",
                "Tap the add button",
                "Enter batch name (example: HSC 2026, Class 12)",
                "Save the batch",
              ],
            ),

            _buildStepCard(
              title: "Step 2: Add Students",
              items: [
                "Open a batch",
                "Tap Add Student",
                "Enter student name",
                "Save the student",
              ],
            ),

            _buildStepCard(
              title: "Step 3: Create Exam Sessions",
              items: [
                "Open a batch",
                "Tap exam icon",
                "Add exam title (Weekly, Monthly, Model Test)",
                "Enter full marks",
                "Select exam type",
                "Save exam session",
              ],
            ),

            _buildStepCard(
              title: "Step 4: Enter Marks",
              items: [
                "Open exam session",
                "Enter marks for each student",
                "Tap Save",
              ],
            ),

            _buildStepCard(
              title: "Step 5: View Results",
              items: [
                "After saving marks",
                "Tap View Result",
                "See ranked student list",
              ],
            ),

            _buildStepCard(
              title: "Step 6: Track Performance",
              items: [
                "View student average marks individually from student list",
                "Check monthly and yearly progress",
                "Identify top and weak students",
              ],
            ),

            _buildTipsCard(),
          ],
        ),
      ),
    );
  }

  // ---------------- INTRO CARD ----------------

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.indigo, Colors.blueAccent],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        "This app helps teachers manage students, batches, exams, and results in one place. It also helps track performance over time.",
        style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
      ),
    );
  }

  // ---------------- STEP CARD ----------------

  Widget _buildStepCard({required String title, required List<String> items}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

          ...items.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ", style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HIGHLIGHTED TIPS CARD ----------------

  Widget _buildTipsCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tips",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Text("• Create exam sessions before entering marks"),
          SizedBox(height: 6),
          Text("• Use consistent exam names"),
          SizedBox(height: 6),
          Text("• Check results after saving"),
        ],
      ),
    );
  }
}
