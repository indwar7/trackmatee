class DiscoverItem {
  final String title;
  final String category; // "Highway", "Flights", "Bus"
  final String subtitle;
  final String description;
  final String status;   // e.g. "Operational", "Upcoming", "Partially Open"
  final String eta;      // e.g. "Oct 2025", "2024–25"
  final List<String> highlights;
  final String emoji;    // e.g. "🚗", "✈️", "🚌"

  const DiscoverItem({
    required this.title,
    required this.category,
    required this.subtitle,
    required this.description,
    required this.status,
    required this.eta,
    required this.highlights,
    required this.emoji,
  });
}
