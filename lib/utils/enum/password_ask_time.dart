enum PasswordAskTime {
  everyOpening('Every Opening'),
  oneMinute('After 1 minute'),
  threeMinutes('After 3 minutes'),
  fiveMinutes('After 5 minutes'),
  never('Never');

  const PasswordAskTime(this.label);

  final String label;
}
