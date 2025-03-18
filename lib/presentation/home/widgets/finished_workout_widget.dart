import 'package:fitnessapp/utils/managers/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FinishedWorkoutsWidget extends StatefulWidget {
  @override
  _FinishedWorkoutsWidgetState createState() => _FinishedWorkoutsWidgetState();
}

class _FinishedWorkoutsWidgetState extends State<FinishedWorkoutsWidget> {
  bool _showAll = false; // Toggle to show all workouts

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('finishedWorkouts')
          .doc(userId)
          .collection('finishedWorkoutsData')
          .orderBy('dateTime', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(12),
            child: Text("No workouts finished yet.", style: TextStyle(fontSize: 16)),
          );
        }

        List<QueryDocumentSnapshot> workouts = snapshot.data!.docs;
        int itemCount = _showAll ? workouts.length : workouts.length.clamp(0, 3);

        return Container(
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            // Adjust to match your app theme
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Finished Workouts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),

              // Display workout list
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  var workout = workouts[index];
                  return Card(
                    color: Colors.blueGrey[800], // Adjust to match your app theme
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(Icons.fitness_center, color: Colors.greenAccent),
                      title: Text(workout['name'], style: TextStyle(color: Colors.white)),
                      subtitle: Text(
                        "Reps: ${workout['repNumber']}, Sets: ${workout['setNumber']}",
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: Text(
                        workout['dateTime'].toDate().toString().split(" ")[0],
                        style: TextStyle(color: Colors.white60),
                      ),
                    ),
                  );
                },
              ),
                SizedBox(height: 8),
              // "View All" Button
              if (workouts.length > 3)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showAll = !_showAll; // Toggle view mode
                      });
                    },
                    child: Text(
                      _showAll ? "Show Less" : "View All",
                      style: TextStyle(color: ColorManager.limeGreen, fontSize: 16),
                    ),
                  ),
                ),
            ],
            
          ),
        );
      },
    );
  }
}
