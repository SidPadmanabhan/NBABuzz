import 'package:flutter/material.dart';
import 'package:nbaBuzz/services/apiservice.dart';

class StandingsPage extends StatefulWidget {
  @override
  _StandingsPageState createState() => _StandingsPageState();
}

class _StandingsPageState extends State<StandingsPage> {
  late Future<List<dynamic>> eastStandings;
  late Future<List<dynamic>> westStandings;

  @override
  void initState() {
    super.initState();
    eastStandings =
        ApiService().fetchStandings(conference: "east", season: "2024");
    westStandings =
        ApiService().fetchStandings(conference: "west", season: "2024");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Standings")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConferenceSection("Eastern Conference", eastStandings),
            SizedBox(height: 24.0),
            _buildConferenceSection("Western Conference", westStandings),
          ],
        ),
      ),
    );
  }

  Widget _buildConferenceSection(
      String title, Future<List<dynamic>> standingsFuture) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 8.0),
        FutureBuilder<List<dynamic>>(
          future: standingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No data available"));
            }

            final sortedTeams = snapshot.data!
              ..sort((a, b) => (b['win']['total'] as int)
                  .compareTo(a['win']['total'] as int));

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: sortedTeams.length,
              itemBuilder: (context, index) {
                final team = sortedTeams[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text("${index + 1}. ${team['team']['name']}",
                            style: TextStyle(fontSize: 16)),
                      ),
                      Text(
                          "W: ${team['win']['total']}, L: ${team['loss']['total']}",
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
