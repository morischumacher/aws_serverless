import 'dart:typed_data';
//import 'package:aic_ui/src/auth/login_controller.dart';
import 'package:aic_ui/src/api/picture_api.dart';
import 'package:aic_ui/src/service/jwt_token.dart';
import 'package:aic_ui/src/service/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ProfileCard extends StatefulWidget {
  const ProfileCard({
    super.key,
  });

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  late Future<Uint8List?> _profileImage;
  //final LoginController _controller = LoginController();

  final _secureStorage = SecureStorage();
  final _pictureApi = PictureApi();

  @override
  void initState() {
    super.initState();
    {
      // Use the obtained user ID to download the profile picture
      _profileImage = _getUserId().then((userId) => _pictureApi.get_picture());
    }
  }

  Future<JwtToken> _getAccessToken() async {
    return await _secureStorage.getAccessToken() as JwtToken;
  }

  Future<JwtToken> _getIdToken() async {
    return await _secureStorage.getIdToken() as JwtToken;
  }

  Future<String> _getEmail() async {
    var token = await _getAccessToken();
    return token.getEmail();
  }

  Future<String> _getUserId() async {
    var token = await _getAccessToken();
    return token.getUserId();
  }

  Future<String> _getUserName() async {
    var token = await _getIdToken();
    return token.getUserName();
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = xFileToUint8List(image);
      });
      _pictureApi.post_picture(await _getUserId(), image);
    } else {
      // User canceled the picker
    }
  }

  Future<Uint8List?> xFileToUint8List(XFile xFile) async {
    List<int> fileBytes = await xFile.readAsBytes();
    return Uint8List.fromList(fileBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () {
                  _pickImage(context);
                },
                icon: const Icon(Icons.edit),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    FutureBuilder<Uint8List?>(
                      future: _profileImage,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text('No Image!');
                        } else {
                          return Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: snapshot.hasData &&
                                      snapshot.data != null &&
                                      !snapshot.hasError
                                  ? DecorationImage(
                                      image: MemoryImage(snapshot.data!),
                                      fit: BoxFit.fill,
                                    )
                                  : null, // Set to null if no image available
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<String>(
                      future: _getUserName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Text(
                            snapshot.data ??
                                '', // Use the data or provide a default value
                            style: const TextStyle(fontSize: 20),
                          );
                        }
                      },
                    ),
                    FutureBuilder<String>(
                      future: _getEmail(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Text(
                            snapshot.data ??
                                '', // Use the data or provide a default value
                            style: const TextStyle(fontSize: 15),
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
