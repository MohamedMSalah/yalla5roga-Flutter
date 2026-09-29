enum GroupRole { owner, admin, member }

enum OutingOccasion { none, birthday, wedding }

enum OutingStatus { upcoming, voting, past }

class OutingPlace {
  const OutingPlace({
    required this.name,
    required this.area,
    this.latitude,
    this.longitude,
  });

  final String name;
  final String area;
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates => latitude != null && longitude != null;

  OutingLocation toLocation() => OutingLocation(
        name: name,
        area: area,
        latitude: latitude,
        longitude: longitude,
      );

  @override
  bool operator ==(Object other) {
    return other is OutingPlace && other.name == name && other.area == area;
  }

  @override
  int get hashCode => Object.hash(name, area);
}

class OutingLocation {
  const OutingLocation({
    required this.name,
    this.area = '',
    this.latitude,
    this.longitude,
  });

  final String name;
  final String area;
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates => latitude != null && longitude != null;

  String get label => area.isEmpty ? name : '$name, $area';

  Map<String, dynamic> toJson() => {
        'name': name,
        'area': area,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory OutingLocation.fromJson(Map<String, dynamic> json) {
    return OutingLocation(
      name: json['name'] as String? ?? '',
      area: json['area'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

class HeroSlide {
  const HeroSlide({
    required this.id,
    required this.image,
    required this.title,
    required this.meta,
    required this.date,
    this.time = '6:30 PM',
    this.going = 7,
    this.groupId,
    this.location,
    this.occasion = OutingOccasion.none,
    this.guestIds = const [],
    this.status = OutingStatus.upcoming,
  });

  final String id;
  final String image;
  final String title;
  final String meta;
  final String date;
  final String time;
  final int going;
  final String? groupId;
  final OutingLocation? location;
  final OutingOccasion occasion;
  final List<String> guestIds;
  final OutingStatus status;

  List<String> get _dateParts {
    return date.replaceAll(',', ' ').split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  }

  String get calendarDay => _dateParts.length >= 2 ? _dateParts[1] : date;

  String get calendarMonth => _dateParts.length >= 3 ? _dateParts.last : '';
}

class DemoMember {
  const DemoMember({
    required this.id,
    required this.name,
    required this.avatar,
    this.role = GroupRole.member,
  });

  final String id;
  final String name;
  final String avatar;
  final GroupRole role;
}

class DemoGroup {
  const DemoGroup({
    required this.id,
    required this.name,
    required this.members,
    required this.outings,
    required this.preview,
    required this.avatars,
    required this.image,
    required this.people,
    this.lastMessage,
    this.unread = 0,
    this.featured = false,
    this.decision,
    this.myRole = GroupRole.member,
  });

  final String id;
  final String name;
  final int members;
  final int outings;
  final String preview;
  final List<String> avatars;
  final String image;
  final List<DemoMember> people;
  final String? lastMessage;
  final int unread;
  final bool featured;
  final String? decision;
  final GroupRole myRole;

  DemoGroup copyWith({
    String? image,
    List<DemoMember>? people,
    int? members,
    int? unread,
  }) {
    return DemoGroup(
      id: id,
      name: name,
      members: members ?? people?.length ?? this.members,
      outings: outings,
      preview: preview,
      avatars: avatars,
      image: image ?? this.image,
      people: people ?? this.people,
      lastMessage: lastMessage,
      unread: unread ?? this.unread,
      featured: featured,
      decision: decision,
      myRole: myRole,
    );
  }
}

class DemoChatMessage {
  const DemoChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.time,
    required this.isMine,
    this.avatar,
    this.senderId,
    this.deliveryStatus = MessageDeliveryStatus.sent,
  });

  final String id;
  final String sender;
  final String text;
  final String time;
  final bool isMine;
  final String? avatar;
  final String? senderId;
  final MessageDeliveryStatus deliveryStatus;

  DemoChatMessage copyWith({MessageDeliveryStatus? deliveryStatus}) {
    return DemoChatMessage(
      id: id,
      sender: sender,
      text: text,
      time: time,
      isMine: isMine,
      avatar: avatar,
      senderId: senderId,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }
}

enum MessageDeliveryStatus { sent, delivered, seen }

class DemoNotificationItem {
  const DemoNotificationItem({
    required this.id,
    required this.body,
    required this.time,
    required this.unread,
    this.image,
    this.eventId,
    this.groupId,
    this.action = false,
  });

  final String id;
  final String body;
  final String time;
  final bool unread;
  final String? image;
  final String? eventId;
  final String? groupId;
  final bool action;

  DemoNotificationItem copyWith({bool? unread}) {
    return DemoNotificationItem(
      id: id,
      body: body,
      time: time,
      unread: unread ?? this.unread,
      image: image,
      eventId: eventId,
      groupId: groupId,
      action: action,
    );
  }
}

class DemoData {
  const DemoData._();

  static const avatars = [
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=120&q=80',
    'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?auto=format&fit=crop&w=120&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&q=80',
  ];

  static const covers = [
    'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=800&q=85',
    'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=800&q=85',
    'https://images.unsplash.com/photo-1533777324565-a040eb52facd?auto=format&fit=crop&w=800&q=85',
    'https://images.unsplash.com/photo-1579532537598-459ecdaf39cc?auto=format&fit=crop&w=800&q=85',
    'https://images.unsplash.com/photo-1528605248644-14dd04022da1?auto=format&fit=crop&w=800&q=85',
  ];

  static const people = [
    DemoMember(id: 'mariam', name: 'Mariam', avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=120&q=80', role: GroupRole.admin),
    DemoMember(id: 'nour', name: 'Nour', avatar: 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?auto=format&fit=crop&w=120&q=80'),
    DemoMember(id: 'omar', name: 'Omar', avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80'),
    DemoMember(id: 'ahmed', name: 'Ahmed', avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&q=80', role: GroupRole.owner),
    DemoMember(id: 'sara', name: 'Sara', avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=120&q=80'),
    DemoMember(id: 'youssef', name: 'Youssef', avatar: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=120&q=80'),
  ];

  static const heroSlides = [
    HeroSlide(
      id: 'sunset-picnic',
      image: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=800&q=85',
      title: 'Sunset Picnic',
      meta: 'ZED Park · 6:30 PM',
      date: 'SAT, 19 SEP',
      groupId: 'maadi-crew',
      location: OutingLocation(name: 'ZED Park', area: 'New Cairo', latitude: 30.0215, longitude: 31.4952),
    ),
    HeroSlide(
      id: 'game-night',
      image: 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=800&q=85',
      title: 'Game Night',
      meta: 'The Tap East · 8:00 PM',
      date: 'FRI, 25 SEP',
      time: '8:00 PM',
      going: 5,
      groupId: 'cinema-squad',
      location: OutingLocation(name: 'The Tap East', area: 'Heliopolis', latitude: 30.0917, longitude: 31.3244),
    ),
    HeroSlide(
      id: 'weekend-brunch',
      image: 'https://images.unsplash.com/photo-1533777324565-a040eb52facd?auto=format&fit=crop&w=800&q=85',
      title: 'Weekend Brunch',
      meta: 'Maadi · 11:30 AM',
      date: 'SAT, 27 SEP',
      time: '11:30 AM',
      going: 8,
      groupId: 'maadi-crew',
      status: OutingStatus.voting,
      location: OutingLocation(name: 'The Brunch Room', area: 'Maadi', latitude: 29.9602, longitude: 31.2589),
    ),
    HeroSlide(
      id: 'bowling-night',
      image: 'https://images.unsplash.com/photo-1579532537598-459ecdaf39cc?auto=format&fit=crop&w=800&q=85',
      title: 'Bowling Night',
      meta: 'Cairo Festival · 8:00 PM',
      date: 'WED, 24 SEP',
      time: '8:00 PM',
      going: 5,
      groupId: 'book-brew',
      status: OutingStatus.past,
      location: OutingLocation(name: 'Cairo Festival City', area: 'New Cairo', latitude: 30.0285, longitude: 31.4073),
    ),
  ];

  static HeroSlide? findSlide(String id) {
    for (final slide in heroSlides) {
      if (slide.id == id) return slide;
    }
    return null;
  }

  // TODO: replace with GET /outings/{id} when outing CRUD exists.
  // Fake stand-in so notification / vote taps still open EventPage in testing.
  static HeroSlide slideById(String id) => findSlide(id) ?? heroSlides.first;

  static const catalogPlaces = [
    OutingPlace(name: 'ZED Park', area: 'New Cairo', latitude: 30.0215, longitude: 31.4952),
    OutingPlace(name: 'The Brunch Room', area: 'Maadi', latitude: 29.9602, longitude: 31.2589),
    OutingPlace(name: "Lucille's", area: 'Zamalek', latitude: 30.0616, longitude: 31.2197),
    OutingPlace(name: 'The Tap East', area: 'Heliopolis', latitude: 30.0917, longitude: 31.3244),
    OutingPlace(name: 'Cairo Festival City', area: 'New Cairo', latitude: 30.0285, longitude: 31.4073),
  ];

  static const groups = [
    DemoGroup(
      id: 'maadi-crew',
      name: 'Maadi Crew',
      members: 4,
      outings: 12,
      preview: '',
      avatars: avatars,
      image: 'https://images.unsplash.com/photo-1528605248644-14dd04022da1?auto=format&fit=crop&w=800&q=85',
      featured: true,
      decision: 'Where should we brunch?',
      myRole: GroupRole.owner,
      people: [
        DemoMember(id: 'ahmed', name: 'Ahmed', avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&q=80', role: GroupRole.owner),
        DemoMember(id: 'mariam', name: 'Mariam', avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=120&q=80', role: GroupRole.admin),
        DemoMember(id: 'nour', name: 'Nour', avatar: 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?auto=format&fit=crop&w=120&q=80'),
        DemoMember(id: 'omar', name: 'Omar', avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80'),
      ],
    ),
    DemoGroup(
      id: 'book-brew',
      name: 'Book & Brew',
      members: 3,
      outings: 7,
      preview: 'Found the perfect café ☕',
      lastMessage: 'Nour',
      image: 'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=800&q=85',
      avatars: [
        'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?auto=format&fit=crop&w=120&q=80',
      ],
      myRole: GroupRole.admin,
      people: [
        DemoMember(id: 'nour', name: 'Nour', avatar: 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?auto=format&fit=crop&w=120&q=80', role: GroupRole.owner),
        DemoMember(id: 'ahmed', name: 'Ahmed', avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&q=80', role: GroupRole.admin),
        DemoMember(id: 'sara', name: 'Sara', avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=120&q=80'),
      ],
    ),
    DemoGroup(
      id: 'cinema-squad',
      name: 'Cinema Squad',
      members: 3,
      outings: 21,
      preview: '8 PM works for me',
      lastMessage: 'Omar',
      unread: 2,
      image: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=800&q=85',
      avatars: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80',
      ],
      myRole: GroupRole.member,
      people: [
        DemoMember(id: 'omar', name: 'Omar', avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80', role: GroupRole.owner),
        DemoMember(id: 'mariam', name: 'Mariam', avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=120&q=80', role: GroupRole.admin),
        DemoMember(id: 'ahmed', name: 'Ahmed', avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&q=80'),
      ],
    ),
  ];

  static DemoGroup? findGroup(String id) {
    for (final group in groups) {
      if (group.id == id) return group;
    }
    return null;
  }

  // TODO: replace with GET /groups/{id} when group CRUD exists.
  // Fake stand-in so notification taps still open GroupDetailsPage in testing.
  static DemoGroup groupById(String id) => findGroup(id) ?? groups.first;

  static const birthdayImage =
      'https://images.unsplash.com/photo-1464349095431-e9a21285b5f3?auto=format&fit=crop&w=800&q=85';
  static const weddingImage =
      'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=85';

  static String specialEventImage(OutingOccasion occasion) {
    return occasion == OutingOccasion.wedding ? weddingImage : birthdayImage;
  }

  static List<DemoMember> get groupContacts {
    final seen = <String>{};
    return [
      for (final group in groups)
        for (final person in group.people)
          if (seen.add(person.id)) person,
    ];
  }

  static DemoMember? memberById(String id) {
    for (final person in groupContacts) {
      if (person.id == id) return person;
    }
    for (final person in people) {
      if (person.id == id) return person;
    }
    return null;
  }

  static String groupsForMember(String id) {
    return groups
        .where((group) => group.people.any((person) => person.id == id))
        .map((group) => group.name)
        .join(' · ');
  }

  static const notifications = [
    DemoNotificationItem(
      id: 'n1',
      body: 'Mariam invited you to vote on Friday brunch.',
      time: '8 minutes ago',
      unread: true,
      image: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=120&q=80',
      eventId: 'weekend-brunch',
      action: true,
    ),
    DemoNotificationItem(
      id: 'n2',
      body: 'Sunset Picnic is confirmed! Everyone agreed on the plan.',
      time: '36 minutes ago',
      unread: true,
      eventId: 'sunset-picnic',
    ),
    DemoNotificationItem(
      id: 'n3',
      body: 'Omar mentioned you in Cinema Squad: “8 PM works for me.”',
      time: '1 hour ago',
      unread: true,
      image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80',
      groupId: 'cinema-squad',
    ),
    DemoNotificationItem(
      id: 'n4',
      body: 'Nour joined your group Book & Brew.',
      time: 'Yesterday, 9:42 PM',
      unread: false,
      groupId: 'book-brew',
    ),
    DemoNotificationItem(
      id: 'n5',
      body: 'Reminder: Bowling Night starts tomorrow at 8:00 PM.',
      time: 'Yesterday, 5:00 PM',
      unread: false,
      eventId: 'bowling-night',
    ),
  ];

  static const chatMessages = [
    DemoChatMessage(
      id: 'm1',
      sender: 'Mariam',
      senderId: 'mariam',
      text: 'Are we still on for 6:30?',
      time: '6:02 PM',
      isMine: false,
      avatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=120&q=80',
    ),
    DemoChatMessage(
      id: 'm2',
      sender: 'You',
      senderId: 'me',
      text: 'Yes! I’ll bring the picnic blanket.',
      time: '6:04 PM',
      isMine: true,
      deliveryStatus: MessageDeliveryStatus.seen,
    ),
    DemoChatMessage(
      id: 'm3',
      sender: 'Omar',
      senderId: 'omar',
      text: 'I can pick up snacks on the way.',
      time: '6:08 PM',
      isMine: false,
      avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80',
    ),
    DemoChatMessage(
      id: 'm4',
      sender: 'Nour',
      senderId: 'nour',
      text: 'See you all there 🌅',
      time: '6:11 PM',
      isMine: false,
      avatar: 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?auto=format&fit=crop&w=120&q=80',
    ),
  ];
}
