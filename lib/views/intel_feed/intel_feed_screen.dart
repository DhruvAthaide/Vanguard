import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'intel_category_bar.dart';
import 'intel_card.dart';

class IntelFeedScreen extends StatelessWidget {
  const IntelFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final intelItems = [
      {
        "category": "Exploits",
        "title": "Critical Android Kernel Zero-Day",
        "summary":
        "A new zero-day vulnerability allows privilege escalation on multiple Android versions.",
      },
      {
        "category": "Malware",
        "title": "Banking Trojan Targeting India",
        "summary":
        "A sophisticated trojan abuses Accessibility Services to steal credentials.",
      },
      {
        "category": "Mobile Security",
        "title": "iOS Sandbox Escape Research",
        "summary":
        "Researchers demonstrated a partial sandbox escape affecting iOS 17.",
      },
      {
        "category": "Threat Intel",
        "title": "APT Group Infrastructure Shift",
        "summary":
        "Known APT actors migrated C2 infrastructure to residential IP ranges.",
      },
      {
        "category": "Leaks",
        "title": "Massive Credential Dump Found",
        "summary":
        "Over 200M credentials surfaced on underground forums this week.",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Intel Feed"),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const IntelCategoryBar(),
          Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: intelItems.length,
                itemBuilder: (context, index) {
                  final item = intelItems[index];

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 450),
                    child: SlideAnimation(
                      verticalOffset: 40,
                      curve: Curves.easeOutCubic,
                      child: FadeInAnimation(
                        child: IntelCard(
                          category: item["category"]!,
                          title: item["title"]!,
                          summary: item["summary"]!,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
