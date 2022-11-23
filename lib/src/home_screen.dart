import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta/services/database.dart';
import 'package:insta/services/models/post_model.dart';
import 'package:insta/services/models/story_model.dart';
import 'package:insta/utils/colors.dart';
import 'package:insta/utils/global_variable.dart';
import 'package:insta/widgets/circular_progress_indicator_ui.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? pickedFile;
  String imageUrl = '';
  String postUrl = '';
  bool isLoading = false;
  List<StoryModel> list = [];
  List<PostModel> postlist = [];
  // bool bClicked = false;
  @override
  void initState() {
    super.initState();

    fetchData();
  }

  fetchData() async {
    //
    isLoading = true;
    list = await UserService.instance.getData('admin');
    postlist = await UserService.instance.getPostData('admin');

    print(postlist.length);
    print(list.length);
    setState(() {});
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return isLoading
        ? const CircularIndicator()
        : Scaffold(
            backgroundColor: width > webScreenSize
                ? webBackgroundColor
                : mobileBackgroundColor,
            appBar: width > webScreenSize
                ? null
                : AppBar(
                    backgroundColor: mobileBackgroundColor,
                    centerTitle: false,
                    title: SvgPicture.asset(
                      'assets/icons/ic_instagram.svg',
                      color: primaryColor,
                      height: 32,
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.squarePlus,
                          color: primaryColor,
                        ),
                        onPressed: addPostImages,
                      ),
                      IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.facebookMessenger,
                          color: primaryColor,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
            body: homeScreenBodyUI(),
          );
  }

  Future addPostImages() async {
    pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {});

    await storePostImage();
    bool bReturn = await UserService.instance.uploadPost('admin', postUrl);
    if (bReturn) {
      print(bReturn);
      fetchData();
    }
  }

  Future getPost() async {
    pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() {});

    await storePostImage();
    bool bReturn = await UserService.instance.uploadStory('admin', imageUrl);
    if (bReturn) {
      fetchData();
    }
  }

  Future getImage() async {
    pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {});

    await storeImage();
    bool bReturn = await UserService.instance.uploadStory('admin', imageUrl);
    if (bReturn) {
      fetchData();
    }
  }

  Future<String> storeImage() async {
    if (pickedFile == null) {
      return imageUrl;
    }

    File imageFile = File(pickedFile!.path);
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("/MoviePoster/image_${DateTime.now()}.jpg");
    UploadTask uploadTask = ref.putFile(imageFile);

    String imageURL = '';
    await uploadTask.then((res) async {
      imageURL = await res.ref.getDownloadURL();
      imageUrl = imageURL;
      print(imageUrl);
      isLoading = false;
    });

    return imageURL;
  }

  Future<String> storePostImage() async {
    if (pickedFile == null) {
      return postUrl;
    }

    File imageFile = File(pickedFile!.path);
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("/InstaPosts/image_${DateTime.now()}.jpg");
    UploadTask uploadTask = ref.putFile(imageFile);

    String imageURL = '';
    await uploadTask.then((res) async {
      imageURL = await res.ref.getDownloadURL();
      postUrl = imageURL;
      print(postUrl);
      isLoading = false;
    });

    return imageURL;
  }

  Widget circleAvatar() {
    //  List list = [1, 2, 3, 4, 5];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  InkWell(
                      onTap: getImage,
                      child: CircleAvatar(
                        radius: 40,
                        //  backgroundColor: Color.fromARGB(255, 126, 81, 81),
                        child: CircleAvatar(
                          radius: 30.0,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: Image.asset('assets/imgs/rocket.png'),
                          ),
                        ),
                      )),
                  const Positioned(
                    right: 5,
                    bottom: 5,
                    child: Icon(
                      Icons.add_circle,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const Text('Your Story')
            ],
          ),
          list.isNotEmpty
              ? Row(
                  children: [
                    for (var i in list)
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.black,
                            child: CircleAvatar(
                              radius: 30.0,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: Image.network(i.image),
                              ),
                            ),
                          ),
                          Text(i.name)
                        ],
                      ),
                  ],
                )
              : const SizedBox()
        ],
      ),
    );
  }

  Widget homeScreenBodyUI() {
    return Column(
      children: [
        circleAvatar(),
        postlist.isEmpty
            ? SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                child: const Center(
                    child: Text(
                  'Yet to Post..',
                )),
              )
            : Expanded(
                flex: 1,
                child: ListView.builder(
                  itemCount: postlist.length,
                  itemBuilder: (ctx, index) => Container(
                      margin: EdgeInsets.symmetric(
                        horizontal:
                            MediaQuery.of(context).size.width > webScreenSize
                                ? MediaQuery.of(context).size.width * 0.3
                                : 0,
                        vertical:
                            MediaQuery.of(context).size.width > webScreenSize
                                ? 15
                                : 0,
                      ),
                      child: Container(
                        // boundary needed for web
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: MediaQuery.of(context).size.width >
                                    webScreenSize
                                ? secondaryColor
                                : mobileBackgroundColor,
                          ),
                          color: mobileBackgroundColor,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 16,
                              ).copyWith(right: 0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.transparent,
                                    child: ClipOval(
                                        child: Image.network(
                                            postlist[index].image)),
                                  ),
                                  postNameUI(postlist[index]),
                                  verticalIconButton()
                                ],
                              ),
                            ),
                            postDisplayUI(postlist[index]),
                            postIconsRowUI(postlist[index]),
                            commentsUI(postlist[index]),
                          ],
                        ),
                      )),
                ),
              ),
      ],
    );
  }

  Widget postNameUI(PostModel postData) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              postData.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget verticalIconButton() {
    return IconButton(
      onPressed: () {
        showDialog(
          useRootNavigator: false,
          context: context,
          builder: (context) {
            return Dialog(
              child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shrinkWrap: true,
                  children: [
                    'Delete',
                  ]
                      .map(
                        (e) => InkWell(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: Text(e),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                            }),
                      )
                      .toList()),
            );
          },
        );
      },
      icon: const Icon(Icons.more_vert),
    );
  }

  Widget postIconsRowUI(PostModel postData) {
    return Row(
      children: <Widget>[
        IconButton(
            icon: postData.isEnabled
                ? const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  )
                : const Icon(
                    Icons.favorite_border,
                  ),
            onPressed: () async {
              if (postData.isEnabled) {
                postData.isEnabled = false;

                await UserService.instance
                    .decreaseData(postData.name, postData.uid);
                await fetchData();
              } else {
                postData.isEnabled = true;

                await UserService.instance
                    .updateData(postData.name, postData.uid);
                await fetchData();
              }
              setState(() {});
            }),
        IconButton(
            icon: const Icon(
              FontAwesomeIcons.comment,
            ),
            onPressed: () {}),
        IconButton(
            icon: const Icon(
              Icons.send,
            ),
            onPressed: () => _loadFromFile(postData)),
        Expanded(
            child: Align(
          alignment: Alignment.bottomRight,
          child: IconButton(
              icon: const Icon(Icons.bookmark_border), onPressed: () {}),
        ))
      ],
    );
  }

  Widget postDisplayUI(PostModel postData) {
    return GestureDetector(
      onDoubleTap: () async {
        if (postData.isEnabled) {
          postData.isEnabled = false;
          await UserService.instance.decreaseData(postData.name, postData.uid);
          await fetchData();
        } else {
          postData.isEnabled = true;
          await UserService.instance.updateData(postData.name, postData.uid);
          await fetchData();
        }
        setState(() {});
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            child: Image.network(
              postData.image,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }

  Widget commentsUI(PostModel postDetails) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DefaultTextStyle(
              style: Theme.of(context)
                  .textTheme
                  .subtitle2!
                  .copyWith(fontWeight: FontWeight.w800),
              child: Row(
                children: [
                  Text(
                    postDetails.count.toString(),
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  Text(
                    ' likes',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              )),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 8,
            ),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: primaryColor),
                children: [
                  TextSpan(
                    text: 'comments',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // TextSpan(
                  //   text: ' description',
                  // ),
                ],
              ),
            ),
          ),
          InkWell(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: const Text(
                  'View all comments',
                  style: TextStyle(
                    fontSize: 16,
                    color: secondaryColor,
                  ),
                ),
              ),
              onTap: () {
                // return Navigator.of(context).push(
                //                           MaterialPageRoute(
                //                             builder: (context) => CommentsScreen(
                //                               postId: widget.snap['postId'].toString(),
                //                             ),
                //                           ),
                //                         ),
              }),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              DateFormat.yMMMd().format(DateTime.now()),
              style: const TextStyle(
                color: secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loadFromFile(PostModel postModel) async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse(postModel.image);
    final response = await http.get(url);

    String tempPath = (await getTemporaryDirectory()).path;
    File file = File('$tempPath/profile.png');
    await file.writeAsBytes(response.bodyBytes);

    await Share.shareFiles([file.path], text: 'Download the document');
    setState(() {
      isLoading = false;
    });
  }
}
