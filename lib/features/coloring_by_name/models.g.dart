// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PathSvgItemCWProxy {
  PathSvgItem path(Path path);

  PathSvgItem currentColor(Color? currentColor);

  PathSvgItem targetColor(Color? targetColor);

  PathSvgItem isColored(bool isColored);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PathSvgItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PathSvgItem(...).copyWith(id: 12, name: "My name")
  /// ````
  PathSvgItem call({
    Path path,
    Color? currentColor,
    Color? targetColor,
    bool isColored,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPathSvgItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPathSvgItem.copyWith.fieldName(...)`
class _$PathSvgItemCWProxyImpl implements _$PathSvgItemCWProxy {
  const _$PathSvgItemCWProxyImpl(this._value);

  final PathSvgItem _value;

  @override
  PathSvgItem path(Path path) => this(path: path);

  @override
  PathSvgItem currentColor(Color? currentColor) =>
      this(currentColor: currentColor);

  @override
  PathSvgItem targetColor(Color? targetColor) => this(targetColor: targetColor);

  @override
  PathSvgItem isColored(bool isColored) => this(isColored: isColored);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PathSvgItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PathSvgItem(...).copyWith(id: 12, name: "My name")
  /// ````
  PathSvgItem call({
    Object? path = const $CopyWithPlaceholder(),
    Object? currentColor = const $CopyWithPlaceholder(),
    Object? targetColor = const $CopyWithPlaceholder(),
    Object? isColored = const $CopyWithPlaceholder(),
  }) {
    return PathSvgItem(
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as Path,
      currentColor: currentColor == const $CopyWithPlaceholder()
          ? _value.currentColor
          // ignore: cast_nullable_to_non_nullable
          : currentColor as Color?,
      targetColor: targetColor == const $CopyWithPlaceholder()
          ? _value.targetColor
          // ignore: cast_nullable_to_non_nullable
          : targetColor as Color?,
      isColored: isColored == const $CopyWithPlaceholder()
          ? _value.isColored
          // ignore: cast_nullable_to_non_nullable
          : isColored as bool,
    );
  }
}

extension $PathSvgItemCopyWith on PathSvgItem {
  /// Returns a callable class that can be used as follows: `instanceOfPathSvgItem.copyWith(...)` or like so:`instanceOfPathSvgItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PathSvgItemCWProxy get copyWith => _$PathSvgItemCWProxyImpl(this);
}
