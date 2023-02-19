import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:movie_api/constants/constants.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart' as http;
import 'package:movie_api/models/movie_model.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController movieName = TextEditingController();

  late StreamController streamController;
  late Stream stream;

  getAllMovieData(String name) async {
    streamController.add('loading');
    var url = 'http://www.omdbapi.com/?t=$name&apikey=9a577ee9';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['Response'] == 'True') {
        MovieModel movieModel = MovieModel.fromJson(jsonData);
        streamController.add(movieModel);
      } else {
        streamController.add('Not Found');
      }
    } else {
      streamController.add('Something Went Wrong');
    }
  }

  @override
  void initState() {
    streamController = StreamController();
    stream = streamController.stream;
    streamController.add('empty');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movie Info',
          style: TextStyle(color: Colors.white70),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                style: const TextStyle(color: Colors.white70),
                controller: movieName,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white70,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  fillColor: kTextFieldColor,
                  filled: true,
                  hintText: 'Search Movie',
                  hintStyle: const TextStyle(color: kHintColor),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 110,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    if (movieName.text.trim().isNotEmpty) {
                      getAllMovieData(movieName.text);
                    } else {
                      showToast(
                        'Please Enter Movie Name',
                        context: context,
                        animation: StyledToastAnimation.scale,
                        animDuration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        reverseCurve: Curves.linear,
                        backgroundColor: kTextFieldColor,
                        textStyle: const TextStyle(color: Colors.white70),
                      );
                    }
                  },
                  child: const Text(
                    'Search',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                child: StreamBuilder(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data == 'loading') {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.data == 'went wrong') {
                        return const Text('Something went wrong');
                      } else if (snapshot.data == 'Not Found') {
                        return const Text('Movie not found', style: TextStyle(color: Colors.white70));
                      } else if (snapshot.data == 'empty') {
                        return const Text('Enter Movie Name', style: TextStyle(color: Colors.white70),);
                      }
                      else {
                        MovieModel movieData = snapshot.data;
                        return Column(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kButtonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                                onPressed: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (context) {
                                    return MovieDetailScreen(
                                      movieModel: movieData,
                                    );
                                  }));
                                },
                                child:  Text('Click Here To See ${movieData.title.toString()} Movie Details', style: const TextStyle(
                                  color: Colors.black,
                                ),), ),
                          ],
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}