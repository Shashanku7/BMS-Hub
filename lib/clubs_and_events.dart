import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClubsAndEventsPage extends StatelessWidget {
  const ClubsAndEventsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CLUBS AND EVENTS',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(title: 'Clubs'),
            const SizedBox(height: 16),
            const ClubsSection(),
            const SizedBox(height: 32),
            const SectionTitle(title: 'Upcoming Events'),
            const SizedBox(height: 16),
            const EventsSection(),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Color(0xFF3D5AFE),
      ),
    );
  }
}

class ClubsSection extends StatelessWidget {
  const ClubsSection({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> clubs = const [
    {
      'name': 'NINAAD',
      'icon': Icons.music_note,
      'description':
      'A vibrant community of music enthusiasts. NINAAD hosts regular jam sessions, musical nights, and vocal training workshops. It is known for its passionate members and soulful performances.',
      'longDescription':
      'NINAAD is the heart of musical expression at BMSCE. Whether you love singing, playing instruments, or just enjoying melodies, NINAAD has something for everyone. Join us for workshops, open mics, and musical festivals where talent finds its voice and friendships are made for life.',
    },
    {
      'name': 'Samskrutika Sambrama',
      'icon': Icons.person,
      'description':
      'A club dedicated to celebrating the cultural diversity of India. It organizes dance competitions, traditional art workshops, and cultural fests to promote heritage and unity.',
      'longDescription':
      'Immerse yourself in India\'s rich tapestry with Samskrutika Sambrama. We bring together all forms of art, culture, and tradition through dance, drama, and folk events. Experience the unity in diversity that makes our campus vibrant and inclusive.',
    },
    {
      'name': 'CODEIO',
      'icon': Icons.code,
      'description':
      'A hub for coding enthusiasts. CODEIO hosts hackathons, coding marathons, and regular coding challenges to sharpen programming skills. It\'s the go-to place for tech enthusiasts.',
      'longDescription':
      'CODEIO is the sanctuary for coders and technophiles. From beginner workshops to national-level hackathons, we make sure every member finds their tech tribe. Learn, collaborate, and innovate as you journey from student to software pro.',
    },
    {
      'name': 'PENTAGRAM',
      'icon': Icons.star,
      'description':
      'A mathematics and problem-solving club that challenges logical thinking and problem-solving abilities. PENTAGRAM regularly conducts quizzes, puzzle contests, and math olympiads.',
      'longDescription':
      'PENTAGRAM is where logic and numbers meet fun! Solve challenging puzzles, compete in math olympiads, and join a community that celebrates the beauty of mathematics. Every event is a step closer to sharper reasoning and analytical skills.',
    },
    {
      'name': 'IEEE BMSCE',
      'icon': Icons.flash_on,
      'description':
      'A professional technical club that aims to foster innovation and technological growth. It holds seminars, workshops, and projects related to electronics and engineering.',
      'longDescription':
      'IEEE BMSCE is committed to technical excellence and innovation. Participate in industry seminars, technical fests, and collaborative projects that open doors to global opportunities. Join us to connect, learn, and grow as a future engineer.',
    },
    {
      'name': 'Mountaineering Club',
      'icon': Icons.landscape,
      'description':
      'For adventure seekers and nature lovers. This club organizes trekking, rock climbing, and camping trips to explore the wild and push physical limits.',
      'longDescription':
      'Discover the thrill of the outdoors with the Mountaineering Club. Whether it\'s trekking, rock climbing, or camping, our adventures foster resilience, environmental awareness, and lifelong friendships. Let\'s conquer new heights together!',
    },
    {
      'name': 'ACM BMSCE',
      'icon': Icons.computer,
      'description':
      'An international society dedicated to computer science and research. It hosts talks, coding competitions, and networking events for aspiring software engineers.',
      'longDescription':
      'ACM BMSCE is your gateway to the world of computer science research and professional networking. We host expert talks, project expos, and competitions that hone your skills and connect you with the tech industry.',
    },
    {
      'name': 'Fine Arts Club',
      'icon': Icons.palette,
      'description':
      'A creative community for artists. The Fine Arts Club encourages painting, sketching, sculpture, and digital art through regular exhibitions and workshops.',
      'longDescription':
      'Unleash your creativity with the Fine Arts Club! Whether you love painting, sketching, or sculpture, this is the place for artistic exploration and expression. Join us for workshops, exhibitions, and collaborations with fellow artists.',
    },
  ];

  void _launchInstagram() async {
    const url = 'https://www.instagram.com/';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: clubs.length,
      itemBuilder: (context, index) {
        final club = clubs[index];
        return GestureDetector(
          onTap: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(club['name']),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club['longDescription'] ?? club['description'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.instagram,
                            color: Colors.purple,
                          ),
                          onPressed: _launchInstagram,
                          tooltip: 'Instagram',
                        ),
                        const SizedBox(width: 8),
                        const Text('Visit Instagram', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
          child: ClubCard(
            title: club['name'],
            icon: club['icon'],
          ),
        );
      },
    );
  }
}

class ClubCard extends StatelessWidget {
  final String title;
  final IconData icon;
  const ClubCard({
    required this.title,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, color: const Color(0xFF888888), size: 22),
        ],
      ),
    );
  }
}

