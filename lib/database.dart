
import 'package:cloud_firestore/cloud_firestore.dart';

class Databases{
  late FirebaseFirestore firestore;
  initialise(){
    firestore = FirebaseFirestore.instance;
  }
  void create_driver(String name,String _uid,String number,String email, String number_plate)async{
    try{
      await firestore.collection("drivers").doc(_uid).set({'name':name,'number':number,'email':email,'numberplate':number_plate,'type':'driver'});
    }catch(e){
      print(e);
    }
  }
  void create_passenger(String name,String _uid,String number,String email)async{
    try{
      await firestore.collection("passengers").doc(_uid).set({'name':name,'number':number,'email':email,'type':'passenger'});
    }catch(e){
      print(e);
    }
  }
  void create_request(String from,String to,String uid,String pending,String driver_uid)async{
    try{
      await firestore.collection("requests").doc(uid).set({'from':from,'to':to,'pending':pending,'driver_uid':driver_uid});
    }catch(e){
      print(e);
    }
  }
  /// Live view of one passenger's own request. Emits null once it is cleared.
  ///
  /// Replaces polling check_request() on a timer. A listener is billed one
  /// read when it attaches and one per changed document after that, so an
  /// idle waiting screen costs nothing.
  Stream<Map<String, dynamic>?> watch_request(String uid) {
    return firestore
        .collection("requests")
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  /// Live view of every unclaimed request, for the driver's list.
  ///
  /// The pending filter runs server-side, so accepted rides are never sent to
  /// the client and never billed. Replaces polling read(), which fetched the
  /// whole collection once a second and filtered on the device.
  Stream<List<Map<String, dynamic>>> watch_open_requests() {
    return firestore
        .collection("requests")
        .where('pending', isEqualTo: '0')
        .snapshots()
        .map((query) => query.docs
            .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
            .toList());
  }

  Future read() async{
    QuerySnapshot querySnapshot;
    List docs=[];
    try{
      querySnapshot= await firestore.collection('requests').get();
      if(querySnapshot.docs.isNotEmpty){
        for(var doc in querySnapshot.docs.toList()){
          Map a ={"id" : doc.id, "from" : doc['from'], "to" : doc['to'],"pending":doc['pending'],"driver_uid":doc['driver_uid']};
          docs.add(a);
        }
        return docs;

      }
    } catch(e){
      print(e);
      return docs;
    }

  }
  void delete(String id) async{
    try{
      await firestore.collection("requests").doc(id).delete();
    }catch(e){
      print(e);
    }
  }
  Future check_request(String uid) async{
    late Map? a;
    try{
      var snapshot=await firestore.collection("requests").doc(uid).get();
      a=snapshot.data();
      // print(a!['name']);
      return a;

    } catch(e){
      print(e);
    }


  }
  Future get_passenger(String uid) async{
    late Map? a;
    try{
      var snapshot=await firestore.collection("passengers").doc(uid).get();
      a=snapshot.data();
      // print(a!['name']);
      return a;

    } catch(e){
      print(e);
    }


  }
  Future get_driver(String uid) async{
    late Map? a;
    try{
      var snapshot=await firestore.collection("drivers").doc(uid).get();
      a=snapshot.data();
      // print(a!['name']);
      return a;

    } catch(e){
      print(e);
    }


  }
}