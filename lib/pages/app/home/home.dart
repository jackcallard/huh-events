import 'package:app_v4/pages/app/home/feed.dart';
import 'package:app_v4/pages/app/home/list_view.dart';
import 'package:app_v4/pages/app/home/map_view.dart';
import 'package:app_v4/pages/database/database_relations.dart';
import 'package:app_v4/pages/models/event.dart';
import 'package:app_v4/pages/models/user.dart';
import 'package:app_v4/pages/utilities/event_panel.dart';
import 'package:flutter/material.dart';
import 'package:app_v4/pages/utilities/drawer.dart';
import 'package:app_v4/pages/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:date_range_picker/date_range_picker.dart' as date_range_picker;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  Map args = {};
  User user;
  DatabaseRelations _dbr;
  bool first = true;
  Map<int, BitmapDescriptor> myIcons;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  TabController _tabController;
  bool closeList = true;

  bool showCard = false;
  EventPanel eventPanel;

  bool showDateRange = true;

  double width;
  double height;

  DateTime now = DateTime.now();
  List<DateTime> dateRange;

  void _setUp(context) {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    dateRange = [now, now];
    var size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    first = false;
    args = ModalRoute.of(context).settings.arguments;
    myIcons = args['icons'];
    user = Provider.of<User>(context);
    _dbr = DatabaseRelations(uid: user.uid);
  }

  void setPanel(Event event) {
    setState(() {
      showCard = true;
      eventPanel = EventPanel(event: event);
    });
  }

  void hidePanel() {
    setState(() {
      showCard = false;
      eventPanel = null;
    });
  }

  bool refresh = false;

  @override
  Widget build(BuildContext context) {
    if (first) _setUp(context);
    return Provider<List<DateTime>>.value(
        value: dateRange,
        child: Scaffold(
          key: scaffoldKey,
          drawer: MyDrawer(loc: '/home'),
          body: Stack(
            children: <Widget>[
              TabBarView(
                controller: _tabController,
                physics: _tabController.index == 0
                    ? NeverScrollableScrollPhysics()
                    : null,
                children: <Widget>[
                  MapPage(
                    hidePanel: hidePanel,
                    setPanel: setPanel,
                    icons: myIcons,
                    toggleRange: () =>
                        setState(() => showDateRange = !showDateRange),
                    openList: () => setState(() => closeList = false),
                  ),
                  Feed(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 90),
                child: SafeArea(
                  child: TabBar(
                    controller: _tabController,
                    onTap: (index) => setState(() {
                      closeList = true;
                      showDateRange = index == 0;
                      hidePanel();
                    }),
                    isScrollable: false,
                    indicator: UnderlineTabIndicator(
                      insets: EdgeInsets.symmetric(horizontal: 37),
                      borderSide: BorderSide(
                        width: 3,
                        color: primary,
                      ),
                    ),
                    tabs: <Tab>[Tab(text: 'Map'), Tab(text: 'Feed')],
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white,
                    unselectedLabelStyle: TextStyle(
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.grey[400],
                          offset: Offset(2, 2),
                        ),
                        Shadow(
                          blurRadius: 1,
                          color: Colors.grey[500],
                          offset: Offset(2, 2),
                        ),
                      ],
                      fontSize: 21,
                      fontFamily: font2,
                    ),
                    labelStyle: TextStyle(
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.grey[400],
                            offset: Offset(2, 2),
                          ),
                          Shadow(
                            blurRadius: 1,
                            color: primary,
                            offset: Offset(2, 2),
                          ),
                        ],
                        fontSize: 26,
                        fontFamily: font2,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, top: 4),
                    child: IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: textColor,
                      ),
                      onPressed: () => scaffoldKey.currentState.openDrawer(),
                    ),
                  ),
                ),
              ),
              StreamBuilder<List<String>>(
                  stream: _dbr.getRequests(),
                  initialData: [],
                  builder: (context, snapshot) {
                    return SafeArea(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Visibility(
                              visible: snapshot.data.isNotEmpty,
                              child: RaisedButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/requests',
                                      arguments: {'requests': snapshot.data});
                                },
                                elevation: 12,
                                shape: CircleBorder(),
                                color: primary,
                                child: Text('${snapshot.data.length}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: font2,
                                        fontSize: 20)),
                              ),
                            )),
                      ),
                    );
                  }),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: CircleButton(
                          onPressed: () {},
                          color: primary,
                          child: Icon(
                            Icons.notifications,
                            color: Colors.white,
                          ))),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10, bottom: 10),
                    child: FloatingActionButton.extended(
                      backgroundColor: Colors.white,
                      onPressed: () => Navigator.of(context).pushNamed(
                          '/create_event',
                          arguments: {'from_drawer': false}),
                      label: Text(
                        'Create',
                        style: TextStyle(color: primary),
                      ),
                      icon: Icon(
                        Icons.add_circle,
                        color: primary,
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                top: closeList ? height : 30,
                curve: Curves.easeIn,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[600].withOpacity(0.7),
                        spreadRadius: 4,
                        blurRadius: 20,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  width: width,
                  height: height - 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                            child: IconButton(
                              icon: Icon(Icons.close, color: primary),
                              onPressed: () => setState(() => closeList = true),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
                            child: IconButton(
                              icon: Icon(
                                Icons.calendar_today,
                                color: primary,
                                size: 22,
                              ),
                              onPressed: () => setState(
                                  () => showDateRange = !showDateRange),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Expanded(child: ListPage()),
                    ],
                  ),
                ),
              ),
              AnimatedPositioned(
                right: showDateRange ? 0 : -70,
                duration: Duration(milliseconds: 200),
                curve: Curves.easeIn,
                child: Container(
                  height: height,
                  child: Column(
                    children: <Widget>[
                      Spacer(),
                      InkWell(
                        onTap: () async {
                          var d = await date_range_picker.showDatePicker(
                              initialFirstDate: dateRange.first,
                              initialLastDate: dateRange.last,
                              context: context,
                              firstDate: now.subtract(Duration(days: 1)),
                              lastDate: now.add(Duration(days: 365)));
                          setState(() => dateRange = d ?? dateRange);
                          ;
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(10)),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[500].withOpacity(0.7),
                                spreadRadius: 4,
                                blurRadius: 20,
                                offset:
                                    Offset(0, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(height: 10),
                              Text(
                                  months[dateRange.first.month - 1]
                                      .toUpperCase(),
                                  style: TextStyle(
                                      color: primary,
                                      fontFamily: font2,
                                      fontSize: 20)),
                              Text('${dateRange.first.day}',
                                  style: TextStyle(
                                      color: primary,
                                      fontFamily: font2,
                                      fontSize: 30)),
                              SizedBox(height: 5),
                              Text('to',
                                  style: TextStyle(
                                      color: primary,
                                      fontFamily: font2,
                                      fontSize: 20)),
                              SizedBox(height: 5),
                              Text(
                                  months[dateRange.last.month - 1]
                                      .toUpperCase(),
                                  style: TextStyle(
                                      color: primary,
                                      fontFamily: font2,
                                      fontSize: 20)),
                              Text('${dateRange.last.day}',
                                  style: TextStyle(
                                      color: primary,
                                      fontFamily: font2,
                                      fontSize: 30)),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
              showCard ? eventPanel : Container(),
            ],
          ),
        ));
  }
}
