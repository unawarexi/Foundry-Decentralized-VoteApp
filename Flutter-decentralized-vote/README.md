## [Resolved] Widget Usage Errors in candidate_tab.dart and personal_tab.dart

All errors related to `VSTextField` and `VSDropdown` usage in `candidate_tab.dart` and `personal_tab.dart` have been fixed:

- Added the required `focusNode` parameter to all `VSTextField` instances.
- Used the correct `maxLines` parameter for multi-line fields.
- Updated `VSDropdown` to use a list of strings (not `DropdownMenuItem`) for `items`.

You can now use these tabs without widget instantiation errors.
