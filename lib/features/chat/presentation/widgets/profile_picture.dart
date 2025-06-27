import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({
    super.key,
    required this.filteredImages,
    required this.isGroup,
  });

  final List<String> filteredImages;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        width: 56,
        height: 56,
        child: isGroup
            ? Stack(
                clipBehavior: Clip.hardEdge,
                children: filteredImages.isNotEmpty
                    ? filteredImages.take(2).toList().asMap().entries.map((
                        entry,
                      ) {
                        final i = entry.key;
                        final image = entry.value;
                        print("Image URL: $image");
                        print(image);
                        return Positioned(
                          left: i * 20.0,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[800],
                            backgroundImage: image.isNotEmpty
                                ? NetworkImage(image)
                                : null,
                            child: image.isEmpty
                                ? const Icon(
                                    Icons.group,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                            onBackgroundImageError: (_, __) => const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        );
                      }).toList()
                    : [
                        const Positioned(
                          left: 0,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.group,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
              )
            : filteredImages.isNotEmpty
            ? CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[800],
                backgroundImage: NetworkImage(filteredImages.first),
                onBackgroundImageError: (_, __) =>
                    const Icon(Icons.person, color: Colors.white, size: 28),
              )
            : const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
      ),
    );
  }
}
