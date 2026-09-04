String? requiredFieldValidator(String? value) =>
    (value == null || value.trim().isEmpty) ? 'Required' : null;
