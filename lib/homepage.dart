import 'package:flutter/material.dart';
import 'settings.dart'; // Import the settings.dart page
import 'website.dart';
import 'feedback.dart';
import 'lost_and_found.dart';
import 'placement_stats.dart';
import 'attendance.dart';
import 'resources.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const AnnouncementsScreen(),
    const PlaceholderWidget("Campus Map"),
    const ProfileScreen(),
  ];

  void _onMenuOptionSelected(BuildContext context, String option) {
    if (option == "Settings") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AppSettingsScreen(),
        ),
      );
    }else if (option == "Campus Website") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WebsiteScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$option Selected")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "BMS Hub!",
          style: TextStyle(color: Colors.white),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: const Center(
                child: Text(
                  "Menu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text("Settings", style: TextStyle(color: Colors.white)),
              onTap: () => _onMenuOptionSelected(context, "Settings"),
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.white),
              title: const Text("Campus Website", style: TextStyle(color: Colors.white)),
              onTap: () => _onMenuOptionSelected(context, "Campus Website"),
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text("About Us", style: TextStyle(color: Colors.white)),
              onTap: () => _onMenuOptionSelected(context, "About Us"),
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: List.generate(4, (index) {
          final icons = [
            Icons.home,
            Icons.campaign,
            Icons.map_outlined,
            Icons.person_outline,
          ];
          final labels = ["Home", "Announcements", "Campus Map", "Profile"];
          return BottomNavigationBarItem(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                if (_currentIndex == index)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                Icon(
                  icons[index],
                  size: _currentIndex == index ? 30 : 24,
                  color: _currentIndex == index ? Colors.white : Colors.white54,
                ),
              ],
            ),
            label: labels[index],
          );
        }),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.blue,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: const Text(
            "WELCOME BACK!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(20.0),
            crossAxisSpacing: 20.0,
            mainAxisSpacing: 20.0,
            children: [
              _buildMenuItem(context, Icons.menu_book, "Study Resources",StudyResourcesHome()),
              _buildMenuItem(context, Icons.show_chart, "Placement Stats",PlacementStatsPage()),
              _buildMenuItem(context, Icons.event, "Clubs and Events"),
              _buildMenuItem(
                  context, Icons.help_outline, "Lost And Found", LostAndFoundPage()),
              _buildMenuItem(context, Icons.person_add, "Attendance Tracker",AttendanceTrackerPage()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String label,
      [Widget? destination]) {
    return GestureDetector(
      onTap: () {
        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$label Selected")),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Column(
      children: [
        Container(
          color: Colors.blue,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: const Text(
            "ANNOUNCEMENTS",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            thickness: 6,
            radius: const Radius.circular(10),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20.0),
              children: [
                _buildAnnouncementCard(
                  title: "UTSAV 2025 🎉",
                  description: "UNLEASH THE VIBE, IGNITE THE NIGHT – UTSAV IS HERE!",
                ),
                const SizedBox(height: 15),
                _buildAnnouncementCard(
                  title: "UG 2025 Graduation Day 🎓",
                  description: "BMSCE UG - 2025 BATCH GRADUATION DAY (20/5/2025)",
                ),
                const SizedBox(height: 15),
                _buildAnnouncementCard(
                  title: "EVEN SEM CIE III",
                  description: "BMSCE UG - IV, VI, VIII SEMESTER TIMETABLE FOR CIE III",
                ),
                const SizedBox(height: 15),
                _buildAnnouncementCard(
                  title: "Hackathon 2025 🚀",
                  description: "Join the annual hackathon and showcase your skills!",
                ),
                const SizedBox(height: 15),
                _buildAnnouncementCard(
                  title: "Alumni Meet 2025 🎓",
                  description: "Reconnect with your batchmates on Alumni Meet Day.",
                ),
                const SizedBox(height: 15),
                _buildAnnouncementCard(
                  title: "Library Week 📚",
                  description: "Enjoy exclusive events and workshops at the library.",
                ),
                const SizedBox(height: 15),
                _buildAnnouncementCard(
                  title: "Sports Fest 2025 🏆",
                  description: "Gear up for this year's Sports Fest and win medals!",
                ),
                const SizedBox(height: 15),
                _buildAnnouncementCard(
                  title: "Tech Seminar 🎙️",
                  description: "Attend the seminar on AI and Machine Learning trends.",
                ),
                const SizedBox(height: 15),
                _buildAnnouncementCard(
                  title: "Cultural Fest 🎭",
                  description: "Show your artistic skills in the annual Cultural Fest.",
                ),
                const SizedBox(height: 15),
                _buildAnnouncementCard(
                  title: "Placement Drive 2025 💼",
                  description: "Top companies are visiting – get ready for placements!",
                ),
                const SizedBox(height: 15),
                _buildAnnouncementCard(
                  title: "Blood Donation Camp ❤️",
                  description: "Participate in the camp and save lives.",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard({required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "READ IN DETAIL",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('images/bms_logo.jpg'),
        ),
        const SizedBox(height: 20),
        const Text(
          "BMSCE",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 10),
        const Text(
          "Shashank U",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          "shashanku.cs23@bmsce.ac.in",
          style: TextStyle(
              color: Colors.white70,
              fontSize: 14),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildActionButton(Icons.edit, "Edit Profile", () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Edit Profile Selected")),
                );
              }),
              const SizedBox(height: 25),
              _buildActionButton(Icons.settings, "App Settings", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppSettingsScreen(),
                  ),
                );
              }),
              const SizedBox(height: 25),
              _buildActionButton(Icons.download, "Downloaded files", () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Downloaded Files Selected")),
                );
              }),
              const SizedBox(height: 25),
              _buildActionButton(Icons.feedback, "Give us feedback", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeedbackScreen(),
                  ),
                );
              }),
              const SizedBox(height: 25),
              _buildActionButton(Icons.info, "App info", () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("App Info Selected")),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
class PlaceholderWidget extends StatelessWidget {
  final String text;
  const PlaceholderWidget(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}