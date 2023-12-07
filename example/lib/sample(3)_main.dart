import 'dart:async';
import 'dart:math';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S-Alpha Grid Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PlutoGridExamplePage(),
    );
  }
}

class PlutoGridExamplePage extends StatefulWidget {
  const PlutoGridExamplePage({Key? key}) : super(key: key);

  @override
  State<PlutoGridExamplePage> createState() => _PlutoGridExamplePageState();
}

class _PlutoGridExamplePageState extends State<PlutoGridExamplePage> {
  // 첫 번째 그리드의 컬럼과 행 설정
  final List<PlutoColumn> columnsA = [];
  final List<PlutoRow> rowsA = [];
  late PlutoGridStateManager stateManagerA;

  // 두 번째 그리드의 컬럼과 행 설정
  final List<PlutoColumn> columnsB = [];
  final List<PlutoRow> rowsB = [];
  late PlutoGridStateManager stateManagerB;

  Key? currentRowKey;

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    columnsA.addAll([
      PlutoColumn(
        title: '처방 ID',
        field: 'prescriptionId',
        type: PlutoColumnType.number(),
        enableRowChecked: true,
      ),
      PlutoColumn(
        title: '진행 상태',
        field: 'status',
        type: PlutoColumnType.select(<String>['처방 없음', '시작전', '진행중', '완료']),
      ),
      PlutoColumn(
        title: '처방 종류',
        field: 'type',
        type: PlutoColumnType.select(<String>['A', 'B', 'C']),
      ),
    ]);
    rowsA.addAll(generateRandomRows(10, columnsA));
    columnsB.addAll([
      PlutoColumn(
        title: '활동명',
        field: 'activity',
        type: PlutoColumnType.text(),
        enableRowChecked: true,
      ),
      PlutoColumn(
        title: '날짜',
        field: 'date',
        type: PlutoColumnType.date(),
      ),
      PlutoColumn(
        title: '시작시간',
        field: 'startTime',
        type: PlutoColumnType.time(),
      ),
      PlutoColumn(
        title: '종료시간',
        field: 'endTime',
        type: PlutoColumnType.time(),
      ),
    ]);
  }

  List<PlutoRow> generateRandomRows(int length, List<PlutoColumn> columns) {
    final random = Random();
    final List<PlutoRow> newRows = [];

    for (int i = 0; i < length; i++) {
      final Map<String, PlutoCell> cells = {};

      for (final column in columns) {
        dynamic value;

        if (column.type is PlutoColumnTypeText) {
          value = faker.lorem.word();
        } else if (column.type is PlutoColumnTypeNumber) {
          value = random.nextInt(100);
        } else if (column.type is PlutoColumnTypeDate) {
          value = DateTime.now()
              .subtract(Duration(days: random.nextInt(30)))
              .toString()
              .substring(0, 10);
        } else if (column.type is PlutoColumnTypeTime) {
          value =
              '${random.nextInt(24).toString().padLeft(2, '0')}:${random.nextInt(60).toString().padLeft(2, '0')}';
        } else if (column.type is PlutoColumnTypeSelect) {
          final options = column.type.select.items;
          value = options[random.nextInt(options.length)];
        } else {
          value = '';
        }

        cells[column.field] = PlutoCell(value: value);
      }

      newRows.add(PlutoRow(cells: cells));
    }

    return newRows;
  }

  void gridAHandler() {
    if (stateManagerA.currentRow == null) {
      return;
    }

    if (stateManagerA.currentRow!.key != currentRowKey) {
      currentRowKey = stateManagerA.currentRow!.key;

      stateManagerB.setShowLoading(true);

      fetchUserActivity();
    }
  }

  void fetchUserActivity() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          final int randomLength =
              Random().nextInt(10) + 1; // 1에서 10 사이의 임의의 길이
          final rows = generateRandomRows(randomLength, columnsB);

          // Grid B 업데이트
          stateManagerB.removeRows(stateManagerB.rows);
          stateManagerB.resetCurrentState();
          stateManagerB.appendRows(rows);
        });

        stateManagerB.setShowLoading(false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlutoDualGrid(
        gridPropsA: PlutoDualGridProps(
          columns: columnsA,
          rows: rowsA,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManagerA = event.stateManager;
            stateManagerA.addListener(gridAHandler); // 리스너 추가
          },
          onChanged: (PlutoGridOnChangedEvent event) {},
        ),
        gridPropsB: PlutoDualGridProps(
          columns: columnsB,
          rows: rowsB,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManagerB = event.stateManager;
          },
          onChanged: (PlutoGridOnChangedEvent event) {},
        ),
        display: PlutoDualGridDisplayRatio(ratio: 0.4), // 화면 분할 비율 설정
      ),
    );
  }
}
