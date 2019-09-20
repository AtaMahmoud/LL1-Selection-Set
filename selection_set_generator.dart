class SelectionSetGenerator {
  final List<String> grammerRules;
  List<String> nullableRules = List();
  List<String> nullableNoneTerminals = List();

  List<Map<String, dynamic>> BWD = List();
  List<Map<String, dynamic>> BW = List();
  List<Map<String, dynamic>> FirstOf = List();
  List<Map<String, dynamic>> FirstOfN = List();
  List<Map<String, dynamic>> FDB = List();
  List<Map<String, dynamic>> DEO = List();
  List<Map<String, dynamic>> EO = List();
  List<Map<String, dynamic>> FB9 = List();
  List<Map<String, dynamic>> FB10 = List();
  List<Map<String, dynamic>> FollowSets = List();
  List<Map<String, dynamic>> SelectionSets = List();

  Set<String> terminals = Set();
  Set<String> noneTerminals = Set();

  SelectionSetGenerator(this.grammerRules) {
    for (var grammer in grammerRules) {
      final String grammerLeftSide = grammer.split('→')[0];
      final String grammerRightSide = grammer.split('→')[1];

      noneTerminals.add(grammerLeftSide);

      for (var char in grammerRightSide.runes) {
        if (char > 96 && String.fromCharCode(char) != 'ε')
          terminals.add(String.fromCharCode(char));
      }
    }
  }

  void generator() {
    print(terminals.toString());
    print(noneTerminals.toString());
    print('=============== Get Nullable Rules (1) ==============');
    _getNullableRules();
    print('=====================================================');
    print('=============== Get BWD  (2) ==============');
    _getBWD();
    print('=====================================================');
    print('=============== Get BW  (3) ==============');
    _getBW();
    print('=====================================================');
    print('=============== Get First Of  (4) ==============');
    _getFirstOf();
    print('=====================================================');
    print('=============== Get First Of N (5) ==============');
    _getFirstOfN();
    print('=====================================================');

    if (nullableRules.length == 0) {
      print('=============== Get Selection Sets (12) ==============');
      _getSelectionSets();
      print('=====================================================');
    } else {
      print('=============== Get FDB (6) ==============');
      _getFDB();
      print('=====================================================');
      print('=============== Get DEO (7) ==============');
      _getDEO();
      print('=====================================================');
      print('=============== Get EO (8) ==============');
      _getEO();
      print('=====================================================');
      print('=============== Get FB (9) ==============');
      _getFB9();
      print('=====================================================');
      print('=============== Get FB (10) ==============');
      _getFB10();
      print('=====================================================');
      print('=============== Get Follow Sets (11) ==============');
      _getFollowSets();
      print('=====================================================');
      print('=============== Get Selection Sets (12) ==============');
      _getSelectionSets();
      print('=====================================================');
    }
  }

  void _getNullableRules() {
    for (var grammer in grammerRules) {
      if (grammer.endsWith('→ε')) {
        nullableRules.add(grammer);
        nullableNoneTerminals.add(grammer.split('→')[0]);
      }
    }

    for (var grammer in grammerRules) {
      final String grammerLeftSide = grammer.split('→')[0];
      final String grammerRightSide = grammer.split('→')[1];

      if (nullableNoneTerminals.contains(grammerRightSide)) {
        nullableNoneTerminals.add(grammerLeftSide);
        nullableRules.add(grammer);
      }
    }

    for (var grammer in grammerRules) {
      final String grammerLeftSide = grammer.split('→')[0];
      final String grammerRightSide = grammer.split('→')[1];
      if (!nullableNoneTerminals.contains(grammerRightSide)) {
        List<bool> nullTerminals = List();
        for (int char in grammerRightSide.runes) {
          String character = String.fromCharCode(char);
          if (nullableNoneTerminals.contains(character))
            nullTerminals.add(true);
        }

        if (nullTerminals.length == grammerRightSide.length) {
          nullableNoneTerminals.add(grammerLeftSide);
          nullableRules.add(grammer);
        }
      }
    }

    print("Nullable None Terminal :${nullableNoneTerminals.toString()}");
    print("Nullable Rules : ${nullableRules.toString()}");
  }

  void _getBWD() {
    for (var grammer in grammerRules) {
      if (grammer.endsWith('→ε')) continue;

      final String grammerLeftSide = grammer.split('→')[0];
      final String grammerRightSide = grammer.split('→')[1];

      List<String> begginers = List();
      for (int char in grammerRightSide.runes) {
        String character = String.fromCharCode(char);

        if (!nullableNoneTerminals.contains(character)) {
          begginers.add(character);
          break;
        } else {
          begginers.add(character);
        }
      }
      BWD.add({
        '$grammerLeftSide': begginers,
      });
    }

    for (var item in BWD) {
      print('${item.keys.toString()} BWD ${item.values.toString()}');
    }
  }

  void _getBW() {
    BW.addAll(BWD);
    //Reflixive
    for (var noneTerminal in noneTerminals) {
      BW.add({
        '$noneTerminal': [noneTerminal],
      });
    }
    for (var termianl in terminals) {
      BW.add({
        '$termianl': [termianl],
      });
    }

    // Transitive
    for (var i = 0; i < BWD.length; i++) {
      final values = BWD[i][BWD[i].keys.first];
      List<String> valuesOfValues = List();
      for (var value in values) {
        for (var i = 0; i < BWD.length; i++) {
          if (BWD[i].containsKey(value)) {
            valuesOfValues.addAll(BWD[i][value].cast<String>());
          }
        }
      }
      if (valuesOfValues.length != 0)
        BW.add({'${BWD[i].keys.first}': valuesOfValues});
    }

    for (var item in BW) {
      print('${item.keys.toString()} BW ${item.values.toString()}');
    }
  }

  void _getFirstOf() {
    for (var noneTerminal in noneTerminals) {
      List<String> first = List();

      for (var item in BW) {
        if (item.containsKey(noneTerminal)) {
          final List<String> valuesOfItems = item[noneTerminal];
          for (var item in valuesOfItems) {
            if (terminals.contains(item)) {
              first.add(item);
            }
          }
        }
      }

      FirstOf.add({'$noneTerminal': first});
    }

    for (var terminal in terminals) {
      List<String> first = List();

      for (var item in BW) {
        if (item.containsKey(terminal)) {
          final List<String> valuesOfItems = item[terminal];
          for (var item in valuesOfItems) {
            if (terminals.contains(item)) {
              first.add(item);
            }
          }
        }
      }

      FirstOf.add({'$terminal': first});
    }

    for (var item in FirstOf) {
      print('First(${item.keys.toString()}) = ${item.values.toString()}');
    }
  }

  void _getFirstOfN() {
    for (var grammer in grammerRules) {
      final String grammerRightSide = grammer.split('→')[1];
      List<String> firstOfN = List();

      if (grammerRightSide == 'ε') {
        FirstOfN.add({'${grammerRightSide}': firstOfN});
        continue;
      }
      for (var char in grammerRightSide.runes) {
        String character = String.fromCharCode(char);

        if (nullableNoneTerminals.contains(character)) {
          final value =
              FirstOf.where((item) => item.containsKey(character)).first;
          String key = value.keys.first;
          firstOfN.addAll(value[key]);
        } else {
          final value =
              FirstOf.where((item) => item.containsKey(character)).first;
          String key = value.keys.first;
          firstOfN.addAll(value[key]);
          break;
        }
      }
      FirstOfN.add({'${grammerRightSide}': firstOfN});
    }

    for (var item in FirstOfN) {
      print('First(${item.keys.toString()}) = ${item.values.toString()}');
    }
  }

  void _getFDB() {
    for (var grammer in grammerRules) {
      final String grammerRightSide = grammer.split('→')[1];

      if (terminals.contains(grammerRightSide) || grammerRightSide == 'ε')
        continue;

      for (var charCode in grammerRightSide.runes) {
        List<String> follower = List();
        String char = String.fromCharCode(charCode);

        if (terminals.contains(char)) continue;

        if (nullableNoneTerminals.contains(char)) {
          int index = grammerRightSide.indexOf(char);
          if (index + 1 == grammerRightSide.length) continue;
          follower.add(grammerRightSide[index + 1]);
        } else {
          int index = grammerRightSide.indexOf(char);
          if (index + 1 == grammerRightSide.length) continue;
          follower.add(grammerRightSide[index + 1]);
          FDB.add({'${String.fromCharCode(charCode)}': follower});
          break;
        }

        FDB.add({'${String.fromCharCode(charCode)}': follower});
      }
    }
    for (var item in FDB) {
      print('${item.keys.toString()} FDB ${item.values.toString()}');
    }
  }

  void _getDEO() {
    for (var grammer in grammerRules) {
      final String grammerLeftSide = grammer.split('→')[0];
      final String grammerRightSide = grammer.split('→')[1];

      if (grammerRightSide == 'ε') continue;

      List<String> enders = List();

      for (var i = grammerRightSide.length - 1; i >= 0; i--) {
        if (nullableNoneTerminals.contains(grammerRightSide[i]))
          enders.add(grammerRightSide[i]);
        else {
          enders.add(grammerRightSide[i]);
          break;
        }
      }

      for (var end in enders) {
        DEO.add({end: grammerLeftSide});
      }
    }
    for (var item in DEO) {
      print('${item.keys.toString()} FDB ${item.values.toString()}');
    }
  }

  void _getEO() {
    EO.addAll(DEO);
    //Reflexive
    for (var noneTerminal in noneTerminals) {
      EO.add({
        '$noneTerminal': [noneTerminal],
      });
    }
    for (var termianl in terminals) {
      EO.add({
        '$termianl': [termianl],
      });
    }
    // Transitive

    for (var i = 0; i < DEO.length; i++) {
      final value = DEO[i][DEO[i].keys.first];
      List<String> valuesOfValues = List();

      for (var j = 0; j < DEO.length; j++) {
        if (i == j) continue;
        if (DEO[j].containsKey(value)) {
          valuesOfValues.add(DEO[j][value]);
        }
      }
      if (valuesOfValues.length != 0)
        EO.add({'${DEO[i].keys.first}': valuesOfValues});
    }

    // Rmove Repeted Rules
    for (var i = 0; i < EO.length; i++) {
      for (var j = 0; j < EO.length; j++) {
        if (i == j) continue;
        if (EO[i].keys.first == EO[j].keys.first &&
            EO[i][EO[i].keys.first][0] == EO[j][EO[j].keys.first][0]) {
          EO.removeAt(j);
        }
      }
    }
    for (var item in EO) {
      print('${item.keys.toString()} EO ${item.values.toString()}');
    }
  }

  void _getFB9() {
    List<Map<String, dynamic>> getMiddle = List.from(FDB);
    List<Map<String, dynamic>> getFirstPosition = List();
    List<Map<String, dynamic>> getLastPostion = List();

    for (var middle in getMiddle) {
      for (var item in EO) {
        if (item[item.keys.first].contains(middle.keys.first)) {
          getFirstPosition.add(item);
        }
      }

      for (var item in BW) {
        if (middle[middle.keys.first].contains(item.keys.first)) {
          getLastPostion.add(item);
        }
      }
    }

    for (var first in getFirstPosition) {
      for (var middle in getMiddle) {
        if (first[first.keys.first].contains(middle.keys.first)) {
          for (var third in getLastPostion) {
            if (middle[middle.keys.first].contains(third.keys.first)) {
              FB9.add({'${first.keys.first}': third[third.keys.first]});
            }
          }
        }
      }
    }

    for (var item in FB9) {
      print('${item.keys.toString()} FB ${item.values.toString()}');
    }
  }

  void _getFB10() {
    final String startNonterminal = grammerRules[0].split('→')[0];

    for (var item in EO) {
      bool endWithStartNonTerminal =
          item[item.keys.first][0] == startNonterminal;
      bool startWithNoneTerminal = noneTerminals.contains(item.keys.first);
      if (endWithStartNonTerminal && startWithNoneTerminal) {
        FB10.add({
          '${item.keys.first}': ['end marker']
        });
      }
    }
    for (var item in FB10) {
      print('${item.keys.toString()} FB ${item.values.toString()}');
    }
  }

  void _getFollowSets() {
    for (var nullableNoneTerminal in nullableNoneTerminals) {
      for (var item in FB9) {
        bool startsWithNullable = item.keys.first == nullableNoneTerminal;
        bool endsWithTerminal = terminals.contains(item[item.keys.first][0]);

        if (startsWithNullable && endsWithTerminal) {
          FollowSets.add({
            '$nullableNoneTerminal': [item[item.keys.first][0]]
          });
        }
      }
      for (var item in FollowSets) {
        print('Fol${item.keys.toString()} = ${item.values.toString()}');
      }
    }
  }

  void _getSelectionSets() {
    for (var i = 0; i < grammerRules.length; i++) {
      final String rightHandSide = grammerRules[i].split('→')[1];
      final List<String> firstOfValues = List();

      for (var item in FirstOfN) {
        final String firstKey = item.keys.first;

        if (firstKey == rightHandSide)
          firstOfValues.addAll(item[item.keys.first]);
      }

      if (!nullableRules.contains(grammerRules[i])) {
        SelectionSets.add({'Sel(${i + 1})': firstOfValues});
      } else {
        final String leftHandSide = grammerRules[i].split('→')[0];
        Map<String, dynamic> followSet;
        try {
          followSet =
              FollowSets.where((rule) => rule.keys.first == leftHandSide).first;
        } catch (e) {
          followSet={
            'key':List()
          };
        }
        firstOfValues.addAll(followSet[followSet.keys.first].cast<String>());
        SelectionSets.add({'Sel(${i + 1})': firstOfValues});
      }
    }

    for (var item in SelectionSets) {
      print('Sel${item.keys.toString()} = ${item.values.toString()}');
    }
  }
}
