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
        alignment: Alignment.center,
        constraints: const BoxConstraints.expand(),
        // alignment: Alignment.center,
        child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: tabController,
          children: const [HorizontalScreen(), VerticalScreen()],
        ),
      ),
    );
  }
}

class HorizontalScreen extends StatefulWidget {
  const HorizontalScreen({super.key});

  @override
  State<HorizontalScreen> createState() => _HorizontalScreenState();
}

class _HorizontalScreenState extends State<HorizontalScreen> {
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
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: RangeIndicator(
            axis: Axis.horizontal,
            thumbRadius: 30,
            railWidth: 5,
            ranges: [
              RangeInfo(end: 50, color: Colors.blue),
              RangeInfo(end: 100, color: Colors.red),
            ],
            min: 1,
            onChanged: (List<Range> value) {
              // print(value);
              setState(() {
                ranges = value;
              });
            },
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        ViewAsText(ranges: ranges),
      ],
    );
  }
}

class VerticalScreen extends StatefulWidget {
  const VerticalScreen({super.key});

  @override
  State<VerticalScreen> createState() => _VerticalScreenState();
}

class _VerticalScreenState extends State<VerticalScreen> {
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
            railWidth: 7,
            ranges: [
              RangeInfo(end: 50, color: Colors.blue),
              RangeInfo(end: 100, color: Colors.red),
            ],
            min: 1,
            onChanged: (List<Range> value) {
              // print(value);
              setState(() {
                ranges = value;
              });
            },
          ),
        ),
        Expanded(
          child: ViewAsText(
            ranges: ranges,
          ),
        ),
      ],
    );
  }
}

class ViewAsText extends StatelessWidget {
  final List<Range> ranges;

  const ViewAsText({super.key, required this.ranges});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < ranges.length; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "RANGE ${i + 1}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                "start ${ranges[i].start.toStringAsFixed(2)}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                "end ${ranges[i].end.toStringAsFixed(2)}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          )
      ],
    );
  }
}
