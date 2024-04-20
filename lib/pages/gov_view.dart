import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ecoevolve/pages/user_profile_page.dart';

void main() {
  runApp(const MaterialApp(
    home: ViewComplaintsPage(),
  ));
}

class ViewComplaintsPage extends StatefulWidget {
  const ViewComplaintsPage({Key? key}) : super(key: key);

  @override
  State<ViewComplaintsPage> createState() => _ViewComplaintsPageState();
}

class _ViewComplaintsPageState extends State<ViewComplaintsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen[400],
        title: const Text(
          'All Complaints',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to the user profile page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfilePage(),
                ),
              );
            },
            icon: const FaIcon(FontAwesomeIcons.circleUser),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.lightGreen[400],
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Received'),
                Tab(text: 'In Process'),
                Tab(text: 'Approved'),
                Tab(text: 'Completed'),
                Tab(text: 'All'),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightGreen[300]!, Colors.lightGreen[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            const ComplaintList(status: 'Received'),
            const ComplaintList(status: 'In Process'),
            const ComplaintList(status: 'Approved'),
            const ComplaintList(status: 'Completed'),
            AllComplaintsTab(),
          ],
        ),
      ),
    );
  }
}

class ComplaintList extends StatefulWidget {
  final String status;

  const ComplaintList({Key? key, required this.status}) : super(key: key);

  @override
  State<ComplaintList> createState() => _ComplaintListState();
}

class _ComplaintListState extends State<ComplaintList> {
  String _expandedComplaintId = '';
  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.status;
  }

  void _toggleExpansion(String complaintId) {
    setState(() {
      _expandedComplaintId =
          _expandedComplaintId == complaintId ? '' : complaintId;
    });
  }

  void _updateStatus(String? status) {
    if (status != null) {
      setState(() {
        _selectedStatus = status;
      });
    }
  }

  Future<void> _pickCompletionDate(
      BuildContext context, String complaintID) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintID)
          .update({'completionDate': Timestamp.fromDate(pickedDate)}).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Completion date updated successfully'),
        ));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update completion date: $error'),
        ));
      });
    }
  }

  void _submitStatus(String complaintID) {
    FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintID)
        .update({'status': _selectedStatus}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Status updated successfully'),
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update status: $error'),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('complaints')
          .where('status', isEqualTo: widget.status)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No complaints found.'),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            final Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            final String complaintID = document.id;
            final DateTime registrationDate =
                (data['registrationDate'] as Timestamp?)?.toDate() ??
                    DateTime.now();
            final DateTime? completionDate =
                (data['completionDate'] as Timestamp?)?.toDate();

            final String registrationDateString = registrationDate.toString();
            final String completionDateString = completionDate != null
                ? completionDate.toString()
                : 'Not completed yet';
            final int daysToComplete = completionDate != null
                ? completionDate.difference(registrationDate).inDays
                : 0;

            final isExpanded = _expandedComplaintId == complaintID;

            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              color: Colors.white,
              child: InkWell(
                onTap: () => _toggleExpansion(complaintID),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['complaint'] ?? 'No complaint type',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _pickCompletionDate(context, complaintID);
                            },
                            icon: const Icon(Icons.calendar_today),
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Description: ${data['description'] ?? 'No description'}',
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Location: ${data['location'] ?? 'Unknown location'}',
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Registration Date: $registrationDateString',
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Completion Date: $completionDateString',
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Days to Complete: $daysToComplete',
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${data['status'] ?? 'No status'}',
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Complaint ID: $complaintID',
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DropdownButton<String>(
                              value: _selectedStatus,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  _updateStatus(newValue);
                                }
                              },
                              items: <String>[
                                'Received',
                                'In Process',
                                'Approved',
                                'Completed'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _submitStatus(complaintID);
                              },
                              child: const Text('Submit'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class AllComplaintsTab extends StatefulWidget {
  const AllComplaintsTab({super.key});

  @override
  State<AllComplaintsTab> createState() => _AllComplaintsTabState();
}

class _AllComplaintsTabState extends State<AllComplaintsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.lightGreen[300]!, Colors.lightGreen[100]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('complaints')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No complaints found.',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dividerThickness: 2.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      headingRowHeight: 50,
                      dataRowMaxHeight: 60,
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Complaint Type',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Registration Date',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Completion Date',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Days to Complete',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Complaint ID',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      rows:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        final Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        final DateTime registrationDate =
                            (data['registrationDate'] as Timestamp?)
                                    ?.toDate() ??
                                DateTime.now();
                        final DateTime? completionDate =
                            (data['completionDate'] as Timestamp?)?.toDate();
                        final String completionDateString =
                            completionDate != null
                                ? completionDate.toString()
                                : 'Not completed yet';
                        final int daysToComplete = completionDate != null
                            ? completionDate.difference(registrationDate).inDays
                            : 0;

                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                data['complaint'] ?? 'No complaint type',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                data['description'] ?? 'No description',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                data['location'] ?? 'Unknown location',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                registrationDate.toString(),
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                completionDateString,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                daysToComplete.toString(),
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                data['status'] ?? 'No status',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                document.id,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
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
