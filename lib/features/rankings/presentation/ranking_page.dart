import 'package:flutter/material.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                child: Text('Friends'),
                onPressed: () {
                  // Handle friends button press
                },
              ),
            ),
            SizedBox(width: 8), // Add some space between the buttons
            Expanded(
              child: ElevatedButton(
                child: Text('Global'),
                onPressed: () {
                  // Handle global button press
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            onChanged: (value) {
              // Handle search input change
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 20, // Replace with your data length
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 8.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                  leading: Text(
                    '${index + 1}', // Display rank number in ascending order
                    style: TextStyle(
                    fontSize: 18.0, 
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                  title: Text('User ${20 - index - 1}'),
                  trailing: Text(
                    '${(20 - index - 1) * 2} hrs', // Display hours in descending order
                  ),
                  ),
                ),
              );    
            },
          ),
        ),
      ],
    );
  }
}
