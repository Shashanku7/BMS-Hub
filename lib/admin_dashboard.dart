import 'package:flutter/material.dart';

// ----------------------- MAIN ADMIN DASHBOARD -----------------------
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          AdminTile(
            icon: Icons.announcement,
            title: 'Manage Announcements',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnnouncementsPage(),
                ),
              );
            },
          ),
          AdminTile(
            icon: Icons.group,
            title: 'Manage Clubs & Events',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ClubsEventsPage(),
                ),
              );
            },
          ),
          AdminTile(
            icon: Icons.work,
            title: 'Manage Placement Statistics',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlacementStatsPage(),
                ),
              );
            },
          ),
          AdminTile(
            icon: Icons.fact_check,
            title: 'Review Study Material Requests',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudyMaterialReviewPage(),
                ),
              );
            },
          ),
          AdminTile(
            icon: Icons.backpack,
            title: 'Review Lost & Found Requests',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LostFoundReviewPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AdminTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const AdminTile({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

// ----------------------- ANNOUNCEMENTS MODULE -----------------------
class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});
  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  List<Map<String, String>> announcements = [
    {'title': 'Holiday Notice', 'body': 'College will remain closed on Friday.'},
    {'title': 'Exam Schedule', 'body': 'Mid-semester exams from June 10.'},
  ];

  void _addAnnouncement() async {
    final newAnnouncement = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _AnnouncementDialog(),
    );
    if (newAnnouncement != null) {
      setState(() => announcements.add(newAnnouncement));
    }
  }

  void _editAnnouncement(int index) async {
    final edited = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _AnnouncementDialog(
        initial: announcements[index],
      ),
    );
    if (edited != null) {
      setState(() => announcements[index] = edited);
    }
  }

  void _deleteAnnouncement(int index) {
    setState(() => announcements.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: ListView.builder(
        itemCount: announcements.length,
        itemBuilder: (ctx, i) => Card(
          child: ListTile(
            title: Text(announcements[i]['title'] ?? ''),
            subtitle: Text(announcements[i]['body'] ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editAnnouncement(i),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteAnnouncement(i),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAnnouncement,
        child: const Icon(Icons.add),
        tooltip: 'Add Announcement',
      ),
    );
  }
}

class _AnnouncementDialog extends StatefulWidget {
  final Map<String, String>? initial;
  const _AnnouncementDialog({this.initial});
  @override
  State<_AnnouncementDialog> createState() => _AnnouncementDialogState();
}

class _AnnouncementDialogState extends State<_AnnouncementDialog> {
  late TextEditingController titleCtrl;
  late TextEditingController bodyCtrl;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.initial?['title']);
    bodyCtrl = TextEditingController(text: widget.initial?['body']);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add Announcement' : 'Edit Announcement'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleCtrl,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: bodyCtrl,
            decoration: const InputDecoration(labelText: 'Body'),
            minLines: 2,
            maxLines: 4,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (titleCtrl.text.isNotEmpty && bodyCtrl.text.isNotEmpty) {
              Navigator.pop(context, {
                'title': titleCtrl.text,
                'body': bodyCtrl.text,
              });
            }
          },
          child: Text(widget.initial == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}

// ----------------------- CLUBS & EVENTS MODULE -----------------------
class ClubsEventsPage extends StatefulWidget {
  const ClubsEventsPage({super.key});
  @override
  State<ClubsEventsPage> createState() => _ClubsEventsPageState();
}

class _ClubsEventsPageState extends State<ClubsEventsPage> {
  List<Map<String, String>> clubs = [
    {'name': 'Photography Club', 'desc': 'Capture your moments.'},
    {'name': 'Coding Club', 'desc': 'Hackathons and coding fun.'},
  ];

  void _addClub() async {
    final newClub = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _ClubDialog(),
    );
    if (newClub != null) {
      setState(() => clubs.add(newClub));
    }
  }

  void _editClub(int index) async {
    final edited = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _ClubDialog(initial: clubs[index]),
    );
    if (edited != null) {
      setState(() => clubs[index] = edited);
    }
  }

  void _deleteClub(int index) {
    setState(() => clubs.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clubs & Events')),
      body: ListView.builder(
        itemCount: clubs.length,
        itemBuilder: (ctx, i) => Card(
          child: ListTile(
            title: Text(clubs[i]['name'] ?? ''),
            subtitle: Text(clubs[i]['desc'] ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editClub(i),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteClub(i),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addClub,
        child: const Icon(Icons.add),
        tooltip: 'Add Club/Event',
      ),
    );
  }
}

class _ClubDialog extends StatefulWidget {
  final Map<String, String>? initial;
  const _ClubDialog({this.initial});
  @override
  State<_ClubDialog> createState() => _ClubDialogState();
}

class _ClubDialogState extends State<_ClubDialog> {
  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.initial?['name']);
    descCtrl = TextEditingController(text: widget.initial?['desc']);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add Club/Event' : 'Edit Club/Event'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: descCtrl,
            decoration: const InputDecoration(labelText: 'Description'),
            minLines: 2,
            maxLines: 4,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (nameCtrl.text.isNotEmpty && descCtrl.text.isNotEmpty) {
              Navigator.pop(context, {
                'name': nameCtrl.text,
                'desc': descCtrl.text,
              });
            }
          },
          child: Text(widget.initial == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}

// ----------------------- PLACEMENT STATISTICS MODULE -----------------------
class PlacementStatsPage extends StatefulWidget {
  const PlacementStatsPage({super.key});
  @override
  State<PlacementStatsPage> createState() => _PlacementStatsPageState();
}

class _PlacementStatsPageState extends State<PlacementStatsPage> {
  List<Map<String, String>> placements = [
    {'company': 'Google', 'students': '3', 'details': 'CTC: 35LPA'},
    {'company': 'Infosys', 'students': '10', 'details': 'CTC: 6LPA'},
  ];

  void _addPlacement() async {
    final newPlacement = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _PlacementDialog(),
    );
    if (newPlacement != null) {
      setState(() => placements.add(newPlacement));
    }
  }

  void _editPlacement(int index) async {
    final edited = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _PlacementDialog(initial: placements[index]),
    );
    if (edited != null) {
      setState(() => placements[index] = edited);
    }
  }

  void _deletePlacement(int index) {
    setState(() => placements.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Placement Statistics')),
      body: ListView.builder(
        itemCount: placements.length,
        itemBuilder: (ctx, i) => Card(
          child: ListTile(
            title: Text(placements[i]['company'] ?? ''),
            subtitle: Text(
                'Selected: ${placements[i]['students']} | ${placements[i]['details']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editPlacement(i),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deletePlacement(i),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlacement,
        child: const Icon(Icons.add),
        tooltip: 'Add Placement',
      ),
    );
  }
}

class _PlacementDialog extends StatefulWidget {
  final Map<String, String>? initial;
  const _PlacementDialog({this.initial});
  @override
  State<_PlacementDialog> createState() => _PlacementDialogState();
}

class _PlacementDialogState extends State<_PlacementDialog> {
  late TextEditingController companyCtrl;
  late TextEditingController studentsCtrl;
  late TextEditingController detailsCtrl;

  @override
  void initState() {
    super.initState();
    companyCtrl = TextEditingController(text: widget.initial?['company']);
    studentsCtrl = TextEditingController(text: widget.initial?['students']);
    detailsCtrl = TextEditingController(text: widget.initial?['details']);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Add Placement' : 'Edit Placement'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: companyCtrl,
            decoration: const InputDecoration(labelText: 'Company'),
          ),
          TextField(
            controller: studentsCtrl,
            decoration: const InputDecoration(labelText: 'Students Selected'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: detailsCtrl,
            decoration: const InputDecoration(labelText: 'Details'),
            minLines: 1,
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (companyCtrl.text.isNotEmpty &&
                studentsCtrl.text.isNotEmpty &&
                detailsCtrl.text.isNotEmpty) {
              Navigator.pop(context, {
                'company': companyCtrl.text,
                'students': studentsCtrl.text,
                'details': detailsCtrl.text,
              });
            }
          },
          child: Text(widget.initial == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}

// ----------------------- STUDY MATERIAL REQUESTS (REVIEW) -----------------------
class StudyMaterialReviewPage extends StatefulWidget {
  const StudyMaterialReviewPage({super.key});
  @override
  State<StudyMaterialReviewPage> createState() => _StudyMaterialReviewPageState();
}

class _StudyMaterialReviewPageState extends State<StudyMaterialReviewPage> {
  // For demo, pending requests are in this list
  List<Map<String, String>> requests = [
    {'title': 'SEM1 Notes', 'by': 'Alice', 'status': 'pending'},
    {'title': 'DBMS Paper', 'by': 'Bob', 'status': 'pending'},
  ];
  // Approved materials
  List<Map<String, String>> approved = [];

  void _approve(int index) {
    setState(() {
      approved.add({...requests[index], 'status': 'approved'});
      requests.removeAt(index);
    });
  }

  void _reject(int index) {
    setState(() => requests.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Material Requests')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Pending Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (ctx, i) => Card(
                child: ListTile(
                  title: Text(requests[i]['title'] ?? ''),
                  subtitle: Text('By: ${requests[i]['by']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _approve(i),
                        tooltip: 'Approve',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _reject(i),
                        tooltip: 'Reject',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Approved Materials', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: approved.length,
              itemBuilder: (ctx, i) => Card(
                child: ListTile(
                  title: Text(approved[i]['title'] ?? ''),
                  subtitle: Text('By: ${approved[i]['by']}'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------- LOST & FOUND REQUESTS (REVIEW) -----------------------
class LostFoundReviewPage extends StatefulWidget {
  const LostFoundReviewPage({super.key});
  @override
  State<LostFoundReviewPage> createState() => _LostFoundReviewPageState();
}

class _LostFoundReviewPageState extends State<LostFoundReviewPage> {
  List<Map<String, String>> lostFoundRequests = [
    {'item': 'Calculator', 'by': 'Alice', 'status': 'pending'},
    {'item': 'ID Card', 'by': 'Bob', 'status': 'pending'},
  ];
  List<Map<String, String>> resolved = [];

  void _approve(int index) {
    setState(() {
      resolved.add({...lostFoundRequests[index], 'status': 'resolved'});
      lostFoundRequests.removeAt(index);
    });
  }

  void _reject(int index) {
    setState(() => lostFoundRequests.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lost & Found Requests')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Pending Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: lostFoundRequests.length,
              itemBuilder: (ctx, i) => Card(
                child: ListTile(
                  title: Text(lostFoundRequests[i]['item'] ?? ''),
                  subtitle: Text('By: ${lostFoundRequests[i]['by']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _approve(i),
                        tooltip: 'Mark as Resolved',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _reject(i),
                        tooltip: 'Reject',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Resolved', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: resolved.length,
              itemBuilder: (ctx, i) => Card(
                child: ListTile(
                  title: Text(resolved[i]['item'] ?? ''),
                  subtitle: Text('By: ${resolved[i]['by']}'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}