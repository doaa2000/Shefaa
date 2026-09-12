import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The city the patient picked, and the governorate it belongs to.
@immutable
class SelectedCity {
  final int governorateId;
  final String governorateName;
  final int cityId;
  final String cityName;

  const SelectedCity({
    required this.governorateId,
    required this.governorateName,
    required this.cityId,
    required this.cityName,
  });
}

/// Remembers which city the patient is looking for doctors in.
///
/// Kept on the device rather than on the account, because it answers "where am
/// I right now", not "who am I" -- somebody visiting family in Alexandria
/// should not have to edit their profile to find a clinic there.
///
/// The value is a [ValueNotifier] so the app bar and the doctor lists follow a
/// change straight away; nothing has to be told to reload.
class SelectedCityService {
  static const _governorateIdKey = 'selected_governorate_id';
  static const _governorateNameKey = 'selected_governorate_name';
  static const _cityIdKey = 'selected_city_id';
  static const _cityNameKey = 'selected_city_name';

  final ValueNotifier<SelectedCity?> selection = ValueNotifier(null);

  SelectedCity? get value => selection.value;

  /// The whole point of the picker: the id every doctor query narrows by.
  /// Null means the patient has not chosen, and then nothing is narrowed.
  int? get cityId => selection.value?.cityId;

  /// Reads what was saved last time. Called once before the app starts, so
  /// every later read is a plain field access and no screen has to wait.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final cityId = prefs.getInt(_cityIdKey);
    final cityName = prefs.getString(_cityNameKey);
    final governorateId = prefs.getInt(_governorateIdKey);
    final governorateName = prefs.getString(_governorateNameKey);

    if (cityId == null ||
        cityName == null ||
        governorateId == null ||
        governorateName == null) {
      return;
    }

    selection.value = SelectedCity(
      governorateId: governorateId,
      governorateName: governorateName,
      cityId: cityId,
      cityName: cityName,
    );
  }

  Future<void> save(SelectedCity city) async {
    selection.value = city;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_governorateIdKey, city.governorateId);
    await prefs.setString(_governorateNameKey, city.governorateName);
    await prefs.setInt(_cityIdKey, city.cityId);
    await prefs.setString(_cityNameKey, city.cityName);
  }

  /// Back to every city. The patient who picked one has to be able to undo it,
  /// or a city with two doctors in it becomes the whole app.
  Future<void> clear() async {
    selection.value = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_governorateIdKey);
    await prefs.remove(_governorateNameKey);
    await prefs.remove(_cityIdKey);
    await prefs.remove(_cityNameKey);
  }
}
