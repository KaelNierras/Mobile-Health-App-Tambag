// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Custom_Widgets/Add_Medication_Dialog_Profile.dart';
import '../Custom_Widgets/CustomActionButton.dart';
import '../Custom_Widgets/Custom_Appbar.dart';
import '../Custom_Widgets/Custom_TextField.dart';
import '../Screen/Dashboard.dart';
import '../constants/light_constants.dart';
import '../functions/custom_functions.dart';

class AddProfilePage extends StatefulWidget {
  const AddProfilePage({super.key});

  @override
  _AddProfilePageState createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController physicianController = TextEditingController();
  List<Map<String, dynamic>> medicationList = [];
  String highestIdValue = '';

  @override
  void initState()  {
    super.initState();
  }

  final CollectionReference patientsCollection = FirebaseFirestore.instance.collection('patients');
  final CollectionReference followUpCollection = FirebaseFirestore.instance.collection('follow_up_history');

  Future<void> addProfileToFirebase() async {
    try {
      // Add profile data to the patients collection
      String id = await getHighestIdDocument();
      DocumentReference profileReference =
          await patientsCollection.add(getProfileData(id));

      await followUpCollection.add(newFolowup(id));

      // Add medication data to the subcollection
      CollectionReference medicationCollection =
          profileReference.collection('medications');
      for (Map<String, dynamic> medicationDetails in medicationList) {
        await medicationCollection.add(medicationDetails);
      }
      showSuccessNotification('Successfully added');
    } catch (e) {
      showErrorNotification('Error adding profile to Firebase: $e');
    }
  }

  Future<String> getHighestIdDocument() async {
    try {
      // Replace 'patients' with your collection name
      QuerySnapshot querySnapshot = await patientsCollection
          .orderBy('id', descending: true)
          .limit(1)
          .get();

      // Check if there are any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Access the document with the highest 'id' value
        DocumentSnapshot highestIdDocument = querySnapshot.docs.first;

        // Access the 'id' field value from the document
        String highestIdValue = (int.parse(highestIdDocument['id']) + 1).toString();
        return highestIdValue;
      } else {
        return '1'; // Return a default value if no documents are found
      }
    } catch (e) {
      return ''; // Return a default value in case of an error
    }
  }


  Map<String, dynamic> getProfileData(String id) {
    return {
      'name': nameController.text,
      'age': ageController.text,
      'address': addressController.text,
      'contact_number': contactNumberController.text,
      'physician': physicianController.text,
      'id' : id,
    };
  }

  Map<String, dynamic> newFolowup(String id) {
    return {
      'isDone': true,
      'id' : id,
    };
  }

  void _showMyDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(width: 2, color: periwinkleColor),
          ),
          scrollable: true,
          backgroundColor: backgroundColor,
          contentPadding: const EdgeInsets.all(20.0),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(periwinkleColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AddMedicationProfile(
                medicationList: medicationList,
                addMedicationCallback:
                    (Map<String, dynamic> medicationDetails) {
                  // Callback function to update medicationList in File 2
                  setState(() {
                    medicationList.add(medicationDetails);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      SafeArea(child: Container(
        height: MediaQuery.of(context).size.height, // Adjust as needed
        color: backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Custom_Appbar(
              titleFontSize: 25,
              hasBrgy: false,
              Baranggay: "Profile",
              Apptitle: "Add Profile",
              hasbackIcon: true,
              hasRightIcon: false,
              iconColor: Colors.white,
              DistinationBack: () => goToPage(context, const Dashboard()),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        controller: nameController,
                        labelText: 'Name:',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        controller: ageController,
                        labelText: 'Age:',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        controller: addressController,
                        labelText: 'Address:',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Medication:',
                            style: TextStyle(
                              color: periwinkleColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: periwinkleColor, // Set the border color
                                width: 2.0, // Set the border width
                              ),
                              borderRadius: BorderRadius.circular(
                                  12.0), // Set the border radius
                            ),
                            child: SizedBox(
                              height:
                                  150.0, // Set a specific height for the container
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ListView.builder(
                                  itemCount: medicationList.length,
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> medicationDetails =
                                        medicationList[index];
                                    return ListTile(
                                      title: Text(
                                        medicationDetails['med_name'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: periwinkleColor,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${medicationDetails['dosage'] ?? ''}',
                                        style: const TextStyle(
                                          fontSize:
                                              13, // Adjust the font size as needed
                                          color: periwinkleColor,
                                        ),
                                      ),
                                      // You can customize the ListTile further if needed
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showMyDialog(context);
                            },
                            child: const Text(
                              'Add Medication',
                              style: TextStyle(
                                color: periwinkleColor, // Set the text color
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        controller: contactNumberController,
                        labelText: 'Contact Number:',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomTextField(
                        controller: physicianController,
                        labelText: 'Physician:',
                      ),
                      const SizedBox(height: 10,),
                      Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                      CustomActionButton(  
                          onPressed: () {
                            addProfileToFirebase();
                            goToPage(context,const Dashboard());  
                          },
                          buttonText: "Add",
                        ),
                      ],)                  
                    ],
                  ),
                ),
                  ], ),
              ),
            )
            
          ],
        ),
      ),),
      
      
    );
  }
}
