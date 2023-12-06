import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

var totalCount = 0;
Future<List<PlutoRow>> fetchApiData(int pageNo, int numOfRows) async {
  String apiUrl =
      'https://apis.data.go.kr/1160100/service/GetStockSecuritiesInfoService/getPreemptiveRightCertificatePriceInfo?serviceKey=sxbIX2Cjub2A6D66MJub9fLuN5qoWAfDIXc4asS%2FEK3Z6cB437KfTtSnTtNVAzhodIxBftpFvelODtbhZG8qkw%3D%3D&numOfRows=$numOfRows&pageNo=$pageNo&resultType=json';

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final items = data['response']['body']['items']['item'] as List;
    totalCount = data['response']['body']['totalCount'];
    return items.map((item) {
      return PlutoRow(
        cells: {
          'srtnCd': PlutoCell(value: item['srtnCd']),
          'itmsNm': PlutoCell(value: item['itmsNm']),
          'clpr': PlutoCell(value: item['clpr']),
          'lopr': PlutoCell(value: item['lopr']),
          'hipr': PlutoCell(value: item['hipr']),
          'fltRt': PlutoCell(value: item['fltRt']),
        },
      );
    }).toList();
  } else {
    throw Exception('Failed to load data');
  }
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

/// 서버 사이드 rows를 테스트하기 위한 Example 프로젝트
//
// - 주제: 주식 시장 데이터 분석
// - 기능: 서버에서 주식 데이터를 가져와 차트 형태로 표시
// - 구현 방향:
//   - [REST API](https://www.data.go.kr/data/15094808/openapi.do)를 사용해 주식 데이터를 서버로부터 가져오기
//   - PlutoGrid를 이용하여 데이터 페이징 및 정렬 기능 구현
//   - 각 주식의 현재 가격, 변동률 등을 시각적으로 표현
class PlutoGridExamplePage extends StatefulWidget {
  const PlutoGridExamplePage({Key? key}) : super(key: key);

  @override
  State<PlutoGridExamplePage> createState() => _PlutoGridExamplePageState();
}

class _PlutoGridExamplePageState extends State<PlutoGridExamplePage> {
  List<PlutoRow> rows = [];
  var pageSize = 100;
  void addRows(List<PlutoRow> newRows) {
    stateManager.appendRows(newRows);
  }

  @override
  void initState() {
    super.initState();
    fetchApiData(1, pageSize).then((fetchedRows) {
      addRows(fetchedRows);
    });
  }

  Future<PlutoLazyPaginationResponse> fetch(
    PlutoLazyPaginationRequest request,
  ) async {
    // API에서 페이지 번호와 행 수에 따라 데이터를 가져옵니다.
    final fetchedRows = await fetchApiData(request.page, pageSize);

    // 이 부분은 API에서 총 데이터 개수를 가져오도록 수정해야 합니다.
    int totalPage = (totalCount / pageSize).ceil();

    return PlutoLazyPaginationResponse(
      totalPage: totalPage, // 실제 총 페이지 수
      rows: fetchedRows,
    );
  }

  final List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: '번호',
      field: 'srtnCd',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: '회사 이름',
      field: 'itmsNm',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: '현재 가격',
      field: 'clpr',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: '최저 가격',
      field: 'lopr',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: '최대 가격',
      field: 'hipr',
      type: PlutoColumnType.number(),
    ),
    PlutoColumn(
      title: '오늘 상승률',
      field: 'fltRt',
      type: PlutoColumnType.number(),
      renderer: (rendererContext) {
        double fltRt = rendererContext.cell.value ?? 0.0;
        Color textColor = fltRt >= 0 ? Colors.blue : Colors.red;

        return Text(
          '${fltRt.toStringAsFixed(1)}%',
          style: TextStyle(color: textColor),
        );
      },
    ),
  ];

  late final PlutoGridStateManager stateManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: PlutoGrid(
          columns: columns,
          rows: rows,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            print(event);

            stateManager = event.stateManager;
          },
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          createFooter: (stateManager) {
            return PlutoLazyPagination(
              initialPage: 1,
              initialFetch: true,
              fetchWithSorting: true,
              fetchWithFiltering: true,
              pageSizeToMove: null,
              fetch: fetch,
              stateManager: stateManager,
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
