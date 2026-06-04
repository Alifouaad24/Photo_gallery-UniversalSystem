class Folder {
  int? id;
  String name;
  String businessName;

  Folder({this.id, required this.name, required this.businessName});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'],
      name: map['name'],
      businessName : map['business_name']
    );
  }
}

class ImageItem {
  int? id;
  String name;
  int folderId;
  bool isUploaded;

  ImageItem({this.id, required this.name, required this.folderId, this.isUploaded = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'folder_id': folderId,
      'isUploaded': isUploaded ? 1 : 0,
    };
  }

  factory ImageItem.fromMap(Map<String, dynamic> map) {
    return ImageItem(
      id: map['id'],
      name: map['name'],
      folderId: map['folder_id'],
      isUploaded: map['isUploaded'] == 1,
    );
  }
}
