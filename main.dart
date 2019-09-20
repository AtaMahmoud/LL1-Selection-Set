import 'dart:io';
import './selection_set_generator.dart';

main(List<String> args)  {
  final File grammerFile = File('grammer.txt');
  final List<String> grammer =  grammerFile.readAsLinesSync();
  SelectionSetGenerator selectionSetGenerator=SelectionSetGenerator(grammer);
  selectionSetGenerator.generator();
}
