/// Arguments for [DoctorsScreen].
///
/// The specialty name travels with the id so the screen can title itself
/// ("أطباء الجلدية") without a second round trip for something the caller
/// already had in hand.
class DoctorsArgsModel {
  final int specialtyId;
  final String specialtyName;

  const DoctorsArgsModel({
    required this.specialtyId,
    required this.specialtyName,
  });
}
