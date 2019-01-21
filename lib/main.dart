import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Snake Game'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class SnakePart {
  int row;
  int col;

  SnakePart({this.row, this.col});
}

class Feed {
  int row;
  int col;

  Feed({this.row, this.col});
}

class _MyHomePageState extends State<MyHomePage> {
  static const int COUNT_ROW = 36;
  static const int COUNT_COL = 36;

  static const int GROUND = 0;
  static const int SNAKE = 1;
  static const int FEED = 2;
  static const int MAX_COUNT_FEED = 20;
  static const int SPEED_SNAKE = 200;

  static const int DIRECTION_TOP = 0;
  static const int DIRECTION_LEFT = 1;
  static const int DIRECTION_RIGHT = 2;
  static const int DIRECTION_BOTTOM = 3;

  int currentSnakeDirection = DIRECTION_RIGHT;

  List<Feed> listFeed;
  List<SnakePart> snake;
  List<List<int>> map = List();
  Timer timer;
  int score = 0;

  Color colorSnakeHead = Colors.pink[900];
  bool playing = true;
  bool enableWall = false;

  @override
  void initState() {
    initMap();
    initSnake();
    initFeed();

    timer = Timer.periodic(
        Duration(milliseconds: SPEED_SNAKE), (Timer t) => process());
    super.initState();
  }

  void initFeed() {
    listFeed = List();
  }

  void initSnake() {
    snake = List();
    snake.add(SnakePart(row: 0, col: 8)); // head of snake.
    snake.add(SnakePart(row: 0, col: 7));
    snake.add(SnakePart(row: 0, col: 6));
    snake.add(SnakePart(row: 0, col: 5));
    snake.add(SnakePart(row: 0, col: 4));
    snake.add(SnakePart(row: 0, col: 3));
    snake.add(SnakePart(row: 0, col: 2));
    snake.add(SnakePart(row: 0, col: 1));
    snake.add(SnakePart(row: 0, col: 0)); // tail of snake.
  }

