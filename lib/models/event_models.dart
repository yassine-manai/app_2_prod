
class Event {
  final int eventId;
  final String title;
  final String startDate;
  final String endDate;
  final String location;
  final String image;
  final int category;
  final int capacity;
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
    required this.capacity,
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
      capacity: json['capacity'],
      price: json['price'],
      userId: List<int>.from(json['user_id']),
    );
  }
}
