import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'theme_config.dart';

// --- States ---
abstract class ThemeState extends Equatable {
  const ThemeState();
  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {}

class ThemeLoading extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final ThemeConfig config;
  const ThemeLoaded(this.config);

  @override
  List<Object?> get props => [config];
}

class ThemeError extends ThemeState {
  final String message;
  const ThemeError(this.message);

  @override
  List<Object?> get props => [message];
}

// --- Cubit ---
class ThemeCubit extends Cubit<ThemeState> {
  final FlutterSecureStorage _storage;
  static const String _themeCacheKey = 'CACHED_THEME';

  ThemeCubit(this._storage) : super(ThemeInitial());

  Future<void> loadTheme() async {
    emit(ThemeLoading());
    try {
      // Attempt to load from secure storage
      final cachedThemeStr = await _storage.read(key: _themeCacheKey);
      if (cachedThemeStr != null && cachedThemeStr.isNotEmpty) {
        final Map<String, dynamic> jsonMap = json.decode(cachedThemeStr);
        emit(ThemeLoaded(ThemeConfig.fromJson(jsonMap)));
      } else {
        // Fallback to default
        final defaultTheme = ThemeConfig.defaultTheme();
        emit(ThemeLoaded(defaultTheme));
      }
    } catch (e) {
      // If error occurs, fallback to default theme instead of breaking the app
      emit(ThemeLoaded(ThemeConfig.defaultTheme()));
    }
  }

  Future<void> changeTheme(ThemeConfig config) async {
    emit(ThemeLoading());
    try {
      final jsonStr = json.encode(config.toJson());
      await _storage.write(key: _themeCacheKey, value: jsonStr);
      emit(ThemeLoaded(config));
    } catch (e) {
      emit(const ThemeError('Failed to save theme configuration'));
    }
  }
}
