/// Default avatar placeholders for UI when a user has no photo.
class AvatarPlaceholders {
  const AvatarPlaceholders._();

  static const urls = [
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=120&q=80',
    'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?auto=format&fit=crop&w=120&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=120&q=80',
  ];

  static String get fallback => urls.last;

  static List<String> take(int count) => urls.take(count).toList();
}
