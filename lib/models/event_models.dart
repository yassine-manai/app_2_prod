
class Event {
  final int eventId;
  final String title;
  final String startDate;
  final String endDate;
  final String location;
  final String image;
  final int category;
    final int min_capacity;
  final int max_capacity;
  final int price;
  final List<int> userId;

  Event({
    required this.eventId,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.image,
    required this.category,
    required this.min_capacity,
    required this.max_capacity,
    required this.price,
    required this.userId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['event_id'],
      title: json['title'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      location: json['location'],
      image: json['image'],
      category: json['category'],
      min_capacity: json['min_capacity'],
      max_capacity: json['max_capacity'],
      price: json['price'],
      userId: List<int>.from(json['user_id']),
    );
  }
}