  void initMap() {
    map = List();
    for (int row = 0; row < COUNT_ROW; row++) {
      List<int> rowMap = List();
      for (int col = 0; col < COUNT_COL; col++) {
        rowMap.add(GROUND);
      }
      map.add(rowMap);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(children: <Widget>[
          Expanded(
              child: Container(
                  color: Colors.blue[50],
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Score : $score",
                          style: TextStyle(
                              fontSize: 28,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold),
                        ),
                        buildMapContainer()
                      ]))),
          buildControlButton()
        ]));
  }

  Container buildMapContainer() {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Colors.blue[800]),
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(16),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: buildMap()));
  }

  Container buildControlButton() {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.blue[200],
      child:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        buildControlDirectionButton(Icons.keyboard_arrow_left, DIRECTION_LEFT),
        Container(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildControlDirectionButton(Icons.keyboard_arrow_up, DIRECTION_TOP),
            buildControlDirectionButton(
                Icons.keyboard_arrow_down, DIRECTION_BOTTOM),
          ],
        )),
        buildControlDirectionButton(
            Icons.keyboard_arrow_right, DIRECTION_RIGHT),
      ]),
    );
  }

  GestureDetector buildControlDirectionButton(IconData icon, int direction) {
    return GestureDetector(
        onTap: () {
          if (currentSnakeDirection == DIRECTION_TOP &&
              direction == DIRECTION_BOTTOM) {
            return;
          }
          if (currentSnakeDirection == DIRECTION_BOTTOM &&
              direction == DIRECTION_TOP) {
            return;
          }
          if (currentSnakeDirection == DIRECTION_RIGHT &&
              direction == DIRECTION_LEFT) {
            return;
          }
          if (currentSnakeDirection == DIRECTION_LEFT &&
              direction == DIRECTION_RIGHT) {
            return;
          }

          setState(() {
            currentSnakeDirection = direction;
          });
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft:
                      direction == DIRECTION_TOP || direction == DIRECTION_LEFT
                          ? Radius.circular(8)
                          : Radius.circular(0),
                  topRight:
                      direction == DIRECTION_TOP || direction == DIRECTION_RIGHT
                          ? Radius.circular(8)
                          : Radius.circular(0),
                  bottomLeft: direction == DIRECTION_LEFT ||
                          direction == DIRECTION_BOTTOM
                      ? Radius.circular(8)
                      : Radius.circular(0),
                  bottomRight: direction == DIRECTION_RIGHT ||
                          direction == DIRECTION_BOTTOM
                      ? Radius.circular(8)
                      : Radius.circular(0))),
          child: Icon(icon, size: 48),
        ));
  }

  List<Widget> buildRowMap(int row) {
    List<Widget> listWidget = List();
    for (int i = 0; i < COUNT_COL; i++) {
      listWidget.add(buildMapUnit(row, i));
    }
    return listWidget;
  }

  List<Widget> buildMap() {
    List<Widget> listWidget = List();
    for (int i = 0; i < COUNT_ROW; i++) {
      listWidget.add(Row(children: buildRowMap(i)));
    }
    return listWidget;
  }

  Container buildMapUnit(int row, int col) {
    if (map[row][col] == GROUND) {
      return Container(
        width: 10,
        height: 10,
        color: getColorBackground(row, col),
      );
    } else if (map[row][col] == SNAKE) {
      SnakePart snakeHead = snake.first;
      SnakePart snakeTail = snake.last;
      if (row == snakeHead.row && col == snakeHead.col) {
        return buildSnakeHead(snakeHead);
      } else if (row == snakeTail.row && col == snakeTail.col) {
        return buildSnakeTail(snakeTail);
      } else {
        return Container(
          width: 10,
          height: 10,
          color: getColorBackground(row, col),
        );
      }
    } else if (map[row][col] == FEED) {
      return Container(
        width: 10,
        height: 10,
        color: Colors.pink[100],
        foregroundDecoration: BoxDecoration(
            shape: BoxShape.circle, color: getColorBackground(row, col)),
      );
    }
  }

  Container buildSnakeHead(SnakePart snakeHead) {
    return Container(
      width: 10,
      height: 10,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: currentSnakeDirection == DIRECTION_TOP ||
                    currentSnakeDirection == DIRECTION_LEFT
                ? Radius.circular(12)
                : Radius.circular(0),
            topRight: currentSnakeDirection == DIRECTION_TOP ||
                    currentSnakeDirection == DIRECTION_RIGHT
                ? Radius.circular(12)
                : Radius.circular(0),
            bottomLeft: currentSnakeDirection == DIRECTION_LEFT ||
                    currentSnakeDirection == DIRECTION_BOTTOM
                ? Radius.circular(12)
                : Radius.circular(0),
            bottomRight: currentSnakeDirection == DIRECTION_RIGHT ||
                    currentSnakeDirection == DIRECTION_BOTTOM
                ? Radius.circular(12)
                : Radius.circular(0)),
        color: colorSnakeHead,
      ),
      color: Colors.pink[100],
    );
  }

  Container buildSnakeTail(SnakePart snakeTail) {
    SnakePart snakeBeforeTail = snake[snake.length - 2];
    return Container(
      width: 10,
      height: 10,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: (snakeBeforeTail.row == snakeTail.row && snakeBeforeTail.col > snakeTail.col) ||
                    (snakeBeforeTail.col == snakeTail.col &&
                        snakeBeforeTail.row > snakeTail.row)
                ? Radius.circular(12)
                : Radius.circular(0),
            topRight: (snakeBeforeTail.col == snakeTail.col && snakeBeforeTail.row > snakeTail.row) ||
                    (snakeBeforeTail.row == snakeTail.row &&
                        snakeBeforeTail.col < snakeTail.col)
                ? Radius.circular(12)
                : Radius.circular(0),
            bottomLeft: (snakeBeforeTail.row == snakeTail.row && snakeBeforeTail.col > snakeTail.col) ||
                    (snakeBeforeTail.col == snakeTail.col &&
                        snakeBeforeTail.row < snakeTail.row)
                ? Radius.circular(12)
                : Radius.circular(0),
            bottomRight: (snakeBeforeTail.col == snakeTail.col && snakeBeforeTail.row < snakeTail.row) ||
                    (snakeBeforeTail.row == snakeTail.row && snakeBeforeTail.col < snakeTail.col)
                ? Radius.circular(12)
                : Radius.circular(0)),
        color: getColorBackground(snakeTail.row, snakeTail.col),
      ),
      color: Colors.pink[100],
    );
  }

  process() {
    if (playing) {
      setState(() {
        SnakePart snakeTailRemoved;
        if (currentSnakeDirection == DIRECTION_RIGHT) {
          snakeTailRemoved = moveSnakeToRight();
        } else if (currentSnakeDirection == DIRECTION_LEFT) {
          snakeTailRemoved = moveSnakeToLeft();
        } else if (currentSnakeDirection == DIRECTION_TOP) {
          snakeTailRemoved = moveSnakeToTop();
        } else if (currentSnakeDirection == DIRECTION_BOTTOM) {
          snakeTailRemoved = moveSnakeToBottom();
        }

        randomFeedOnMap();
        Feed feed = getFeedEatenBySnake();
        if (feed != null) {
          eatFeed(snakeTailRemoved, feed);
        }
      });
    }
  }

  bool isSnakeEatSelf() {
    SnakePart snakeHead = snake.first;
    for (int i = 1; i < snake.length; i++) {
      SnakePart snakeBody = snake[i];
      if (snakeHead.row == snakeBody.row && snakeHead.col == snakeBody.col) {
        return true;
      }
    }
    return false;
  }

  void eatFeed(SnakePart snakeTail, Feed feed) {
    score += 10;
    map[snakeTail.row][snakeTail.col] = SNAKE;
    map[feed.row][feed.col] = SNAKE;
    snake.add(snakeTail);
    removeFeedOnMap(feed);
  }

  SnakePart moveSnakeToRight() {
    SnakePart snakeHead = snake.first;
    if (snakeHead.col + 1 < COUNT_COL) {
      SnakePart snakeNewHead =
          SnakePart(row: snakeHead.row, col: snakeHead.col + 1);

      if (map[snakeNewHead.row][snakeNewHead.col] == SNAKE) {
        gameOver();
        return null;
      }
      snake.insert(0, snakeNewHead);
      map[snakeNewHead.row][snakeNewHead.col] = SNAKE;
      SnakePart snakeTail = snake.last;
      map[snakeTail.row][snakeTail.col] = GROUND;
      snake.removeLast();
      return snakeTail;
    } else {
      // Head of Snake attack the wall.
      if(enableWall) {
        gameOver();
      }else{
        moveSnakeToCrossLeft(snakeHead.row);
      }
    }
    return null;
  }

  SnakePart moveSnakeToLeft() {
    SnakePart snakeHead = snake.first;
    if (snakeHead.col - 1 >= 0) {
      SnakePart snakeNewHead =
          SnakePart(row: snakeHead.row, col: snakeHead.col - 1);
      snake.insert(0, snakeNewHead);
      map[snakeNewHead.row][snakeNewHead.col] = SNAKE;

      SnakePart snakeTail = snake.last;
      map[snakeTail.row][snakeTail.col] = GROUND;
      snake.removeLast();
      return snakeTail;
    } else {
      // Head of Snake attack the wall.
      if(enableWall) {
        gameOver();
      }else{
        moveSnakeToCrossRight(snakeHead.row);
      }
    }
  }

  SnakePart moveSnakeToTop() {
    SnakePart snakeHead = snake.first;
    if (snakeHead.row - 1 >= 0) {
      SnakePart snakeNewHead =
          SnakePart(row: snakeHead.row - 1, col: snakeHead.col);
      snake.insert(0, snakeNewHead);
      map[snakeNewHead.row][snakeNewHead.col] = SNAKE;

      SnakePart snakeTail = snake.last;
      map[snakeTail.row][snakeTail.col] = GROUND;
      snake.removeLast();
      return snakeTail;
    } else {
      // Head of Snake attack the wall.
      if(enableWall) {
        gameOver();
      }else{
        moveSnakeToCrossBottom(snakeHead.col);
      }
    }
  }

  SnakePart moveSnakeToBottom() {
    SnakePart snakeHead = snake.first;
    if (snakeHead.row + 1 < COUNT_ROW) {
      SnakePart snakeNewHead =
          SnakePart(row: snakeHead.row + 1, col: snakeHead.col);
      snake.insert(0, snakeNewHead);
      map[snakeNewHead.row][snakeNewHead.col] = SNAKE;

      SnakePart snakeTail = snake.last;
      map[snakeTail.row][snakeTail.col] = GROUND;
      snake.removeLast();
      return snakeTail;
    } else {
      // Head of Snake attack the wall.
      if(enableWall) {
        gameOver();
      }else{
        moveSnakeToCrossTop(snakeHead.col);
      }
    }
  }

  printMap() {
    for (int row = 0; row < COUNT_ROW; row++) {
      String str = "";
      for (int col = 0; col < COUNT_COL; col++) {
        str += "" + map[row][col].toString() + " ";
      }
//      print("[$str]");
    }
  }

  Color getColorBackground(int row, int col) {
    if (map[row][col] == SNAKE) {
      return Colors.pink[500];
    } else if (map[row][col] == GROUND) {
      return Colors.pink[100];
    } else if (map[row][col] == FEED) {
      return Colors.green[600];
    }
  }

  randomFeedOnMap() {
    if (listFeed.length < MAX_COUNT_FEED) {
      Random rd = Random();
      int rowFeed = rd.nextInt(COUNT_ROW);
      int colFeed = rd.nextInt(COUNT_COL);
      if (map[rowFeed][colFeed] == GROUND) {
        Feed feed = Feed(row: rowFeed, col: colFeed);
        listFeed.add(feed);
        map[rowFeed][colFeed] = FEED;
      }
    }
  }

  Feed getFeedEatenBySnake() {
    SnakePart snakeHead = snake.first;
    for (Feed feed in listFeed) {
      if (snakeHead.row == feed.row && snakeHead.col == feed.col) {
        return feed;
      }
    }
    return null;
  }

  void removeFeedOnMap(Feed feed) {
    listFeed.removeWhere((f) {
      return f.row == feed.row && f.col == feed.col;
    });
  }

  void gameOver() {
    playing = false;
    showGameOverDialog();
  }

  void showGameOverDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Text("Game Over ):",
              style: TextStyle(
                  fontSize: 32,
                  color: Colors.pink[800],
                  fontWeight: FontWeight.bold)),
          RaisedButton(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            color: Colors.yellow[800],
            child: Text("Play again",
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.of(context).pop();
              restart();
            },
          )
        ]));
      },
    );
  }

  void restart() {
    setState(() {
      initMap();
      initSnake();
      initFeed();
      playing = true;
      score = 0;
      currentSnakeDirection = DIRECTION_RIGHT;
    });
  }

  SnakePart moveSnakeToCrossTop(int col) {
    SnakePart snakeNewHead =
    SnakePart(row: 0, col: col);
    snake.insert(0, snakeNewHead);
    map[snakeNewHead.row][snakeNewHead.col] = SNAKE;

    SnakePart snakeTail = snake.last;
    map[snakeTail.row][snakeTail.col] = GROUND;
    snake.removeLast();
    return snakeTail;
  }

  SnakePart moveSnakeToCrossBottom(int col) {
    SnakePart snakeNewHead =
    SnakePart(row: COUNT_ROW -1, col: col);
    snake.insert(0, snakeNewHead);
    map[snakeNewHead.row][snakeNewHead.col] = SNAKE;

    SnakePart snakeTail = snake.last;
    map[snakeTail.row][snakeTail.col] = GROUND;
    snake.removeLast();
    return snakeTail;
  }

  SnakePart moveSnakeToCrossLeft(int row) {
    SnakePart snakeNewHead =
    SnakePart(row: row, col: 0);
    snake.insert(0, snakeNewHead);
    map[snakeNewHead.row][snakeNewHead.col] = SNAKE;

    SnakePart snakeTail = snake.last;
    map[snakeTail.row][snakeTail.col] = GROUND;
    snake.removeLast();
    return snakeTail;
  }
  SnakePart moveSnakeToCrossRight(int row) {
    SnakePart snakeNewHead =
    SnakePart(row: row, col: COUNT_COL -1);
    snake.insert(0, snakeNewHead);
    map[snakeNewHead.row][snakeNewHead.col] = SNAKE;

    SnakePart snakeTail = snake.last;
    map[snakeTail.row][snakeTail.col] = GROUND;
    snake.removeLast();
    return snakeTail;
  }
}
