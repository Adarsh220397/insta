import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insta/services/models/post_model.dart';
import 'package:insta/services/models/story_model.dart';

class UserService {
  UserService._internal();
  static UserService instance = UserService._internal();

  Future<bool> uploadStory(String name, String image) async {
    try {
      DocumentReference ref = FirebaseFirestore.instance
          .collection('story')
          .doc(name)
          .collection('image')
          .doc();

      var documentSnapshot = await ref.get();
      if (!documentSnapshot.exists) {
        DocumentReference movieRef = FirebaseFirestore.instance
            .collection('story')
            .doc(name)
            .collection('image')
            .doc();
        await movieRef.set({
          'image': image,
          'name': name,
          'count': FieldValue.increment(1),
          'isEnabled': false
        });

        return true;
      } else {
        DocumentReference movieRef = FirebaseFirestore.instance
            .collection('story')
            .doc(name)
            .collection('image')
            .doc(image);
        await movieRef.set({
          'image': image,
          'name': name,
          'count': FieldValue.increment(1),
          'isEnabled': false
        });

        return true;
      }
    } catch (e) {
      print('------$e');
      return false;
    }
  }

  Future<bool> uploadPost(String name, String image) async {
    try {
      String uid = '';
      uid = FirebaseFirestore.instance.collection('post').doc().id;
      DocumentReference ref = FirebaseFirestore.instance
          .collection('post')
          .doc(name)
          .collection('image')
          .doc(uid);

      var documentSnapshot = await ref.get();
      if (!documentSnapshot.exists) {
        DocumentReference movieRef = FirebaseFirestore.instance
            .collection('post')
            .doc(name)
            .collection('image')
            .doc(uid);

        await movieRef.set({
          'image': image,
          'name': name,
          'count': 0,
          'uid': uid,
          'isEnabled': false
        });

        return true;
      } else {
        DocumentReference movieRef = FirebaseFirestore.instance
            .collection('post')
            .doc(name)
            .collection('image')
            .doc(uid);
        await movieRef.set({
          'image': image,
          'name': name,
          'count': 0,
          'uid': uid,
          'isEnabled': false
        });

        return true;
      }
    } catch (e) {
      print('------$e');
      return false;
    }
  }

  Future<void> updateData(String name, String uid) async {
    DocumentReference updateRef = FirebaseFirestore.instance
        .collection('post')
        .doc(name)
        .collection('image')
        .doc(uid);

    await updateRef
        .update({'count': FieldValue.increment(1), 'isEnabled': true});
  }

  Future<void> decreaseData(String name, String uid) async {
    DocumentReference updateRef = FirebaseFirestore.instance
        .collection('post')
        .doc(name)
        .collection('image')
        .doc(uid);

    await updateRef
        .update({'count': FieldValue.increment(-1), 'isEnabled': false});
  }

  Future<List<StoryModel>> getData(String name) async {
    List<StoryModel> list = [];
    try {
      CollectionReference movieReleaseCollectionRef = FirebaseFirestore.instance
          .collection('story')
          .doc(name)
          .collection('image');

      QuerySnapshot stateCollectionRef = await movieReleaseCollectionRef.get();

      if (stateCollectionRef.docs.isEmpty) {
        list;
      }
      list = stateCollectionRef.docs
          .map((doc) => StoryModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return list;
    } catch (e) {
      print('-----$e');
    }
    return list;
  }

  Future<List<PostModel>> getPostData(String name) async {
    List<PostModel> list = [];
    try {
      CollectionReference movieReleaseCollectionRef = FirebaseFirestore.instance
          .collection('post')
          .doc(name)
          .collection('image');

      QuerySnapshot stateCollectionRef = await movieReleaseCollectionRef.get();

      if (stateCollectionRef.docs.isEmpty) {
        list;
      }
      list = stateCollectionRef.docs
          .map((doc) => PostModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return list;
    } catch (e) {
      print('--[ost---$e');
    }
    return list;
  }
}
