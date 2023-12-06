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

/// 기본 그리드를 테스트하기 위한 Example 프로젝트
//
/// - 주제: 학생 성적 관리 시스템
/// - 기능: 학생들의 이름, 과목별 성적을 입력받아 테이블 형태로 표시
/// - 구현 방향:
///   - PlutoGrid를 사용하여 성적 데이터를 입력, 표시
///   - 과목별 성적 추가, 수정, 삭제 기능 구현
///   - 간단한 데이터 검증 로직 적용 (예: 점수 범위 확인)
class PlutoGridExamplePage extends StatefulWidget {
  const PlutoGridExamplePage({Key? key}) : super(key: key);

  @override
  State<PlutoGridExamplePage> createState() => _PlutoGridExamplePageState();
}

class _PlutoGridExamplePageState extends State<PlutoGridExamplePage> {
  final List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: '학번',
      field: 'id',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: '국어',
      field: 'korean',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: '수학',
      field: 'math',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: '물리',
      field: 'physics',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: '화학',
      field: 'chemistry',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: '생물',
      field: 'biology',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: '지구과학',
      field: 'earth_science',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: '평균',
      field: 'average',
      type: PlutoColumnType.number(
        format: '#,###.0',
      ),
      footerRenderer: (rendererContext) {
        return PlutoAggregateColumnFooter(
          rendererContext: rendererContext,
          // formatAsCurrency: true,
          type: PlutoAggregateColumnType.average,
          format: '#,###',
          alignment: Alignment.center,
          titleSpanBuilder: (text) {
            return [
              const TextSpan(
                text: 'Avg',
                style: TextStyle(color: Colors.red),
              ),
              const TextSpan(text: ' : '),
              TextSpan(text: text),
            ];
          },
        );
      },
    ),
  ];

  final List<PlutoRow> rows = [
    PlutoRow(cells: {
      'id': PlutoCell(value: '1'),
      'korean': PlutoCell(value: 90),
      'math': PlutoCell(value: 80),
      'physics': PlutoCell(value: 70),
      'chemistry': PlutoCell(value: 60),
      'biology': PlutoCell(value: 50),
      'earth_science': PlutoCell(value: 40),
      'average': PlutoCell(value: 10),
    }),
    PlutoRow(cells: {
      'id': PlutoCell(value: '2'),
      'korean': PlutoCell(value: 90),
      'math': PlutoCell(value: 80),
      'physics': PlutoCell(value: 70),
      'chemistry': PlutoCell(value: 60),
      'biology': PlutoCell(value: 50),
      'earth_science': PlutoCell(value: 40),
      'average': PlutoCell(value: 10),
    }),
    PlutoRow(cells: {
      'id': PlutoCell(value: '3'),
      'korean': PlutoCell(value: 90),
      'math': PlutoCell(value: 80),
      'physics': PlutoCell(value: 70),
      'chemistry': PlutoCell(value: 60),
      'biology': PlutoCell(value: 50),
      'earth_science': PlutoCell(value: 40),
      'average': PlutoCell(value: 10),
    }),
    PlutoRow(cells: {
      'id': PlutoCell(value: '4'),
      'korean': PlutoCell(value: 90),
      'math': PlutoCell(value: 80),
      'physics': PlutoCell(value: 70),
      'chemistry': PlutoCell(value: 60),
      'biology': PlutoCell(value: 50),
      'earth_science': PlutoCell(value: 40),
      'average': PlutoCell(value: 10),
    }),
    PlutoRow(cells: {
      'id': PlutoCell(value: '5'),
      'korean': PlutoCell(value: 90),
      'math': PlutoCell(value: 80),
      'physics': PlutoCell(value: 70),
      'chemistry': PlutoCell(value: 60),
      'biology': PlutoCell(value: 50),
      'earth_science': PlutoCell(value: 40),
      'average': PlutoCell(value: 10),
    }),
    PlutoRow(cells: {
      'id': PlutoCell(value: '6'),
      'korean': PlutoCell(value: 90),
      'math': PlutoCell(value: 80),
      'physics': PlutoCell(value: 70),
      'chemistry': PlutoCell(value: 60),
      'biology': PlutoCell(value: 50),
      'earth_science': PlutoCell(value: 40),
      'average': PlutoCell(value: 10),
    }),
  ];

  /// columnGroups that can group columns can be omitted.
  final List<PlutoColumnGroup> columnGroups = [
    PlutoColumnGroup(title: '공통 과목', fields: [
      'korean',
      'math',
    ]),
    PlutoColumnGroup(title: '선택 과목', fields: [
      'physics',
      'chemistry',
      'biology',
      'earth_science',
    ]),
  ];

  /// [PlutoGridStateManager] has many methods and properties to dynamically manipulate the grid.
  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  late final PlutoGridStateManager stateManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          columnGroups: columnGroups,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;

            //rows 값을 가져와
            final rows = stateManager.rows;
            // 모든 행에 대해서 반복
            for (final row in rows) {
              // 각 과목의 점수를 가져오고
              final korean = row.cells['korean']?.value ?? 0;
              final math = row.cells['math']?.value ?? 0;
              final physics = row.cells['physics']?.value ?? 0;
              final chemistry = row.cells['chemistry']?.value ?? 0;
              final biology = row.cells['biology']?.value ?? 0;
              final earthScience = row.cells['earth_science']?.value ?? 0;

              // 모든 과목의 점수를 더하고
              final total =
                  korean + math + physics + chemistry + biology + earthScience;

              // 평균을 계산한 다음
              final average = total / 6;

              // 평균을 행의 'average' 필드에 업데이트
              stateManager.changeCellValue(row.cells['average']!, average);
            }
          },
          onChanged: (PlutoGridOnChangedEvent event) {
            // 변경된 행을 찾아서
            final row = event.row;

            // 과목별 점수를 가져오고
            final korean = row.cells['korean']?.value ?? 0;
            final math = row.cells['math']?.value ?? 0;
            final physics = row.cells['physics']?.value ?? 0;
            final chemistry = row.cells['chemistry']?.value ?? 0;
            final biology = row.cells['biology']?.value ?? 0;
            final earthScience = row.cells['earth_science']?.value ?? 0;

            // 모든 과목의 점수를 더하고
            final total =
                korean + math + physics + chemistry + biology + earthScience;

            // 평균을 계산한 다음
            final average = total / 6;
            // 평균을 행의 'average' 필드에 업데이트
            stateManager.changeCellValue(row.cells['average']!, average);
          },
        ),
      ),
    );
  }
}
