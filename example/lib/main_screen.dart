import 'package:flutter/material.dart';
import 'package:range_indicator/range_indicator.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Indicator"),
        bottom: TabBar(
          tabs: const [
            Tab(
              text: "Horizontal",
            ),
            Tab(
              text: "Vertical",
            ),
          ],
          controller: tabController,
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        constraints: const BoxConstraints.expand(),
        // alignment: Alignment.center,
        child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: tabController,
          children: const [VerticalView(), HorizontalView()],
        ),
      ),
    );
  }
}

class VerticalView extends StatefulWidget {
  const VerticalView({super.key});

  @override
  State<VerticalView> createState() => _VerticalViewState();
}

class _VerticalViewState extends State<VerticalView> {
  List<Range> ranges = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RangeIndicator(
          axis: Axis.horizontal,
          thumbRadius: 20,
          railWidth: 5,
          ranges: [
            RangeInfo(end: 30, color: Colors.blue),
            RangeInfo(end: 60, color: Colors.green),
            RangeInfo(end: 90, color: Colors.red),
          ],
          min: 10,
          onChanged: (List<Range> value) {
            // print(value);
            setState(() {
              ranges = value;
            });
          },
        ),
        const SizedBox(
          height: 30,
        ),
        Text(
          ranges.toString(),
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class HorizontalView extends StatefulWidget {
  const HorizontalView({super.key});

  @override
  State<HorizontalView> createState() => _HorizontalViewState();
}

class _HorizontalViewState extends State<HorizontalView> {
  List<Range> ranges = [];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: RangeIndicator(
            axis: Axis.vertical,
            thumbRadius: 20,
            railWidth: 5,
            ranges: [
              RangeInfo(end: 30, color: Colors.blue),
              RangeInfo(end: 90, color: Colors.red),
            ],
            min: 10,
            onChanged: (List<Range> value) {
              // print(value);
              setState(() {
                ranges = value;
              });
            },
          ),
        ),
        Expanded(
          child: Text(
            ranges.toString(),
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