class EventsSection extends StatelessWidget {
  const EventsSection({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> events = const [
    {
      'name': 'Gen - AI Hackathon',
      'date': 'May 7',
      'icon': Icons.group,
      'description':
      'A 24-hour hackathon focused on generative AI. Participants will build innovative solutions using AI tools, collaborate in teams, and compete for exciting prizes. No prior experience is required—just bring your creativity and passion for technology.',
      'longDescription':
      'Gen - AI Hackathon brings together creative minds to build, innovate, and solve real-world problems using generative AI. With workshops, mentorship, and non-stop coding, it\'s the ultimate test of your technical and teamwork skills. Open to all students!',
    },
    {
      'name': 'Pratidhwani',
      'date': 'May 9',
      'icon': Icons.mic,
      'description':
      'An annual cultural extravaganza featuring music, dance, drama, and more. Pratidhwani celebrates talent and diversity, offering a platform for students to showcase their artistic flair and connect with peers.',
      'longDescription':
      'Pratidhwani is the grand stage for cultural performances at BMSCE. From classical to contemporary, solo to group acts, there is room for every genre and artist. Join us for a celebration of art, harmony, and unforgettable memories!',
    },
    {
      'name': 'TechXpo',
      'date': 'May 13',
      'icon': Icons.science,
      'description':
      'A technology exhibition featuring innovative student projects, workshops, and guest lectures from industry leaders.',
      'longDescription':
      'TechXpo is an annual showcase of the best technological innovations by students. Explore cutting-edge projects, attend informative workshops, and network with industry experts. A must-attend for any tech enthusiast!',
    },
    {
      'name': 'Art Fest',
      'date': 'May 18',
      'icon': Icons.brush,
      'description':
      'A festival celebrating visual arts—painting, sculpture, digital art, and live demonstrations by renowned artists.',
      'longDescription':
      'Art Fest transforms the campus into a vibrant gallery of creativity. Participate in painting competitions, attend live art demonstrations, and admire the works of talented artists. Whether you create art or appreciate it, there’s something for everyone.',
    },
    {
      'name': 'Sports Day',
      'date': 'May 20',
      'icon': Icons.sports_soccer,
      'description':
      'An action-packed day with athletics, football, cricket, and fun games for all students.',
      'longDescription':
      'Sports Day is about teamwork, competition, and fun! Take part in various sports events, cheer for your friends, and experience the thrill of healthy competition. All students are welcome, regardless of skill level.',
    },
    {
      'name': 'Eco Awareness Drive',
      'date': 'May 22',
      'icon': Icons.eco,
      'description':
      'An environmental awareness campaign with seminars, tree planting, and clean-up activities.',
      'longDescription':
      'Join us for the Eco Awareness Drive! Participate in seminars, pledge to protect the environment, and help clean up our campus and nearby parks. Make a difference—one tree, one action at a time.',
    },
    {
      'name': 'Food Festival',
      'date': 'May 25',
      'icon': Icons.restaurant,
      'description':
      'A celebration of global cuisines with food stalls, cooking contests, and live tastings.',
      'longDescription':
      'Experience a world of flavors at the Food Festival! Sample dishes from around the globe, take part in cooking contests, and enjoy live tastings and entertainment. Bring your appetite!',
    },
    {
      'name': 'Quiz Mania',
      'date': 'May 27',
      'icon': Icons.quiz,
      'description':
      'A general knowledge quiz competition open to all students.',
      'longDescription':
      'Show off your smarts at Quiz Mania! Compete in teams or solo, tackle questions from every subject, and win exciting prizes. It’s fun, fast, and open to all!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: events.map((event) {
        return EventCard(
          title: event['name'],
          date: event['date'],
          icon: event['icon'],
          description: event['longDescription'] ?? event['description'],
        );
      }).toList(),
    );
  }
}

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  final String description;

  const EventCard({
    required this.title,
    required this.date,
    required this.icon,
    required this.description,
    Key? key,
  }) : super(key: key);

  void _showEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(description, style: const TextStyle(fontSize: 16)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEventDialog(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              date,
              style: const TextStyle(color: Color(0xFF888888), fontSize: 14),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
            ),
            Icon(icon, color: const Color(0xFF888888), size: 22),
          ],
        ),
      ),
    );
  }
}