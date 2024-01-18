//Function to return all patients
import '../Screen/Masterlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Screen/Dashboard.dart';

CollectionReference patientsCollection =
    FirebaseFirestore.instance.collection('patients');
CollectionReference medicationInventoryCollection =
    FirebaseFirestore.instance.collection('medication_inventory');

Future<List<Patient>> getAllPatients() async {
  QuerySnapshot querySnapshot = await patientsCollection.get();
  return querySnapshot.docs.map((DocumentSnapshot document) {
    return Patient(
      id: document['id'],
      name: document['name'],
    );
  }).toList();
}

Future<List<medication_inventory>> getAllMedicalInventory() async {
  QuerySnapshot querySnapshot = await medicationInventoryCollection.get();
  return querySnapshot.docs.map((DocumentSnapshot document) {
    return medication_inventory(
      med_name: document['med_name'],
      med_quan: document['med_quan'],
    );
  }).toList();
}

Future<Map<String, int>> getMedicationQuantities() async {
  final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collectionGroup('medications').get();

  final Map<String, int> medicationQuantities = {};

  for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
      in querySnapshot.docs) {
    final String medName = doc.data()['med_name'] as String;
    final int medQuan = doc.data()['med_quan'] as int;

    if (medicationQuantities.containsKey(medName)) {
      medicationQuantities[medName] = medicationQuantities[medName]! + medQuan;
    } else {
      medicationQuantities[medName] = medQuan;
    }
  }

  return medicationQuantities;
}

class DataService {
  static Future<Map<String, dynamic>> getPatientData(String patientId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('id', isEqualTo: patientId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming there is only one document matching the ID
        return querySnapshot.docs.first.data();
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> getMedications(
      String patientId) async {
    try {
      final medicationsSnapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('id', isEqualTo: patientId)
          .limit(1)
          .get();

      if (medicationsSnapshot.docs.isNotEmpty) {
        final patientDoc = medicationsSnapshot.docs.first;

        final medicationsSubcollection =
            await patientDoc.reference.collection('medications').get();

        int count = 0;
        return medicationsSubcollection.docs.map((medicationDoc) {
          count++;
          return {
            'name': medicationDoc['med_name'],
            'dosage': medicationDoc['dosage'].toString(),
            'indication': medicationDoc['med_ind'].toString(),
            'contraindication': medicationDoc['contraindication'].toString(),
            'diet': medicationDoc['diet'].toString(),
            'count': count,
          };
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching medications: $e');
      return [];
    }
  }
}
