String? validateResolutionComment(String? value) =>
    value == null || value.trim().isEmpty
    ? 'A resolution comment is required.'
    : null;
