import 'package:test/test.dart';
import 'package:uploader/model/sign_pole.dart';

void main() {
  group('SignPole', () {
    test('from CSV', () {
      var csv = ['(46.2906727, 10.6815487)', 'Non necessario', 'Ok'];
      var signPole = SignPole.fromCsv(csv);
      expect(signPole, equals(SignPole(status: SignPoleStatus.notNeeded)));
      csv = ['(46.2906727, 10.6815487)', 'Ok', 'Ok'];
      signPole = SignPole.fromCsv(csv);
      expect(signPole, equals(SignPole(status: SignPoleStatus.ok)));
      csv = ['(46.2906727, 10.6815487)', 'Solo segno rosso', 'Ok'];
      signPole = SignPole.fromCsv(csv);
      expect(signPole, equals(SignPole(status: SignPoleStatus.onlyMark)));
      csv = ['(46.2906727, 10.6815487)', 'Nuovo', 'Ok'];
      signPole = SignPole.fromCsv(csv);
      expect(signPole, equals(SignPole(status: SignPoleStatus.add)));
      csv = ['(46.2906727, 10.6815487)', 'Eliminare', 'Ok'];
      signPole = SignPole.fromCsv(csv);
      expect(signPole, equals(SignPole(status: SignPoleStatus.remove)));
      csv = ['(46.2906727, 10.6815487)', 'Cambiare', 'Ok'];
      signPole = SignPole.fromCsv(csv);
      expect(signPole, equals(SignPole(status: SignPoleStatus.change)));
      csv = ['(46.2906727, 10.6815487)', 'Wrong value', 'Ok'];
      expect(() => SignPole.fromCsv(csv), throwsArgumentError);
    });
  });
}
