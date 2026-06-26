import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openUrl() async {
    final uri = Uri.parse('https://antidot.ca');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5)),
              const SizedBox(height: 32),
              // App icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.timer,
                      size: 40, color: Color(0xFF6C63FF)),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text('Time Tracker',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text('v1.0.0',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.4))),
              ),
              const SizedBox(height: 32),
              // Description
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Time Tracker is a simple yet powerful time tracking app '
                  'designed for freelancers and professionals. Track time on '
                  'tasks, organize with tags, set hourly rates to monitor '
                  'earnings, and export reports — all stored privately on '
                  'your device with no account required.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Developer info
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2C),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5A0).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.code,
                          color: Color(0xFF00E5A0), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Developed by',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white54)),
                          const SizedBox(height: 2),
                          const Text('Antidot Inc.',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: _openUrl,
                            child: const Text('antidot.ca',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6C63FF),
                                    decoration:
                                        TextDecoration.underline,
                                    decorationColor:
                                        Color(0xFF6C63FF))),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _openUrl,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.open_in_new,
                            color: Color(0xFF6C63FF), size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Text('Made with ♥ in Canada',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.3))),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
